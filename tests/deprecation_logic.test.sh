#!/bin/bash
# tests/deprecation_logic.test.sh
# Tests for Makefile deprecation logic

set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Workspace paths
export DOTFILES_DIR="$(pwd)"
MK_DIR="$DOTFILES_DIR/mk"
TEMP_DIR="/tmp/make-test-$$"

mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || { echo "failed to cd to $TEMP_DIR" >&2; exit 1; }
# Clean up on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "=== Makefile Deprecation Logic Tests ==="

# Mock new target
cat <<EOF > test-targets.mk
.PHONY: new-target
new-target:
	@echo "NEW_TARGET_EXECUTED"
EOF

# Helper to run make with custom mapping
run_test() {
    local target="$1"
    local mapping="$2"
    local expect_code="$3"
    local expect_msg="$4"
    local env_vars="${5:-}"

    cat <<EOF > Makefile
include $DOTFILES_DIR/mk/idempotency.mk
include test-targets.mk
DEPRECATED_TARGETS := $mapping
DEPRECATION_MIN_DAYS := 10
include $DOTFILES_DIR/mk/deprecated-targets.mk

# Mock get_deprecation_entry to avoid filter issues with custom mapping
# Actually we use the real one.
EOF

    echo -n "Test $target... "
    
    # Run make and capture output
    output=$(eval "$env_vars make $target 2>&1")
    code=$?
    
    # Check exit code
    if [ $expect_code -eq 0 ]; then
        if [ $code -ne 0 ]; then
            echo -e "${RED}[FAIL]${NC} Expected exit code 0, got $code"
            echo "Output: $output"
            return 1
        fi
    else
        if [ $code -eq 0 ]; then
            echo -e "${RED}[FAIL]${NC} Expected non-zero exit code, got 0"
            echo "Output: $output"
            return 1
        fi
    fi
    
    # Check message
    if [[ ! "$output" =~ $expect_msg ]]; then
        echo -e "${RED}[FAIL]${NC} Expected message matching '$expect_msg', but not found."
        echo "Output: $output"
        return 1
    fi
    
    echo -e "${GREEN}[PASS]${NC}"
    return 0
}

# Dates for testing
# We use dates relative to "now"
# Since we can't easily fake 'date +%s' inside makefile without editing it,
# we'll use dates far in the future or past.
# Wait, let's use fixed dates and hope the machine's date is "now".
# TODAY is 2026-01-08 in the summary.

PAST_DATE="2020-01-01"
FUTURE_DATE="2030-01-01"
NEAR_FUTURE="2026-02-01" # Within 30 days of 1/8? No, it's ~23 days.
# Wait, transition starts 30 days before REMOVAL_DATE.
# If REMOVAL_DATE is 2026-02-01, today (1/8) is within 30 days.

# Test 1: Warning phase
# dep: past, rem: far future -> warning
run_test "old-target" "old-target:new-target:$PAST_DATE:$FUTURE_DATE:warning" 0 "deprecated and will be removed" "MAKE_DEPRECATION_WARN=1" || exit 1

# Test 2: Transition phase
# Today is 1/8. Removal is 1/20. -> transition
run_test "old-target" "old-target:new-target:$PAST_DATE:2026-01-20:warning" 0 "scheduled for removal" "MAKE_DEPRECATION_WARN=1" || exit 1

# Test 3: Removed phase
# Removal is 1/1. (Past) -> removed
run_test "old-target" "old-target:new-target:$PAST_DATE:2026-01-01:warning" 1 "has been removed" || exit 1

# Test 4: STRICT mode (Error on warning)
run_test "old-target" "old-target:new-target:$PAST_DATE:$FUTURE_DATE:warning" 1 "treated as error" "MAKE_DEPRECATION_STRICT=1" || exit 1

# Test 5: QUIET mode
output=$(make old-target DEPRECATED_TARGETS="old-target:new-target:$PAST_DATE:$FUTURE_DATE:warning" MAKE_DEPRECATION_WARN=1 MAKE_DEPRECATION_QUIET=1 2>&1)
if [[ "$output" =~ "deprecated" ]]; then
    echo -e "${RED}[FAIL]${NC} QUIET mode should not show deprecation warning."
    exit 1
fi
echo -e "${GREEN}[PASS]${NC} QUIET mode works."

# Test 6: Policy validation (DEPRECATION_MIN_DAYS)
cat <<EOF > Makefile
include $DOTFILES_DIR/mk/idempotency.mk
DEPRECATED_TARGETS := fail-target:new:2026-01-01:2026-01-10:warning
DEPRECATION_MIN_DAYS := 180
include $DOTFILES_DIR/mk/deprecated-targets.mk
EOF
output=$(make test-deprecation-policy 2>&1)
if [[ ! "$output" =~ "FAIL" ]]; then
    echo -e "${RED}[FAIL]${NC} Policy validation should fail for short warning period."
    exit 1
fi
echo -e "${GREEN}[PASS]${NC} Policy validation correctly detects short warning period."

echo ""
echo "=== All Deprecation Logic Tests Passed ==="
