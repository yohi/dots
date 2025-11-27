# Testing Guide

This document describes how to test the LazyGit AI Commit Message Generator to ensure it's working correctly.

## Quick Test

Run the complete test suite to verify everything works:

```bash
./test-complete-workflow.sh
```

This will run 23 integration tests covering all aspects of the system.

## Test Suite Overview

### Complete Workflow Test (`test-complete-workflow.sh`)

Comprehensive integration test that validates the entire system end-to-end.

**What it tests**:
1. Complete happy path workflow (diff → AI → commit)
2. Special character handling and escaping
3. Empty staging area detection
4. Large diff truncation (12KB limit)
5. Conventional Commits format compliance
6. Markdown removal from messages
7. Timeout handling
8. Error recovery
9. Multiple backend support
10. UI update verification
11. Cancellation scenario
12. Parser robustness

**Expected result**: All 23 tests should pass

**Run it**:
```bash
./test-complete-workflow.sh
```

### Error Scenario Tests (`test-all-error-scenarios.sh`)

Tests all error handling paths to ensure the system fails gracefully.

**What it tests**:
- Empty diff input handling
- AI tool empty output detection
- AI tool failure handling
- Timeout detection
- Parser empty input handling
- Parser whitespace-only input handling
- Pipeline failure propagation
- Valid input produces valid output
- Error messages include suggestions
- Timeout configurability

**Run it**:
```bash
./test-all-error-scenarios.sh
```

### Component Tests

Individual component tests for specific functionality:

#### Commit Integration Test (`test-lazygit-commit-integration.sh`)

Tests the complete pipeline from menuFromCommand to commit execution.

**Run it**:
```bash
./test-lazygit-commit-integration.sh
```

#### Regex Parser Test (`test-regex-parser.sh`)

Tests the parsing of AI output into individual commit messages.

**Run it**:
```bash
./test-regex-parser.sh
```

#### Error Handling Test (`test-error-handling.sh`)

Tests error detection and reporting.

**Run it**:
```bash
./test-error-handling.sh
```

#### Timeout Handling Test (`test-timeout-handling.sh`)

Tests timeout functionality.

**Run it**:
```bash
./test-timeout-handling.sh
```

#### AI Backend Integration Test (`test-ai-backend-integration.sh`)

Tests integration with different AI backends.

**Run it**:
```bash
./test-ai-backend-integration.sh
```

## Manual Testing

### Test with Mock Backend

The mock backend requires no API keys and is perfect for testing:

```bash
# Set backend to mock
export AI_BACKEND=mock

# Create a test repository
mkdir ~/test-ai-commit
cd ~/test-ai-commit
git init

# Make some changes
echo "function hello() { return 'world'; }" > test.js
git add test.js

# Test the pipeline manually
git diff --cached | ./ai-commit-generator.sh | ./parse-ai-output.sh

# Or test in LazyGit
lazygit
# Press Ctrl+A to see AI-generated messages
```

### Test with Real AI Backend

Once you have API keys configured:

```bash
# For Gemini
export AI_BACKEND=gemini
export GEMINI_API_KEY="your-key"

# For Claude
export AI_BACKEND=claude
export ANTHROPIC_API_KEY="your-key"

# For Ollama (ensure it's running)
export AI_BACKEND=ollama
ollama serve  # In another terminal

# Test the pipeline
cd your-project
git add some-file.js
git diff --cached | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

### Test in LazyGit

The ultimate test is using it in LazyGit:

```bash
# 1. Make changes in a real project
cd your-project
vim some-file.js

# 2. Open LazyGit
lazygit

# 3. Stage files (press space)

# 4. Press Ctrl+A to generate messages

# 5. Verify:
#    - Loading message appears
#    - Menu shows 5+ messages
#    - Messages follow Conventional Commits format
#    - No markdown formatting
#    - Messages are relevant to your changes

# 6. Select a message and press Enter

