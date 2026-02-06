#!/bin/bash
# Task 5.2: Devcontainer クレデンシャル転送と起動時ブートストラップのテスト
# Requirements: 5.3, 5.4

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================="
echo "Task 5.2: Devcontainer Credentials & Bootstrap Tests"
echo "=================================="

test_count=0
pass_count=0
fail_count=0

run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((test_count++))
    echo ""
    echo "[TEST $test_count] $test_name"
    
    if eval "$test_command"; then
        echo "  [PASS]"
        ((pass_count++))
        return 0
    else
        echo "  [FAIL]"
        ((fail_count++))
        return 1
    fi
}

# ============================================================
# Test 1: devcontainer.json に remoteEnv が定義されている
# ============================================================
run_test "devcontainer.json has remoteEnv with BW_SESSION" \
    'grep -q "\"BW_SESSION\": \"\${localEnv:BW_SESSION}\"" "$DOTFILES_DIR/.devcontainer/devcontainer.json"'

run_test "devcontainer.json has remoteEnv with WITH_BW" \
    'grep -q "\"WITH_BW\": \"\${localEnv:WITH_BW}\"" "$DOTFILES_DIR/.devcontainer/devcontainer.json"'

# ============================================================
# Test 2: postCreateCommand が定義されている
# ============================================================
run_test "devcontainer.json has postCreateCommand" \
    'grep -q "\"postCreateCommand\":" "$DOTFILES_DIR/.devcontainer/devcontainer.json"'

# ============================================================
# Test 3: post-create スクリプトが存在し実行可能
# ============================================================
run_test ".devcontainer/scripts/post-create.sh exists and is executable" \
    'test -x "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

# ============================================================
# Test 4: post-create スクリプトが依存関係チェックを含む
# ============================================================
run_test "post-create.sh contains dependency verification" \
    'grep -q "Verifying dependencies" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh verifies GNU Make" \
    'grep -q "make" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh verifies Bitwarden CLI" \
    'grep -q "bw" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh verifies jq" \
    'grep -q "jq" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

# ============================================================
# Test 5: post-create スクリプトが Bitwarden 疎通確認を含む
# ============================================================
run_test "post-create.sh contains Bitwarden integration check" \
    'grep -q "Checking Bitwarden integration" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh checks WITH_BW flag" \
    'grep -q "WITH_BW" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh checks BW_SESSION when WITH_BW=1" \
    'grep -q "BW_SESSION" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

# ============================================================
# Test 6: post-create スクリプトがマーカーディレクトリを初期化
# ============================================================
run_test "post-create.sh initializes marker directory" \
    'grep -q "Initializing marker directory" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

run_test "post-create.sh creates MARKER_DIR" \
    'grep -q "mkdir -p.*MARKER_DIR" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

# ============================================================
# Test 7: postCreateCommand が post-create.sh を参照
# ============================================================
run_test "postCreateCommand references post-create.sh" \
    'grep -q "post-create.sh" "$DOTFILES_DIR/.devcontainer/devcontainer.json"'

# ============================================================
# Test 8: WITH_BW=0 または未設定時に Bitwarden チェックをスキップ
# ============================================================
run_test "post-create.sh skips Bitwarden check when WITH_BW is not set" \
    'grep -q "SKIP.*Bitwarden integration disabled" "$DOTFILES_DIR/.devcontainer/scripts/post-create.sh"'

# ============================================================
# Summary
# ============================================================
echo ""
echo "=================================="
echo "Test Summary"
echo "=================================="
echo "Total:  $test_count"
echo "Passed: $pass_count"
echo "Failed: $fail_count"
echo "=================================="

if [ $fail_count -eq 0 ]; then
    echo "[PASS] All tests passed!"
    exit 0
else
    echo "[FAIL] Some tests failed."
    exit 1
fi
