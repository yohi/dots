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
current_ver=$$($(1) 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); if [ -z "$$current_ver" ]; then echo "[CHECK] $(2) is not installed."; exit 1; fi; python3 -c "import sys; req='$(3)'; cur='$$current_ver'; from packaging import version; result = version.parse(cur) >= version.parse(req)" 2>/dev/null && { echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; exit 0; } || python3 -c "req='$(3)'; cur='$$current_ver'; req_t=tuple(map(int,req.split('.'))); cur_t=tuple(map(int,cur.split('.'))); sys.exit(0 if cur_t >= req_t else 1)" && { echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; exit 0; } || { echo "[UPDATE] $(2) $$current_ver < $(3) (needs update)"; exit 1; }
endef

define check_symlink
if [ -L "$(1)" ]; then actual=$$(python3 -c "import os; print(os.path.realpath('$(1)'))"); expected=$$(python3 -c "import os; print(os.path.realpath('$(2)'))"); if [ "$$actual" = "$$expected" ]; then echo "[SKIP] $(1) -> $(2) (already configured)"; exit 0; else echo "[UPDATE] $(1) points to $$actual, expected $(2)"; exit 1; fi; elif [ -e "$(1)" ]; then echo "[CONFLICT] $(1) exists but is not a symlink"; exit 1; else exit 1; fi
endef

define check_command
command -v $(1) >/dev/null 2>&1
endef
