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
	get)
		sub="${2:-}"
		if [ "$sub" = "item" ]; then
			item="${3:-}"
			if [ -n "${BW_MOCK_ITEM_NAME:-}" ] && [ "$item" = "$BW_MOCK_ITEM_NAME" ]; then
				printf '%s\n' "${BW_MOCK_ITEM_JSON:-}"
				exit 0
			fi
			echo "Item not found" >&2
			exit 1
		fi
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
	.login.password)
		value="${input#*\"password\":\"}"
		value="${value%%\"*}"
		;;
	.notes)
		value="${input#*\"notes\":\"}"
		value="${value%%\"*}"
		;;
	".login.password // .notes // empty")
		value="${input#*\"password\":\"}"
		value="${value%%\"*}"
		if [ -z "$value" ] || [ "$value" = "$input" ]; then
			value="${input#*\"notes\":\"}"
			value="${value%%\"*}"
			if [ "$value" = "$input" ]; then
				value=""
			fi
		fi
		;;
	*)
		value=""
		;;
esac
printf '%s\n' "$value"
EOF_JQ
	chmod +x "$bin_dir/jq"
}

mock_path="$TMP_DIR/mock-bin"
mkdir -p "$mock_path"
write_bw_mock "$mock_path"
write_jq_mock "$mock_path"
PATH_WITH_MOCK="$mock_path:/usr/bin:/bin"

item_name="test-secret"
item_json='{"login":{"password":"s3cr3t"}}'


echo "[TEST] bw-get-item warns and exits 0 when WITH_BW is disabled"
warn_out="$TMP_DIR/warn.out"
warn_err="$TMP_DIR/warn.err"
set +e
PATH="$PATH_WITH_MOCK" run_make "bw-get-item-$item_name" >"$warn_out" 2>"$warn_err"
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

echo "[TEST] setup-config-secrets warns and exits 0 when WITH_BW is disabled"
setup_warn_out="$TMP_DIR/setup-warn.out"
setup_warn_err="$TMP_DIR/setup-warn.err"
setup_warn_file="$TMP_DIR/setup-warn.env"
set +e
PATH="$PATH_WITH_MOCK" run_make setup-config-secrets BW_SECRETS_FILE="$setup_warn_file" >"$setup_warn_out" 2>"$setup_warn_err"
setup_warn_status=$?
set -e
if [[ $setup_warn_status -ne 0 ]]; then
	echo "Expected exit 0 but got $setup_warn_status"
	exit 1
fi
if ! grep -q "\\[WARN\\] Bitwarden integration is disabled\\." "$setup_warn_err"; then
	echo "Expected warning on stderr"
	exit 1
fi
if [[ -s "$setup_warn_out" ]]; then
	echo "Expected no stdout output"
	exit 1
fi
if [[ -f "$setup_warn_file" ]]; then
	echo "Expected no secrets file to be created"
	exit 1
fi


echo "[TEST] bw-get-item fails when BW_SESSION is missing"
locked_out="$TMP_DIR/locked.out"
locked_err="$TMP_DIR/locked.err"
set +e
PATH="$PATH_WITH_MOCK" BW_MOCK_STATUS=locked run_make "bw-get-item-$item_name" WITH_BW=1 >"$locked_out" 2>"$locked_err"
locked_status=$?
set -e
if [[ $locked_status -eq 0 ]]; then
	echo "Expected non-zero exit status when BW_SESSION is missing"
	exit 1
fi
if ! grep -q "\[ERROR\] Bitwarden vault is locked\." "$locked_err"; then
	echo "Expected locked vault error"
	exit 1
fi
if [[ -s "$locked_out" ]]; then
	echo "Expected no stdout output"
	exit 1
fi


echo "[TEST] bw-get-item returns secret when unlocked"
secret_out="$TMP_DIR/secret.out"
secret_err="$TMP_DIR/secret.err"
set +e
PATH="$PATH_WITH_MOCK" BW_MOCK_STATUS=unlocked BW_SESSION="token" BW_MOCK_ITEM_NAME="$item_name" BW_MOCK_ITEM_JSON="$item_json" run_make "bw-get-item-$item_name" WITH_BW=1 >"$secret_out" 2>"$secret_err"
secret_status=$?
set -e
if [[ $secret_status -ne 0 ]]; then
	echo "Expected exit 0 but got $secret_status"
	exit 1
fi
if [[ "$(cat "$secret_out")" != "s3cr3t" ]]; then
	echo "Expected secret output"
	exit 1
fi
if [[ -s "$secret_err" ]]; then
	echo "Expected no stderr output"
	exit 1
fi


echo "[TEST] bw-get-item reports missing secret"
missing_out="$TMP_DIR/missing.out"
missing_err="$TMP_DIR/missing.err"
set +e
PATH="$PATH_WITH_MOCK" BW_MOCK_STATUS=unlocked BW_SESSION="token" BW_MOCK_ITEM_NAME="other" BW_MOCK_ITEM_JSON="$item_json" run_make "bw-get-item-$item_name" WITH_BW=1 >"$missing_out" 2>"$missing_err"
missing_status=$?
set -e
if [[ $missing_status -eq 0 ]]; then
	echo "Expected non-zero exit status for missing secret"
	exit 1
fi
if ! grep -q "\[ERROR\] Secret not found: $item_name" "$missing_err"; then
	echo "Expected missing secret error"
	exit 1
fi
if [[ -s "$missing_out" ]]; then
	echo "Expected no stdout output"
	exit 1
fi


echo "[TEST] setup-config-secrets stores secret without logging"
secrets_file="$TMP_DIR/secrets.env"
setup_out="$TMP_DIR/setup.out"
setup_err="$TMP_DIR/setup.err"
set +e
PATH="$PATH_WITH_MOCK" BW_MOCK_STATUS=unlocked BW_SESSION="token" BW_MOCK_ITEM_NAME="$item_name" BW_MOCK_ITEM_JSON="$item_json" run_make setup-config-secrets WITH_BW=1 BW_SECRET_ITEM="$item_name" BW_SECRET_KEY=TEST_SECRET BW_SECRETS_FILE="$secrets_file" >"$setup_out" 2>"$setup_err"
setup_status=$?
set -e
if [[ $setup_status -ne 0 ]]; then
	echo "Expected exit 0 but got $setup_status"
	exit 1
fi
if ! grep -q "^TEST_SECRET=s3cr3t$" "$secrets_file"; then
	echo "Expected secret to be stored in env file"
	exit 1
fi
if grep -q "s3cr3t" "$setup_out" "$setup_err"; then
	echo "Expected secret to be hidden from logs"
	exit 1
fi


echo "All Bitwarden get-item tests passed."
