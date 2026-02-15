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

# Check if command matches 'git <subcommand> ...'
if [[ "$CMD" =~ ^git[[:space:]]+ ]]; then
    # Split command into array to extract subcommand
    read -r -a PARTS <<< "$CMD"
    # Subcommand is typically the second element
    SUBCOMMAND="${PARTS[1]}"

    case "$SUBCOMMAND" in
        push)
            # Block force push
            if [[ "$CMD" =~ --force ]] || [[ "$CMD" =~ [[:space:]]-f([[:space:]]|$) ]] || [[ "$CMD" =~ --force-with-lease ]]; then
                BEHAVIOR="ask"
            else
                BEHAVIOR="allow"
            fi
            ;;
        clean)
            # Always block clean
            BEHAVIOR="ask"
            ;;
        rebase)
            # Always block rebase
            BEHAVIOR="ask"
            ;;
        reset)
            # Block destructive reset
            if [[ "$CMD" =~ --hard ]] || [[ "$CMD" =~ --merge ]]; then
                BEHAVIOR="ask"
            else
                BEHAVIOR="allow"
            fi
            ;;
        *)
            # Allow all other git commands (checkout, commit, add, etc.)
            BEHAVIOR="allow"
            ;;
    esac
else
    # Non-git commands -> ask
    BEHAVIOR="ask"
fi

# Output result
echo "{\"behavior\": \"$BEHAVIOR\"}"
