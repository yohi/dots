#!/bin/bash
set -euo pipefail

# Read input from stdin
# If stdin is empty, exit with error or default behavior
if [ -t 0 ]; then
    echo '{"behavior": "ask"}'
    exit 0
fi
INPUT=$(cat)

# Extract command using jq
CMD=$(echo "$INPUT" | jq -r '.command // empty')

# Default behavior
BEHAVIOR="ask"

# Check if command is git
if [[ "$CMD" == git* ]]; then
    # Check for destructive commands
    if [[ "$CMD" == *"push --force"* ]] || \
       [[ "$CMD" == *"push -f"* ]] || \
       [[ "$CMD" == *"push --force-with-lease"* ]] || \
       [[ "$CMD" == *"clean"* ]] || \
       [[ "$CMD" == *"reset"* ]] || \
       [[ "$CMD" == *"rebase"* ]]; then
        BEHAVIOR="ask"
    else
        # Allow other git commands
        BEHAVIOR="allow"
    fi
else
    # Non-git commands -> ask
    BEHAVIOR="ask"
fi

# Output result
echo "{\"behavior\": \"$BEHAVIOR\"}"
