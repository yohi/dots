#!/bin/bash
# Regex Parser for AI Output
# Parses AI-generated commit messages and converts newlines to literal '\n'
# This allows multi-line commit messages to be treated as a single item in Lazygit menu

set -e
set -o pipefail

# Read all input
INPUT=$(cat)

# Check if input is empty or whitespace only
if [[ -z "${INPUT//[[:space:]]/}" ]]; then
    echo "Error: No AI output provided" >&2
    echo "Suggestion: Try again or check AI configuration" >&2
    exit 1
fi

# Replace actual newlines with literal string "\n"
# using sed to read the whole stream and replace
echo "$INPUT" | sed ':a;N;$!ba;s/\n/\\n/g'