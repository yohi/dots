# 段階的セットアップ関連のターゲット

# ==================== ステージ完了チェック用ヘルパーマクロ ====================
# 各ステージの完了状態をチェックする再利用可能なマクロ
# 戻り値: 0 = 完了, 1 = 未完了

define _check_stage_1
	command -v brew >/dev/null 2>&1
endef

define _check_stage_2
	command -v cursor >/dev/null 2>&1 && command -v wezterm >/dev/null 2>&1
endef

define _check_stage_3
	[ -f ~/.zshrc ] && [ -f ~/.vimrc ]
endef

define _check_stage_4
	command -v gnome-extensions >/dev/null 2>&1
endef

define _check_stage_5
	command -v claude-code >/dev/null 2>&1
endef


.PHONY: stage1 stage2 stage3 stage4 stage5
stage1: ## ステージ1: システム基盤セットアップ（Homebrew + 基本パッケージ）
	@set -e; \
	echo "🚀 ステージ1: システム基盤セットアップを開始します..."; \
	echo "   📦 Homebrew + 基本パッケージのインストール"; \
	$(MAKE) install-packages-homebrew || { echo "❌ ステージ1失敗: Homebrewパッケージのインストールに失敗しました (install-packages-homebrew)"; exit 1; }; \
	$(MAKE) install-packages-fuse || { echo "❌ ステージ1失敗: FUSEのインストールに失敗しました (install-packages-fuse)"; exit 1; }; \
	echo "✅ ステージ1完了! 次は 'make stage2' でアプリケーションをインストールしてください"

stage2: ## ステージ2: 必須アプリケーションのインストール
	@set -e; \
	echo "🚀 ステージ2: 必須アプリケーションのインストール..."; \
	echo "   💻 IDE・エディタ・ブラウザなどの必須ツール"; \
	$(MAKE) install-packages-apps || { echo "❌ ステージ2失敗: 必須アプリケーションのインストールに失敗しました (install-packages-apps)"; exit 1; }; \
	$(MAKE) install-packages-deb || { echo "❌ ステージ2失敗: DEBパッケージのインストールに失敗しました (install-packages-deb)"; exit 1; }; \
	$(MAKE) install-packages-cursor || { echo "❌ ステージ2失敗: Cursorのインストールに失敗しました (install-packages-cursor)"; exit 1; }; \
	$(MAKE) install-packages-wezterm || { echo "❌ ステージ2失敗: WezTermのインストールに失敗しました (install-packages-wezterm)"; exit 1; }; \
	echo "✅ ステージ2完了! 次は 'make stage3' で設定ファイルをセットアップしてください"

stage3: ## ステージ3: 設定ファイル・dotfilesのセットアップ
	@set -e; \
	echo "🚀 ステージ3: 設定ファイル・dotfilesのセットアップ..."; \
	echo "   ⚙️  ZSH・Vim・WezTerm・VS Codeの設定"; \
	$(MAKE) install || { echo "❌ ステージ3失敗: dotfilesのリンク作成に失敗しました (install)"; exit 1; }; \
	$(MAKE) setup-config-zsh || { echo "❌ ステージ3失敗: ZSHの設定に失敗しました (setup-config-zsh)"; exit 1; }; \
	$(MAKE) setup-config-vim || { echo "❌ ステージ3失敗: Vimの設定に失敗しました (setup-config-vim)"; exit 1; }; \
	$(MAKE) setup-config-wezterm || { echo "❌ ステージ3失敗: WezTermの設定に失敗しました (setup-config-wezterm)"; exit 1; }; \
	$(MAKE) setup-config-vscode || { echo "❌ ステージ3失敗: VS Codeの設定に失敗しました (setup-config-vscode)"; exit 1; }; \
	echo "✅ ステージ3完了! 次は 'make stage4' でシステム設定をセットアップしてください"

stage4: ## ステージ4: システム設定・GNOME設定
	@set -e; \
	echo "🚀 ステージ4: システム設定・GNOME設定..."; \
	echo "   🖥️  GNOME拡張機能・システムTweaks"; \
	$(MAKE) setup-gnome-extensions || { echo "❌ ステージ4失敗: GNOME拡張機能の設定に失敗しました (setup-gnome-extensions)"; exit 1; }; \
	$(MAKE) setup-gnome-tweaks || { echo "❌ ステージ4失敗: GNOME Tweaksの設定に失敗しました (setup-gnome-tweaks)"; exit 1; }; \
	$(MAKE) setup-system || { echo "❌ ステージ4失敗: その他システム設定に失敗しました (setup-system)"; exit 1; }; \
	echo "✅ ステージ4完了! 次は 'make stage5' でオプション機能をインストールしてください"

stage5: ## ステージ5: オプション機能（AI開発ツール・フォント等）
	@set -e; \
	echo "🚀 ステージ5: オプション機能のインストール..."; \
	echo "   🤖 AI開発ツール・フォント・その他ツール"; \
	$(MAKE) install-claude-ecosystem || { echo "❌ ステージ5失敗: Claudeエコシステムのインストールに失敗しました (install-claude-ecosystem)"; exit 1; }; \
	$(MAKE) install-packages-cica-fonts || { echo "❌ ステージ5失敗: Cicaフォントのインストールに失敗しました (install-packages-cica-fonts)"; exit 1; }; \
	$(MAKE) install-packages-mysql-workbench || { echo "❌ ステージ5失敗: MySQL Workbenchのインストールに失敗しました (install-packages-mysql-workbench)"; exit 1; }; \
	$(MAKE) setup-mozc || { echo "❌ ステージ5失敗: Mozcの設定に失敗しました (setup-mozc)"; exit 1; }; \
	echo "✅ ステージ5完了! セットアップ完了です 🎉"

