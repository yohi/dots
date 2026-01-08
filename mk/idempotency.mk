# Idempotency helpers (no parse-time side effects)

MARKER_DIR := $(or $(XDG_STATE_HOME),$(HOME)/.local/state)/dots
IDEMPOTENCY_SKIP_MSG = [SKIP] $(1) is already completed.
IDEMPOTENCY_FORCE_MSG = [FORCE] Re-running $(1).

define create_marker
mkdir -p "$(MARKER_DIR)" && chmod 700 "$(MARKER_DIR)" && echo "# Makefile Target Completion Marker" > "$(MARKER_DIR)/.done-$(1)" && echo "# Target: $(1)" >> "$(MARKER_DIR)/.done-$(1)" && echo "# Completed: $$(date -Iseconds)" >> "$(MARKER_DIR)/.done-$(1)" && echo "# Version: $(if $(strip $(2)),$(2),N/A)" >> "$(MARKER_DIR)/.done-$(1)"
endef

define check_marker
test -f "$(MARKER_DIR)/.done-$(1)"
endef

define check_min_version
current_ver=$$($(1) 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1); if [ -z "$$current_ver" ]; then echo "[CHECK] $(2) is not installed."; exit 1; fi; if [ $$(printf '%s\n%s\n' "$(3)" "$$current_ver" | sort -V | head -n1) = "$(3)" ]; then echo "[SKIP] $(2) $$current_ver >= $(3) (satisfied)"; exit 0; else echo "[UPDATE] $(2) $$current_ver < $(3) (needs update)"; exit 1; fi
endef

define check_symlink
if [ -L "$(1)" ]; then actual=$$(readlink -f "$(1)"); expected=$$(readlink -f "$(2)"); if [ "$$actual" = "$$expected" ]; then echo "[SKIP] $(1) -> $(2) (already configured)"; exit 0; else echo "[UPDATE] $(1) points to $$actual, expected $(2)"; exit 1; fi; elif [ -e "$(1)" ]; then echo "[CONFLICT] $(1) exists but is not a symlink"; exit 1; else exit 1; fi
endef

define check_command
command -v $(1) >/dev/null 2>&1
endef
