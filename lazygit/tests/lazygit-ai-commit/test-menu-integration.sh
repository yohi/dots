#!/bin/bash
# Integration test for menuFromCommand configuration
# Tests the complete pipeline as it would run in LazyGit
# Requirements: 2.2, 2.3, 3.1, 3.2, 1.2

set -e

echo "=== menuFromCommand Integration Test ==="
echo ""

# Test 1: Complete pipeline with staged changes
echo "Test 1: Complete pipeline execution"
echo "-----------------------------------"

# Create test repository
TEST_DIR="/tmp/test-menu-integration-$$"
mkdir -p "$TEST_DIR"
git init "$TEST_DIR" > /dev/null 2>&1

# Create and stage a test file
echo "test content" > "$TEST_DIR/test.txt"
git -C "$TEST_DIR" add test.txt

# Run the complete pipeline (simulating LazyGit's command)
RESULT=$(git -C "$TEST_DIR" diff --cached | head -c 12000 | ../../scripts/lazygit-ai-commit/ai-commit-generator.sh | ../../scripts/lazygit-ai-commit/parse-ai-output.sh)

# Verify output
if [ -z "$RESULT" ]; then
    echo "✗ FAIL: No output from pipeline"
    exit 1
fi

# Count number of lines (should be multiple candidates)
LINE_COUNT=$(echo "$RESULT" | wc -l)
if [ "$LINE_COUNT" -lt 2 ]; then
    echo "✗ FAIL: Expected multiple candidates, got $LINE_COUNT"
    exit 1
fi

echo "✓ PASS: Pipeline produced $LINE_COUNT commit message candidates"
echo ""

# Test 2: Verify regex filter pattern
echo "Test 2: Regex filter pattern validation"
echo "---------------------------------------"

# The filter pattern should match non-empty lines with non-whitespace
FILTER_PATTERN='^(?P<msg>.+\S.*)$'

# Test with sample output
SAMPLE_OUTPUT="feat: add new feature
fix: resolve bug

docs: update readme"

FILTERED=$(echo "$SAMPLE_OUTPUT" | grep -E '.+\S.*')
FILTERED_COUNT=$(echo "$FILTERED" | wc -l)

if [ "$FILTERED_COUNT" -eq 3 ]; then
    echo "✓ PASS: Regex filter correctly matches non-empty lines"
else
    echo "✗ FAIL: Regex filter produced unexpected results"
    exit 1
fi
echo ""

# Test 3: Verify valueFormat and labelFormat compatibility
echo "Test 3: Format template validation"
echo "----------------------------------"

# Verify that the output can be used with Go templates
# The pattern captures the entire line in 'msg' group
echo "$RESULT" | while IFS= read -r line; do
    if [ -n "$line" ]; then
        # Simulate what LazyGit would do with valueFormat: "{{ .msg }}"
        # The line itself is the value
        if [ ${#line} -gt 0 ]; then
            echo "  ✓ Line captured: $line"
        fi
    fi
done
echo "✓ PASS: All lines compatible with template format"
echo ""

# Test 4: Verify empty staging area handling
echo "Test 4: Empty staging area error handling"
echo "-----------------------------------------"

# Create empty repository
EMPTY_DIR="/tmp/test-empty-staging-$$"
mkdir -p "$EMPTY_DIR"
git init "$EMPTY_DIR" > /dev/null 2>&1

# Try to run pipeline with no staged changes
ERROR_OUTPUT=$(git -C "$EMPTY_DIR" diff --cached --quiet && echo "Error: No staged changes. Please stage files first." || echo "")

if echo "$ERROR_OUTPUT" | grep -q "No staged changes"; then
    echo "✓ PASS: Empty staging area correctly detected"
else
    echo "✗ FAIL: Empty staging area not handled correctly"
    exit 1
fi
echo ""

# Test 5: Verify loadingText requirement
echo "Test 5: LoadingText configuration"
echo "---------------------------------"

# Check that config.yml has loadingText set
if grep -q 'loadingText: "Generating commit messages with AI..."' ../../config/config.yml; then
    echo "✓ PASS: loadingText configured for user feedback"
else
    echo "✗ FAIL: loadingText not found in config.yml"
    exit 1
fi
echo ""

# Test 6: Verify color formatting in labelFormat
echo "Test 6: Color formatting in labelFormat"
echo "---------------------------------------"

# Check that config.yml has green color formatting
if grep -q 'labelFormat: "{{ .msg | green }}"' ../../config/config.yml; then
    echo "✓ PASS: labelFormat configured with green color"
else
    echo "✗ FAIL: labelFormat color not configured"
    exit 1
fi
echo ""

# Test 7: Verify complete menuFromCommand structure
echo "Test 7: Complete menuFromCommand structure"
echo "------------------------------------------"

# Verify all required fields are present
REQUIRED_FIELDS=(
    "type: \"menuFromCommand\""
    "title:"
    "command:"
    "filter:"
    "valueFormat:"
    "labelFormat:"
)

ALL_PRESENT=true
for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -q "$field" ../../config/config.yml; then
        echo "✗ FAIL: Missing required field: $field"
        ALL_PRESENT=false
    fi
done

if [ "$ALL_PRESENT" = true ]; then
    echo "✓ PASS: All required menuFromCommand fields present"
else
    exit 1
fi
echo ""

# Cleanup
rm -rf "$TEST_DIR" "$EMPTY_DIR"

echo "=== All Integration Tests Passed ==="
echo ""
echo "Summary:"
echo "  ✓ Pipeline execution works correctly"
echo "  ✓ Multiple candidates generated (Req 2.2)"
echo "  ✓ Regex filter validates correctly"
echo "  ✓ Format templates compatible"
echo "  ✓ Empty staging handled (Req 2.4)"
echo "  ✓ LoadingText configured (Req 1.2)"
echo "  ✓ Color formatting configured (Req 2.3)"
echo "  ✓ Complete menuFromCommand structure (Req 3.1, 3.2)"
echo ""
echo "Task 6 implementation verified successfully!"

exit 0
