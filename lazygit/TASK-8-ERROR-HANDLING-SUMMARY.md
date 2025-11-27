# Task 8: Error Handling Enhancement - Implementation Summary

## Overview
Task 8 focused on enhancing error handling throughout the LazyGit AI commit system to meet Requirements 8.2 and 8.4. The implementation adds robust error detection, timeout handling, and user-friendly error messages.

## Requirements Addressed

### Requirement 8.2: AI Execution Error Handling
**Acceptance Criteria**: "WHEN AIツールが不正な形式の出力を返す THEN LazyGitシステムはエラーメッセージを表示し、ユーザーが再試行またはキャンセルできるようにすること"

**Implementation**:
- Added `set -o pipefail` to all scripts to catch pipeline failures
- Implemented empty output detection in `ai-commit-generator.sh`
- Added malformed output detection in `parse-ai-output.sh`
- All error messages include helpful suggestions for users

### Requirement 8.4: Timeout Handling
**Acceptance Criteria**: "WHEN AIツールの実行がタイムアウトする THEN LazyGitシステムはタイムアウトメッセージを表示し、ユーザーに制御を返すこと"

**Implementation**:
- Implemented timeout using the `timeout` command with configurable duration
- Default timeout: 30 seconds (configurable via `TIMEOUT_SECONDS` environment variable)
- Specific timeout error detection (exit code 124)
- Timeout error messages include suggestions to reduce staged files or increase timeout

## Files Modified

### 1. ai-commit-generator.sh
**Changes**:
- Added `set -o pipefail` with comment referencing Requirement 8.2
- Enhanced timeout handling with proper exit code capture
- Added empty output validation
- Improved error messages with suggestions:
  - Timeout: "Try staging fewer files or increase TIMEOUT_SECONDS"
  - AI failure: "Check AI tool configuration and try again"
  - Empty output: "Check AI tool configuration or try different changes"

**Key Code**:
```bash
set -o pipefail  # Requirement 8.2: Catch pipeline failures

# Timeout handling (Requirement 8.4)
set +e  # Temporarily disable to capture exit code
AI_OUTPUT=$(echo "$COMBINED_INPUT" | timeout "$TIMEOUT_SECONDS" "$AI_TOOL" 2>&1)
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
    if [ $EXIT_CODE -eq 124 ]; then
        # Timeout occurred
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

# Validate output is not empty
if [ -z "$AI_OUTPUT" ]; then
    echo "Error: AI tool returned empty output" >&2
    echo "Suggestion: Check AI tool configuration or try different changes" >&2
    exit 1
fi
```

### 2. parse-ai-output.sh
**Changes**:
- Added `set -o pipefail` with comment referencing Requirement 8.2
- Added message count validation
- Detects when no valid messages are extracted from AI output
- Fixed arithmetic expansion to work with `set -e`

**Key Code**:
```bash
set -o pipefail  # Requirement 8.2: Catch pipeline failures

# Count valid messages
MESSAGE_COUNT=0

# ... parsing logic ...

# Validate at least one message was extracted
if [ $MESSAGE_COUNT -eq 0 ]; then
    echo "Error: No valid commit messages found in AI output" >&2
    echo "Suggestion: AI output may be malformed. Try again or check AI configuration" >&2
    exit 1
fi
```

### 3. config.yml
**Changes**:
- Added `set -o pipefail` to the menuFromCommand pipeline
- Updated requirements comments to include 8.2 and 8.4

