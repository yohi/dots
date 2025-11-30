#!/bin/bash
# Test script for parser
# Validates that the parser converts newlines to literal \n
set -e

echo "Testing parser..."
echo ""

# Test 1: Newline conversion
echo "Test 1: Newline conversion"
OUTPUT=$(cat << 'EOF' | ../../scripts/lazygit-ai-commit/parse-ai-output.sh
feat: title

body line 1
body line 2
EOF
)
EXPECTED="feat: title\n\nbody line 1\nbody line 2"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Newlines converted correctly"
else
    echo "✗ FAIL: Newlines conversion"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$OUTPUT'"
    exit 1
fi
echo ""

# Test 2: Single line input
echo "Test 2: Single line input"
OUTPUT=$(echo "feat: title" | ../../scripts/lazygit-ai-commit/parse-ai-output.sh)
EXPECTED="feat: title"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Single line handled correctly"
else
    echo "✗ FAIL: Single line"
    echo "Expected: '$EXPECTED'"
    echo "Got:      '$OUTPUT'"
    exit 1
fi
echo ""

echo "========================================="
echo "All tests passed! ✓"
echo "========================================="
