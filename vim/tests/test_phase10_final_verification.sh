#!/bin/bash
# Test Phase 10: Final Verification and Testing
# This test validates the complete migration from Vim script to Lua

set -euo pipefail

VIM_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
    ((TEST_COUNT++))
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS_COUNT++))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL_COUNT++))
}

# ====================
# Task 10.1: Integration Tests
# ====================

# Test 1: Neovim startup without errors
test_neovim_startup() {
    log_test "Neovim starts without errors"
    
    if nvim --headless +qa 2>&1; then
        log_pass "Neovim starts cleanly (--headless +qa)"
    else
        log_fail "Neovim startup failed"
        return 1
    fi
}

# Test 2: All modules load successfully
test_all_modules_load() {
    log_test "All configuration modules load successfully"
    
    local modules=(
        "config.options"
        "config.keymaps"
        "config.autocmds"
        "lazy_bootstrap"
        "utils.apikey"
    )
    
    local all_ok=true
    for mod in "${modules[@]}"; do
        if nvim --headless -c "lua local ok, err = pcall(require, '${mod}'); if not ok then print('FAIL: ' .. '${mod}' .. ' - ' .. tostring(err)); os.exit(1) else print('OK: ${mod}') end" +qa 2>&1 | grep -q "OK: ${mod}"; then
            echo "  ✓ ${mod}"
        else
            echo "  ✗ ${mod}"
            all_ok=false
        fi
    done
    
    if $all_ok; then
        log_pass "All modules load correctly"
    else
        log_fail "Some modules failed to load"
        return 1
    fi
}

