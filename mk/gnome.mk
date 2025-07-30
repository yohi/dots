# GNOME関連のターゲット

# GNOME拡張機能の設定
setup-gnome-extensions:
	@echo "🔧 GNOME拡張機能の設定を実行中..."

	# GNOME拡張機能のインストール
	@echo "📦 GNOME拡張機能をインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-shell-extension-manager || true

	# User Themesの有効化
	@echo "🎨 User Themesを有効化中..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true; \
	fi

	# Dash to Dockの有効化
	@echo "🖥️  Dash to Dockを有効化中..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions enable dash-to-dock@micxgx.gmail.com || true; \
	fi

	# その他の拡張機能の有効化
	@echo "🔧 その他の拡張機能を有効化中..."
	@if command -v gnome-extensions >/dev/null 2>&1; then \
		gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com || true; \
		gnome-extensions enable clipboard-indicator@tudmotu.com || true; \
		gnome-extensions enable gsconnect@andyholmes.github.io || true; \
		gnome-extensions enable openweather-extension@jenslody.de || true; \
		gnome-extensions enable screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com || true; \
		gnome-extensions enable workspace-indicator@gnome-shell-extensions.gcampax.github.com || true; \
	fi

	@echo "✅ GNOME拡張機能の設定が完了しました。"
	@echo "ℹ️  一部の拡張機能は、ログアウト・ログインまたはAlt+F2でrを実行して反映されます。"

# GNOME Tweaksの設定
setup-gnome-tweaks:
	@echo "🔧 GNOME Tweaksの設定を実行中..."

	# GNOME Tweaksのインストール
	@echo "📦 GNOME Tweaksをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-tweaks || true

	# dconf設定の読み込み
	@if [ -f "$(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.interface.dconf" ]; then \
		echo "🖥️  デスクトップインターフェース設定を読み込み中..."; \
		dconf load /org/gnome/desktop/interface/ < $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.interface.dconf || true; \
		echo "✅ デスクトップインターフェース設定が読み込まれました"; \
	else \
		echo "ℹ️  デスクトップインターフェース設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.interface.dconf"; \
	fi

	@if [ -f "$(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.wm.preferences.dconf" ]; then \
		echo "🪟 ウィンドウマネージャ設定を読み込み中..."; \
		dconf load /org/gnome/desktop/wm/preferences/ < $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.wm.preferences.dconf || true; \
		echo "✅ ウィンドウマネージャ設定が読み込まれました"; \
	else \
		echo "ℹ️  ウィンドウマネージャ設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.wm.preferences.dconf"; \
	fi

	@if [ -f "$(DOTFILES_DIR)/gnome-tweaks/org.gnome.shell.dconf" ]; then \
		echo "🐚 GNOME Shell設定を読み込み中..."; \
		dconf load /org/gnome/shell/ < $(DOTFILES_DIR)/gnome-tweaks/org.gnome.shell.dconf || true; \
		echo "✅ GNOME Shell設定が読み込まれました"; \
	else \
		echo "ℹ️  GNOME Shell設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-tweaks/org.gnome.shell.dconf"; \
	fi

	@if [ -f "$(DOTFILES_DIR)/gnome-tweaks/org.gnome.mutter.dconf" ]; then \
		echo "🏗️  Mutter設定を読み込み中..."; \
		dconf load /org/gnome/mutter/ < $(DOTFILES_DIR)/gnome-tweaks/org.gnome.mutter.dconf || true; \
		echo "✅ Mutter設定が読み込まれました"; \
	else \
		echo "ℹ️  Mutter設定ファイルが見つかりません: $(DOTFILES_DIR)/gnome-tweaks/org.gnome.mutter.dconf"; \
	fi

	@echo "✅ GNOME Tweaksの設定が完了しました。"
	@echo "ℹ️  設定を反映するため、一度ログアウト・ログインすることを推奨します。"

