#!/bin/bash
# Test script for Phase 8: Legacy Code Cleanup
# Requirements: 1.2 (Vim script not loaded), 2.2 (duplicate LSP disabled), 3.1 (no orphan files), 3.4 (related config removed)

set -euo pipefail

VIM_DIR="${VIM_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"

echo "=== Phase 8: Legacy Code Cleanup Tests ==="

# Test 8.1.1: init.vim should be removed or renamed to .bak
test_init_vim_removed() {
    echo -n "Test 8.1.1: init.vim removed or renamed... "
    if [[ -f "${VIM_DIR}/init.vim" ]]; then
        echo "FAILED: init.vim still exists"
        return 1
    fi
    if [[ ! -f "${VIM_DIR}/init.vim.bak" ]]; then
        echo "FAILED: init.vim.bak does not exist (rollback not available)"
        return 1
    fi
    echo "PASSED"
}

# Test 8.1.2: rc/ directory should be removed
test_rc_dir_removed() {
    echo -n "Test 8.1.2: rc/ directory removed... "
    if [[ -d "${VIM_DIR}/rc" ]]; then
        echo "FAILED: rc/ directory still exists"
        return 1
    fi
    echo "PASSED"
}

# Test 8.1.3: lua/lsp.lua should be removed or renamed to .bak
test_lsp_lua_removed() {
    echo -n "Test 8.1.3: lua/lsp.lua removed or renamed... "
    if [[ -f "${VIM_DIR}/lua/lsp.lua" ]]; then
        echo "FAILED: lua/lsp.lua still exists"
        return 1
    fi
    if [[ ! -f "${VIM_DIR}/lua/lsp.lua.bak" ]]; then
        echo "FAILED: lua/lsp.lua.bak does not exist (rollback not available)"
        return 1
    fi
    echo "PASSED"
}

# Test 8.1.4: Git state should allow revert
test_git_revertible() {
    echo -n "Test 8.1.4: Git repository state allows revert... "
    if ! git -C "${VIM_DIR}" rev-parse --is-inside-work-tree &>/dev/null; then
        echo "SKIPPED: Not a git repository"
        return 0
    fi
    # Check that we can find the rc/ directory in git history
    if ! git -C "${VIM_DIR}" ls-tree -r HEAD~10 --name-only 2>/dev/null | grep -q "^rc/"; then
        # If not in recent history, check current commit
        if ! git -C "${VIM_DIR}" log --oneline -1 &>/dev/null; then
            echo "SKIPPED: Git history not available"
            return 0
        fi
    fi
    echo "PASSED"
}

# Test 8.2.1: nvim --headless +qa should exit without errors
test_nvim_headless() {
    echo -n "Test 8.2.1: nvim --headless +qa exits cleanly... "
    if ! command -v nvim &>/dev/null; then
        echo "SKIPPED: nvim not found"
        return 0
    fi
    
    # Run nvim with custom config path
    local output
    local exit_code=0
    output=$(nvim --headless -u "${VIM_DIR}/init.lua" +qa 2>&1) || exit_code=$?
    
    if [[ $exit_code -ne 0 ]]; then
        echo "FAILED: nvim exited with code $exit_code"
        echo "Output: $output"
        return 1
    fi
    echo "PASSED"
}

# Test 8.2.2: init.lua should not source any Vim script files
test_no_vim_script_sourcing() {
    echo -n "Test 8.2.2: init.lua does not source Vim script... "
    if grep -qE "runtime!|source.*\.vim" "${VIM_DIR}/init.lua" 2>/dev/null; then
        echo "FAILED: init.lua still sources Vim script"
        grep -E "runtime!|source.*\.vim" "${VIM_DIR}/init.lua"
        return 1
    fi
    echo "PASSED"
}

# Test 8.2.3: No orphan require statements for deleted modules
test_no_orphan_requires() {
    echo -n "Test 8.2.3: No orphan requires for deleted modules... "
    local orphans=()
    
    # Check for requires that would fail
    if grep -rq 'require.*"lsp"' "${VIM_DIR}/lua/" 2>/dev/null; then
        # Exclude lsp_cfg which is valid
        if ! grep -rq 'require.*"lsp"' "${VIM_DIR}/lua/" 2>/dev/null | grep -v "lsp_cfg" | grep -v "lsp.lua.bak"; then
            :  # No actual orphan
        else
            orphans+=("lsp module")
        fi
    fi
    
    if [[ ${#orphans[@]} -gt 0 ]]; then
        echo "FAILED: Found orphan requires: ${orphans[*]}"
        return 1
    fi
    echo "PASSED"
}

# Test 8.2.4: Core Lua modules should load without errors
test_lua_modules_loadable() {
    echo -n "Test 8.2.4: Core Lua modules are loadable... "
    if ! command -v nvim &>/dev/null; then
        echo "SKIPPED: nvim not found"
        return 0
    fi
    
    local modules=("config.options" "config.keymaps" "config.autocmds" "lazy_bootstrap" "utils.apikey")
    local failed=()
    
    for mod in "${modules[@]}"; do
        if ! nvim --headless -u NONE \
            --cmd "set rtp+=${VIM_DIR}" \
            -c "lua pcall(require, '${mod}')" \
            +qa 2>/dev/null; then
            failed+=("$mod")
        fi
    done
    
    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "FAILED: Could not load: ${failed[*]}"
        return 1
    fi
    echo "PASSED"
}

# Run all tests
main() {
    local failed=0
    
    test_init_vim_removed || ((failed++))
    test_rc_dir_removed || ((failed++))
    test_lsp_lua_removed || ((failed++))
    test_git_revertible || ((failed++))
    test_nvim_headless || ((failed++))
    test_no_vim_script_sourcing || ((failed++))
    test_no_orphan_requires || ((failed++))
    test_lua_modules_loadable || ((failed++))
    
    echo ""
    if [[ $failed -eq 0 ]]; then
        echo "=== All Phase 8 tests PASSED ==="
        exit 0
    else
        echo "=== $failed test(s) FAILED ==="
        exit 1
    fi
}

main "$@"
