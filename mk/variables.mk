# 変数定義
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
USER := $(shell whoami)

# Git設定用変数（空の場合はスクリプト内でプロンプト表示）
GIT_USER_NAME := $(shell git config --global user.name 2>/dev/null || echo "")
EMAIL := $(shell git config --global user.email 2>/dev/null || echo "")

# PHONYターゲットの定義
.PHONY: all help setup-system install-packages-homebrew install-packages-apps install-packages-deb install-packages-flatpak \
        setup-config-vim setup-config-zsh setup-config-wezterm setup-config-vscode setup-config-cursor setup-config-mcp-tools setup-config-git setup-config-docker setup-config-development setup-config-shortcuts setup-config-claude \
        setup-config-gnome-extensions setup-config-gnome-tweaks backup-config-gnome-tweaks export-config-gnome-tweaks fix-extensions-schema setup-config-all clean system-config clean-repos install-packages-cursor install-packages-wezterm install-packages-fuse install-packages-claude-code install-packages-claudia install-packages-superclaude install-packages-claude-ecosystem install-packages-cica-fonts install-packages-ibm-plex-fonts install-packages-mysql-workbench install-packages-chrome-beta \
        setup-config-mozc-ut-dictionaries setup-config-mozc-ut-dictionaries-manual get-mozc-dict-checksum check-mozc-import-status export-config-mozc-keymap \
        system-setup install-homebrew install-apps install-deb install-flatpak setup-vim setup-zsh setup-wezterm setup-vscode setup-cursor setup-mcp-tools setup-git setup-docker setup-development setup-shortcuts \
        setup-gnome-extensions setup-gnome-tweaks backup-gnome-tweaks export-gnome-tweaks setup-all install-cursor update-cursor stop-cursor check-cursor-version install-wezterm install-fuse install-claude-code install-claudia install-superclaude install-claude-ecosystem fix-superclaude install-cica-fonts install-mysql-workbench setup-claude \
        setup-mozc setup-mozc-ut-dictionaries setup-mozc-ut-dictionaries-manual \
        fonts-setup fonts-install fonts-install-nerd fonts-install-google fonts-install-japanese fonts-clean fonts-update fonts-list fonts-refresh fonts-debug fonts-backup fonts-configure \
        memory-status memory-clear-swap memory-clear-cache memory-optimize-chrome memory-optimize-swappiness memory-setup-monitoring memory-start-monitoring memory-stop-monitoring memory-optimize memory-optimize-auto memory-emergency-cleanup memory-help \
        install-gemini-cli install-packages-gemini-cli install-packages-ccusage install-ccusage
