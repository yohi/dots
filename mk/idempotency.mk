# Idempotency helpers (no parse-time side effects)

MARKER_DIR := $(or $(XDG_STATE_HOME),$(HOME)/.local/state)/dots
IDEMPOTENCY_SKIP_MSG = [SKIP] $(1) is already completed.
IDEMPOTENCY_FORCE_MSG = [FORCE] Re-running $(1).

define create_marker
mkdir -p "$(MARKER_DIR)" && chmod 700 "$(MARKER_DIR)" && echo "# Makefile Target Completion Marker" > "$(MARKER_DIR)/.done-$(1)" && echo "# Target: $(1)" >> "$(MARKER_DIR)/.done-$(1)" && echo "# Completed: $$(date -u +"%Y-%m-%dT%H:%M:%SZ")" >> "$(MARKER_DIR)/.done-$(1)" && echo "# Version: $(if $(strip $(2)),$(2),N/A)" >> "$(MARKER_DIR)/.done-$(1)"
endef

define check_marker
test -f "$(MARKER_DIR)/.done-$(1)"
endef

define check_min_version
current_ver=$$($(1) 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); if [ -z "$$current_ver" ]; then echo "[CHECK] $(2) is not installed."; exit 1; fi; python3 -c "import sys; req='$(3)'; cur='$$current_ver'; from packaging import version; result = version.parse(cur) >= version.parse(req); sys.exit(0 if result else 1)" 2>/dev/null && { echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; exit 0; } || python3 -c "import sys; req='$(3)'; cur='$$current_ver'; exec('try:\n rt=tuple(map(int,req.split(\".\")))\n ct=tuple(map(int,cur.split(\".\")))\n res=(ct>=rt)\n print(f\"[SKIP] $(2) {cur} >= {req} (satisfied)\" if res else f\"[UPDATE] $(2) {cur} < {req} (needs update)\")\n sys.exit(0 if res else 1)\nexcept Exception: print(f\"[ERROR] Non-numeric version segments in $(2): current={cur}, required={req}\"); sys.exit(1)')"
endef

define check_symlink
if [ -L "$(1)" ]; then actual=$$(python3 -c "import os; print(os.path.realpath('$(1)'))"); expected=$$(python3 -c "import os; print(os.path.realpath('$(2)'))"); if [ "$$actual" = "$$expected" ]; then echo "[SKIP] $(1) -> $(2) (already configured)"; exit 0; else echo "[UPDATE] $(1) points to $$actual, expected $(2)"; exit 1; fi; elif [ -e "$(1)" ]; then echo "[CONFLICT] $(1) exists but is not a symlink"; exit 1; else exit 1; fi
endef

define check_command
command -v $(1) >/dev/null 2>&1
endef

# ============================================================
# FORCE flag support
# ============================================================
ifdef FORCE
  SKIP_IDEMPOTENCY_CHECK := true
endif

# ============================================================
# Marker file cleanup targets
# ============================================================
.PHONY: clean-markers
clean-markers: ## 全てのマーカーファイルを削除（再セットアップを強制）
	@echo "[CLEAN] Removing all completion markers..."
	@rm -f "$(MARKER_DIR)"/.done-*
	@echo "[DONE] All markers removed. Next run will re-execute all targets."

.PHONY: clean-marker-%
clean-marker-%: ## 特定ターゲットのマーカーを削除
	@echo "[CLEAN] Removing marker for $*..."
	@rm -f "$(MARKER_DIR)/.done-$*"

# ============================================================
# Idempotency status check
# ============================================================
.PHONY: check-idempotency
check-idempotency: ## 各ターゲットの冪等性状態を表示
	@echo "=== Idempotency Status ==="
	@echo ""
	@echo "Marker Files ($(MARKER_DIR)):"
	@ls -la "$(MARKER_DIR)"/.done-* 2>/dev/null || echo "  (no markers found)"
	@echo ""
	@echo "Package Installation Status:"
	@command -v brew >/dev/null 2>&1 && echo "  [✓] Homebrew: $$(brew --version | head -1)" || echo "  [ ] Homebrew: not installed"
	@command -v node >/dev/null 2>&1 && echo "  [✓] Node.js: $$(node --version)" || echo "  [ ] Node.js: not installed"
	@command -v python3 >/dev/null 2>&1 && echo "  [✓] Python: $$(python3 --version)" || echo "  [ ] Python: not installed"
	@echo ""
	@echo "Config Symlinks Status:"
	@test -L "$(HOME)/.zshrc" && echo "  [✓] .zshrc -> $$(readlink $(HOME)/.zshrc)" || echo "  [ ] .zshrc: not a symlink"
	@test -L "$(HOME)/.vimrc" && echo "  [✓] .vimrc -> $$(readlink $(HOME)/.vimrc)" || echo "  [ ] .vimrc: not a symlink"
