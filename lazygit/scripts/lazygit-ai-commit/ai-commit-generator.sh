#!/bin/bash
# AI Commit Message Generator Interface
# Provides a standardized interface for AI CLI tools
# Requirements: 5.2, 5.3, 6.1, 6.3, 7.1, 7.2, 7.3, 8.2, 8.4

set -e
set -o pipefail  # Requirement 8.2: Catch pipeline failures

# Configuration
# Requirement 7.1: Support for configurable AI CLI commands
AI_BACKEND="${AI_BACKEND:-mock}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"

# AI Backend Configuration
# Requirement 7.2: Execute configured command with diff as input
case "$AI_BACKEND" in
    gemini)
        # Gemini CLI
        # Uses the installed 'gemini' command which handles authentication
        AI_TOOL="gemini"
        
        # Note: We skip the explicit API key check here because the CLI 
        # manages credentials via oauth/config files.
        ;;
    claude)
        # Claude 3.5 Haiku - Excellent for code understanding
        CLAUDE_MODEL="${CLAUDE_MODEL:-claude-3-5-haiku-20241022}"
        if [ -z "$ANTHROPIC_API_KEY" ]; then
            echo "Error: ANTHROPIC_API_KEY environment variable not set" >&2
            echo "Suggestion: export ANTHROPIC_API_KEY='your-api-key'" >&2
            echo "Get your key from: https://console.anthropic.com/" >&2
            exit 1
        fi
        AI_TOOL="claude"
        ;;
    ollama)
        # Ollama - Local LLM, privacy-focused
        OLLAMA_MODEL="${OLLAMA_MODEL:-mistral}"
        OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
        AI_TOOL="ollama"
        ;;
    mock)
        # Mock tool for testing
        # Use absolute path based on script location
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        AI_TOOL="$SCRIPT_DIR/mock-ai-tool.sh"
        ;;
    *)
        echo "Error: Unknown AI_BACKEND '$AI_BACKEND'" >&2
        echo "Suggestion: Set AI_BACKEND to one of: gemini, claude, ollama, mock" >&2
        exit 1
        ;;
esac

# Prompt structure for AI tools
# This prompt ensures Conventional Commits format and no Markdown
PROMPT='Staged changes are provided via stdin.
Generate 1 commit message following Conventional Commits format.

Rules:
- DO NOT USE ANY TOOLS.
- DO NOT EDIT ANY FILES.
- No markdown, no code blocks, no decorations
- One message per line
- No numbering (e.g., "1. ")
- Concise and descriptive
- Pure text output only
- Format: <type>(<scope>): <description> OR <type>: <description>
- Valid types: feat, fix, docs, style, refactor, test, chore
- Keep under 72 characters
- Be specific about what changed

Example output format:
feat(auth): add JWT token validation
fix(db): correct connection timeout handling
docs(readme): update installation steps
refactor(api): simplify error handling logic
test(user): add unit tests for user model'

# Read diff from stdin
DIFF_INPUT=$(cat)

# Check if input is empty
if [ -z "$DIFF_INPUT" ]; then
    echo "Error: No diff input provided" >&2
    exit 1
fi

# Prompt delivery mechanism: Combine PROMPT and DIFF via stdin piping
# This approach is chosen because:
# 1. Most AI CLI tools accept full input via stdin
# 2. No temporary files needed (cleaner, no cleanup required)
# 3. Works well with pipes and process substitution
# 4. The mock AI tool can parse or ignore the prompt as needed
COMBINED_INPUT="${PROMPT}

---DIFF START---
${DIFF_INPUT}
---DIFF END---"

# Execute AI tool with timeout (Requirement 8.4)
# Requirement 7.2: Execute configured command with diff as input
# Requirement 7.3: Function without code changes when backend changes
AI_OUTPUT=""

# Build AI-specific command
case "$AI_BACKEND" in
    gemini)
        # Gemini CLI call
        # We use -p for prompt as positional arguments + stdin seems to cause 404s in some contexts
        # We also disable extensions to ensure a clean context
        # We filter out "Loaded cached credentials." from stderr to keep the output clean
        export PROMPT
        AI_COMMAND='gemini --extensions "" -p "$PROMPT" --model "$GEMINI_MODEL" 2>&1 | grep -v "Loaded cached credentials."'
        COMBINED_INPUT="$DIFF_INPUT"
        ;;
    claude)
        # Claude API call via official CLI
        AI_COMMAND="claude --model $CLAUDE_MODEL --no-stream"
        ;;
    ollama)
        # Ollama local API call
        AI_COMMAND="ollama run $OLLAMA_MODEL"
        ;;
    mock)
        # Mock tool for testing
        AI_COMMAND="$AI_TOOL"
        ;;
esac

if command -v timeout &> /dev/null; then
    # Use timeout command to prevent hanging
    set +e  # Temporarily disable exit on error to capture exit code
    AI_OUTPUT=$(echo "$COMBINED_INPUT" | timeout "$TIMEOUT_SECONDS" bash -c "$AI_COMMAND" 2>&1)
    EXIT_CODE=$?
    set -e  # Re-enable exit on error
    
    if [ $EXIT_CODE -ne 0 ]; then
        if [ $EXIT_CODE -eq 124 ]; then
            # Timeout occurred (exit code 124 from timeout command)
            echo "Error: AI tool timed out after ${TIMEOUT_SECONDS} seconds" >&2
            echo "Suggestion: Try staging fewer files or increase TIMEOUT_SECONDS" >&2
            exit 1
        else
            # Other error
            echo "Error: AI tool failed with exit code $EXIT_CODE" >&2
            echo "Details: $AI_OUTPUT" >&2
            if [ "$AI_BACKEND" = "gemini" ]; then
                echo "Suggestion: Check GEMINI_API_KEY and internet connection" >&2
            elif [ "$AI_BACKEND" = "claude" ]; then
                echo "Suggestion: Check ANTHROPIC_API_KEY and internet connection" >&2
            elif [ "$AI_BACKEND" = "ollama" ]; then
                echo "Suggestion: Ensure Ollama is running (ollama serve)" >&2
            else
                echo "Suggestion: Check AI tool configuration and try again" >&2
            fi
            exit 1
        fi
    fi
else
    # Fallback if timeout command is not available
    set +e  # Temporarily disable exit on error to capture exit code
    AI_OUTPUT=$(echo "$COMBINED_INPUT" | bash -c "$AI_COMMAND" 2>&1)
    EXIT_CODE=$?
    set -e  # Re-enable exit on error
    
    if [ $EXIT_CODE -ne 0 ]; then
        echo "Error: AI tool failed with exit code $EXIT_CODE" >&2
        echo "Suggestion: Check AI tool configuration and try again" >&2
        exit 1
    fi
fi

# Validate AI output is not empty (Requirement 8.2)
if [ -z "$AI_OUTPUT" ]; then
    echo "Error: AI tool returned empty output" >&2
    echo "Suggestion: Check AI tool configuration or try different changes" >&2
    exit 1
fi

# Output the result
echo "$AI_OUTPUT"

exit 0
