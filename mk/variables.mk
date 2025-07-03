# 変数定義
DOTFILES_DIR := $(shell pwd)
HOME_DIR := $(HOME)
CONFIG_DIR := $(HOME_DIR)/.config
USER := $(shell whoami)

# Git設定用変数（空の場合はスクリプト内でプロンプト表示）
GIT_USER_NAME := $(shell git config --global user.name 2>/dev/null || echo "")
EMAIL := $(shell git config --global user.email 2>/dev/null || echo "")

# PHONYターゲットの定義
.PHONY: all help system-setup install-homebrew install-apps install-deb install-flatpak \
        setup-vim setup-zsh setup-wezterm setup-vscode setup-cursor setup-git setup-docker setup-development setup-shortcuts \
        setup-gnome-extensions setup-gnome-tweaks backup-gnome-tweaks export-gnome-tweaks setup-all clean system-config clean-repos install-cursor install-wezterm install-fuse install-cica-fonts install-ibm-plex-fonts install-mysql-workbench \
        test-extensions extensions-status fix-extensions-schema setup-mozc setup-mozc-ut-dictionaries setup-mozc-ut-dictionaries-manual get-mozc-dict-checksum check-mozc-import-status
