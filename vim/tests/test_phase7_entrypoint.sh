#!/bin/bash
# test_phase7_entrypoint.sh
# タスク7: エントリポイント完成テスト

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$(dirname "${SCRIPT_DIR}")"

echo "=== Phase 7: Entrypoint Completion Tests ==="

# Test 1: init.lua に互換モードの source 文がないこと
echo -n "Test 1: init.lua has no legacy compatibility code... "
if ! grep -q 'source.*init\.vim' "${VIM_DIR}/init.lua" && \
   ! grep -q 'legacy_init' "${VIM_DIR}/init.lua" && \
   ! grep -q 'runtime!' "${VIM_DIR}/init.lua"; then
  echo "PASS"
else
  echo "FAIL: Legacy compatibility code found in init.lua"
  exit 1
fi

# Test 2: init.lua でロード順序が正しいこと (options → keymaps → autocmds → lazy)
echo -n "Test 2: init.lua loads modules in correct order... "
init_content=$(cat "${VIM_DIR}/init.lua")
options_line=$(grep -n 'require.*config\.options' "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1 || echo "0")
keymaps_line=$(grep -n 'require.*config\.keymaps' "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1 || echo "0")
autocmds_line=$(grep -n 'require.*config\.autocmds' "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1 || echo "0")
lazy_line=$(grep -n 'require.*lazy' "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1 || echo "0")

if [ "$options_line" != "0" ] && [ "$keymaps_line" != "0" ] && \
   [ "$autocmds_line" != "0" ] && [ "$lazy_line" != "0" ] && \
   [ "$options_line" -lt "$keymaps_line" ] && \
   [ "$keymaps_line" -lt "$autocmds_line" ] && \
   [ "$autocmds_line" -lt "$lazy_line" ]; then
  echo "PASS"
else
  echo "FAIL: Module load order is incorrect"
  echo "  options: $options_line, keymaps: $keymaps_line, autocmds: $autocmds_line, lazy: $lazy_line"
  exit 1
fi

# Test 3: init.lua で全モジュールが pcall でロードされていること
echo -n "Test 3: init.lua loads modules with pcall... "
if grep -q 'pcall.*require.*config\.options' "${VIM_DIR}/init.lua" && \
   grep -q 'pcall.*require.*config\.keymaps' "${VIM_DIR}/init.lua" && \
   grep -q 'pcall.*require.*config\.autocmds' "${VIM_DIR}/init.lua" && \
   grep -q 'pcall.*require.*lazy' "${VIM_DIR}/init.lua"; then
  echo "PASS"
else
  echo "FAIL: Not all modules are loaded with pcall"
  exit 1
fi

# Test 4: lazy_bootstrap.lua で checker.enabled が false であること (要件4.3)
echo -n "Test 4: lazy_bootstrap.lua has checker.enabled = false... "
if grep -P 'checker\s*=\s*\{[^}]*enabled\s*=\s*false' "${VIM_DIR}/lua/lazy_bootstrap.lua"; then
  echo "PASS"
else
  echo "FAIL: checker.enabled should be false in lazy_bootstrap.lua"
  exit 1
fi

# Test 5: Leader キーがプラグインロード前に設定されていること
echo -n "Test 5: Leader key is set before lazy.nvim load... "
leader_line=$(grep -n 'vim\.g\.mapleader' "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1 || echo "0")
if [ "$leader_line" != "0" ] && [ "$leader_line" -lt "$lazy_line" ]; then
  echo "PASS"
else
  echo "FAIL: mapleader must be set before lazy.nvim"
  exit 1
fi

# Test 6: Neovim がエラーなしで起動すること
echo -n "Test 6: Neovim starts without errors... "
# NVIM_APPNAME を設定して別のNeovim環境として起動
export NVIM_APPNAME="nvim-test"
TEST_CONFIG_DIR="${HOME}/.config/${NVIM_APPNAME}"

# テスト用設定ディレクトリを準備（シンボリックリンク）
mkdir -p "$(dirname "${TEST_CONFIG_DIR}")"
rm -rf "${TEST_CONFIG_DIR}"
ln -sf "${VIM_DIR}" "${TEST_CONFIG_DIR}"

# headless で起動し、致命的なエラー（設定ファイルのロード失敗）がないことを確認
# Note: Python3 provider関連のエラーはheadlessモードで発生しやすいため除外
startup_output=$(nvim --headless -c 'qa!' 2>&1)
if echo "$startup_output" | grep -qiE 'Failed to load config\.|Error detected while processing.*init\.lua'; then
  echo "FAIL: Neovim startup has configuration errors"
  echo "$startup_output"
  rm -rf "${TEST_CONFIG_DIR}"
  exit 1
else
  echo "PASS"
fi

# クリーンアップ
rm -rf "${TEST_CONFIG_DIR}"

echo ""
echo "=== All Phase 7 tests passed! ==="
