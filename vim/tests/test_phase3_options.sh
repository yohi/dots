#!/usr/bin/env bash
set -euo pipefail

options_file="vim/lua/config/options.lua"

if [[ ! -f "${options_file}" ]]; then
  echo "config/options.lua is missing"
  exit 1
fi

required_patterns=(
  "(?:vim\\.opt|opt)\\.encoding = \"utf-8\""
  "(?:vim\\.opt|opt)\\.fileencodings ="
  "(?:vim\\.opt|opt)\\.fileformat = \"unix\""
  "(?:vim\\.opt|opt)\\.fileformats ="
  "(?:vim\\.opt|opt)\\.expandtab = true"
  "(?:vim\\.opt|opt)\\.shiftwidth = 4"
  "(?:vim\\.opt|opt)\\.tabstop = 4"
  "(?:vim\\.opt|opt)\\.softtabstop = 4"
  "(?:vim\\.opt|opt)\\.noswapfile = true"
  "(?:vim\\.opt|opt)\\.noundofile = true"
  "(?:vim\\.opt|opt)\\.autoread = true"
  "(?:vim\\.opt|opt)\\.hidden = true"
  "(?:vim\\.opt|opt)\\.timeout = true"
  "(?:vim\\.opt|opt)\\.timeoutlen = 500"
  "(?:vim\\.opt|opt)\\.clipboard:append\\(\"unnamedplus\"\\)"
  "(?:vim\\.opt|opt)\\.number = true"
  "(?:vim\\.opt|opt)\\.cursorline = true"
  "(?:vim\\.opt|opt)\\.list = true"
  "(?:vim\\.opt|opt)\\.listchars ="
  "(?:vim\\.opt|opt)\\.ignorecase = true"
  "(?:vim\\.opt|opt)\\.smartcase = true"
  "(?:vim\\.opt|opt)\\.incsearch = true"
  "(?:vim\\.opt|opt)\\.hlsearch = true"
  "(?:vim\\.opt|opt)\\.nowrapscan = true"
  "(?:vim\\.opt|opt)\\.updatetime = 300"
  "(?:vim\\.opt|opt)\\.exrc = false"
  "(?:vim\\.opt|opt)\\.secure = true"
)

for pattern in "${required_patterns[@]}"; do
  if ! rg -P -q "${pattern}" "${options_file}"; then
    echo "Missing required setting: ${pattern}"
    exit 1
  fi
done

if rg -q "TODO" "${options_file}"; then
  echo "TODO markers should not exist in config/options.lua"
  exit 1
fi
