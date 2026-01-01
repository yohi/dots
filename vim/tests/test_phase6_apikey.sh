#!/usr/bin/env bash
# Test Phase 6: APIキー管理ユーティリティ
set -euo pipefail

apikey_file="vim/lua/utils/apikey.lua"

echo "=== Phase 6: APIキー管理ユーティリティのテスト ==="

# Test 1: ファイルが存在するか
echo "Test 1: utils/apikey.lua の存在確認"
if [[ ! -f "${apikey_file}" ]]; then
  echo "  FAIL: utils/apikey.lua が見つかりません"
  exit 1
fi
echo "  PASS"

# Test 2: get_api_key 関数が定義されているか
echo "Test 2: get_api_key 関数の定義確認"
if ! rg -q "function.*get_api_key" "${apikey_file}"; then
  echo "  FAIL: get_api_key 関数が定義されていません"
  exit 1
fi
echo "  PASS"

# Test 3: 環境変数からキーを取得する処理があるか
echo "Test 3: 環境変数からの取得処理確認"
if ! rg -q "vim\.env\[" "${apikey_file}"; then
  echo "  FAIL: vim.env からの環境変数取得処理がありません"
  exit 1
fi
echo "  PASS"

# Test 4: 未設定時の警告表示処理があるか
echo "Test 4: 警告表示処理の確認"
if ! rg -q "vim\.notify" "${apikey_file}"; then
  echo "  FAIL: vim.notify による警告表示処理がありません"
  exit 1
fi
echo "  PASS"

# Test 5: 戻り値の構造が定義されているか (key, valid フィールド)
echo "Test 5: 戻り値構造の確認"
if ! rg -q "valid\s*=" "${apikey_file}"; then
  echo "  FAIL: valid フィールドを含む戻り値がありません"
  exit 1
fi
echo "  PASS"

# Test 6: モジュールがエクスポートされているか
echo "Test 6: モジュールのエクスポート確認"
if ! rg -q "return M" "${apikey_file}"; then
  echo "  FAIL: モジュールがエクスポートされていません"
  exit 1
fi
echo "  PASS"

# Test 7: Neovim で実際にロードできるか
echo "Test 7: Neovim でのロードテスト"
result=$(nvim --headless -u vim/init.lua -c 'lua local ok, mod = pcall(require, "utils.apikey"); if ok and mod.get_api_key then print("OK") else print("FAIL") end' -c 'qa!' 2>&1 | tail -1)
if [[ "${result}" != "OK" ]]; then
  echo "  FAIL: Neovim で utils.apikey をロードできません: ${result}"
  exit 1
fi
echo "  PASS"

# Test 8: キーが設定されている場合の動作確認
echo "Test 8: キー設定時の動作確認"
result=$(TEST_API_KEY="test-key-123" nvim --headless -u vim/init.lua -c 'lua local apikey = require("utils.apikey"); local r = apikey.get_api_key("TEST_API_KEY", "TestPlugin"); if r.valid and r.key == "test-key-123" then print("OK") else print("FAIL") end' -c 'qa!' 2>&1 | tail -1)
if [[ "${result}" != "OK" ]]; then
  echo "  FAIL: キー設定時の戻り値が正しくありません: ${result}"
  exit 1
fi
echo "  PASS"

# Test 9: キーが未設定の場合の動作確認
echo "Test 9: キー未設定時の動作確認"
result=$(nvim --headless -u vim/init.lua -c 'lua local apikey = require("utils.apikey"); local r = apikey.get_api_key("NONEXISTENT_KEY_12345", "TestPlugin"); if not r.valid and r.key == nil then print("OK") else print("FAIL") end' -c 'qa!' 2>&1 | tail -1)
if [[ "${result}" != "OK" ]]; then
  echo "  FAIL: キー未設定時の戻り値が正しくありません: ${result}"
  exit 1
fi
echo "  PASS"

echo ""
echo "=== 全テストが合格しました ==="
