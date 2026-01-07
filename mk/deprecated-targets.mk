# Deprecated target compatibility aliases

# Mapping format: OLD:NEW:DEPRECATION_DATE:REMOVAL_DATE:STATUS
DEPRECATED_TARGETS := \
	install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
	install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
	install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
	setup-vim:setup-config-vim:2026-02-01:2026-08-01:warning \
	setup-zsh:setup-config-zsh:2026-02-01:2026-08-01:warning \
	setup-git:setup-config-git:2026-02-01:2026-08-01:warning

# Return the new target for a given deprecated target
define get_new_target
$(word 2,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

# Generate an alias rule that forwards to the mapped new target
define _deprecated_target_rule
$(if $(call get_new_target,$(1)),,$(error Deprecated target '$(1)' is not mapped.))
.PHONY: $(1)
$(1): $(call get_new_target,$(1))
endef

_DEPRECATED_OLD_TARGETS := $(foreach entry,$(DEPRECATED_TARGETS),$(word 1,$(subst :, ,$(entry))))
$(foreach t,$(_DEPRECATED_OLD_TARGETS),$(eval $(call _deprecated_target_rule,$(t))))
