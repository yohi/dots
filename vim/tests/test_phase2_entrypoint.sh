#!/usr/bin/env bash
# Test script for Phase 2: Lua Configuration Foundation
# Note: Updated after Phase 8 completion - init.vim references are no longer expected
set -euo pipefail

echo "=== Phase 2: Lua Configuration Foundation Tests ==="

# Test 2.1: init.lua exists
echo -n "Test 2.1: init.lua exists... "
if [[ ! -f vim/init.lua ]]; then
  echo "FAILED: init.lua is missing"
  exit 1
fi
echo "PASSED"

# Test 2.2: config directory exists
echo -n "Test 2.2: vim/lua/config directory exists... "
if [[ ! -d vim/lua/config ]]; then
  echo "FAILED: vim/lua/config is missing"
  exit 1
fi
echo "PASSED"

# Test 2.3: utils directory exists
echo -n "Test 2.3: vim/lua/utils directory exists... "
if [[ ! -d vim/lua/utils ]]; then
  echo "FAILED: vim/lua/utils is missing"
  exit 1
fi
echo "PASSED"

# Test 2.4: init.lua sets mapleader (leader key must be set before plugins)
echo -n "Test 2.4: init.lua sets mapleader... "
if ! rg -q "mapleader" vim/init.lua; then
  echo "FAILED: init.lua does not set mapleader"
  exit 1
fi
echo "PASSED"

# Test 2.5: init.lua loads config modules
echo -n "Test 2.5: init.lua requires config modules... "
if ! rg -q 'require.*config\.options' vim/init.lua; then
  echo "FAILED: init.lua does not require config.options"
  exit 1
fi
echo "PASSED"

# Test 2.6: init.lua loads lazy_bootstrap (plugin manager)
echo -n "Test 2.6: init.lua requires lazy_bootstrap... "
if ! rg -q 'require.*lazy_bootstrap' vim/init.lua; then
  echo "FAILED: init.lua does not require lazy_bootstrap"
  exit 1
fi
echo "PASSED"

echo ""
echo "=== All Phase 2 tests PASSED ==="
