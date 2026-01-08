# mk/test.mk
# Test targets for the Makefile automation system

# ============================================================
# Test configuration
# ============================================================
MOCK_BW_PATH := $(DOTFILES_DIR)/.devcontainer/mocks/bw

# ============================================================
# Mock tests (no authentication required)
# ============================================================

.PHONY: test-bw-mock
test-bw-mock: ## Run Bitwarden tests with mock (no authentication required)
	@echo "=========================================="
	@echo "Running Bitwarden Mock Tests"
	@echo "=========================================="
	@echo ""
	@# 1. Verify mock bw script exists
	@if [ ! -f "$(MOCK_BW_PATH)" ]; then \
		echo "[ERROR] Mock bw script not found: $(MOCK_BW_PATH)" >&2; \
		exit 1; \
	fi
	@echo "[TEST] Mock bw script exists: $(MOCK_BW_PATH)"
	@echo ""
	@# 2. Test unlocked state
	@echo "[TEST] Testing unlocked state..."
	@if BW_MOCK_STATE=unlocked "$(MOCK_BW_PATH)" status | jq -e '.status == "unlocked"' >/dev/null; then \
		echo "  [PASS] Mock bw simulates unlocked state"; \
	else \
		echo "  [FAIL] Mock bw failed to simulate unlocked state" >&2; \
		exit 1; \
	fi
	@echo ""
	@# 3. Test locked state
	@echo "[TEST] Testing locked state..."
	@if BW_MOCK_STATE=locked "$(MOCK_BW_PATH)" status | jq -e '.status == "locked"' >/dev/null; then \
		echo "  [PASS] Mock bw simulates locked state"; \
	else \
		echo "  [FAIL] Mock bw failed to simulate locked state" >&2; \
		exit 1; \
	fi
	@echo ""
	@# 4. Test unauthenticated state
	@echo "[TEST] Testing unauthenticated state..."
	@if BW_MOCK_STATE=unauthenticated "$(MOCK_BW_PATH)" status | jq -e '.status == "unauthenticated"' >/dev/null; then \
		echo "  [PASS] Mock bw simulates unauthenticated state"; \
	else \
		echo "  [FAIL] Mock bw failed to simulate unauthenticated state" >&2; \
		exit 1; \
	fi
	@echo ""
	@# 5. Test secret retrieval
	@echo "[TEST] Testing secret retrieval..."
	@if "$(MOCK_BW_PATH)" get item "github-token" | jq -e '.login.password' >/dev/null; then \
		echo "  [PASS] Mock bw can retrieve secrets"; \
	else \
		echo "  [FAIL] Mock bw failed to retrieve secrets" >&2; \
		exit 1; \
	fi
	@echo ""
	@# 6. Test unlock command
	@echo "[TEST] Testing unlock command..."
	@if "$(MOCK_BW_PATH)" unlock --raw | grep -q "mock-session-key"; then \
		echo "  [PASS] Mock bw unlock returns session key"; \
	else \
		echo "  [FAIL] Mock bw unlock failed" >&2; \
		exit 1; \
	fi
	@echo ""
	@echo "=========================================="
	@echo "All mock tests passed!"
	@echo "=========================================="

# ============================================================
# Integration tests (BW_SESSION required)
# ============================================================

.PHONY: test-bw-integration
test-bw-integration: ## Run Bitwarden integration tests (requires BW_SESSION)
	@echo "=========================================="
	@echo "Running Bitwarden Integration Tests"
	@echo "=========================================="
	@echo ""
	@# Check if BW_SESSION is set
	@if [ -z "$${BW_SESSION:-}" ]; then \
		echo "[ERROR] BW_SESSION is required for integration tests" >&2; \
		echo "        Set it with: export BW_SESSION=\$$(bw unlock --raw)" >&2; \
		echo "        Or: eval \$$(make bw-unlock WITH_BW=1)" >&2; \
		exit 1; \
	fi
	@echo "[INFO] BW_SESSION is set"
	@echo ""
	@# Check if bw is unlocked
	@echo "[TEST] Verifying Bitwarden session..."
	@if ! command -v bw >/dev/null 2>&1; then \
		echo "  [SKIP] Bitwarden CLI not installed, skipping integration tests"; \
		exit 0; \
	fi
	@status=$$(BW_SESSION="$$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error"); \
	if [ "$$status" = "unlocked" ]; then \
		echo "  [PASS] Bitwarden session is active"; \
	else \
		echo "  [FAIL] Bitwarden session is not unlocked (status: $$status)" >&2; \
		echo "        Re-unlock with: eval \$$(make bw-unlock WITH_BW=1)" >&2; \
		exit 1; \
	fi
	@echo ""
	@# Test bw-status target
	@echo "[TEST] Testing bw-status target..."
	@if $(MAKE) bw-status WITH_BW=1 >/dev/null 2>&1; then \
		echo "  [PASS] bw-status works with active session"; \
	else \
		echo "  [FAIL] bw-status failed" >&2; \
		exit 1; \
	fi
	@echo ""
	@echo "=========================================="
	@echo "Integration tests passed!"
	@echo "=========================================="
	@echo ""
	@echo "Note: Full integration tests require actual Bitwarden secrets."
	@echo "      Add more test cases as needed in mk/test.mk"

# ============================================================
# Composite test target
# ============================================================

.PHONY: test-unit
test-unit: ## Run unit tests (alias for backward compatibility)
	@echo "[INFO] Running unit tests..."
	@# Add unit test targets here when implemented
	@echo "[PASS] No unit tests defined yet"

.PHONY: test
test: test-unit test-bw-mock ## Run all tests (unit + mock)
	@echo ""
	@echo "=========================================="
	@echo "All tests completed successfully!"
	@echo "=========================================="
	@echo ""
	@echo "To run integration tests with real Bitwarden:"
	@echo "  make test-bw-integration WITH_BW=1"
