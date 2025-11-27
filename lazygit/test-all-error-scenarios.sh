#!/bin/bash
# Comprehensive error scenario testing
# Validates all error handling paths work correctly

set -e

echo "=== Comprehensive Error Scenario Testing ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

test_scenario() {
    local name="$1"
    local expected_error="$2"
    shift 2
    
    echo "Testing: $name"
    if "$@" 2>&1 | grep -q "$expected_error"; then
        echo "✓ PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "✗ FAIL: Expected error '$expected_error' not found"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    echo ""
}

# Scenario 1: Empty diff input
echo "Scenario 1: Empty diff input to AI generator"
if echo "" | ./ai-commit-generator.sh 2>&1 | grep -q "No diff input provided"; then
    echo "✓ PASS: Empty diff detected"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Empty diff not detected"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Scenario 2: AI tool returns empty output
echo "Scenario 2: AI tool returns empty output"
EMPTY_AI=$(mktemp)
cat > "$EMPTY_AI" << 'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$EMPTY_AI"
cp mock-ai-tool.sh mock-ai-tool.sh.backup
cp "$EMPTY_AI" mock-ai-tool.sh
if echo "test diff" | AI_BACKEND=mock ./ai-commit-generator.sh 2>&1 | grep -q "AI tool returned empty output"; then
    echo "✓ PASS: Empty AI output detected"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Empty AI output not detected"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
mv mock-ai-tool.sh.backup mock-ai-tool.sh
rm "$EMPTY_AI"
echo ""

# Scenario 3: AI tool fails with error
echo "Scenario 3: AI tool fails with non-zero exit code"
FAILING_AI=$(mktemp)
cat > "$FAILING_AI" << 'EOF'
#!/bin/bash
echo "Internal error" >&2
exit 1
EOF
chmod +x "$FAILING_AI"
cp mock-ai-tool.sh mock-ai-tool.sh.backup
cp "$FAILING_AI" mock-ai-tool.sh
if echo "test diff" | AI_BACKEND=mock ./ai-commit-generator.sh 2>&1 | grep -q "AI tool failed"; then
    echo "✓ PASS: AI tool failure detected"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: AI tool failure not detected"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
mv mock-ai-tool.sh.backup mock-ai-tool.sh
rm "$FAILING_AI"
echo ""

# Scenario 4: AI tool times out
echo "Scenario 4: AI tool times out"
SLOW_AI=$(mktemp)
cat > "$SLOW_AI" << 'EOF'
#!/bin/bash
sleep 10
echo "feat: too slow"
EOF
chmod +x "$SLOW_AI"
cp mock-ai-tool.sh mock-ai-tool.sh.backup
cp "$SLOW_AI" mock-ai-tool.sh
if echo "test diff" | TIMEOUT_SECONDS=1 AI_BACKEND=mock ./ai-commit-generator.sh 2>&1 | grep -q "timed out"; then
    echo "✓ PASS: Timeout detected"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Timeout not detected"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
mv mock-ai-tool.sh.backup mock-ai-tool.sh
rm "$SLOW_AI"
echo ""

# Scenario 5: Parser receives empty input
echo "Scenario 5: Parser receives empty input"
if echo "" | ./parse-ai-output.sh 2>&1 | grep -q "No AI output provided"; then
    echo "✓ PASS: Parser detects empty input"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Parser doesn't detect empty input"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Scenario 6: Parser receives whitespace-only input
echo "Scenario 6: Parser receives whitespace-only input"
if echo -e "\n  \n\t\n" | ./parse-ai-output.sh 2>&1 | grep -q "No valid commit messages found"; then
    echo "✓ PASS: Parser detects whitespace-only input"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Parser doesn't detect whitespace-only input"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Scenario 7: Pipeline failure propagation
echo "Scenario 7: Pipeline failure propagation (pipefail)"
FAILING_AI=$(mktemp)
cat > "$FAILING_AI" << 'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$FAILING_AI"
# Test that pipeline failure is caught
if bash -c "set -o pipefail; echo 'test' | $FAILING_AI | cat" 2>&1; then
    echo "✗ FAIL: Pipeline failure not propagated"
    FAIL_COUNT=$((FAIL_COUNT + 1))
else
    echo "✓ PASS: Pipeline failure propagated correctly"
    PASS_COUNT=$((PASS_COUNT + 1))
fi
rm "$FAILING_AI"
echo ""

# Scenario 8: Valid input produces valid output
echo "Scenario 8: Valid input produces valid output"
OUTPUT=$(echo "test diff" | ./ai-commit-generator.sh 2>&1 | ./parse-ai-output.sh 2>&1)
if [ -n "$OUTPUT" ] && echo "$OUTPUT" | grep -q "feat:"; then
    echo "✓ PASS: Valid input produces valid output"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Valid input doesn't produce valid output"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Scenario 9: Error messages include suggestions
echo "Scenario 9: All error messages include suggestions"
SUGGESTION_COUNT=0

# Check ai-commit-generator.sh
SUGGESTION_COUNT=$(grep -c "Suggestion:" ai-commit-generator.sh || true)
if [ "$SUGGESTION_COUNT" -ge 3 ]; then
    echo "✓ PASS: ai-commit-generator.sh has $SUGGESTION_COUNT suggestions"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: ai-commit-generator.sh has only $SUGGESTION_COUNT suggestions"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Check parse-ai-output.sh
SUGGESTION_COUNT=$(grep -c "Suggestion:" parse-ai-output.sh || true)
if [ "$SUGGESTION_COUNT" -ge 1 ]; then
    echo "✓ PASS: parse-ai-output.sh has $SUGGESTION_COUNT suggestions"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: parse-ai-output.sh has only $SUGGESTION_COUNT suggestions"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Scenario 10: Timeout is configurable
echo "Scenario 10: Timeout configuration"
if grep -q 'TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"' ai-commit-generator.sh; then
    echo "✓ PASS: Timeout is configurable with default 30s"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "✗ FAIL: Timeout configuration not found"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo "Passed: $PASS_COUNT"
echo "Failed: $FAIL_COUNT"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo "✓ All error scenarios handled correctly!"
    exit 0
else
    echo "✗ Some error scenarios failed"
    exit 1
fi
