#!/bin/bash
# Test script for AI backend integration
# Tests all supported backends and verifies they work correctly
# Requirements: 7.1, 7.2, 7.3

set -e

echo "=== AI Backend Integration Test ==="
echo ""

# Test data
TEST_DIFF='diff --git a/test.txt b/test.txt
index 1234567..abcdefg 100644
--- a/test.txt
+++ b/test.txt
@@ -1,3 +1,4 @@
 line 1
 line 2
+line 3
 line 4'

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local backend="$2"
    local should_fail="${3:-false}"
    
    echo -n "Testing $test_name... "
    
    export AI_BACKEND="$backend"
    
    # Run the test
    set +e
    OUTPUT=$(echo "$TEST_DIFF" | ../../scripts/lazygit-ai-commit/ai-commit-generator.sh 2>&1)
    EXIT_CODE=$?
    set -e
    
    if [ "$should_fail" = "true" ]; then
        # Test should fail
        if [ $EXIT_CODE -ne 0 ]; then
            echo -e "${GREEN}PASS${NC} (correctly failed)"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            return 0
        else
            echo -e "${RED}FAIL${NC} (should have failed but didn't)"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    else
        # Test should succeed
        if [ $EXIT_CODE -eq 0 ]; then
            # Verify output has multiple lines
            LINE_COUNT=$(echo "$OUTPUT" | wc -l)
            if [ "$LINE_COUNT" -ge 2 ]; then
                echo -e "${GREEN}PASS${NC} ($LINE_COUNT messages generated)"
                TESTS_PASSED=$((TESTS_PASSED + 1))
                return 0
            else
                echo -e "${RED}FAIL${NC} (insufficient output: $LINE_COUNT lines)"
                echo "Output: $OUTPUT"
                TESTS_FAILED=$((TESTS_FAILED + 1))
                return 1
            fi
        else
            echo -e "${RED}FAIL${NC} (exit code: $EXIT_CODE)"
            echo "Output: $OUTPUT"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            return 1
        fi
    fi
}

# Test 1: Mock backend (should always work)
echo "--- Test 1: Mock Backend ---"
run_test "Mock backend" "mock"
echo ""

# Test 2: Invalid backend (should fail)
echo "--- Test 2: Invalid Backend ---"
run_test "Invalid backend" "invalid_backend" "true"
echo ""

# Test 3: Gemini backend (conditional)
echo "--- Test 3: Gemini Backend ---"
if [ -n "$GEMINI_API_KEY" ]; then
    if command -v python3 &> /dev/null; then
        if python3 -c "import google.generativeai" 2>/dev/null; then
            run_test "Gemini with API key" "gemini"
        else
            echo -e "${YELLOW}SKIP${NC} (google-generativeai not installed)"
            echo "Install with: pip install google-generativeai"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (python3 not found)"
    fi
else
    echo -e "${YELLOW}SKIP${NC} (GEMINI_API_KEY not set)"
    echo "Set with: export GEMINI_API_KEY='your-key'"
fi
echo ""

# Test 4: Claude backend (conditional)
echo "--- Test 4: Claude Backend ---"
if [ -n "$ANTHROPIC_API_KEY" ]; then
    if command -v claude &> /dev/null; then
        run_test "Claude with API key" "claude"
    else
        echo -e "${YELLOW}SKIP${NC} (claude CLI not installed)"
        echo "Install with: npm install -g @anthropic-ai/claude-cli"
    fi
else
    echo -e "${YELLOW}SKIP${NC} (ANTHROPIC_API_KEY not set)"
    echo "Set with: export ANTHROPIC_API_KEY='your-key'"
fi
echo ""

# Test 5: Ollama backend (conditional)
echo "--- Test 5: Ollama Backend ---"
if command -v ollama &> /dev/null; then
    # Check if Ollama is running
    if curl -s http://localhost:11434/api/tags &> /dev/null; then
        # Check if default model is available
        if ollama list | grep -q "mistral"; then
            run_test "Ollama with mistral model" "ollama"
        else
            echo -e "${YELLOW}SKIP${NC} (mistral model not installed)"
            echo "Install with: ollama pull mistral"
        fi
    else
        echo -e "${YELLOW}SKIP${NC} (Ollama service not running)"
        echo "Start with: ollama serve"
    fi
else
    echo -e "${YELLOW}SKIP${NC} (ollama not installed)"
    echo "Install from: https://ollama.com/install"
fi
echo ""

# Test 6: Gemini without API key (should fail)
echo "--- Test 6: Error Handling ---"
if command -v python3 &> /dev/null && python3 -c "import google.generativeai" 2>/dev/null; then
    SAVED_KEY="$GEMINI_API_KEY"
    unset GEMINI_API_KEY
    run_test "Gemini without API key" "gemini" "true"
    export GEMINI_API_KEY="$SAVED_KEY"
else
    echo -e "${YELLOW}SKIP${NC} (Gemini not available for testing)"
fi
echo ""

# Test 7: Timeout handling
echo "--- Test 7: Timeout Handling ---"
export TIMEOUT_SECONDS=1
run_test "Mock with short timeout" "mock"
unset TIMEOUT_SECONDS
echo ""

# Test 8: Empty input handling
echo "--- Test 8: Empty Input Handling ---"
echo -n "Testing empty input... "
set +e
OUTPUT=$(echo "" | ../../scripts/lazygit-ai-commit/ai-commit-generator.sh 2>&1)
EXIT_CODE=$?
set -e
if [ $EXIT_CODE -ne 0 ]; then
    echo -e "${GREEN}PASS${NC} (correctly rejected empty input)"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}FAIL${NC} (should have rejected empty input)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi
echo ""

# Summary
echo "=== Test Summary ==="
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
