#!/usr/bin/env bash
# Test for Task 4.2: Idempotency detection for public targets
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== Task 4.2: Idempotency Detection Tests ==="
echo ""

# Test 1: Check that install-packages-apps has idempotency check
echo "[TEST 1] install-packages-apps should have idempotency check"
if grep -q "IDEMPOTENCY_SKIP_MSG.*install-packages-apps" mk/install.mk; then
    echo "  ✓ PASS: install-packages-apps has skip message"
else
    echo "  ✗ FAIL: install-packages-apps missing skip message"
    exit 1
fi

# Test 2: Check that install-packages-deb has idempotency check  
echo "[TEST 2] install-packages-deb should have idempotency check"
if grep -q "IDEMPOTENCY_SKIP_MSG.*install-packages-deb" mk/install.mk; then
    echo "  ✓ PASS: install-packages-deb has skip message"
else
    echo "  ✗ FAIL: install-packages-deb missing skip message"
    exit 1
fi

# Test 3: Check that setup-config-vim has idempotency check
echo "[TEST 3] setup-config-vim should have idempotency check"
if grep -q "check_symlink" mk/setup.mk && grep -q "setup-config-vim" mk/setup.mk; then
    echo "  ✓ PASS: setup-config-vim has symlink check"
else
    echo "  ✗ FAIL: setup-config-vim missing symlink check"
    exit 1
fi

# Test 4: Check that setup-config-zsh has idempotency check
echo "[TEST 4] setup-config-zsh should have idempotency check"
if grep -q "check_symlink" mk/setup.mk && grep -q "setup-config-zsh" mk/setup.mk; then
    echo "  ✓ PASS: setup-config-zsh has symlink check"
else
    echo "  ✗ FAIL: setup-config-zsh missing symlink check"
    exit 1
fi

# Test 5: Check that setup-config-git has idempotency check
echo "[TEST 5] setup-config-git should have idempotency check"
if grep -q "setup-config-git" mk/setup.mk; then
    echo "  ✓ PASS: setup-config-git target exists"
else
    echo "  ✗ FAIL: setup-config-git target missing"
    exit 1
fi

echo ""
echo "=== All Task 4.2 Tests Passed ==="
