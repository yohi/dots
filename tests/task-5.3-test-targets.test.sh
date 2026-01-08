#!/bin/bash
# Task 5.3 Test: Mock and Integration Test Targets
# Tests that make test-bw-mock and make test-bw-integration work correctly

set -euo pipefail

echo "=========================================="
echo "Task 5.3: Mock/Integration Test Targets"
echo "=========================================="

FAILURES=0

# Test 1: test-bw-mock が認証なしで実行可能
echo ""
echo "[TEST 1] test-bw-mock target exists and runs without authentication"
if make test-bw-mock 2>&1 | tee /tmp/test-bw-mock.log; then
    echo "  [PASS] test-bw-mock executed successfully"
else
    echo "  [FAIL] test-bw-mock failed"
    ((FAILURES++))
fi

# Test 2: test-bw-integration が BW_SESSION 未設定時にエラー終了
echo ""
echo "[TEST 2] test-bw-integration fails without BW_SESSION"
unset BW_SESSION
set +e  # Allow command to fail
test_output=$(make test-bw-integration 2>&1)
test_result=$?
set -e  # Re-enable error handling

if [ $test_result -ne 0 ] && echo "$test_output" | grep -qE "\[ERROR\].*BW_SESSION"; then
    echo "  [PASS] test-bw-integration requires BW_SESSION"
else
    echo "  [FAIL] test-bw-integration did not fail correctly"
    echo "  Exit code: $test_result"
    echo "  Output: $test_output" | head -5
    ((FAILURES++))
fi

# Test 3: make test が test-bw-mock を実行する
echo ""
echo "[TEST 3] make test includes test-bw-mock"
if grep -q "^test:.*test-bw-mock" mk/test.mk || grep -q "test-unit test-bw-mock" mk/test.mk; then
    echo "  [PASS] make test includes test-bw-mock"
else
    echo "  [FAIL] make test should include test-bw-mock"
    ((FAILURES++))
fi

# Test 4: モック bw スクリプトが存在し、実行可能
echo ""
echo "[TEST 4] Mock bw script exists and is executable"
if [ -f ".devcontainer/mocks/bw" ] && [ -x ".devcontainer/mocks/bw" ]; then
    echo "  [PASS] Mock bw script exists and is executable"
else
    echo "  [FAIL] Mock bw script not found or not executable"
    ((FAILURES++))
fi

# Test 5: モック bw スクリプトが各状態を再現可能
echo ""
echo "[TEST 5] Mock bw script reproduces different states"
if [ -x ".devcontainer/mocks/bw" ]; then
    # unlocked 状態
    if .devcontainer/mocks/bw status 2>&1 | grep -q '"status":"unlocked"'; then
        echo "  [PASS] Mock bw can simulate unlocked state"
    else
        echo "  [FAIL] Mock bw cannot simulate unlocked state"
        ((FAILURES++))
    fi
    
    # locked 状態
    if BW_MOCK_STATE=locked .devcontainer/mocks/bw status 2>&1 | grep -q '"status":"locked"'; then
        echo "  [PASS] Mock bw can simulate locked state"
    else
        echo "  [FAIL] Mock bw cannot simulate locked state"
        ((FAILURES++))
    fi
    
    # unauthenticated 状態
    if BW_MOCK_STATE=unauthenticated .devcontainer/mocks/bw status 2>&1 | grep -q '"status":"unauthenticated"'; then
        echo "  [PASS] Mock bw can simulate unauthenticated state"
    else
        echo "  [FAIL] Mock bw cannot simulate unauthenticated state"
        ((FAILURES++))
    fi
fi

# Test 6: test-bw-mock が exit 0 で終了
echo ""
echo "[TEST 6] test-bw-mock exits with code 0"
if make test-bw-mock >/dev/null 2>&1; then
    echo "  [PASS] test-bw-mock exits with 0"
else
    EXIT_CODE=$?
    echo "  [FAIL] test-bw-mock exited with $EXIT_CODE"
    ((FAILURES++))
fi

# Summary
echo ""
echo "=========================================="
if [ $FAILURES -eq 0 ]; then
    echo "All tests passed!"
    echo "=========================================="
    exit 0
else
    echo "$FAILURES test(s) failed"
    echo "=========================================="
    exit 1
fi
