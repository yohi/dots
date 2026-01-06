# mk/deprecated-targets.mk

# ============================================================
# 責務: 旧ターゲット名→新ターゲット名へのエイリアス定義
#       + 廃止予定マッピング管理 + ガイダンス出力
# 
# 注意: 短縮エイリアス（i, s, h 等）は mk/shortcuts.mk で定義
# ============================================================

# ============================================================
# 廃止予定ターゲットマッピング
# フォーマット: OLD:NEW:DEPRECATION_DATE:REMOVAL_DATE:STATUS
# ============================================================
DEPRECATED_TARGETS := \
    install-homebrew:install-packages-homebrew:2026-02-01:2026-08-01:warning \
    install-apps:install-packages-apps:2026-02-01:2026-08-01:warning \
    install-deb:install-packages-deb:2026-02-01:2026-08-01:warning \
    install-flatpak:install-packages-flatpak:2026-02-01:2026-08-01:warning \
    install-fuse:install-packages-fuse:2026-02-01:2026-08-01:warning \
    install-wezterm:install-packages-wezterm:2026-02-01:2026-08-01:warning \
    install-cursor:install-packages-cursor:2026-02-01:2026-08-01:warning \
    install-claude-code:install-packages-claude-code:2026-02-01:2026-08-01:warning \
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
    setup-vscode-copilot:setup-config-vscode-copilot:2026-02-01:2026-08-01:warning \
    setup-cursor:setup-config-cursor:2026-02-01:2026-08-01:warning \
    setup-git:setup-config-git:2026-02-01:2026-08-01:warning \
    setup-docker:setup-config-docker:2026-02-01:2026-08-01:warning \
    setup-ime:setup-config-ime:2026-02-01:2026-08-01:warning \
    setup-claude:setup-config-claude:2026-02-01:2026-08-01:warning \
    setup-mcp-tools:setup-config-mcp-tools:2026-02-01:2026-08-01:warning \
    setup-lazygit:setup-config-lazygit:2026-02-01:2026-08-01:warning \
    setup-all:setup-config-all:2026-02-01:2026-08-01:warning

