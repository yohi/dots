#!/bin/bash
# Regex Parser for AI Output
# Parses AI-generated commit messages and extracts clean text
# Requirements: 5.4

set -e
set -o pipefail

# Read AI output from stdin
AI_OUTPUT=$(cat)

# Check if input is empty
if [ -z "$AI_OUTPUT" ]; then
    echo "Error: No AI output provided" >&2
    exit 1
fi

# Parse AI output line by line
# This script demonstrates the regex patterns that will be used in config.yml
# 
# Patterns to handle:
# 1. Standard lines: any non-empty line
# 2. Numbered lists: "1. feat: message" -> "feat: message"
# 3. Empty lines: skip them
# 4. Whitespace-only lines: skip them

echo "$AI_OUTPUT" | while IFS= read -r line; do
    # Skip empty lines and whitespace-only lines
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
        continue
    fi
    
    # Remove numbered list prefix if present (e.g., "1. " or "2. ")
    # Pattern: ^\d+\.\s*(.+)$
    if [[ "$line" =~ ^[0-9]+\.[[:space:]]*(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        # Standard line - output as is
        echo "$line"
    fi
done

exit 0
