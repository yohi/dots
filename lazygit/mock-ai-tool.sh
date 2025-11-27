#!/bin/bash
# Mock AI CLI tool for testing
# Simulates AI-generated commit messages based on diff input
# Requirements: 5.2, 5.3, 6.1, 6.3

set -e
set -o pipefail

# Read diff from stdin
DIFF_INPUT=$(cat)

# Check if input is empty
if [ -z "$DIFF_INPUT" ]; then
    echo "Error: No diff input provided" >&2
    exit 1
fi

# Analyze diff to generate contextual messages
# This is a simple heuristic-based approach for testing
HAS_NEW_FILE=$(echo "$DIFF_INPUT" | grep -c "^+++ b/" || true)
HAS_DELETED_FILE=$(echo "$DIFF_INPUT" | grep -c "^--- a/" || true)
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

if [ "$HAS_NEW_FILE" -gt 0 ]; then
    echo "feat: add new files and functionality"
fi

# Always provide some generic options
echo "feat: implement new feature based on changes"
echo "fix: resolve issues identified in code review"
echo "refactor: improve code structure and readability"

exit 0
