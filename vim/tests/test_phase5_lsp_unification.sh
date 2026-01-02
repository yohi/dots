#!/bin/bash
# Test Phase 5: LSP Configuration Unification
# Tests that LSP configuration is unified in lsp_cfg.lua and lsp.lua is removed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Phase 5: LSP Unification Tests ==="

# Test 5.1: LSP server configuration consolidation
echo "Test 5.1: Verify lsp.lua is deleted and lsp_cfg.lua contains all configurations"

if [ -f "$VIM_DIR/lua/lsp.lua" ]; then
    echo "❌ FAIL: lsp.lua still exists (should be deleted)"
    exit 1
fi
echo "✓ lsp.lua has been removed"

LSP_CFG_FILE="$VIM_DIR/lua/plugins/lsp_cfg.lua"
if [ ! -f "$LSP_CFG_FILE" ]; then
    echo "❌ FAIL: lsp_cfg.lua does not exist"
    exit 1
fi

# Check that lsp_cfg.lua contains required LSP servers
required_servers=(
    "basedpyright"
    "bashls"
    "lua_ls"
    "yamlls"
    "jsonls"
    "html"
    "vimls"
    "dockerls"
    "intelephense"
)

for server in "${required_servers[@]}"; do
    if ! grep -q "$server" "$LSP_CFG_FILE"; then
        echo "❌ FAIL: $server not found in lsp_cfg.lua"
        exit 1
    fi
done
echo "✓ All required LSP servers are configured in lsp_cfg.lua"

# Test 5.2: LSP common configuration consolidation
echo ""
echo "Test 5.2: Verify diagnostic config and keymaps are in lsp_cfg.lua"

# Check for diagnostic configuration
if ! grep -q "vim.diagnostic.config" "$LSP_CFG_FILE"; then
    echo "❌ FAIL: vim.diagnostic.config not found in lsp_cfg.lua"
    exit 1
fi
echo "✓ Diagnostic configuration is present in lsp_cfg.lua"

# Check for LSP keymaps (should be present)
lsp_keymaps=(
    "vim.lsp.buf.hover"
    "vim.lsp.buf.definition"
    "vim.lsp.buf.references"
    "vim.diagnostic.open_float"
    "vim.diagnostic.goto_next"
    "vim.diagnostic.goto_prev"
)

for keymap in "${lsp_keymaps[@]}"; do
    if ! grep -q "$keymap" "$LSP_CFG_FILE"; then
        echo "❌ FAIL: Keymap $keymap not found in lsp_cfg.lua"
        exit 1
    fi
done
echo "✓ LSP keymaps are present in lsp_cfg.lua"

# Check that updatetime is NOT in lsp_cfg.lua (should be in options.lua)
if grep -q "updatetime" "$LSP_CFG_FILE"; then
    echo "⚠️  WARNING: updatetime found in lsp_cfg.lua (should be in options.lua)"
    # Not a failure, just a warning
fi

# Test 5.3: Verify no duplicate configurations
echo ""
echo "Test 5.3: Verify no duplicate LSP server definitions"

# Count occurrences of vim.lsp.config for each server
for server in "${required_servers[@]}"; do
    # Count how many times this server is configured (should be exactly 1)
    # Use more specific pattern to avoid matching nested tables in settings
    count=$(grep -E "^[[:space:]]{16}$server = \\{" "$LSP_CFG_FILE" 2>/dev/null | wc -l)
    if [ "$count" -eq 0 ]; then
        # Server not found - that's okay, it might not be in this config
        continue
    elif [ "$count" -gt 1 ]; then
        echo "❌ FAIL: $server is configured $count times (should be 1)"
        exit 1
    fi
done
echo "✓ No duplicate LSP server configurations found"

echo ""
echo "=== All Phase 5 Tests Passed ==="
echo ""
echo "Summary:"
echo "  ✓ lsp.lua removed"
echo "  ✓ All LSP servers consolidated in lsp_cfg.lua"
echo "  ✓ Diagnostic configuration present"
echo "  ✓ LSP keymaps present"
echo "  ✓ No duplicates"