# ============================================================
# ヘルパー関数
# ============================================================
define get_new_target
$(word 2,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

define get_removal_date
$(word 4,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

define get_deprecation_status
$(word 5,$(subst :, ,$(filter $(1):%,$(DEPRECATED_TARGETS))))
endef

# ============================================================
# 廃止予定ターゲットガイダンス出力
# ============================================================
define deprecation_warning
	@if [ "$(MAKE_DEPRECATION_STRICT)" = "1" ]; then \
		echo "[DEPRECATED] Target '$(1)' is deprecated and treated as error (MAKE_DEPRECATION_STRICT=1)." >&2; \
		echo "             Use '$(2)' instead." >&2; \
		echo "             Migration: make $(2)" >&2; \
		exit 1; \
	fi
	@if [ "$(MAKE_DEPRECATION_WARN)" = "1" ] && [ "$(MAKE_DEPRECATION_QUIET)" != "1" ]; then \
		echo "[DEPRECATED] Target '$(1)' is deprecated and will be removed on $(3)." >&2; \
		echo "             Use '$(2)' instead." >&2; \
		echo "             Migration: make $(2)" >&2; \
	fi
endef

define deprecation_error
	@echo "[ERROR] Target '$(1)' has been removed as of $(3)." >&2
	@echo "        Use '$(2)' instead." >&2
	@echo "        Run: make $(2)" >&2
	@exit 1
endef

# ============================================================
# 旧名→新名エイリアス（本ファイルで集中管理）
# ============================================================
# 注: デフォルトでは警告なしでエイリアスとして動作（後方互換性優先）。
# - MAKE_DEPRECATION_WARN=1 で warning/transition のガイダンスを有効化
# - MAKE_DEPRECATION_STRICT=1 で warning/transition をエラー扱い（exit 1）

# パッケージインストール系
.PHONY: install-homebrew
install-homebrew: install-packages-homebrew
	$(call deprecation_warning,install-homebrew,install-packages-homebrew,2026-08-01)

.PHONY: install-apps
install-apps: install-packages-apps
	$(call deprecation_warning,install-apps,install-packages-apps,2026-08-01)

.PHONY: install-deb
install-deb: install-packages-deb
	$(call deprecation_warning,install-deb,install-packages-deb,2026-08-01)

.PHONY: install-flatpak
install-flatpak: install-packages-flatpak
	$(call deprecation_warning,install-flatpak,install-packages-flatpak,2026-08-01)

.PHONY: install-fuse
install-fuse: install-packages-fuse
	$(call deprecation_warning,install-fuse,install-packages-fuse,2026-08-01)

.PHONY: install-wezterm
install-wezterm: install-packages-wezterm
	$(call deprecation_warning,install-wezterm,install-packages-wezterm,2026-08-01)

.PHONY: install-cursor
install-cursor: install-packages-cursor
	$(call deprecation_warning,install-cursor,install-packages-cursor,2026-08-01)

.PHONY: install-claude-code
install-claude-code: install-packages-claude-code
	$(call deprecation_warning,install-claude-code,install-packages-claude-code,2026-08-01)

.PHONY: install-cica-fonts
install-cica-fonts: install-packages-cica-fonts
	$(call deprecation_warning,install-cica-fonts,install-packages-cica-fonts,2026-08-01)

.PHONY: install-mysql-workbench
install-mysql-workbench: install-packages-mysql-workbench
	$(call deprecation_warning,install-mysql-workbench,install-packages-mysql-workbench,2026-08-01)

.PHONY: install-chrome-beta
install-chrome-beta: install-packages-chrome-beta
	$(call deprecation_warning,install-chrome-beta,install-packages-chrome-beta,2026-08-01)

.PHONY: install-playwright
install-playwright: install-packages-playwright
	$(call deprecation_warning,install-playwright,install-packages-playwright,2026-08-01)

.PHONY: install-clipboard
install-clipboard: install-packages-clipboard
	$(call deprecation_warning,install-clipboard,install-packages-clipboard,2026-08-01)

.PHONY: install-gemini-cli
install-gemini-cli: install-packages-gemini-cli
	$(call deprecation_warning,install-gemini-cli,install-packages-gemini-cli,2026-08-01)

# 設定セットアップ系
.PHONY: setup-vim
setup-vim: setup-config-vim
	$(call deprecation_warning,setup-vim,setup-config-vim,2026-08-01)

.PHONY: setup-zsh
setup-zsh: setup-config-zsh
	$(call deprecation_warning,setup-zsh,setup-config-zsh,2026-08-01)

.PHONY: setup-wezterm
setup-wezterm: setup-config-wezterm
	$(call deprecation_warning,setup-wezterm,setup-config-wezterm,2026-08-01)

.PHONY: setup-vscode
setup-vscode: setup-config-vscode
	$(call deprecation_warning,setup-vscode,setup-config-vscode,2026-08-01)

.PHONY: setup-cursor
setup-cursor: setup-config-cursor
	$(call deprecation_warning,setup-cursor,setup-config-cursor,2026-08-01)

.PHONY: setup-git
setup-git: setup-config-git
	$(call deprecation_warning,setup-git,setup-config-git,2026-08-01)

.PHONY: setup-docker
setup-docker: setup-config-docker
	$(call deprecation_warning,setup-docker,setup-config-docker,2026-08-01)

.PHONY: setup-ime
setup-ime: setup-config-ime
	$(call deprecation_warning,setup-ime,setup-config-ime,2026-08-01)

.PHONY: setup-claude
setup-claude: setup-config-claude
	$(call deprecation_warning,setup-claude,setup-config-claude,2026-08-01)

.PHONY: setup-vscode-copilot
setup-vscode-copilot: setup-config-vscode-copilot
	$(call deprecation_warning,setup-vscode-copilot,setup-config-vscode-copilot,2026-08-01)

.PHONY: setup-mcp-tools
setup-mcp-tools: setup-config-mcp-tools
	$(call deprecation_warning,setup-mcp-tools,setup-config-mcp-tools,2026-08-01)

.PHONY: setup-lazygit
setup-lazygit: setup-config-lazygit
	$(call deprecation_warning,setup-lazygit,setup-config-lazygit,2026-08-01)

.PHONY: setup-all
setup-all: setup-config-all
	$(call deprecation_warning,setup-all,setup-config-all,2026-08-01)

# GNOME 系
.PHONY: gnome-settings
gnome-settings: setup-gnome-settings
	$(call deprecation_warning,gnome-settings,setup-gnome-settings,2026-08-01)

.PHONY: gnome-extensions
gnome-extensions: setup-gnome-extensions
	$(call deprecation_warning,gnome-extensions,setup-gnome-extensions,2026-08-01)

.PHONY: gnome-tweaks
gnome-tweaks: setup-gnome-tweaks
	$(call deprecation_warning,gnome-tweaks,setup-gnome-tweaks,2026-08-01)

.PHONY: setup-mozc
setup-mozc: setup-config-mozc
	$(call deprecation_warning,setup-mozc,setup-config-mozc,2026-08-01)

# AI 開発ツール系
.PHONY: claudecode
claudecode: superclaude-install
	$(call deprecation_warning,claudecode,superclaude-install,2026-08-01)

.PHONY: cc-sdd
cc-sdd: cc-sdd-install
	$(call deprecation_warning,cc-sdd,cc-sdd-install,2026-08-01)
