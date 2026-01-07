# Deprecated target compatibility aliases

# Mapping format: OLD:NEW:DEPRECATION_DATE:REMOVAL_DATE:STATUS
DEPRECATED_TARGETS ?= \
	install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
	install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
	install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
	setup-vim:setup-config-vim:2026-02-01:2026-08-01:warning \
	setup-zsh:setup-config-zsh:2026-02-01:2026-08-01:warning \
	setup-git:setup-config-git:2026-02-01:2026-08-01:warning

DEPRECATION_MIN_DAYS ?= 180

define get_deprecation_entry
$(filter $(1):%,$(DEPRECATED_TARGETS))
endef

# Return the new target for a given deprecated target
define get_new_target
$(word 2,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

# Extract metadata fields from deprecated target entry
define get_deprecation_date
$(word 3,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

define get_removal_date
$(word 4,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

define get_status
$(word 5,$(subst :, ,$(call get_deprecation_entry,$(1))))
endef

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
	if ! printf '%s' "$$$$dep_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$$$'; then \
		printf '%s\n' "[ERROR] Invalid deprecation date format for '$$$$old': $$$$dep_date" >&2; \
		exit 2; \
	fi; \
	if ! printf '%s' "$$$$rem_date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$$$$'; then \
		printf '%s\n' "[ERROR] Invalid removal date format for '$$$$old': $$$$rem_date" >&2; \
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
	if [ -z "$$$$dep_epoch" ] || [ -z "$$$$rem_epoch" ]; then \
		printf '%s\n' "[ERROR] Failed to parse deprecation dates for '$$$$old'." >&2; \
		exit 2; \
	fi; \
	diff_days=$$$$(( (rem_epoch - dep_epoch) / 86400 )); \
	if [ $$$$diff_days -lt $(DEPRECATION_MIN_DAYS) ]; then \
		printf '%s\n' "[ERROR] $$$$old: $$$$dep_date -> $$$$rem_date ($$$$diff_days days, < $(DEPRECATION_MIN_DAYS) required)" >&2; \
		printf '%s\n' "        Minimum warning period is 6 months ($(DEPRECATION_MIN_DAYS) days)." >&2; \
		exit 2; \
	fi; \
	case "$$$$status" in \
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
		removed) \
			printf '%s\n' "[ERROR] Target '$$$$old' has been removed as of $$$$rem_date." >&2; \
			printf '%s\n' "        Use '$$$$new' instead." >&2; \
			printf '%s\n' "        Run: make $$$$new" >&2; \
			exit 1; \
			;; \
		*) \
			printf '%s\n' "[ERROR] Invalid deprecation status for '$$$$old': $$$$status" >&2; \
			exit 2; \
			;; \
	esac
endef

_DEPRECATED_OLD_TARGETS := $(foreach entry,$(DEPRECATED_TARGETS),$(word 1,$(subst :, ,$(entry))))
$(foreach t,$(_DEPRECATED_OLD_TARGETS),$(eval $(call _deprecated_target_rule,$(t))))
