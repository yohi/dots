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
	@echo "No setup required for Codex CLI at the moment."


