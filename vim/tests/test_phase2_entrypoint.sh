#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f vim/init.lua ]]; then
  echo "init.lua is missing"
  exit 1
fi

if [[ ! -d vim/lua/config ]]; then
  echo "vim/lua/config is missing"
  exit 1
fi

if [[ ! -d vim/lua/utils ]]; then
  echo "vim/lua/utils is missing"
  exit 1
fi

if ! rg -q "init.vim" vim/init.lua; then
  echo "init.lua does not reference init.vim"
  exit 1
fi

if ! rg -q "mapleader" vim/init.lua; then
  echo "init.lua does not set mapleader"
  exit 1
fi
