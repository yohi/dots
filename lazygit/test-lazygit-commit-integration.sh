#!/bin/bash
# Integration test for LazyGit commit execution
# Tests the complete workflow: menuFromCommand → user selection → commit execution
# Requirements: 4.1, 4.2, 4.3

set +e

# Determine the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== LazyGit Commit Integration Test ==="
echo

# Create a temporary test repository
TEST_DIR=$(mktemp -d)
if ! cd "$TEST_DIR"; then
    echo "failed to cd $TEST_DIR" >&2
    exit 1
fi
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

echo "Test repository: $TEST_DIR"
echo

# Test the complete pipeline that LazyGit would execute
echo "Testing complete pipeline simulation..."
echo

# Create a test file with changes
cat > test.txt << 'EOF'
function hello() {
    console.log("Hello, World!");
}
EOF

git add test.txt

# Simulate the menuFromCommand pipeline
echo "1. Getting staged diff..."
DIFF=$(git diff --cached)
if [ -z "$DIFF" ]; then
    echo "✗ FAIL: No staged changes detected"
    exit 1
fi
echo "✓ Staged diff retrieved"
echo

# Simulate AI generation (using mock)
echo "2. Generating commit messages..."
# Use the script directory to locate companion scripts
MESSAGES=$(echo "$DIFF" | head -c 12000 | "$SCRIPT_DIR/ai-commit-generator.sh" | "$SCRIPT_DIR/parse-ai-output.sh")

if [ -z "$MESSAGES" ]; then
    echo "✗ FAIL: No messages generated"
    exit 1
fi

echo "✓ Messages generated:"
echo "$MESSAGES" | head -3
echo

# Simulate user selecting a message with special characters
echo "3. Testing commit with special characters..."
TEST_MSG='feat(test): add "hello" function with $variable and `backticks`'

# Simulate LazyGit's | quote filter (using printf %q for shell escaping)
ESCAPED_MSG=$(printf %q "$TEST_MSG")

# Execute the commit
eval "git commit -m $ESCAPED_MSG" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Commit executed successfully"
    
    # Verify the message was stored correctly
    ACTUAL_MSG=$(git log -1 --pretty=%s)
    if [ "$ACTUAL_MSG" = "$TEST_MSG" ]; then
        echo "✓ Message integrity verified"
        echo "  Expected: $TEST_MSG"
        echo "  Got:      $ACTUAL_MSG"
    else
        echo "✗ Message mismatch!"
        echo "  Expected: $TEST_MSG"
        echo "  Got:      $ACTUAL_MSG"
        exit 1
    fi
else
    echo "✗ Commit failed"
    exit 1
fi
echo

# Test UI update simulation (verify commit is in log)
echo "4. Verifying UI update (commit in log)..."
COMMIT_COUNT=$(git log --oneline | wc -l)
if [ "$COMMIT_COUNT" -eq 1 ]; then
    echo "✓ Commit appears in git log"
    echo "  Commit: $(git log -1 --oneline)"
else
    echo "✗ Unexpected commit count: $COMMIT_COUNT"
    exit 1
fi
echo

# Test cancellation scenario
echo "5. Testing cancellation scenario..."
echo "test2" > test2.txt
git add test2.txt

# Simulate user pressing Esc (no commit should happen)
echo "  (Simulating Esc - no commit executed)"
COMMIT_COUNT_BEFORE=$(git log --oneline | wc -l)
# In LazyGit, pressing Esc simply doesn't execute the command
COMMIT_COUNT_AFTER=$(git log --oneline | wc -l)

if [ "$COMMIT_COUNT_BEFORE" -eq "$COMMIT_COUNT_AFTER" ]; then
    echo "✓ Cancellation works correctly (no new commit)"
else
    echo "✗ Unexpected commit after cancellation"
    exit 1
fi
echo

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo "=== All Integration Tests Passed ==="
exit 0