# GNOME Tweaks設定のバックアップ
backup-gnome-tweaks:
	@echo "💾 GNOME Tweaks設定をバックアップ中..."
	@mkdir -p $(DOTFILES_DIR)/gnome-tweaks

	# 現在の設定をバックアップ
	@echo "📁 設定ファイルを保存中..."
	@dconf dump /org/gnome/desktop/interface/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.interface.dconf || true
	@dconf dump /org/gnome/desktop/wm/preferences/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.wm.preferences.dconf || true
	@dconf dump /org/gnome/shell/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.shell.dconf || true
	@dconf dump /org/gnome/mutter/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.mutter.dconf || true

	@echo "✅ GNOME Tweaks設定のバックアップが完了しました。"
	@echo "ℹ️  設定ファイルは $(DOTFILES_DIR)/gnome-tweaks/ に保存されました。"

# GNOME Tweaks設定のエクスポート
export-gnome-tweaks:
	@echo "📤 GNOME Tweaks設定をエクスポート中..."
	@mkdir -p $(DOTFILES_DIR)/gnome-tweaks

	# 現在の設定をエクスポート
	@echo "📁 設定ファイルをエクスポート中..."
	@dconf dump /org/gnome/desktop/interface/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.interface.dconf || true
	@dconf dump /org/gnome/desktop/wm/preferences/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.desktop.wm.preferences.dconf || true
	@dconf dump /org/gnome/shell/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.shell.dconf || true
	@dconf dump /org/gnome/mutter/ > $(DOTFILES_DIR)/gnome-tweaks/org.gnome.mutter.dconf || true

	@echo "✅ GNOME Tweaks設定のエクスポートが完了しました。"
	@echo "ℹ️  設定ファイルは $(DOTFILES_DIR)/gnome-tweaks/ に保存されました。"

# Weztermをデフォルト端末に設定
setup-gnome-wezterm:
	@echo "🚀 Weztermをデフォルト端末に設定中..."
	@if [ -x "$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh" ]; then \
		$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh; \
	else \
		echo "❌ Wezterm設定スクリプトが見つからないか実行権限がありません: $(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh"; \
		exit 1; \
	fi

# Weztermデフォルト端末設定の確認
check-gnome-wezterm:
	@echo "🔍 Weztermデフォルト端末設定を確認中..."
	@if [ -x "$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh" ]; then \
		$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh --check; \
	else \
		echo "❌ Wezterm設定スクリプトが見つからないか実行権限がありません: $(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh"; \
		exit 1; \
	fi

# Weztermデフォルト端末設定のテスト
test-gnome-wezterm:
	@echo "🧪 Weztermデフォルト端末設定をテスト中..."
	@if [ -x "$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh" ]; then \
		$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh --test; \
	else \
		echo "❌ Wezterm設定スクリプトが見つからないか実行権限がありません: $(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh"; \
		exit 1; \
	fi

# Nautilusの再起動
restart-nautilus:
	@echo "🔄 Nautilusを再起動中..."
	@if [ -x "$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh" ]; then \
		$(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh --restart-nautilus; \
	else \
		echo "❌ Wezterm設定スクリプトが見つからないか実行権限がありません: $(DOTFILES_DIR)/gnome-settings/setup-wezterm-default.sh"; \
		exit 1; \
	fi

# ========================================
# 新しい階層的な命名規則のターゲット
# ========================================

# GNOME関連設定系
setup-config-gnome-extensions: setup-gnome-extensions
setup-config-gnome-tweaks: setup-gnome-tweaks
setup-config-gnome-wezterm: setup-gnome-wezterm
backup-config-gnome-tweaks: backup-gnome-tweaks
export-config-gnome-tweaks: export-gnome-tweaks

# ========================================
# 後方互換性のためのエイリアス
# ========================================

# 古いターゲット名を維持（既に実装済み）
# setup-gnome-extensions: は既に実装済み
# setup-gnome-tweaks: は既に実装済み
# backup-gnome-tweaks: は既に実装済み
# export-gnome-tweaks: は既に実装済み
