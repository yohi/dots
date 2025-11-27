#!/bin/bash
# Script to retrieve staged git diff with error handling
# Requirements: 5.1, 2.4

set -e

# Check if there are any staged changes
if git diff --cached --quiet; then
    echo "Error: No staged changes detected" >&2
    echo "Suggestion: Use 'space' to stage files, then retry" >&2
    exit 1
fi

# Get the staged diff
git diff --cached

exit 0