**Key Code**:
```yaml
command: |
  set -o pipefail  # Requirement 8.2: Catch pipeline failures
  if git diff --cached --quiet; then
    echo "Error: No staged changes. Please stage files first."
    exit 1
  fi
  # Complete pipeline with enhanced error handling
  git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

## Test Coverage

### test-error-handling.sh
Comprehensive test suite covering:
1. ✓ pipefail is set in ai-commit-generator.sh
2. ✓ pipefail is set in parse-ai-output.sh
3. ✓ Timeout handling is implemented
4. ✓ Timeout error message is present
5. ✓ Empty output is detected and reported
6. ✓ AI tool failure is detected and reported
7. ✓ Empty input to parser is detected
8. ✓ Whitespace-only input is detected
9. ✓ Valid input is parsed correctly
10. ✓ Timeout is configurable (default 30s)
11. ✓ Error messages include suggestions
12. ✓ pipefail is set in config.yml

### test-timeout-handling.sh
Specific timeout tests:
1. ✓ Timeout with slow AI tool (2s timeout)
2. ✓ Timeout error message includes suggestion
3. ✓ Normal operation completes within timeout
4. ✓ Timeout is configurable via environment variable
5. ✓ Very short timeout (1s) is enforced correctly

### Integration Tests
- ✓ All existing integration tests still pass
- ✓ Error handling doesn't break normal workflow
- ✓ Pipeline failures are properly caught

## Error Handling Strategy

### Error Categories Handled

1. **Input Errors**
   - Empty staged changes (handled in config.yml)
   - Empty diff input (handled in ai-commit-generator.sh)

2. **AI Execution Errors**
   - AI tool failure (non-zero exit code)
   - AI tool timeout (exit code 124)
   - Empty AI output

3. **Parsing Errors**
   - Empty parser input
   - Whitespace-only input
   - No valid messages extracted

4. **Pipeline Errors**
   - Any command in pipeline fails (caught by pipefail)

### Error Message Format
All error messages follow this pattern:
```
Error: [Clear description of what went wrong]
Suggestion: [Actionable advice for the user]
```

Examples:
- "Error: AI tool timed out after 30 seconds"
  "Suggestion: Try staging fewer files or increase TIMEOUT_SECONDS"
- "Error: No valid commit messages found in AI output"
  "Suggestion: AI output may be malformed. Try again or check AI configuration"

## Configuration

### Environment Variables
- `TIMEOUT_SECONDS`: Configure AI tool timeout (default: 30)
- `AI_TOOL`: Specify AI CLI tool to use (default: ./mock-ai-tool.sh)

### Usage Examples

**Normal usage** (default 30s timeout):
```bash
# In LazyGit, press Ctrl+A
```

**Custom timeout**:
```bash
# Set before starting LazyGit
export TIMEOUT_SECONDS=60
lazygit
```

**Testing with short timeout**:
```bash
echo "test diff" | TIMEOUT_SECONDS=5 ./ai-commit-generator.sh
```

## Benefits

1. **Robustness**: Pipeline failures are caught immediately
2. **User Experience**: Clear error messages with actionable suggestions
3. **Configurability**: Timeout can be adjusted for different environments
4. **Debugging**: Specific error codes help identify issues
5. **Safety**: No silent failures - all errors are reported

## Verification

All tests pass:
```bash
./test-error-handling.sh      # 12/12 tests pass
./test-timeout-handling.sh    # 5/5 tests pass
./test-lazygit-commit-integration.sh  # 5/5 tests pass
```

## Next Steps

Task 8 is complete. The next tasks in the implementation plan are:
- Task 9: Integration with real AI CLI tools (Gemini, Claude, Ollama)
- Task 10: Integration testing and documentation
- Task 11: Final checkpoint - ensure all tests pass

## Technical Notes

### pipefail Behavior
`set -o pipefail` ensures that if any command in a pipeline fails, the entire pipeline returns a non-zero exit code. This is critical for catching errors in:
```bash
git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

Without pipefail, only the last command's exit code would be checked.

### Timeout Exit Codes
- Exit code 124: Timeout occurred
- Exit code 0: Success
- Other non-zero: Command failed for other reasons

### Arithmetic Expansion with set -e
Changed from `((MESSAGE_COUNT++))` to `MESSAGE_COUNT=$((MESSAGE_COUNT + 1))` because the former can trigger `set -e` when the result is 0.
