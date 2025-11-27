# AI CLI Interface Documentation

## Overview

This document describes the AI CLI interface implementation for LazyGit commit message generation.

## Components

### 1. `ai-commit-generator.sh`

Main interface script that:
- Accepts git diff via stdin
- Applies standardized prompt structure
- Calls configured AI tool
- Handles timeouts and errors
- Returns formatted commit messages

**Prompt Delivery Mechanism:**
The script combines the PROMPT and DIFF via stdin piping. This approach:
- Sends both prompt and diff to the AI tool in a single stream
- Uses `---DIFF START---` and `---DIFF END---` markers to separate content
- Requires no temporary files (cleaner, no cleanup needed)
- Works seamlessly with pipes and process substitution
- Preserves timeout handling and environment variables

**Usage:**
```bash
git diff --cached | ./ai-commit-generator.sh
```

**Environment Variables:**
- `AI_TOOL`: Path to AI CLI tool (default: `./mock-ai-tool.sh`)
- `TIMEOUT_SECONDS`: Timeout in seconds (default: `30`)

### 2. `mock-ai-tool.sh`

Mock AI tool for testing that:
- Simulates AI-generated commit messages
- Analyzes diff content heuristically
- Returns Conventional Commits formatted messages
- No markdown, numbering, or decorations
- Handles combined prompt + diff input (extracts diff from markers)
- Backward compatible with plain diff input

**Usage:**
```bash
echo "diff content" | ./mock-ai-tool.sh
```

**Input Format:**
The tool accepts either:
1. Combined input with markers (from `ai-commit-generator.sh`)
2. Plain diff input (for direct testing)

## Prompt Structure

The AI CLI interface uses a standardized prompt that ensures:

1. **Conventional Commits Format**: `<type>(<scope>): <description>`
2. **Valid Types**: feat, fix, docs, style, refactor, test, chore
3. **No Markdown**: Pure text output only
4. **Character Limit**: Under 72 characters per message
5. **Multiple Candidates**: Generates 5 commit message options

### Example Prompt

```
Staged changes are provided via stdin.
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
```

## Pipeline Integration

The complete pipeline in `config.yml`:

```yaml
command: |
  if git diff --cached --quiet; then
    echo "Error: No staged changes. Please stage files first."
    exit 1
  fi
  git diff --cached | head -c 12000 | ./ai-commit-generator.sh
```

### Pipeline Flow

1. Check for staged changes
2. Get staged diff with `git diff --cached`
3. Limit size to 12KB with `head -c 12000`
4. Pass to AI CLI interface
5. Parse output with regex filter
6. Display in LazyGit menu

## Switching to Real AI Tools

To use a real AI tool instead of the mock:

### Option 1: Gemini CLI

```bash
export AI_TOOL="gemini-cli"
```

### Option 2: Claude CLI

```bash
export AI_TOOL="claude-cli"
```

### Option 3: Ollama

```bash
export AI_TOOL="ollama run mistral"
```

### Option 4: Custom Script

Create a wrapper script that formats the prompt for your AI tool:

```bash
#!/bin/bash
# custom-ai-wrapper.sh
DIFF=$(cat)
echo "$DIFF" | your-ai-tool --prompt "Generate commit messages..."
```

Then set:
```bash
export AI_TOOL="./custom-ai-wrapper.sh"
```

## Error Handling

The interface handles:

1. **Empty Input**: Returns error if no diff provided
2. **Timeout**: Kills AI process after 30 seconds (configurable)
3. **Tool Failure**: Captures and reports non-zero exit codes
4. **Invalid Output**: LazyGit shows "No items" if regex doesn't match

## Testing

Test the mock AI tool:
```bash
echo "test diff" | ./mock-ai-tool.sh
```

Test the complete interface:
```bash
echo "test diff" | ./ai-commit-generator.sh
```

Test with actual staged changes:
```bash
git diff --cached | ./ai-commit-generator.sh
```

## Requirements Validation

This implementation satisfies:

- **Requirement 5.2**: Diff piped to AI CLI tool via stdin
- **Requirement 5.3**: Prompt structure specifies output format
- **Requirement 6.1**: Conventional Commits format enforced
- **Requirement 6.3**: No markdown in output (pure text only)

## Next Steps

- Implement regex parser (Task 5)
- Integrate with menuFromCommand (Task 6)
- Add real AI tool integration (Task 9)
