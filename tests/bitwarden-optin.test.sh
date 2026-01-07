#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MAKE_BIN="$(command -v make)"
MAKEFILE_PATH="$TMP_DIR/Makefile"
PATH_NO_BW="$TMP_DIR/no-bw"
mkdir -p "$PATH_NO_BW"

cat >"$MAKEFILE_PATH" <<'EOF_MAKE'
ROOT_DIR := __ROOT_DIR__
include $(ROOT_DIR)/mk/bitwarden.mk
EOF_MAKE

# Inject the actual root path after heredoc to avoid nested expansion issues.
sed -i "s|__ROOT_DIR__|$ROOT_DIR|" "$MAKEFILE_PATH"

run_make() {
	MAKEFLAGS=--no-print-directory "$MAKE_BIN" -f "$MAKEFILE_PATH" "$@"
}

echo "[TEST] bw-unlock warns and exits 0 when WITH_BW is disabled"
warn_out="$TMP_DIR/warn.out"
warn_err="$TMP_DIR/warn.err"
set +e
PATH="$PATH_NO_BW" run_make bw-unlock >"$warn_out" 2>"$warn_err"
warn_status=$?
set -e
if [[ $warn_status -ne 0 ]]; then
	echo "Expected exit 0 but got $warn_status"
	exit 1
fi
if ! grep -q "\[WARN\] Bitwarden integration is disabled\." "$warn_err"; then
	echo "Expected warning on stderr"
	exit 1
fi
if [[ -s "$warn_out" ]]; then
	echo "Expected no stdout output"
	exit 1
fi

echo "[TEST] bw-unlock errors when WITH_BW=1 and bw is missing"
err_out="$TMP_DIR/err.out"
err_err="$TMP_DIR/err.err"
set +e
PATH="$PATH_NO_BW" run_make bw-unlock WITH_BW=1 >"$err_out" 2>"$err_err"
err_status=$?
set -e
if [[ $err_status -eq 0 ]]; then
	echo "Expected non-zero exit status"
	exit 1
fi
if ! grep -q "\[ERROR\] Bitwarden CLI (bw) is not installed\." "$err_err"; then
	echo "Expected missing bw error on stderr"
	exit 1
fi
if [[ -s "$err_out" ]]; then
	echo "Expected no stdout output"
	exit 1
fi

echo "[TEST] bw-status differs between WITH_BW disabled and enabled"
status_no_out="$TMP_DIR/status-no.out"
status_with_out="$TMP_DIR/status-with.out"
set +e
PATH="$PATH_NO_BW" run_make bw-status >"$status_no_out" 2>&1
status_no=$?
PATH="$PATH_NO_BW" run_make bw-status WITH_BW=1 >"$status_with_out" 2>&1
status_with=$?
set -e
if [[ $status_no -ne 0 ]]; then
	echo "Expected exit 0 for bw-status without WITH_BW, got $status_no"
	exit 1
fi
if ! grep -q "\[WARN\] Bitwarden integration is disabled\." "$status_no_out"; then
	echo "Expected warning output for bw-status without WITH_BW"
	exit 1
fi
if cmp -s "$status_no_out" "$status_with_out" && [[ $status_no -eq $status_with ]]; then
	echo "Expected bw-status output or status to differ when WITH_BW is enabled"
	exit 1
fi

echo "[TEST] bw-status treats env WITH_BW=1 and arg WITH_BW=1 the same"
status_env_out="$TMP_DIR/status-env.out"
status_arg_out="$TMP_DIR/status-arg.out"
set +e
PATH="$PATH_NO_BW" WITH_BW=1 run_make bw-status >"$status_env_out" 2>&1
status_env=$?
PATH="$PATH_NO_BW" run_make bw-status WITH_BW=1 >"$status_arg_out" 2>&1
status_arg=$?
set -e
if [[ $status_env -ne $status_arg ]]; then
	echo "Expected identical exit status but got env=$status_env arg=$status_arg"
	exit 1
fi
if ! cmp -s "$status_env_out" "$status_arg_out"; then
	echo "Expected identical output for env/arg WITH_BW=1"
	exit 1
fi

echo "All Bitwarden opt-in tests passed."
