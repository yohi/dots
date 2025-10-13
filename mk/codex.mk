.PHONY: codex codex-install codex-update codex-setup

codex: codex-install codex-setup ## Install and setup Codex CLI

codex-install: ## Install Codex CLI using npm
	@echo "Uninstalling existing Codex CLI (if any)..."
	@npm uninstall -g @openai/codex 2>/dev/null || true
	@echo "Installing Codex CLI via npm..."
	@npm install -g @openai/codex

codex-update: ## Update Codex CLI using npm
	@echo "Updating Codex CLI via npm..."
	@npm update -g @openai/codex

codex-setup: ## Setup Codex CLI configuration
	@echo "Setting up Codex CLI configuration..."
	@mkdir -p $(DOTFILES_DIR)/codex
	@if [ ! -f "$(DOTFILES_DIR)/codex/config.toml" ]; then \
		echo "Creating default config file at $(DOTFILES_DIR)/codex/config.toml"; \
		cat <<'EOF' > $(DOTFILES_DIR)/codex/config.toml ; \
# OpenAI Codex CLI Configuration
#
# For more information on configuration options, see the official documentation.

# Set the default model to use for requests.
# model = "gpt-5"

# Set the approval mode. Options are: suggest, auto-edit, full-auto
# approval_policy = "on-request"

# You can also configure a different model provider, like Ollama
# model_provider = "ollama"
EOF
	fi
	@echo "Creating symbolic link: $(HOME_DIR)/.codex -> $(DOTFILES_DIR)/codex"
	@ln -sfn $(DOTFILES_DIR)/codex $(HOME_DIR)/.codex
	@echo "Codex CLI setup complete."


