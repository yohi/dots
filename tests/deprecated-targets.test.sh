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

echo "[TEST] deprecation warning is shown on stderr when enabled"
warn_out="$TMP_DIR/warn.out"
warn_err="$TMP_DIR/warn.err"
MAKE_DEPRECATION_WARN=1 run_make install-homebrew >"$warn_out" 2>"$warn_err"
if ! grep -q "\\[DEPRECATED\\]" "$warn_err"; then
	echo "Expected deprecation warning on stderr"
	exit 1
fi
if grep -q "\\[DEPRECATED\\]" "$warn_out"; then
	echo "Did not expect deprecation warning on stdout"
	exit 1
fi
if [[ "$(cat "$warn_out")" != "$new_output" ]]; then
	echo "Expected stdout to match new target output but got:"
	echo "stdout: $(cat "$warn_out")"
	echo "expected: $new_output"
	exit 1
fi

echo "[TEST] deprecation warnings are suppressed when quiet is enabled"
quiet_out="$TMP_DIR/quiet.out"
quiet_err="$TMP_DIR/quiet.err"
MAKE_DEPRECATION_WARN=1 MAKE_DEPRECATION_QUIET=1 run_make install-homebrew >"$quiet_out" 2>"$quiet_err"
if grep -q "\\[DEPRECATED\\]" "$quiet_err"; then
	echo "Expected no deprecation warning when quiet is enabled"
	exit 1
fi
if [[ "$(cat "$quiet_out")" != "$new_output" ]]; then
	echo "Expected stdout to match new target output but got:"
	echo "stdout: $(cat "$quiet_out")"
	echo "expected: $new_output"
	exit 1
fi

echo "[TEST] strict mode turns warnings into errors"
strict_out="$TMP_DIR/strict.out"
strict_err="$TMP_DIR/strict.err"
set +e
MAKE_DEPRECATION_STRICT=1 run_make install-homebrew >"$strict_out" 2>"$strict_err"
strict_status=$?
set -e
if [[ $strict_status -eq 0 ]]; then
	echo "Expected strict mode to exit non-zero but got $strict_status"
	exit 1
fi
if grep -q "NEW install-packages-homebrew" "$strict_out"; then
	echo "Did not expect new target to run in strict mode"
	exit 1
fi
if ! grep -q "treated as error" "$strict_err"; then
	echo "Expected strict mode message on stderr"
	exit 1
fi

# Note: Policy validation (minimum warning period) is enforced statically
# via 'make test-deprecation-policy', not at runtime. This is by design
# to avoid unnecessary overhead during normal target execution.

echo "All deprecated target alias tests passed."
