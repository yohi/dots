# Deprecated target compatibility aliases

# Mapping format: OLD:NEW:DEPRECATION_DATE:REMOVAL_DATE:STATUS
# STATUS can be 'warning', 'transition', or 'removed'.
# Transition phase automatically starts 30 days before REMOVAL_DATE.
DEPRECATED_TARGETS ?= \
	install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
	install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
	install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
	install-flatpak:install-packages-flatpak:2026-02-01:2026-08-01:warning \
	install-fuse:install-packages-fuse:2026-02-01:2026-08-01:warning \
	install-wezterm:install-packages-wezterm:2026-02-01:2026-08-01:warning \
	install-cursor:install-packages-cursor:2026-02-01:2026-08-01:warning \
	install-claude-code:install-packages-claude-code:2026-02-01:2026-08-01:warning \
	install-superclaude:install-packages-superclaude:2026-02-01:2026-08-01:warning \
	install-claudia:install-packages-claudia:2026-02-01:2026-08-01:warning \
	install-cica-fonts:install-packages-cica-fonts:2026-02-01:2026-08-01:warning \
	install-mysql-workbench:install-packages-mysql-workbench:2026-02-01:2026-08-01:warning \
	install-chrome-beta:install-packages-chrome-beta:2026-02-01:2026-08-01:warning \
	install-playwright:install-packages-playwright:2026-02-01:2026-08-01:warning \
	install-clipboard:install-packages-clipboard:2026-02-01:2026-08-01:warning \
	install-gemini-cli:install-packages-gemini-cli:2026-02-01:2026-08-01:warning \
	setup-vim:setup-config-vim:2026-02-01:2026-08-01:warning \
	setup-zsh:setup-config-zsh:2026-02-01:2026-08-01:warning \
	setup-wezterm:setup-config-wezterm:2026-02-01:2026-08-01:warning \
	setup-vscode:setup-config-vscode:2026-02-01:2026-08-01:warning \
	setup-cursor:setup-config-cursor:2026-02-01:2026-08-01:warning \
	setup-git:setup-config-git:2026-02-01:2026-08-01:warning \
	setup-docker:setup-config-docker:2026-02-01:2026-08-01:warning \
	setup-ime:setup-config-ime:2026-02-01:2026-08-01:warning \
	setup-claude-code:setup-config-claude-code:2026-02-01:2026-08-01:warning \
	setup-secrets:setup-config-secrets:2026-02-01:2026-08-01:warning \
	setup-all:setup-config-all:2026-02-01:2026-08-01:warning

DEPRECATION_MIN_DAYS ?= 180

# Helper to get entry
define get_deprecation_entry
$(filter $(1):%,$(DEPRECATED_TARGETS))
endef

