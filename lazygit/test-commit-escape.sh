#!/bin/bash
# Test script for commit execution and escape processing
# Requirements: 4.1, 4.2, 4.3

# Don't exit on error - we want to test all cases
set +e

echo "=== Testing Commit Execution and Escape Processing ==="
echo

# Create a temporary test repository
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init
git config user.email "test@example.com"
git config user.name "Test User"

echo "Test repository created at: $TEST_DIR"
echo

# Test cases with special characters that need escaping
test_cases=(
    "feat: add user's profile page"
    'fix: handle "quoted" strings'
    'docs: update `code` examples'
    'refactor: remove ; semicolons'
    'test: add $(command) substitution'
    'chore: fix $variable expansion'
    'feat: handle backslash \ character'
    "fix: newline handling"
)

echo "Running escape processing tests..."
echo

passed=0
failed=0

for msg in "${test_cases[@]}"; do
    # Create a test file and stage it
    echo "test content" > test_file_$RANDOM.txt
    git add .
    
    # Simulate the LazyGit quote filter behavior
    # In LazyGit, the | quote filter uses Go's template.JSEscapeString or similar
    # For bash testing, we'll use printf %q which provides shell escaping
    escaped_msg=$(printf %q "$msg")
    
    # Try to commit with the escaped message
    commit_output=$(eval "git commit -m $escaped_msg" 2>&1)
    commit_status=$?
    
    if [ $commit_status -eq 0 ]; then
        echo "✓ PASS: Successfully committed with message: $msg"
        
        # Verify the commit message was stored correctly
        actual_msg=$(git log -1 --pretty=%s)
        if [ "$actual_msg" = "$msg" ]; then
            echo "  ✓ Message integrity verified"
            ((passed++))
        else
            echo "  ✗ Message mismatch!"
            echo "    Expected: $msg"
            echo "    Got: $actual_msg"
            ((failed++))
        fi
    else
        echo "✗ FAIL: Could not commit with message: $msg"
        echo "  Error: $commit_output"
        ((failed++))
    fi
    echo
done

echo "=== Test Results ==="
echo "Passed: $passed"
echo "Failed: $failed"
echo

# Cleanup
cd /
rm -rf "$TEST_DIR"

if [ $failed -eq 0 ]; then
    echo "✓ All escape processing tests passed!"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi
