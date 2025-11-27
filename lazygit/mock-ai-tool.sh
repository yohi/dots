#!/bin/bash
# Mock AI CLI tool for testing
# Simulates AI-generated commit messages based on diff input
# Requirements: 5.2, 5.3, 6.1, 6.3

set -e
set -o pipefail

# Read full input from stdin (includes prompt + diff)
FULL_INPUT=$(cat)

# Check if input is empty
if [ -z "$FULL_INPUT" ]; then
    echo "Error: No input provided" >&2
    exit 1
fi

# Extract diff portion from combined input
# The diff is between ---DIFF START--- and ---DIFF END--- markers
if echo "$FULL_INPUT" | grep -qF -- "---DIFF START---"; then
    # Extract only the diff portion for analysis
    DIFF_INPUT=$(echo "$FULL_INPUT" | sed -n '/---DIFF START---/,/---DIFF END---/p' | sed '1d;$d')
else
    # Fallback: treat entire input as diff (for backward compatibility)
    DIFF_INPUT="$FULL_INPUT"
fi

# Analyze diff to generate contextual messages
# This is a simple heuristic-based approach for testing
HAS_NEW_FILE=$(echo "$DIFF_INPUT" | grep -c "^+++ b/" || true)
HAS_DELETED_FILE=$(echo "$DIFF_INPUT" | grep -c "^deleted file mode" || true)
HAS_TEST=$(echo "$DIFF_INPUT" | grep -ci "test\|spec" || true)
HAS_DOC=$(echo "$DIFF_INPUT" | grep -ci "readme\|doc\|\.md" || true)
HAS_CONFIG=$(echo "$DIFF_INPUT" | grep -ci "config\|\.yml\|\.yaml\|\.json" || true)

# Generate mock commit messages following Conventional Commits format
# No markdown, no numbering, no decorations - pure text only

if [ "$HAS_TEST" -gt 0 ]; then
    echo "test: add test coverage for new functionality"
fi

if [ "$HAS_DOC" -gt 0 ]; then
    echo "docs: update documentation with latest changes"
fi

if [ "$HAS_CONFIG" -gt 0 ]; then
    echo "chore: update configuration files"
fi

if [ "$HAS_DELETED_FILE" -gt 0 ]; then
    echo "chore: remove obsolete files"
fi

if [ "$HAS_NEW_FILE" -gt 0 ]; then
    echo "feat: add new files and functionality"
fi

# Always provide some generic options
echo "feat: implement new feature based on changes"
echo "fix: resolve issues identified in code review"
echo "refactor: improve code structure and readability"

exit 0