.PHONY: stage-status
stage-status: ## 各ステージの完了状況を確認
	@echo "📊 セットアップ進捗状況:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo -n "📦 ステージ1 (Homebrew): "
	@if $(call _check_stage_1); then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "💻 ステージ2 (アプリ): "
	@if $(call _check_stage_2); then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "⚙️  ステージ3 (設定): "
	@if $(call _check_stage_3); then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "🖥️  ステージ4 (GNOME): "
	@if $(call _check_stage_4); then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "🤖 ステージ5 (AI/その他): "
	@if $(call _check_stage_5); then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

.PHONY: stage-guide
stage-guide: ## 段階的セットアップの完全ガイド
	@echo "🎯 段階的セットアップガイド"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "このセットアップは5つのステージに分かれています:"
	@echo ""
	@echo "📦 ステージ1: make stage1    (5-10分)"
	@echo "   - Homebrewのインストール"
	@echo "   - FUSE等の基本パッケージ"
	@echo ""
	@echo "💻 ステージ2: make stage2    (10-20分)"
	@echo "   - Cursor IDE, WezTerm"
	@echo "   - ブラウザ、アプリケーション"
	@echo ""
	@echo "⚙️  ステージ3: make stage3    (5分)"
	@echo "   - Dotfiles, ZSH, Vim設定"
	@echo "   - VS Code設定"
	@echo ""
	@echo "🖥️  ステージ4: make stage4    (5-10分)"
	@echo "   - GNOME拡張機能"
	@echo "   - システム設定"
	@echo ""
	@echo "🤖 ステージ5: make stage5    (15-30分)"
	@echo "   - Claude Code AI ツール"
	@echo "   - フォント、その他ツール"
	@echo ""
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "💡 各ステージ間で再起動が推奨されます"
	@echo "📊 進捗確認: make stage-status"

.PHONY: next-stage
next-stage: ## 次に実行すべきステージを提案
	@echo "🔍 次のステージを確認中..."
	@if ! $(call _check_stage_1); then \
		echo "📦 次は: make stage1 (または make s1)"; \
	elif ! $(call _check_stage_2); then \
		echo "💻 次は: make stage2 (または make s2)"; \
	elif ! $(call _check_stage_3); then \
		echo "⚙️  次は: make stage3 (または make s3)"; \
	elif ! $(call _check_stage_4); then \
		echo "🖥️  次は: make stage4 (または make s4)"; \
	elif ! $(call _check_stage_5); then \
		echo "🤖 次は: make stage5 (または make s5)"; \
	else \
		echo "🎉 全てのステージが完了しています!"; \
	fi

.PHONY: stage-all
stage-all: ## 全ステージを順次実行（各ステージ後に確認）
	@echo "⚠️  全5ステージを順次実行します。各ステージ後に継続確認があります。"
	@if [ "$$NON_INTERACTIVE" = "1" ] || ! [ -t 0 ]; then \
		echo "ℹ️  非インタラクティブモードで実行します（確認をスキップ）"; \
	else \
		read -p "続行しますか？ (y/N): " confirm && echo "$$confirm" | grep -iq '^y' || { echo "中止します"; exit 1; }; \
	fi
	@if $(MAKE) stage1; then \
		echo "ステージ1完了。ステージ2に進みますか？"; \
		if [ "$$NON_INTERACTIVE" = "1" ] || ! [ -t 0 ]; then \
			echo "→ 自動的に次のステージに進みます"; \
		else \
			read -p "続行しますか？ (y/N): " confirm && echo "$$confirm" | grep -iq '^y' || { echo "中止します"; exit 1; }; \
		fi; \
	else \
		echo "❌ ステージ1の実行に失敗しました"; \
		exit 1; \
	fi
	@if $(MAKE) stage2; then \
		echo "ステージ2完了。ステージ3に進みますか？"; \
		if [ "$$NON_INTERACTIVE" = "1" ] || ! [ -t 0 ]; then \
			echo "→ 自動的に次のステージに進みます"; \
		else \
			read -p "続行しますか？ (y/N): " confirm && echo "$$confirm" | grep -iq '^y' || { echo "中止します"; exit 1; }; \
		fi; \
	else \
		echo "❌ ステージ2の実行に失敗しました"; \
		exit 1; \
	fi
	@if $(MAKE) stage3; then \
		echo "ステージ3完了。ステージ4に進みますか？"; \
		if [ "$$NON_INTERACTIVE" = "1" ] || ! [ -t 0 ]; then \
			echo "→ 自動的に次のステージに進みます"; \
		else \
			read -p "続行しますか？ (y/N): " confirm && echo "$$confirm" | grep -iq '^y' || { echo "中止します"; exit 1; }; \
		fi; \
	else \
		echo "❌ ステージ3の実行に失敗しました"; \
		exit 1; \
	fi
	@if $(MAKE) stage4; then \
		echo "ステージ4完了。ステージ5に進みますか？"; \
		if [ "$$NON_INTERACTIVE" = "1" ] || ! [ -t 0 ]; then \
			echo "→ 自動的に次のステージに進みます"; \
		else \
			read -p "続行しますか？ (y/N): " confirm && echo "$$confirm" | grep -iq '^y' || { echo "中止します"; exit 1; }; \
		fi; \
	else \
		echo "❌ ステージ4の実行に失敗しました"; \
		exit 1; \
	fi
	@if $(MAKE) stage5; then \
		echo "🎉 全ステージ完了！"; \
	else \
		echo "❌ ステージ5の実行に失敗しました"; \
		exit 1; \
	fi
