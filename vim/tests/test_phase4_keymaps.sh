#!/usr/bin/env bash
set -euo pipefail

keymaps_file="vim/lua/config/keymaps.lua"

if [[ ! -f "${keymaps_file}" ]]; then
  echo "config/keymaps.lua is missing"
  exit 1
fi

# 必須のキーマップが存在することを確認
missing=()

# Check for semicolon to colon mapping
if ! grep -q 'keymap("n", ";", ":"' "${keymaps_file}"; then
  missing+=("semicolon to colon mapping")
fi

# Check for split navigation (file contains literal \u003cC-h\u003e strings)
for key in 'h' 'j' 'k' 'l'; do
  if ! grep -q "C-${key}.*C-w" "${keymaps_file}"; then
    missing+=("split navigation C-$key")
  fi
done

# Check for ESC ESC -> nohlsearch  
if ! grep -q 'ESC.*ESC.*nohlsearch' "${keymaps_file}"; then
  missing+=("ESC ESC nohlsearch")
fi

# Check for insert mode navigation
if ! grep -q '"i".*C-a.*Home' "${keymaps_file}"; then
  missing+=("insert mode C-a")
fi
if ! grep -q '"i".*C-e.*End' "${keymaps_file}"; then
  missing+=("insert mode C-e")
fi

# Check for command mode navigation
if ! grep -q '"c".*C-a.*Home' "${keymaps_file}"; then
  missing+=("command mode C-a")
fi

if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing required keymaps:"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

# TODOマーカーとコメントアウトされたコードが無いことを確認
if grep -q "TODO" "${keymaps_file}"; then
  echo "TODO markers should not exist in config/keymaps.lua"
  exit 1
fi

# コメントアウトされたマッピングが無いことを確認
if grep -q "^[[:space:]]*--.*[ni]noremap" "${keymaps_file}"; then
  echo "Commented-out Vimscript mappings should not exist in config/keymaps.lua"
  exit 1
fi

echo "✓ All keymap tests passed"
