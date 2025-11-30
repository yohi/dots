#!/bin/bash
set -o pipefail

# Configure AI backend via environment variable
# Set AI_BACKEND to one of: gemini, claude, ollama, mock
# Default: gemini (requires gemini CLI or API key)
export AI_BACKEND="${AI_BACKEND:-gemini}"

# API key management via environment variables
# For Gemini: export GEMINI_API_KEY="your-key"
# For Claude: export ANTHROPIC_API_KEY="your-key"
# For Ollama: No API key needed (local)

# Optional configuration
export TIMEOUT_SECONDS="${TIMEOUT_SECONDS:-60}"
export GEMINI_MODEL="${GEMINI_MODEL:-gemini-2.5-flash}"
export CLAUDE_MODEL="${CLAUDE_MODEL:-claude-3-5-haiku-20241022}"
export OLLAMA_MODEL="${OLLAMA_MODEL:-mistral}"

# Check for staged changes
if git diff --cached --quiet; then
  echo "Error: No staged changes. Please stage files first."
  exit 1
fi

# Notify user of start (since loadingText might not be visible)
if command -v notify-send > /dev/null; then
  notify-send -t 5000 "Lazygit AI" "Generating commit message... 🤖"
fi

# Resolve script directory for calling sibling scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Complete pipeline: Get staged diff → Limit size → AI generation → Parse output
git diff --cached | head -c 3000 | "$SCRIPT_DIR/ai-commit-generator.sh" | "$SCRIPT_DIR/parse-ai-output.sh"
