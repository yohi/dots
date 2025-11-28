#!/bin/bash
# Regex Parser for AI Output
# Parses AI-generated commit messages and extracts clean text
# Requirements: 5.4, 8.2

set -e
set -o pipefail  # Requirement 8.2: Catch pipeline failures

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

# Count valid messages extracted
MESSAGE_COUNT=0

# Temporary storage for parsed messages
PARSED_OUTPUT=""

while IFS= read -r line; do
    # Skip empty lines and whitespace-only lines
    if [[ -z "$line" || "$line" =~ ^[[:space:]]*$ ]]; then
        continue
    fi
    
    # Remove numbered list prefix if present (e.g., "1. " or "2. ")
    # Pattern: ^\d+\.\s*(.+)$
    if [[ "$line" =~ ^[0-9]+\.[[:space:]]*(.+)$ ]]; then
        PARSED_OUTPUT="${PARSED_OUTPUT}${BASH_REMATCH[1]}"$'\n'
        MESSAGE_COUNT=$((MESSAGE_COUNT + 1))
    else
        # Standard line - output as is
        PARSED_OUTPUT="${PARSED_OUTPUT}${line}"$'\n'
        MESSAGE_COUNT=$((MESSAGE_COUNT + 1))
    fi
done <<< "$AI_OUTPUT"

# Validate that we extracted at least one message (Requirement 8.2)
if [ $MESSAGE_COUNT -eq 0 ]; then
    echo "Error: No valid commit messages found in AI output" >&2
    echo "Suggestion: AI output may be malformed. Try again or check AI configuration" >&2
    exit 1
fi

# Output the parsed messages
echo -n "$PARSED_OUTPUT"

exit 0
