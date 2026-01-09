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

log_dir="${BW_MOCK_LOG_DIR:-}"
cmd="${1:-}"
case "$cmd" in
	status)
		status="${BW_MOCK_STATUS:-unlocked}"
		email="${BW_MOCK_EMAIL:-test@example.com}"
		printf '{"status":"%s","userEmail":"%s"}\n' "$status" "$email"
		;;
	unlock)
		if [ -n "$log_dir" ]; then
			/bin/mkdir -p "$log_dir"
			echo "unlock $*" >> "$log_dir/bw.calls"
			if [ -t 0 ]; then
				: > "$log_dir/bw.stdin"
			else
				/bin/cat > "$log_dir/bw.stdin"
			fi
		fi
		echo "${BW_MOCK_SESSION:-mock-session}"
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

mock_path="$TMP_DIR/mock-bin"
mkdir -p "$mock_path"
write_bw_mock "$mock_path"
write_jq_mock "$mock_path"

echo "[TEST] bw-unlock reuses valid BW_SESSION without unlock"
reuse_log="$TMP_DIR/reuse-log"
reuse_out="$TMP_DIR/reuse.out"
reuse_err="$TMP_DIR/reuse.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=unlocked BW_MOCK_LOG_DIR="$reuse_log" BW_SESSION="existing-session" run_make bw-unlock WITH_BW=1 >"$reuse_out" 2>"$reuse_err"
reuse_status=$?
set -e
if [[ $reuse_status -ne 0 ]]; then
	echo "Expected exit 0 but got $reuse_status"
	exit 1
fi
if [[ "$(cat "$reuse_out")" != "export BW_SESSION=\"existing-session\"" ]]; then
	echo "Expected export of existing BW_SESSION"
	exit 1
fi
if [[ -s "$reuse_err" ]]; then
	echo "Expected no stderr output"
	exit 1
fi
if [[ -f "$reuse_log/bw.calls" ]] && grep -q "unlock" "$reuse_log/bw.calls"; then
	echo "Expected bw unlock to be skipped for existing session"
	exit 1
fi

echo "[TEST] bw-unlock uses BW_PASSWORD for non-interactive unlock"
pw_log="$TMP_DIR/pw-log"
pw_out="$TMP_DIR/pw.out"
pw_err="$TMP_DIR/pw.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=locked BW_MOCK_SESSION="new-session" BW_PASSWORD="pw123" BW_MOCK_LOG_DIR="$pw_log" run_make bw-unlock WITH_BW=1 >"$pw_out" 2>"$pw_err"
pw_status=$?
set -e
if [[ $pw_status -ne 0 ]]; then
	echo "Expected exit 0 but got $pw_status"
	exit 1
fi
if [[ "$(cat "$pw_out")" != "export BW_SESSION=\"new-session\"" ]]; then
	echo "Expected export of new BW_SESSION"
	exit 1
fi
if [[ -s "$pw_err" ]]; then
	echo "Expected no stderr output"
	exit 1
fi
if [[ ! -f "$pw_log/bw.stdin" ]]; then
	echo "Expected bw unlock to read BW_PASSWORD"
	exit 1
fi
pw_input="$(tr -d '\n' < "$pw_log/bw.stdin")"
if [[ "$pw_input" != "pw123" ]]; then
	echo "Expected BW_PASSWORD to be passed to bw unlock"
	exit 1
fi

echo "[TEST] bw-unlock fails when BW_SESSION is expired"
expired_out="$TMP_DIR/expired.out"
expired_err="$TMP_DIR/expired.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=locked BW_SESSION="expired-session" run_make bw-unlock WITH_BW=1 >"$expired_out" 2>"$expired_err"
expired_status=$?
set -e
if [[ $expired_status -eq 0 ]]; then
	echo "Expected non-zero exit status for expired session"
	exit 1
fi
if ! grep -q "\[ERROR\] Bitwarden session has expired\." "$expired_err"; then
	echo "Expected expired session error"
	exit 1
fi
if [[ -s "$expired_out" ]]; then
	echo "Expected no stdout output on error"
	exit 1
fi

echo "[TEST] bw-unlock fails when BW_SESSION token is invalid"
invalid_out="$TMP_DIR/invalid.out"
invalid_err="$TMP_DIR/invalid.err"
set +e
PATH="$mock_path" BW_MOCK_STATUS=unauthenticated BW_SESSION="invalid-session" run_make bw-unlock WITH_BW=1 >"$invalid_out" 2>"$invalid_err"
invalid_status=$?
set -e
if [[ $invalid_status -eq 0 ]]; then
	echo "Expected non-zero exit status for invalid session"
	exit 1
fi
if ! grep -q "\[ERROR\] Invalid Bitwarden session token\." "$invalid_err"; then
	echo "Expected invalid session error"
	exit 1
fi
if [[ -s "$invalid_out" ]]; then
	echo "Expected no stdout output on error"
	exit 1
fi

echo "All Bitwarden unlock tests passed."