# Test 3: Load order is correct (options → keymaps → autocmds → lazy_bootstrap)
test_load_order() {
    log_test "Configuration load order is correct"
    
    # Verify init.lua loads modules in correct order
    if grep -n "require.*config.options" "${VIM_DIR}/init.lua" > /dev/null && \
       grep -n "require.*config.keymaps" "${VIM_DIR}/init.lua" > /dev/null && \
       grep -n "require.*config.autocmds" "${VIM_DIR}/init.lua" > /dev/null && \
       grep -n "require.*lazy_bootstrap" "${VIM_DIR}/init.lua" > /dev/null; then
        
        # Check order by line numbers
        local options_line keymaps_line autocmds_line lazy_line
        options_line=$(grep -n "require.*config.options" "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1)
        keymaps_line=$(grep -n "require.*config.keymaps" "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1)
        autocmds_line=$(grep -n "require.*config.autocmds" "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1)
        lazy_line=$(grep -n "require.*lazy_bootstrap" "${VIM_DIR}/init.lua" | head -1 | cut -d: -f1)
        
        if [[ ${options_line} -lt ${keymaps_line} ]] && \
           [[ ${keymaps_line} -lt ${autocmds_line} ]] && \
           [[ ${autocmds_line} -lt ${lazy_line} ]]; then
            log_pass "Load order is correct: options(${options_line}) → keymaps(${keymaps_line}) → autocmds(${autocmds_line}) → lazy(${lazy_line})"
        else
            log_fail "Load order is incorrect"
            return 1
        fi
    else
        log_fail "Required modules not found in init.lua"
        return 1
    fi
}

# Test 4: Primary keymaps work
test_primary_keymaps() {
    log_test "Primary keymaps are defined"
    
    local keymaps_file="${VIM_DIR}/lua/config/keymaps.lua"
    
    # Check for essential keymaps
    local essential_keymaps=(
        ";" # Quick command access
        "<C-h>" # Window navigation
        "<C-j>"
        "<C-k>"
        "<C-l>"
    )
    
    local all_found=true
    for keymap in "${essential_keymaps[@]}"; do
        if grep -q "${keymap}" "${keymaps_file}"; then
            echo "  ✓ ${keymap}"
        else
            echo "  ✗ ${keymap} not found"
            all_found=false
        fi
    done
    
    if $all_found; then
        log_pass "All primary keymaps are defined"
    else
        log_fail "Some keymaps are missing"
        return 1
    fi
}

# Test 5: checkhealth has no critical errors
test_checkhealth() {
    log_test "checkhealth has no critical errors"
    
    local health_output
    health_output=$(nvim --headless -c "checkhealth" -c "redir! > /tmp/checkhealth.txt" -c "qa" 2>&1 || true)
    
    # Give nvim time to write the file
    sleep 1
    
    if [[ -f /tmp/checkhealth.txt ]]; then
        if grep -qi "ERROR" /tmp/checkhealth.txt; then
            echo "  Health check errors found:"
            grep -i "ERROR" /tmp/checkhealth.txt | head -5
            log_fail "Critical errors in checkhealth"
            return 1
        else
            log_pass "No critical errors in checkhealth"
        fi
        rm -f /tmp/checkhealth.txt
    else
        # Alternative check - just verify startup works
        if nvim --headless +qa 2>&1; then
            log_pass "Neovim starts without errors (checkhealth skipped)"
        else
            log_fail "Could not verify health"
            return 1
        fi
    fi
}

# ====================
# Task 10.2: Migration Checklist
# ====================

# Test 6: No Vim script config files remain active
test_no_vim_script_active() {
    log_test "No Vim script configuration files are active"
    
    # Check that rc/ directory doesn't exist or is empty
    if [[ -d "${VIM_DIR}/rc" ]]; then
        if [[ -n "$(ls -A "${VIM_DIR}/rc" 2>/dev/null)" ]]; then
            log_fail "rc/ directory still contains files"
            ls "${VIM_DIR}/rc"
            return 1
        fi
    fi
    
    # Check that init.vim is either deleted or backed up
    if [[ -f "${VIM_DIR}/init.vim" ]]; then
        log_fail "init.vim still exists (should be deleted or renamed to .bak)"
        return 1
    fi
    
    log_pass "No Vim script configuration files are active"
}

# Test 7: LSP configuration is unified
test_lsp_unified() {
    log_test "LSP configuration is unified in lsp_cfg.lua"
    
    local lsp_cfg="${VIM_DIR}/lua/plugins/lsp_cfg.lua"
    local old_lsp="${VIM_DIR}/lua/lsp.lua"
    
    # Check lsp_cfg.lua exists
    if [[ ! -f "${lsp_cfg}" ]]; then
        log_fail "lsp_cfg.lua not found"
        return 1
    fi
    
    # Check old lsp.lua is removed (or backed up)
    if [[ -f "${old_lsp}" ]]; then
        log_fail "lua/lsp.lua still exists (should be deleted or backed up)"
        return 1
    fi
    
    # Check for essential LSP servers in lsp_cfg.lua
    local servers=(
        "lua_ls"
        "basedpyright|pylsp|pyright"
        "bashls"
        "yamlls"
    )
    
    local all_found=true
    for server in "${servers[@]}"; do
        if grep -E "${server}" "${lsp_cfg}" > /dev/null; then
            echo "  ✓ LSP server: ${server}"
        else
            echo "  ✗ LSP server not found: ${server}"
            all_found=false
        fi
    done
    
    if $all_found; then
        log_pass "LSP configuration is unified"
    else
        log_fail "Some LSP servers missing from unified config"
        return 1
    fi
}

# Test 8: Lazy.nvim checker is disabled
test_lazy_checker_disabled() {
    log_test "Lazy.nvim auto-update checker is disabled"
    
    local lazy_file="${VIM_DIR}/lua/lazy_bootstrap.lua"
    
    if [[ ! -f "${lazy_file}" ]]; then
        log_fail "lazy_bootstrap.lua not found"
        return 1
    fi
    
    # Check for checker.enabled = false
    # The check needs to handle multi-line/nested tables
    if grep -E "checker[[:space:]]*=" "${lazy_file}" | grep -qE "enabled[[:space:]]*=[[:space:]]*false" || \
       awk '/checker[[:space:]]*=/{found=1; braces=0} found{braces+=gsub(/{/,""); braces-=gsub(/}/,""); if(/enabled[[:space:]]*=[[:space:]]*false/){print "FOUND"; exit} if(braces<=0 && found)exit}' "${lazy_file}" | grep -q "FOUND"; then
        log_pass "Lazy.nvim checker is disabled"
    else
        # Alternative: directly check via Neovim
        if nvim --headless -c "lua if require('lazy.core.config').options.checker.enabled == false then print('DISABLED') else print('ENABLED') end" +qa 2>&1 | grep -q "DISABLED"; then
            log_pass "Lazy.nvim checker is disabled (verified via Neovim)"
        else
            log_fail "Lazy.nvim checker.enabled is not set to false"
            return 1
        fi
    fi
}

# Test 9: lazy-lock.json is Git managed
test_lazy_lock_git() {
    log_test "lazy-lock.json is managed by Git"
    
    local lock_file="${VIM_DIR}/lazy-lock.json"
    
    if [[ ! -f "${lock_file}" ]]; then
        log_fail "lazy-lock.json not found"
        return 1
    fi
    
    # Check if file is tracked by Git
    if git -C "${VIM_DIR}" ls-files --error-unmatch "lazy-lock.json" &>/dev/null; then
        log_pass "lazy-lock.json is tracked by Git"
    else
        # Check if it's staged
        if git -C "${VIM_DIR}" diff --cached --name-only | grep -q "lazy-lock.json"; then
            log_pass "lazy-lock.json is staged for Git"
        else
            log_fail "lazy-lock.json is not managed by Git"
            return 1
        fi
    fi
}

# Test 10: Security settings are correct
test_security_settings() {
    log_test "Security settings are configured correctly"
    
    local options_file="${VIM_DIR}/lua/config/options.lua"
    
    # Check for exrc and secure settings
    local exrc_ok=false
    local secure_ok=false
    
    if grep -E "exrc[[:space:]]*=[[:space:]]*false" "${options_file}" > /dev/null; then
        exrc_ok=true
        echo "  ✓ exrc = false"
    else
        echo "  ✗ exrc not set to false"
    fi
    
    if grep -E "secure[[:space:]]*=[[:space:]]*true" "${options_file}" > /dev/null; then
        secure_ok=true
        echo "  ✓ secure = true"
    else
        echo "  ✗ secure not set to true"
    fi
    
    if $exrc_ok && $secure_ok; then
        log_pass "Security settings are correct"
    else
        log_fail "Security settings are incomplete"
        return 1
    fi
}

# Test 11: updatetime is explicitly set
test_updatetime() {
    log_test "updatetime is explicitly set"
    
    local options_file="${VIM_DIR}/lua/config/options.lua"
    
    if grep -E "updatetime[[:space:]]*=" "${options_file}" > /dev/null; then
        log_pass "updatetime is explicitly configured"
    else
        log_fail "updatetime is not explicitly set"
        return 1
    fi
}

# Test 12: API key utility exists and works
test_apikey_utility() {
    log_test "API key utility is implemented"
    
    local apikey_file="${VIM_DIR}/lua/utils/apikey.lua"
    
    if [[ ! -f "${apikey_file}" ]]; then
        log_fail "utils/apikey.lua not found"
        return 1
    fi
    
    # Check for get_api_key function
    if grep -q "get_api_key" "${apikey_file}"; then
        log_pass "API key utility is implemented with get_api_key function"
    else
        log_fail "get_api_key function not found"
        return 1
    fi
}

# Test 13: No TODO markers in config files
test_no_todo_markers() {
    log_test "No TODO markers in configuration files"
    
    local config_dir="${VIM_DIR}/lua/config"
    
    if grep -rn "TODO" "${config_dir}" 2>/dev/null; then
        log_fail "TODO markers found in config files"
        return 1
    else
        log_pass "No TODO markers in configuration files"
    fi
}

# Test 14: pcall is used for module loading in init.lua
test_pcall_error_handling() {
    log_test "pcall is used for error handling in init.lua"
    
    local init_file="${VIM_DIR}/init.lua"
    
    if grep -q "pcall" "${init_file}"; then
        log_pass "pcall is used for error handling"
    else
        log_fail "pcall not found in init.lua - error handling may be missing"
        return 1
    fi
}

# ====================
# Summary
# ====================

print_summary() {
    echo ""
    echo "========================================"
    echo "Final Verification Summary"
    echo "========================================"
    echo -e "Total tests: ${TEST_COUNT}"
    echo -e "Passed: ${GREEN}${PASS_COUNT}${NC}"
    echo -e "Failed: ${RED}${FAIL_COUNT}${NC}"
    echo "========================================"
    
    if [[ ${FAIL_COUNT} -eq 0 ]]; then
        echo -e "${GREEN}✓ All tests passed! Migration is complete.${NC}"
        return 0
    else
        echo -e "${RED}✗ Some tests failed. Please review and fix.${NC}"
        return 1
    fi
}

# Run all tests
main() {
    echo "========================================"
    echo "Phase 10: Final Verification Tests"
    echo "========================================"
    echo ""
    
    echo "--- Task 10.1: Integration Tests ---"
    test_neovim_startup || true
    test_all_modules_load || true
    test_load_order || true
    test_primary_keymaps || true
    test_checkhealth || true
    
    echo ""
    echo "--- Task 10.2: Migration Checklist ---"
    test_no_vim_script_active || true
    test_lsp_unified || true
    test_lazy_checker_disabled || true
    test_lazy_lock_git || true
    test_security_settings || true
    test_updatetime || true
    test_apikey_utility || true
    test_no_todo_markers || true
    test_pcall_error_handling || true
    
    echo ""
    print_summary
}

main "$@"