# Helper functions to extract fields
define get_new_target
$(word 2,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

define get_deprecation_date
$(word 3,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

define get_removal_date
$(word 4,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

define get_status
$(word 5,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

# Deprecated target guard template
define _deprecated_target_rule
$(if $(call get_deprecation_entry,$(1)),,$(error Deprecated target '$(1)' is not mapped.))
.PHONY: $(1) _deprecated_guard_$(1)
$(1): _deprecated_guard_$(1) .WAIT $(call get_new_target,$(1))

_deprecated_guard_$(1):
	@old="$(1)"; \
	new="$(call get_new_target,$(1))"; \
	dep_date="$(call get_deprecation_date,$(1))"; \
	rem_date="$(call get_removal_date,$(1))"; \
	status="$(call get_status,$(1))"; \
	if [ -z "$$$$new" ] || [ -z "$$$$dep_date" ] || [ -z "$$$$rem_date" ] || [ -z "$$$$status" ]; then \
		printf '%s\n' "[ERROR] Deprecated target mapping for '$$$$old' is invalid." >&2; \
		exit 2; \
	fi; \
	date_to_epoch() { \
		if command -v gdate >/dev/null 2>&1; then \
			gdate -d "$$$$1" +%s 2>/dev/null || echo; \
		elif date -d "$$$$1" +%s >/dev/null 2>&1; then \
			date -d "$$$$1" +%s; \
		elif date -j -f "%Y-%m-%d" "$$$$1" +%s >/dev/null 2>&1; then \
			date -j -f "%Y-%m-%d" "$$$$1" +%s; \
		else \
			echo; \
		fi; \
	}; \
	dep_epoch=$$$$(date_to_epoch "$$$$dep_date"); \
	rem_epoch=$$$$(date_to_epoch "$$$$rem_date"); \
	now_epoch=$$$$(date +%s); \
	if [ -z "$$$$dep_epoch" ] || [ -z "$$$$rem_epoch" ]; then \
		printf '%s\n' "[ERROR] Failed to parse deprecation dates for '$$$$old'." >&2; \
		exit 2; \
	fi; \
	\
	active_phase="none"; \
	if [ "$$$$now_epoch" -ge "$$$$rem_epoch" ] || [ "$$$$status" = "removed" ]; then \
		active_phase="removed"; \
	elif [ "$$$$now_epoch" -ge "$$$$((rem_epoch - 30*86400))" ] || [ "$$$$status" = "transition" ]; then \
		active_phase="transition"; \
	elif [ "$$$$now_epoch" -ge "$$$$dep_epoch" ] || [ "$$$$status" = "warning" ]; then \
		active_phase="warning"; \
	fi; \
	\
	case "$$$$active_phase" in \
		removed) \
			printf '%s\n' "[ERROR] Target '$$$$old' has been removed as of $$$$rem_date." >&2; \
			printf '%s\n' "        Use '$$$$new' instead." >&2; \
			printf '%s\n' "        Run: make $$$$new" >&2; \
			exit 1; \
			;; \
		transition) \
			if [ "$$$${MAKE_DEPRECATION_STRICT:-0}" = "1" ]; then \
				printf '%s\n' "[DEPRECATED] Target '$$$$old' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1)." >&2; \
				printf '%s\n' "             Use '$$$$new' instead." >&2; \
				printf '%s\n' "             Migration: make $$$$new" >&2; \
				exit 1; \
			fi; \
			if [ "$$$${MAKE_DEPRECATION_WARN:-0}" = "1" ] && [ "$$$${MAKE_DEPRECATION_QUIET:-0}" != "1" ]; then \
				printf '%s\n' "[DEPRECATED] Target '$$$$old' is deprecated and scheduled for removal on $$$$rem_date." >&2; \
				printf '%s\n' "             This target will be removed in the next major version." >&2; \
				printf '%s\n' "             Migrate now: make $$$$new" >&2; \
				printf '%s\n' "             Proceeding with legacy behavior..." >&2; \
			fi; \
			;; \
		warning) \
			if [ "$$$${MAKE_DEPRECATION_STRICT:-0}" = "1" ]; then \
				printf '%s\n' "[DEPRECATED] Target '$$$$old' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1)." >&2; \
				printf '%s\n' "             Use '$$$$new' instead." >&2; \
				printf '%s\n' "             Migration: make $$$$new" >&2; \
				exit 1; \
			fi; \
			if [ "$$$${MAKE_DEPRECATION_WARN:-0}" = "1" ] && [ "$$$${MAKE_DEPRECATION_QUIET:-0}" != "1" ]; then \
				printf '%s\n' "[DEPRECATED] Target '$$$$old' is deprecated and will be removed on $$$$rem_date." >&2; \
				printf '%s\n' "             Use '$$$$new' instead." >&2; \
				printf '%s\n' "             Migration: make $$$$new" >&2; \
			fi; \
			;; \
	esac
endef

# Rule generation
_DEPRECATED_OLD_TARGETS := $(foreach entry,$(DEPRECATED_TARGETS),$(word 1,$(subst :, ,$(entry))))
$(foreach t,$(_DEPRECATED_OLD_TARGETS),$(eval $(call _deprecated_target_rule,$(t))))

# Policy validation task
.PHONY: test-deprecation-policy
test-deprecation-policy: ## Validate all deprecated targets against timeline policies
	@echo "=== Deprecation Timeline Policy Tests ==="
	@date_to_epoch() { \
		if command -v gdate >/dev/null 2>&1; then \
			gdate -d "$$1" +%s 2>/dev/null || echo 0; \
		elif date -d "$$1" +%s >/dev/null 2>&1; then \
			date -d "$$1" +%s; \
		elif date -j -f "%Y-%m-%d" "$$1" +%s >/dev/null 2>&1; then \
			date -j -f "%Y-%m-%d" "$$1" +%s; \
		else \
			echo 0; \
		fi; \
	}; \
	echo "[TEST] TL-001: Minimum warning period validation..."; \
	failed=0; \
	for entry in $(DEPRECATED_TARGETS); do \
		old=$$(echo "$$entry" | cut -d: -f1); \
		dep_date=$$(echo "$$entry" | cut -d: -f3); \
		rem_date=$$(echo "$$entry" | cut -d: -f4); \
		dep_epoch=$$(date_to_epoch "$$dep_date"); \
		rem_epoch=$$(date_to_epoch "$$rem_date"); \
		if [ "$$dep_epoch" = "0" ] || [ "$$rem_epoch" = "0" ]; then \
			echo "[FAIL] $$old: Failed to parse deprecation dates (dep=$$dep_date, rem=$$rem_date)"; \
			failed=1; \
			continue; \
		fi; \
		diff_days=$$(( (rem_epoch - dep_epoch) / 86400 )); \
		if [ $$diff_days -lt $(DEPRECATION_MIN_DAYS) ]; then \
			echo "[FAIL] $$old: $$diff_days days < $(DEPRECATION_MIN_DAYS) required"; \
			failed=1; \
		else \
			echo "[PASS] $$old: $$diff_days days >= $(DEPRECATION_MIN_DAYS) required"; \
		fi; \
	done; \
	echo ""; \
	echo "[TEST] TL-002: Date format validation (ISO 8601)..."; \
	for entry in $(DEPRECATED_TARGETS); do \
		dep_date=$$(echo "$$entry" | cut -d: -f3); \
		rem_date=$$(echo "$$entry" | cut -d: -f4); \
		if ! echo "$$dep_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$'; then \
			echo "[FAIL] $$old: Invalid deprecation date format: $$dep_date"; \
			failed=1; \
		fi; \
		if ! echo "$$rem_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$'; then \
			echo "[FAIL] $$old: Invalid removal date format: $$rem_date"; \
			failed=1; \
		fi; \
	done; \
	if [ $$failed -eq 0 ]; then \
		echo "[PASS] All dates in ISO 8601 format"; \
		echo ""; \
		echo "=== All Policy Tests Passed ==="; \
	else \
		echo ""; \
		echo "=== Policy Tests FAILED ==="; \
		exit 2; \
	fi
