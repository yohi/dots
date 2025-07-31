# Ubuntu開発環境セットアップ用Makefile
# 更新日: 2024年3月版

# 分割されたMakefileをinclude
include mk/variables.mk
include mk/help.mk
include mk/system.mk
include mk/install.mk
include mk/setup.mk
include mk/gnome.mk
include mk/mozc.mk
include mk/extensions.mk
include mk/clean.mk
include mk/main.mk

.PHONY: all
all: help

.PHONY: setup
setup: gnome-settings gnome-extensions system ## Set up the system

.PHONY: install
install: ## Install dotfiles only (without SuperCopilot)
	@bash install.sh

.PHONY: install-all
install-all: install vscode-supercopilot ## Install dotfiles and SuperCopilot

.PHONY: clean
clean: ## Clean up temporary files and directories
	@rm -rf *.tmp
	@find . -name "*.tmp" -type f -delete

.PHONY: help
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST) | sort

.PHONY: vscode-supercopilot
vscode-supercopilot: ## Install SuperCopilot Framework for VSCode
	@echo "Installing SuperCopilot Framework for VSCode..."
	@bash vscode/setup-supercopilot.sh

.PHONY: gemini-cli
gemini-cli: ## Install Gemini CLI
	@echo "Installing Gemini CLI..."
	@$(MAKE) install-gemini-cli

.PHONY: supergemini
supergemini: ## Install SuperGemini Framework for Gemini CLI
	@echo "Installing SuperGemini Framework for Gemini CLI..."
	@$(MAKE) install-supergemini

.PHONY: gemini-ecosystem
gemini-ecosystem: ## Install complete Gemini ecosystem (CLI + SuperGemini)
	@echo "Installing complete Gemini ecosystem..."
	@$(MAKE) install-gemini-ecosystem

.PHONY: supercursor
supercursor: ## Install SuperCursor Framework for Cursor
	@echo "Installing SuperCursor Framework for Cursor..."
	@$(MAKE) install-supercursor
