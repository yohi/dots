#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

MAKE_BIN="$(command -v make)"
MAKEFILE_PATH="$TMP_DIR/Makefile"

cat >"$MAKEFILE_PATH" <<'EOF_MAKE'
ROOT_DIR := __ROOT_DIR__
include $(ROOT_DIR)/mk/bitwarden.mk
EOF_MAKE

sed "s|__ROOT_DIR__|$ROOT_DIR|" "$MAKEFILE_PATH" > "$MAKEFILE_PATH.tmp" && mv "$MAKEFILE_PATH.tmp" "$MAKEFILE_PATH"

run_make() {
	MAKEFLAGS=--no-print-directory "$MAKE_BIN" -f "$MAKEFILE_PATH" "$@"
}

write_bw_mock() {
	local bin_dir="$1"
	cat >"$bin_dir/bw" <<'EOF_BW'
#!/bin/sh
set -eu

cmd="${1:-}"
case "$cmd" in
	status)
		status="${BW_MOCK_STATUS:-unlocked}"
		email="${BW_MOCK_EMAIL:-test@example.com}"
		printf '{"status":"%s","userEmail":"%s"}\n' "$status" "$email"
		;;
	--version)
		echo "2024.9.0"
		;;
	*)
		exit 0
		;;
esac
EOF_BW
	chmod +x "$bin_dir/bw"
}

write_jq_mock() {
	local bin_dir="$1"
	cat >"$bin_dir/jq" <<'EOF_JQ'
#!/bin/sh
set -eu

filter="${1:-}"
if [ "$filter" = "-r" ]; then
	filter="${2:-}"
fi

input="$(/bin/cat)"
value=""
case "$filter" in
	.status)
		value="${input#*\"status\":\"}"
		value="${value%%\"*}"
		;;
	.userEmail)
		value="${input#*\"userEmail\":\"}"
		value="${value%%\"*}"
		;;
	*)
		value=""
		;;
esac
printf '%s\n' "$value"
EOF_JQ
	chmod +x "$bin_dir/jq"
}

echo "[TEST] bw-status fails and reports not installed when bw is missing"
no_bw_path="$TMP_DIR/no-bw"
mkdir -p "$no_bw_path"
no_bw_out="$TMP_DIR/no-bw.out"
no_bw_err="$TMP_DIR/no-bw.err"
set +e
PATH="$no_bw_path" run_make bw-status WITH_BW=1 >"$no_bw_out" 2>"$no_bw_err"
no_bw_status=$?
set -e
if [[ $no_bw_status -eq 0 ]]; then
	echo "Expected non-zero exit status when bw is missing"
	exit 1
fi
if ! grep -q "Status: NOT INSTALLED" "$no_bw_out"; then
	echo "Expected status output for missing bw"
	exit 1
fi
if ! grep -q "Install with: brew install bitwarden-cli" "$no_bw_out"; then
	echo "Expected install hint for missing bw"
	exit 1
fi

echo "[TEST] bw-status fails and reports missing jq when jq is not available"
no_jq_path="$TMP_DIR/no-jq"
mkdir -p "$no_jq_path"
write_bw_mock "$no_jq_path"
no_jq_out="$TMP_DIR/no-jq.out"
no_jq_err="$TMP_DIR/no-jq.err"
set +e
PATH="$no_jq_path" run_make bw-status WITH_BW=1 >"$no_jq_out" 2>"$no_jq_err"
no_jq_status=$?
set -e
if [[ $no_jq_status -eq 0 ]]; then
	echo "Expected non-zero exit status when jq is missing"
	exit 1
fi
if ! grep -q "\[ERROR\] jq is required for Bitwarden integration\." "$no_jq_err"; then
	echo "Expected jq missing error on stderr"
	exit 1
fi

echo "[TEST] bw-status reports unauthenticated vault"
mock_path="$TMP_DIR/mock-bin"
mkdir -p "$mock_path"
write_bw_mock "$mock_path"
write_jq_mock "$mock_path"
unauth_out="$TMP_DIR/unauth.out"
unauth_err="$TMP_DIR/unauth.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=unauthenticated run_make bw-status WITH_BW=1 >"$unauth_out" 2>"$unauth_err"
unauth_status=$?
set -e
if ! grep -q "Vault Status: unauthenticated" "$unauth_out"; then
	echo "Expected unauthenticated status output"
	exit 1
fi
if [[ $unauth_status -eq 0 ]]; then
	echo "Expected non-zero exit status for unauthenticated vault"
	exit 1
fi

echo "[TEST] bw-status reports locked vault"
locked_out="$TMP_DIR/locked.out"
locked_err="$TMP_DIR/locked.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=locked run_make bw-status WITH_BW=1 >"$locked_out" 2>"$locked_err"
locked_status=$?
set -e
if ! grep -q "Vault Status: locked" "$locked_out"; then
	echo "Expected locked status output"
	exit 1
fi
if [[ $locked_status -eq 0 ]]; then
	echo "Expected non-zero exit status for locked vault"
	exit 1
fi

echo "[TEST] bw-status reports unlocked vault and hides BW_SESSION"
unlocked_out="$TMP_DIR/unlocked.out"
unlocked_err="$TMP_DIR/unlocked.err"
secret="supersecret"
set +e
PATH="$mock_path" BW_MOCK_STATUS=unlocked BW_MOCK_EMAIL="user@example.com" BW_SESSION="$secret" run_make bw-status WITH_BW=1 >"$unlocked_out" 2>"$unlocked_err"
unlocked_status=$?
set -e
if [[ $unlocked_status -ne 0 ]]; then
	echo "Expected exit 0 for unlocked vault"
	exit 1
fi
if ! grep -q "Vault Status: unlocked" "$unlocked_out"; then
	echo "Expected unlocked status output"
	exit 1
fi
if ! grep -q "Logged in as: user@example.com" "$unlocked_out"; then
	echo "Expected logged-in email output"
	exit 1
fi
if grep -q "$secret" "$unlocked_out" "$unlocked_err"; then
	echo "Expected BW_SESSION value to be hidden"
	exit 1
fi

echo "All Bitwarden status tests passed."
