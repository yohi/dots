#!/bin/bash
# AI Commit Message Generator Interface
# Provides a standardized interface for AI CLI tools
# Requirements: 5.2, 5.3, 6.1, 6.3, 8.2, 8.4

set -e
set -o pipefail  # Requirement 8.2: Catch pipeline failures

# Configuration
AI_TOOL="${AI_TOOL:-./mock-ai-tool.sh}"
TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-30}"

# Prompt structure for AI tools
# This prompt ensures Conventional Commits format and no Markdown
PROMPT='Staged changes are provided via stdin.
Generate 5 commit messages following Conventional Commits format.

Rules:
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
# Pass combined prompt + diff via stdin and capture output
AI_OUTPUT=""
if command -v timeout &> /dev/null; then
    # Use timeout command to prevent hanging
    set +e  # Temporarily disable exit on error to capture exit code
    AI_OUTPUT=$(echo "$COMBINED_INPUT" | timeout "$TIMEOUT_SECONDS" "$AI_TOOL" 2>&1)
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
            echo "Suggestion: Check AI tool configuration and try again" >&2
            exit 1
        fi
    fi
else
    # Fallback if timeout command is not available
    set +e  # Temporarily disable exit on error to capture exit code
    AI_OUTPUT=$(echo "$COMBINED_INPUT" | "$AI_TOOL" 2>&1)
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
