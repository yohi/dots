#!/bin/bash
# Test script for error handling enhancements
# Tests Requirements 8.2 and 8.4

set -e

echo "=== Testing Error Handling Enhancements ==="
echo ""

# Test 1: Verify pipefail is set in ai-commit-generator.sh
echo "Test 1: Checking pipefail in ai-commit-generator.sh..."
if grep -q "set -o pipefail" ../../scripts/lazygit-ai-commit/ai-commit-generator.sh; then
    echo "✓ PASS: pipefail is set in ai-commit-generator.sh"
else
    echo "✗ FAIL: pipefail is not set in ai-commit-generator.sh"
    exit 1
fi
echo ""

# Test 2: Verify pipefail is set in parse-ai-output.sh
echo "Test 2: Checking pipefail in parse-ai-output.sh..."
if grep -q "set -o pipefail" ../../scripts/lazygit-ai-commit/parse-ai-output.sh; then
    echo "✓ PASS: pipefail is set in parse-ai-output.sh"
else
    echo "✗ FAIL: pipefail is not set in parse-ai-output.sh"
    exit 1
fi
echo ""

# Test 3: Verify timeout handling exists
echo "Test 3: Checking timeout handling in ai-commit-generator.sh..."
if grep -q "timeout.*TIMEOUT_SECONDS" ../../scripts/lazygit-ai-commit/ai-commit-generator.sh; then
    echo "✓ PASS: timeout handling is implemented"
else
    echo "✗ FAIL: timeout handling is not implemented"
    exit 1
fi
echo ""

# Test 4: Verify timeout error message
echo "Test 4: Checking timeout error message..."
if grep -q "AI tool timed out" ../../scripts/lazygit-ai-commit/ai-commit-generator.sh; then
    echo "✓ PASS: timeout error message is present"
else
    echo "✗ FAIL: timeout error message is missing"
    exit 1
fi
echo ""

# Test 5: Test empty output handling
echo "Test 5: Testing empty output handling..."
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
# Empty output generator
exit 0
EOF
chmod +x "$TEMP_SCRIPT"

# Backup and replace mock-ai-tool.sh temporarily
    cp ../../scripts/lazygit-ai-commit/mock-ai-tool.sh mock-ai-tool.sh.backup
    cp "$TEMP_SCRIPT" ../../scripts/lazygit-ai-commit/mock-ai-tool.sh

        # Test with empty output

        if echo "test diff" | AI_BACKEND=mock ../../scripts/lazygit-ai-commit/ai-commit-generator.sh 2>&1 | grep -q "AI tool returned empty output"; then
            echo "✓ PASS: Empty output is detected and reported"
            mv mock-ai-tool.sh.backup ../../scripts/lazygit-ai-commit/mock-ai-tool.sh
        else
            echo "✗ FAIL: Empty output is not properly handled"
            mv mock-ai-tool.sh.backup ../../scripts/lazygit-ai-commit/mock-ai-tool.sh
            rm "$TEMP_SCRIPT"
            exit 1
        fi
rm "$TEMP_SCRIPT"
echo ""

# Test 6: Test AI tool failure handling
echo "Test 6: Testing AI tool failure handling..."
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << 'EOF'
#!/bin/bash
# Failing AI tool
echo "Error occurred" >&2
exit 1
EOF
    chmod +x "$TEMP_SCRIPT"

    # Backup and replace mock-ai-tool.sh temporarily
    cp ../../scripts/lazygit-ai-commit/mock-ai-tool.sh mock-ai-tool.sh.backup
    cp "$TEMP_SCRIPT" ../../scripts/lazygit-ai-commit/mock-ai-tool.sh
    
    # Test with failing AI tool
    if echo "test diff" | AI_BACKEND=mock ../../scripts/lazygit-ai-commit/ai-commit-generator.sh 2>&1 | grep -q "AI tool failed"; then
        echo "✓ PASS: AI tool failure is detected and reported"
        mv mock-ai-tool.sh.backup ../../scripts/lazygit-ai-commit/mock-ai-tool.sh
    else
        echo "✗ FAIL: AI tool failure is not properly handled"
        mv mock-ai-tool.sh.backup ../../scripts/lazygit-ai-commit/mock-ai-tool.sh
        rm "$TEMP_SCRIPT"
        exit 1
    fi
rm "$TEMP_SCRIPT"
echo ""

# Test 7: Test parse-ai-output.sh with empty input
echo "Test 7: Testing parse-ai-output.sh with empty input..."
if echo "" | ../../scripts/lazygit-ai-commit/parse-ai-output.sh 2>&1 | grep -q "No AI output provided"; then
    echo "✓ PASS: Empty input to parser is detected"
else
    echo "✗ FAIL: Empty input to parser is not properly handled"
    exit 1
fi
echo ""

# Test 8: Test parse-ai-output.sh with no valid messages
echo "Test 8: Testing parse-ai-output.sh with whitespace-only input..."
if echo -e "\n  \n\t\n" | ../../scripts/lazygit-ai-commit/parse-ai-output.sh 2>&1 | grep -q "No valid commit messages found"; then
    echo "✓ PASS: Whitespace-only input is detected"
else
    echo "✗ FAIL: Whitespace-only input is not properly handled"
    exit 1
fi
echo ""

# Test 9: Test parse-ai-output.sh with valid input
echo "Test 9: Testing parse-ai-output.sh with valid input..."
OUTPUT=$(echo -e "feat: add feature\nfix: fix bug" | ../../scripts/lazygit-ai-commit/parse-ai-output.sh 2>&1)
if echo "$OUTPUT" | grep -q "feat: add feature" && echo "$OUTPUT" | grep -q "fix: fix bug"; then
    echo "✓ PASS: Valid input is parsed correctly"
else
    echo "✗ FAIL: Valid input is not parsed correctly"
    echo "Output: $OUTPUT"
    exit 1
fi
echo ""

# Test 10: Test timeout configuration
echo "Test 10: Testing timeout configuration..."
if grep -q 'TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"' ../../scripts/lazygit-ai-commit/ai-commit-generator.sh; then
    echo "✓ PASS: Timeout is configurable with default of 30 seconds"
else
    echo "✗ FAIL: Timeout configuration is incorrect"
    exit 1
fi
echo ""

# Test 11: Test error messages have suggestions
echo "Test 11: Checking error messages include suggestions..."
ERROR_COUNT=$(grep -c "Suggestion:" ../../scripts/lazygit-ai-commit/ai-commit-generator.sh || true)
if [ "$ERROR_COUNT" -ge 2 ]; then
    echo "✓ PASS: Error messages include helpful suggestions"
else
    echo "✗ FAIL: Not enough error messages with suggestions"
    exit 1
fi
echo ""

# Test 12: Test pipefail in config.yml
echo "Test 12: Checking pipefail in config.yml..."
if grep -q "set -o pipefail" config.yml; then
    echo "✓ PASS: pipefail is set in config.yml command"
else
    echo "✗ FAIL: pipefail is not set in config.yml command"
    exit 1
fi
echo ""

echo "=== All Error Handling Tests Passed ==="
echo ""
echo "Summary:"
echo "- ✓ pipefail is set in all scripts (Requirement 8.2)"
echo "- ✓ Timeout handling is implemented (Requirement 8.4)"
echo "- ✓ Empty output is detected and reported (Requirement 8.2)"
echo "- ✓ AI tool failures are caught and reported (Requirement 8.2)"
echo "- ✓ Malformed output is detected (Requirement 8.2)"
echo "- ✓ Error messages include helpful suggestions"
echo "- ✓ Timeout is configurable (default 30s)"

exit 0
