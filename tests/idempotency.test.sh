#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

IDEMPOTENCY_FILE="$ROOT_DIR/mk/idempotency.mk"
if [[ ! -f "$IDEMPOTENCY_FILE" ]]; then
	echo "Expected $IDEMPOTENCY_FILE to exist"
	exit 1
fi

echo "[TEST] idempotency.mk defines required functions"
for name in create_marker check_marker check_min_version check_symlink check_command; do
	if ! grep -q "define $name" "$IDEMPOTENCY_FILE"; then
		echo "Expected function definition: $name"
		exit 1
	fi
done

if grep -q '\$(shell mkdir -p' "$IDEMPOTENCY_FILE"; then
	echo "Expected no parse-time mkdir in idempotency.mk"
	exit 1
fi

MAKEFILE_PATH="$TMP_DIR/Makefile"
cat >"$MAKEFILE_PATH" <<'EOF_MAKE'
ROOT_DIR := __ROOT_DIR__
include $(ROOT_DIR)/mk/idempotency.mk

.PHONY: help
help:
	@echo "help"

.PHONY: create-marker-test
create-marker-test:
	@$(call create_marker,setup-system,1.2.3)

.PHONY: check-marker-test
check-marker-test:
	@if $(call check_marker,setup-system); then echo "FOUND"; else echo "MISSING"; exit 1; fi

.PHONY: check-command-ok
check-command-ok:
	@if $(call check_command,sh); then echo "OK"; else exit 1; fi

.PHONY: check-command-missing
check-command-missing:
	@if $(call check_command,definitely-missing-cmd); then exit 1; else echo "MISSING"; fi

.PHONY: check-symlink
check-symlink:
	@$(call check_symlink,$(LINK_PATH),$(TARGET_PATH))

.PHONY: min-version-ok
min-version-ok:
	@$(call check_min_version,printf 'tool 2.0.0',Tool,1.0.0)

.PHONY: min-version-fail
min-version-fail:
	@$(call check_min_version,printf 'tool 0.1.0',Tool,1.0.0)
EOF_MAKE

sed "s|__ROOT_DIR__|$ROOT_DIR|" "$MAKEFILE_PATH" > "$MAKEFILE_PATH.tmp" && mv "$MAKEFILE_PATH.tmp" "$MAKEFILE_PATH"

run_make() {
	XDG_STATE_HOME="$TMP_DIR/state" HOME="$TMP_DIR/home" MAKEFLAGS=--no-print-directory make -f "$MAKEFILE_PATH" "$@"
}

marker_dir="$TMP_DIR/state/dots"
marker_file="$marker_dir/.done-setup-system"

if [[ -e "$marker_dir" ]]; then
	echo "Expected marker dir to be absent before help"
	exit 1
fi

echo "[TEST] make help has no side effects"
run_make help >/dev/null
if [[ -e "$marker_dir" ]]; then
	echo "Expected no marker dir creation from help"
	exit 1
fi

echo "[TEST] create_marker writes formatted marker"
run_make create-marker-test
if [[ ! -f "$marker_file" ]]; then
	echo "Expected marker file to exist: $marker_file"
	exit 1
fi
if ! grep -q "^# Target: setup-system$" "$marker_file"; then
	echo "Expected Target line in marker file"
	exit 1
fi
if ! grep -q "^# Completed: " "$marker_file"; then
	echo "Expected Completed line in marker file"
	exit 1
fi
if ! grep -q "^# Version: 1.2.3$" "$marker_file"; then
	echo "Expected Version line in marker file"
	exit 1
fi

perm="$(stat -c '%a' "$marker_dir" 2>/dev/null || stat -f '%Lp' "$marker_dir")"
if [[ "$perm" != "700" ]]; then
	echo "Expected marker dir permissions 700 but got $perm"
	exit 1
fi

echo "[TEST] check_marker detects marker"
run_make check-marker-test >/dev/null

echo "[TEST] check_command handles existing and missing commands"
run_make check-command-ok >/dev/null
run_make check-command-missing >/dev/null

echo "[TEST] check_symlink validates expected target"
link_target="$TMP_DIR/target"
link_path="$TMP_DIR/link"
echo "data" > "$link_target"
ln -s "$link_target" "$link_path"
run_make check-symlink LINK_PATH="$link_path" TARGET_PATH="$link_target" >/dev/null

echo "[TEST] check_min_version returns expected status"
run_make min-version-ok >/dev/null
set +e
run_make min-version-fail >/dev/null
status=$?
set -e
if [[ $status -eq 0 ]]; then
	echo "Expected min-version-fail to exit non-zero"
	exit 1
fi

echo "All idempotency tests passed."
