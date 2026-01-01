#!/usr/bin/env bash
# Test Phase 4.2: Autocmd Migration
# Tests that autocmds from rc/basic.vim are properly migrated to config/autocmds.lua

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$(dirname "${SCRIPT_DIR}")"

echo "Testing Phase 4.2: Autocmd Migration..."

# Test 1: config/autocmds.lua exists
autocmds_file="${VIM_DIR}/lua/config/autocmds.lua"
if [[ ! -f "${autocmds_file}" ]]; then
    echo "✗ FAIL: config/autocmds.lua does not exist"
    exit 1
fi
echo "✓ PASS: config/autocmds.lua exists"

# Test 2: File uses Lua autocmd API
required_patterns=(
    'vim\.api\.nvim_create_augroup'
    'vim\.api\.nvim_create_autocmd'
)

for pattern in "${required_patterns[@]}"; do
    if ! rg -P -q "${pattern}" "${autocmds_file}"; then
        echo "✗ FAIL: Missing required pattern: ${pattern}"
        exit 1
    fi
done
echo "✓ PASS: Uses Lua autocmd API"

# Test 3: WezTerm IME integration autocmds are present
wezterm_events=(
    'InsertLeave'
    'InsertEnter'
    'CmdlineEnter'
    'CmdlineLeave'
    'VimEnter'
)

for event in "${wezterm_events[@]}"; do
    if ! rg -q "${event}" "${autocmds_file}"; then
        echo "✗ FAIL: Missing WezTerm IME event: ${event}"
        exit 1
    fi
done
echo "✓ PASS: WezTerm IME integration autocmds present"

# Test 4: Various file-type autocmds are present
# Check for textwidth=0 setting
if ! rg -q 'textwidth' "${autocmds_file}"; then
    echo "✗ FAIL: Missing textwidth autocmd"
    exit 1
fi
echo "✓ PASS: File-type autocmds present"

# Test 5: JSON syntax highlighting autocmd is present
if ! rg -q 'Syntax' "${autocmds_file}" || ! rg -q 'pattern = "json"' "${autocmds_file}"; then
    echo "✗ FAIL: Missing JSON syntax highlighting autocmd"
    exit 1
fi
echo "✓ PASS: JSON syntax highlighting autocmd present"

# Test 6: No TODO markers
if rg -q 'TODO' "${autocmds_file}"; then
    echo "✗ FAIL: TODO markers found in autocmds.lua"
    exit 1
fi
echo "✓ PASS: No TODO markers"

# Test 7: No commented-out code (lines starting with -- followed by actual code)
# This is a heuristic check - look for commented vim.api calls or augroup patterns
commented_code_count=$(rg -c '^--\s*(vim\.api\.nvim_create|augroup)' "${autocmds_file}" || echo "0")
if [[ "${commented_code_count}" -gt 0 ]]; then
    echo "✗ FAIL: Found ${commented_code_count} commented-out autocmd lines"
    exit 1
fi
echo "✓ PASS: No commented-out autocmds"

# Test 8: Can be loaded without errors
if ! nvim --headless --noplugin -u NONE -c "luafile ${autocmds_file}" -c 'qa!' 2>&1 | grep -i error; then
    echo "✓ PASS: autocmds.lua loads without errors"
else
    echo "✗ FAIL: autocmds.lua has loading errors"
    exit 1
fi

echo ""
echo "All Phase 4.2 autocmd tests passed!"
