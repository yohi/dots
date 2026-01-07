#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MAKEFILE_PATH="$TMP_DIR/Makefile"

cat >"$MAKEFILE_PATH" <<EOF
ROOT_DIR := $ROOT_DIR
include \$(ROOT_DIR)/mk/deprecated-targets.mk

.PHONY: install-packages-homebrew install-packages-deb

install-packages-homebrew:
	@echo "NEW install-packages-homebrew"

install-packages-deb:
	@echo "NEW install-packages-deb"
	@exit 7
EOF

run_make() {
	MAKEFLAGS=--no-print-directory make -f "$MAKEFILE_PATH" "$@"
}

echo "[TEST] alias redirection keeps output identical (success case)"
old_output="$(run_make install-homebrew)"
new_output="$(run_make install-packages-homebrew)"
if [[ "$old_output" != "$new_output" ]]; then
	echo "Expected identical output but got:"
	echo "old: $old_output"
	echo "new: $new_output"
	exit 1
fi
if echo "$old_output" | grep -qi "deprecated"; then
	echo "Unexpected deprecation warning in default mode"
	exit 1
fi

echo "[TEST] alias redirection propagates failure status without warnings"
set +e
old_fail_output="$(run_make install-deb 2>&1)"
old_status=$?
new_fail_output="$(run_make install-packages-deb 2>&1)"
new_status=$?
set -e

if [[ $old_status -eq 0 || $new_status -eq 0 ]]; then
	echo "Expected non-zero exit codes from failure path (old=$old_status, new=$new_status)"
	exit 1
fi
if [[ $old_status -ne $new_status ]]; then
	echo "Expected identical non-zero exit codes but got old=$old_status new=$new_status"
	exit 1
fi
if [[ "$old_fail_output" != "$new_fail_output" ]]; then
	echo "Expected identical failure output but got:"
	echo "old: $old_fail_output"
	echo "new: $new_fail_output"
	exit 1
fi
if echo "$old_fail_output" | grep -qi "deprecated"; then
	echo "Unexpected deprecation warning in failure path"
	exit 1
fi

echo "All deprecated target alias tests passed."
