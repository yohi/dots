# 統合ターゲットとその他のターゲット

# 全体のセットアップ
setup-all:
	@echo "🚀 全体のセットアップを開始中..."
	@echo "ℹ️  以下の順序で実行します:"
	@echo "   1. システムセットアップ"
	@echo "   2. Homebrewインストール"
	@echo "   3. アプリケーションインストール"
	@echo "   4. Claude Codeエコシステムインストール"
	@echo "   5. 設定セットアップ"
	@echo "   6. 拡張機能インストール"
	@echo ""

	# 各セットアップを順次実行
	@echo "📋 1. システムセットアップ実行中..."
	@$(MAKE) system-setup
	@echo ""

	@echo "📋 2. Homebrewインストール実行中..."
	@$(MAKE) install-homebrew
	@echo ""

	@echo "📋 3. アプリケーションインストール実行中..."
	@$(MAKE) install-apps
	@echo ""

	@echo "📋 4. Claude Codeエコシステムインストール実行中..."
	@$(MAKE) install-claude-ecosystem
	@echo ""

	@echo "📋 5. 設定セットアップ実行中..."
	@$(MAKE) setup-vim
	@$(MAKE) setup-zsh
	@$(MAKE) setup-git
	@$(MAKE) setup-wezterm
	@$(MAKE) setup-vscode
	@$(MAKE) setup-cursor
	@$(MAKE) setup-cursor-rules
	@$(MAKE) setup-mcp-tools
	@$(MAKE) setup-docker
	@$(MAKE) setup-development
	@$(MAKE) setup-shortcuts
	@echo ""

	@echo "📋 6. 拡張機能インストール実行中..."
	@$(MAKE) install-extensions-simple
	@echo ""

	@echo "✅ 全体のセットアップが完了しました！"
	@echo "ℹ️  以下の手順で最終設定を完了してください:"
	@echo "   1. ログアウト・ログインして設定を反映"
	@echo "   2. 必要に応じて個別の設定を実行"
	@echo "   3. 'make help' で利用可能なコマンドを確認"

# デバッグ用のターゲット
debug:
	@echo "🔍 デバッグ情報を表示中..."
	@echo "=== システム情報 ==="
	@echo "OS: $$(lsb_release -d 2>/dev/null | cut -f2 || echo 'Unknown')"
	@echo "Kernel: $$(uname -r)"
	@echo "Architecture: $$(uname -m)"
	@echo "Shell: $$SHELL"
	@echo "User: $$USER"
	@echo "Home: $$HOME"
	@echo ""

	@echo "=== ディレクトリ情報 ==="
	@echo "DOTFILES_DIR: $(DOTFILES_DIR)"
	@echo "CONFIG_DIR: $(CONFIG_DIR)"
	@echo "HOME_DIR: $(HOME_DIR)"
	@echo ""

	@echo "=== インストール状態 ==="
	@echo -n "Git: "; command -v git >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "Homebrew: "; command -v brew >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "ZSH: "; command -v zsh >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "Vim: "; command -v vim >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "Neovim: "; command -v nvim >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "Docker: "; command -v docker >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "VS Code: "; command -v code >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo -n "Cursor: "; \
	if [ -f /opt/cursor/cursor.AppImage ]; then \
		FILE_DATE=$$(stat -c%Y /opt/cursor/cursor.AppImage 2>/dev/null || echo "0"); \
		FORMATTED_DATE=$$(date -d @$$FILE_DATE '+%Y-%m-%d' 2>/dev/null || echo '不明'); \
		echo "✅ インストール済み (更新日: $$FORMATTED_DATE)"; \
	elif command -v cursor >/dev/null 2>&1; then \
		echo "✅ インストール済み"; \
	else \
		echo "❌ 未インストール"; \
	fi
	@echo -n "GNOME Extensions: "; command -v gnome-extensions >/dev/null 2>&1 && echo "✅ インストール済み" || echo "❌ 未インストール"
	@echo ""

	@echo "=== 設定ファイル状態 ==="
	@echo -n ".zshrc: "; [ -f "$(HOME_DIR)/.zshrc" ] && echo "✅ 存在" || echo "❌ 不在"
	@echo -n ".vimrc: "; [ -f "$(HOME_DIR)/.vimrc" ] && echo "✅ 存在" || echo "❌ 不在"
	@echo -n ".gitconfig: "; [ -f "$(HOME_DIR)/.gitconfig" ] && echo "✅ 存在" || echo "❌ 不在"
	@echo -n "SSH鍵: "; [ -f "$(HOME_DIR)/.ssh/id_ed25519" ] && echo "✅ 存在" || echo "❌ 不在"
	@echo ""

	@echo "=== 環境変数 ==="
	@echo "PATH: $$PATH"
	@echo "LANG: $$LANG"
	@echo "EDITOR: $$EDITOR"
	@echo "BROWSER: $$BROWSER"
	@echo ""

	@echo "✅ デバッグ情報の表示が完了しました。"

# WEZTERMのインストール
install-wezterm:
	@echo "📱 WEZTERMをインストール中..."

	# WEZTERMのインストール
	@if ! command -v wezterm >/dev/null 2>&1; then \
		echo "📦 WEZTERMをインストール中..."; \
		echo ""; \
		echo "⚠️  セキュリティ確認：外部GPGキーとリポジトリの追加"; \
		echo "   以下の操作を実行します:"; \
		echo "   1. WEZTERMのGPGキーを追加 (https://apt.fury.io/wez/gpg.key)"; \
		echo "   2. WEZTERMのリポジトリを追加 (https://apt.fury.io/wez/)"; \
		echo ""; \
		echo -n "🔐 続行しますか？ (y/N): "; \
		read -r confirm; \
		if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
			echo "✅ 確認されました。インストールを続行します..."; \
			curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg; \
			echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list; \
			sudo apt update; \
			sudo DEBIAN_FRONTEND=noninteractive apt install -y wezterm; \
		else \
			echo "❌ インストールがキャンセルされました。"; \
			echo "ℹ️  手動でインストールする場合は、公式ドキュメントを参照してください。"; \
			exit 1; \
		fi; \
	else \
		echo "✅ WEZTERMは既にインストール済みです"; \
	fi

	@echo "✅ WEZTERMのインストールが完了しました。"

# ========================================
# 新しい階層的な命名規則のターゲット
# ========================================

# システム設定系
setup-system: system-setup

# 統合セットアップ系
setup-config-all: setup-all

# ========================================
# 後方互換性のためのエイリアス
# ========================================

# 古いターゲット名を維持（既に実装済み）
# setup-all: は既に実装済み
# system-setup: は既に実装済み
