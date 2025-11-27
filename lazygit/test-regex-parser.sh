#!/bin/bash
# Test script for regex parser
# Validates that the parser handles all required cases

set -e

echo "Testing regex parser..."
echo ""

# Test 1: Standard lines
echo "Test 1: Standard lines"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
feat: add new feature
fix: resolve bug
docs: update readme
EOF
)
EXPECTED="feat: add new feature
fix: resolve bug
docs: update readme"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Standard lines parsed correctly"
else
    echo "✗ FAIL: Standard lines"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

# Test 2: Numbered lists
echo "Test 2: Numbered lists"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
1. feat: add authentication
2. fix: correct validation
3. docs: update API docs
EOF
)
EXPECTED="feat: add authentication
fix: correct validation
docs: update API docs"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Numbered lists parsed correctly"
else
    echo "✗ FAIL: Numbered lists"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

# Test 3: Empty lines skipped
echo "Test 3: Empty lines skipped"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
feat: first message

fix: second message


docs: third message
EOF
)
EXPECTED="feat: first message
fix: second message
docs: third message"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Empty lines skipped correctly"
else
    echo "✗ FAIL: Empty lines"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

# Test 4: Mixed format
echo "Test 4: Mixed format (numbered + standard + empty)"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
feat: standard line
1. fix: numbered line

2. docs: another numbered

refactor: another standard
EOF
)
EXPECTED="feat: standard line
fix: numbered line
docs: another numbered
refactor: another standard"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Mixed format parsed correctly"
else
    echo "✗ FAIL: Mixed format"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

# Test 5: Whitespace-only lines
echo "Test 5: Whitespace-only lines skipped"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
feat: first
   
fix: second
		
docs: third
EOF
)
EXPECTED="feat: first
fix: second
docs: third"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Whitespace-only lines skipped correctly"
else
    echo "✗ FAIL: Whitespace-only lines"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

# Test 6: Integration with mock AI tool
echo "Test 6: Integration with mock AI tool"
OUTPUT=$(echo "test diff" | ./mock-ai-tool.sh | ./parse-ai-output.sh)
LINE_COUNT=$(echo "$OUTPUT" | wc -l)

if [ "$LINE_COUNT" -ge 3 ]; then
    echo "✓ PASS: Mock AI tool integration works (generated $LINE_COUNT messages)"
else
    echo "✗ FAIL: Mock AI tool integration"
    echo "Expected at least 3 messages, got $LINE_COUNT"
    exit 1
fi
echo ""

# Test 7: Numbers with varying spacing
echo "Test 7: Numbered lists with varying spacing"
OUTPUT=$(cat << 'EOF' | ./parse-ai-output.sh
1.feat: no space after dot
2. fix: one space
3.  docs: two spaces
EOF
)
EXPECTED="feat: no space after dot
fix: one space
docs: two spaces"

if [ "$OUTPUT" = "$EXPECTED" ]; then
    echo "✓ PASS: Varying spacing handled correctly"
else
    echo "✗ FAIL: Varying spacing"
    echo "Expected:"
    echo "$EXPECTED"
    echo "Got:"
    echo "$OUTPUT"
    exit 1
fi
echo ""

echo "=========================================="
echo "All tests passed! ✓"
echo "=========================================="
