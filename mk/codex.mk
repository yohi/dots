.PHONY: codex codex-install codex-update codex-setup

codex: codex-install codex-setup ## Install and setup Codex CLI

codex-install: ## Install Codex CLI using npm
	@echo "Uninstalling existing Codex CLI (if any)..."
	@if command -v brew &> /dev/null; then \
		brew uninstall codex 2>/dev/null || true; \
	fi
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
		echo '# OpenAI Codex CLI Configuration\n#\n# For more information on configuration options, see the official documentation.\n\n# Set the default model to use for requests.\n# model = "gpt-5"\n\n# Set the approval mode. Options are: suggest, auto-edit, full-auto\n# approval_policy = "on-request"\n\n# You can also configure a different model provider, like Ollama\n# model_provider = "ollama"\n' > $(DOTFILES_DIR)/codex/config.toml; \
	fi
	@echo "Creating symbolic link: $(HOME_DIR)/.codex -> $(DOTFILES_DIR)/codex"
	@ln -sfn $(DOTFILES_DIR)/codex $(HOME_DIR)/.codex
	@echo "Codex CLI setup complete."


