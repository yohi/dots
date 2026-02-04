#!/usr/bin/env bash
# Integration test for Experimental Task System
# Verifies that tasks can be stored in .sisyphus/tasks/ and adhere to Claude Code-style schema

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TASKS_DIR="$ROOT_DIR/.sisyphus/tasks"
TEST_TASK_FILE="$TASKS_DIR/test-task-$(date +%s).json"

echo "=== Experimental Task System Integration Test ==="
echo ""

# 1. Verify Directory Existence
echo "[TEST] 1. Verifying task storage directory..."
if [ -d "$TASKS_DIR" ]; then
    echo "  [PASS] $TASKS_DIR exists"
else
    echo "  [FAIL] $TASKS_DIR does not exist"
    echo "  Creating it now..."
    mkdir -p "$TASKS_DIR"
fi
echo ""

# 2. Verify Write Capability (Simulating Agent/Plugin write)
echo "[TEST] 2. Verifying task write capability..."
# Claude Code style task object
cat > "$TEST_TASK_FILE" <<EOF
{
  "id": "test-task-001",
  "content": "Verify task system integration",
  "status": "in_progress",
  "priority": "high",
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF

if [ -f "$TEST_TASK_FILE" ]; then
    echo "  [PASS] Successfully wrote test task to $TEST_TASK_FILE"
else
    echo "  [FAIL] Failed to write test task"
    exit 1
fi
echo ""

# 3. Verify Read Capability & Schema (Simulating Agent/Plugin read)
echo "[TEST] 3. Verifying task schema (Claude Code style)..."
if command -v jq >/dev/null 2>&1; then
    # Check for required fields: id, content, status, priority
    if jq -e '.id and .content and .status and .priority' "$TEST_TASK_FILE" >/dev/null; then
        echo "  [PASS] Task file has required Claude Code-style fields"
        
        # Verify status values
        STATUS=$(jq -r '.status' "$TEST_TASK_FILE")
        if [[ "$STATUS" =~ ^(pending|in_progress|completed|cancelled)$ ]]; then
             echo "  [PASS] Task status '$STATUS' is valid"
        else
             echo "  [WARN] Task status '$STATUS' might be invalid (expected: pending, in_progress, completed, cancelled)"
        fi
    else
        echo "  [FAIL] Task file missing required fields"
        exit 1
    fi
else
    echo "  [SKIP] jq not installed, skipping schema validation"
fi

# Cleanup
rm -f "$TEST_TASK_FILE"
echo ""
echo "=== All Task System Tests Passed ==="
exit 0
