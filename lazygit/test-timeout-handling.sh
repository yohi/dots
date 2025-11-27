#!/bin/bash
# Test script for timeout handling (Requirement 8.4)

set -e

echo "=== Testing Timeout Handling (Requirement 8.4) ==="
echo ""

# Test 1: Create a slow AI tool that takes longer than timeout
echo "Test 1: Testing timeout with slow AI tool..."
SLOW_AI=$(mktemp)
cat > "$SLOW_AI" << 'EOF'
#!/bin/bash
# Slow AI tool that sleeps for 35 seconds (longer than default 30s timeout)
sleep 35
echo "feat: this should never appear"
EOF
chmod +x "$SLOW_AI"

# Run with short timeout
START_TIME=$(date +%s)
if echo "test diff" | TIMEOUT_SECONDS=2 AI_TOOL="$SLOW_AI" ./ai-commit-generator.sh 2>&1 | grep -q "AI tool timed out"; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    echo "✓ PASS: Timeout detected correctly"
    echo "  Elapsed time: ${ELAPSED}s (expected ~2s)"
    if [ $ELAPSED -le 5 ]; then
        echo "✓ PASS: Timeout enforced within reasonable time"
    else
        echo "✗ FAIL: Timeout took too long: ${ELAPSED}s"
        rm "$SLOW_AI"
        exit 1
    fi
else
    echo "✗ FAIL: Timeout not detected"
    rm "$SLOW_AI"
    exit 1
fi
rm "$SLOW_AI"
echo ""

# Test 2: Verify timeout error message includes suggestion
echo "Test 2: Checking timeout error message includes suggestion..."
SLOW_AI=$(mktemp)
cat > "$SLOW_AI" << 'EOF'
#!/bin/bash
sleep 10
EOF
chmod +x "$SLOW_AI"

OUTPUT=$(echo "test diff" | TIMEOUT_SECONDS=1 AI_TOOL="$SLOW_AI" ./ai-commit-generator.sh 2>&1 || true)
if echo "$OUTPUT" | grep -q "Suggestion:"; then
    echo "✓ PASS: Timeout error includes helpful suggestion"
    echo "  Message: $(echo "$OUTPUT" | grep "Suggestion:")"
else
    echo "✗ FAIL: Timeout error missing suggestion"
    rm "$SLOW_AI"
    exit 1
fi
rm "$SLOW_AI"
echo ""

# Test 3: Verify normal operation completes within timeout
echo "Test 3: Testing normal operation completes within timeout..."
START_TIME=$(date +%s)
if OUTPUT=$(echo "test diff" | TIMEOUT_SECONDS=30 ./ai-commit-generator.sh 2>&1); then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    echo "✓ PASS: Normal operation completed successfully"
    echo "  Elapsed time: ${ELAPSED}s"
    if [ $ELAPSED -lt 30 ]; then
        echo "✓ PASS: Completed well within timeout"
    fi
else
    echo "✗ FAIL: Normal operation failed"
    exit 1
fi
echo ""

# Test 4: Verify timeout is configurable via environment variable
echo "Test 4: Testing timeout configuration..."
if grep -q 'TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"' ai-commit-generator.sh; then
    echo "✓ PASS: Timeout is configurable via TIMEOUT_SECONDS environment variable"
    echo "  Default: 30 seconds"
else
    echo "✗ FAIL: Timeout configuration not found"
    exit 1
fi
echo ""

# Test 5: Test with very short timeout to ensure immediate failure
echo "Test 5: Testing with very short timeout (1 second)..."
SLOW_AI=$(mktemp)
cat > "$SLOW_AI" << 'EOF'
#!/bin/bash
sleep 5
echo "feat: should timeout"
EOF
chmod +x "$SLOW_AI"

START_TIME=$(date +%s)
if echo "test diff" | TIMEOUT_SECONDS=1 AI_TOOL="$SLOW_AI" ./ai-commit-generator.sh 2>&1 | grep -q "timed out"; then
    END_TIME=$(date +%s)
    ELAPSED=$((END_TIME - START_TIME))
    if [ $ELAPSED -le 3 ]; then
        echo "✓ PASS: Short timeout enforced correctly (${ELAPSED}s)"
    else
        echo "✗ FAIL: Short timeout took too long: ${ELAPSED}s"
        rm "$SLOW_AI"
        exit 1
    fi
else
    echo "✗ FAIL: Short timeout not detected"
    rm "$SLOW_AI"
    exit 1
fi
rm "$SLOW_AI"
echo ""

echo "=== All Timeout Tests Passed ==="
echo ""
echo "Summary:"
echo "- ✓ Timeout command is used (Requirement 8.4)"
echo "- ✓ Timeout is configurable (default 30s)"
echo "- ✓ Timeout errors are detected and reported"
echo "- ✓ Timeout error messages include suggestions"
echo "- ✓ Normal operations complete within timeout"
echo "- ✓ Timeout is enforced promptly"

exit 0