# 7. Verify commit was created:
git log -1
```

## Testing Checklist

Use this checklist to verify a complete installation:

### Installation Tests

- [ ] Scripts are executable (`ls -l *.sh` shows `-rwxr-xr-x`)
- [ ] AI backend is installed and accessible
- [ ] API keys are set (for cloud backends)
- [ ] Environment variables are configured
- [ ] LazyGit config.yml has correct absolute paths
- [ ] LazyGit config.yml syntax is valid

### Functional Tests

- [ ] Mock backend works: `echo "test" | AI_BACKEND=mock ./ai-commit-generator.sh`
- [ ] Parser works: `echo "feat: test" | ./parse-ai-output.sh`
- [ ] Complete pipeline works: `git diff --cached | ./ai-commit-generator.sh | ./parse-ai-output.sh`
- [ ] LazyGit shows Ctrl+A option in files view
- [ ] Pressing Ctrl+A shows loading message
- [ ] Menu appears with multiple messages
- [ ] Messages follow Conventional Commits format
- [ ] Selecting a message creates a commit
- [ ] Commit message is preserved correctly
- [ ] Special characters are handled (test with quotes, backticks)

### Error Handling Tests

- [ ] Empty staging area shows error
- [ ] AI failure shows error message
- [ ] Timeout shows error message (if applicable)
- [ ] Invalid output is handled gracefully
- [ ] Pressing Esc cancels without committing

### Quality Tests

- [ ] Messages are relevant to changes
- [ ] Messages follow Conventional Commits format
- [ ] No markdown formatting in messages
- [ ] Messages are concise (under 72 characters)
- [ ] Multiple candidates are provided

## Troubleshooting Test Failures

### "AI tool failed with exit code 127"

**Cause**: Script not found or not executable

**Fix**:
```bash
chmod +x *.sh
ls -l mock-ai-tool.sh  # Should show -rwxr-xr-x
```

### "No such file or directory"

**Cause**: Relative paths not working from test directory

**Fix**: The scripts now use absolute paths. Ensure you're running from the correct directory.

### "Timeout not detected"

**Cause**: `timeout` command not available on your system

**Fix**: This is acceptable - the test will pass with a note. The timeout feature requires the `timeout` command (usually available on Linux).

### "Some messages don't follow format"

**Cause**: Mock AI tool not generating proper format

**Fix**: Check that `mock-ai-tool.sh` is the correct version and executable.

### Tests pass but LazyGit doesn't work

**Cause**: LazyGit config.yml has incorrect paths

**Fix**:
1. Edit `~/.config/lazygit/config.yml`
2. Replace `./ai-commit-generator.sh` with full absolute path
3. Replace `./parse-ai-output.sh` with full absolute path
4. Restart LazyGit

## Continuous Integration

To run tests in CI/CD:

```bash
#!/bin/bash
# CI test script

set -e

# Use mock backend (no API keys needed)
export AI_BACKEND=mock

# Run all tests
./test-complete-workflow.sh
./test-all-error-scenarios.sh

echo "All tests passed!"
```

## Performance Testing

Test with different diff sizes:

```bash
# Small diff (< 1KB)
echo "small change" > test.txt
git add test.txt
time git diff --cached | ./ai-commit-generator.sh

# Medium diff (5-10KB)
cat large-file.js > test.js
git add test.js
time git diff --cached | ./ai-commit-generator.sh

# Large diff (> 12KB, will be truncated)
dd if=/dev/zero of=large.bin bs=1024 count=20
git add large.bin
time git diff --cached | head -c 12000 | ./ai-commit-generator.sh
```

## Backend-Specific Testing

### Test Gemini

```bash
export AI_BACKEND=gemini
export GEMINI_API_KEY="your-key"

# Test API connection
python3 -c "
import google.generativeai as genai
import os
genai.configure(api_key=os.environ['GEMINI_API_KEY'])
print('Gemini API key is valid')
"

# Test message generation
echo "test change" | ./ai-commit-generator.sh
```

### Test Claude

```bash
export AI_BACKEND=claude
export ANTHROPIC_API_KEY="your-key"

# Test CLI installation
claude --version

# Test message generation
echo "test change" | ./ai-commit-generator.sh
```

### Test Ollama

```bash
export AI_BACKEND=ollama

# Test Ollama is running
curl http://localhost:11434/api/tags

# Test model is available
ollama list | grep mistral

# Test message generation
echo "test change" | ./ai-commit-generator.sh
```

## Test Coverage

The test suite covers:

- ✅ Requirements 1.1, 1.2 - LazyGit integration
- ✅ Requirements 2.1, 2.2, 2.3, 2.4 - Multiple candidates and menu
- ✅ Requirements 3.1, 3.2, 3.3, 3.4 - User selection and confirmation
- ✅ Requirements 4.1, 4.2, 4.3 - Commit execution and escaping
- ✅ Requirements 5.1, 5.2, 5.3, 5.4 - Diff processing and parsing
- ✅ Requirements 6.1, 6.3 - Conventional Commits format
- ✅ Requirements 7.1, 7.2, 7.3 - Configurable AI backends
- ✅ Requirements 8.1, 8.2, 8.3, 8.4 - Error handling and edge cases
- ✅ Requirements 9.1, 9.2, 9.3 - Keyboard shortcuts

## Reporting Issues

If tests fail, gather this information:

```bash
# System information
uname -a
bash --version
git --version
lazygit --version

# Environment
env | grep -E 'AI_|GEMINI|ANTHROPIC|OLLAMA'

# Test output
./test-complete-workflow.sh > test-output.log 2>&1

# Script permissions
ls -la *.sh

# LazyGit config
cat ~/.config/lazygit/config.yml
```

Include this information when reporting issues.

## Success Criteria

A successful test run should show:

```
==========================================
Test Summary
==========================================

Total Tests: 23
Passed: 23
Failed: 0

✓ All integration tests passed!

The LazyGit AI Commit system is working correctly.
You can now use it with confidence in your workflow.
```

If you see this, your installation is complete and working correctly!
