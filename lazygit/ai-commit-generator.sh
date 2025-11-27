#!/bin/bash
# AI Commit Message Generator Interface
# Provides a standardized interface for AI CLI tools
# Requirements: 5.2, 5.3, 6.1, 6.3

set -e
set -o pipefail

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

# Execute AI tool with timeout
# Pass diff via stdin and capture output
if command -v timeout &> /dev/null; then
    echo "$DIFF_INPUT" | timeout "$TIMEOUT_SECONDS" "$AI_TOOL" 2>&1
else
    # Fallback if timeout command is not available
    echo "$DIFF_INPUT" | "$AI_TOOL" 2>&1
fi

EXIT_CODE=$?

# Check for errors
if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: AI tool failed with exit code $EXIT_CODE" >&2
    exit 1
fi

exit 0
