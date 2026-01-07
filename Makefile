# Ubuntu開発環境セットアップ用Makefile
# 更新日: 2024年3月版

# デフォルトターゲット
.DEFAULT_GOAL := help

# 分割されたMakefileをinclude
include mk/variables.mk
include mk/help.mk
include mk/help-short.mk
include mk/presets.mk
include mk/system.mk
include mk/fonts.mk
include mk/install.mk
include mk/setup.mk
include mk/gnome.mk
include mk/mozc.mk
include mk/extensions.mk
include mk/clipboard.mk
include mk/sticky-keys.mk
include mk/clean.mk
include mk/main.mk
include mk/stages.mk
include mk/menu.mk
include mk/shortcuts.mk
include mk/memory.mk
include mk/codex.mk
include mk/superclaude.mk
include mk/cc-sdd.mk

.PHONY: all
all: help

.PHONY: setup
setup: setup-gnome-tweaks setup-gnome-extensions system
# Run sticky-keys setup only when GNOME schema is available
	@if command -v gsettings >/dev/null 2>&1 && \
	gsettings list-schemas | grep -qx 'org.gnome.desktop.a11y.keyboard'; then \
	$(MAKE) setup-sticky-keys; \
else \
	echo "ℹ️  GNOME 環境が見つからないため sticky-keys セットアップをスキップしました"; \
fi

.PHONY: install
install: ## Install dotfiles only (without SuperCopilot)
	@bash install.sh

.PHONY: install-all
install-all: install vscode-supercopilot ## Install dotfiles and SuperCopilot

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
