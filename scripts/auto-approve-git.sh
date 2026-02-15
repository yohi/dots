#!/bin/bash
set -euo pipefail

# 必要なコマンドのチェック
if ! command -v jq &> /dev/null; then
    echo >&2 "エラー: jq コマンドが見つかりません。インストールしてください。"
    exit 1
fi

# Read input from stdin
# If stdin is empty, exit with error or default behavior
if [ -t 0 ]; then
    echo '{"behavior": "ask"}'
    exit 0
fi
INPUT=$(cat)

# Extract command using jq (default to "ask" on failure/empty)
CMD=$(echo "$INPUT" | jq -r '.command // "ask"' 2>/dev/null || echo "ask")

# Default behavior
BEHAVIOR="ask"

# Check if command matches 'git <subcommand> ...'
if [[ "$CMD" =~ ^git[[:space:]]+ ]]; then
    # Split command into array to extract subcommand
    read -r -a PARTS <<< "$CMD"
    # Subcommand is typically the second element
    if [[ ${#PARTS[@]} -gt 1 ]]; then
        SUBCOMMAND="${PARTS[1]}"
    else
        SUBCOMMAND=""
    fi

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
