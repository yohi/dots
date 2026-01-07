# 短縮エイリアス・プリセット・カテゴリ別コマンド

# ==================== 短縮エイリアス ====================
# よく使うコマンドの短縮形
.PHONY: i s c u m h claudecode
i: install                ## 短縮: make install
s: setup                  ## 短縮: make setup
c: check-cursor-version   ## 短縮: Cursorバージョン確認
u: update-cursor          ## 短縮: Cursorアップデート
m: menu                   ## 短縮: インタラクティブメニュー
h: help                   ## 短縮: ヘルプ表示
claudecode: install-superclaude  ## 短縮: SuperClaudeフレームワークインストール

# ==================== プリセット実行 ====================
# クイックセットアップ（基本環境）
.PHONY: quick
quick: ## クイックセットアップ - 基本的な開発環境を素早くセットアップ
	@echo "🚀 クイックセットアップを開始します..."
	@echo "📋 実行内容: システム設定 → Homebrew → 基本ツール → シェル設定"
	@$(MAKE) setup-system
	@$(MAKE) install-packages-homebrew
	@$(MAKE) install-packages-deb
	@$(MAKE) setup-config-zsh
	@echo "✅ クイックセットアップが完了しました！"

# 開発者セットアップ（開発環境重視）
.PHONY: dev-setup
dev-setup: ## 開発者セットアップ - IDEとAI開発ツールを含む開発者向け環境
	@echo "👨‍💻 開発者セットアップを開始します..."
	@echo "📋 実行内容: 基本環境 → IDE → AI開発ツール → 設定適用"
	@$(MAKE) quick
	@$(MAKE) install-packages-cursor
	@$(MAKE) install-packages-claude-ecosystem
	@$(MAKE) setup-config-vscode
	@$(MAKE) setup-config-cursor
	@$(MAKE) setup-config-git
	@echo "✅ 開発者セットアップが完了しました！"

# フルセットアップ（全機能）
.PHONY: full
full: ## フルセットアップ - 全ての機能を含む完全なセットアップ
	@echo "🌟 フルセットアップを開始します..."
	@echo "📋 実行内容: 全システム設定 → 全ソフトウェア → 全設定"
	@$(MAKE) dev-setup
	@$(MAKE) install-packages-cica-fonts
	@$(MAKE) install-packages-mysql-workbench
	@$(MAKE) gnome-settings
	@$(MAKE) gnome-extensions
	@$(MAKE) setup-config-all
	@echo "✅ フルセットアップが完了しました！"

# ミニマルセットアップ（最小構成）
.PHONY: minimal
minimal: ## ミニマルセットアップ - 最小限の構成でセットアップ
	@echo "⚡ ミニマルセットアップを開始します..."
	@echo "📋 実行内容: 基本システム設定 → 必須ツールのみ"
	@$(MAKE) setup-system
	@$(MAKE) install-packages-homebrew
	@$(MAKE) setup-config-zsh
	@echo "✅ ミニマルセットアップが完了しました！"

# ==================== カテゴリ別サブメニュー ====================
# パッケージカテゴリ
.PHONY: pkg-basic pkg-dev pkg-ai pkg-fonts pkg-browser pkg-others
pkg-basic: ## 基本パッケージインストール
	@echo "📦 基本パッケージをインストール中..."
	@$(MAKE) install-packages-homebrew
	@$(MAKE) install-packages-deb
	@$(MAKE) install-packages-fuse

pkg-dev: ## 開発環境パッケージインストール
	@echo "👨‍💻 開発環境をインストール中..."
	@$(MAKE) install-packages-cursor
	@$(MAKE) install-packages-wezterm

pkg-ai: ## AI開発ツールインストール
	@echo "🤖 AI開発ツールをインストール中..."
	@$(MAKE) install-packages-claude-ecosystem

pkg-fonts: ## フォントインストール
	@echo "🔤 フォントをインストール中..."
	@$(MAKE) install-packages-cica-fonts

pkg-browser: ## ブラウザインストール
	@echo "🌐 ブラウザをインストール中..."
	@$(MAKE) install-packages-chrome-beta

pkg-others: ## その他ツールインストール
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│               🔧 その他ツールメニュー                    │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) MySQL Workbench (データベース管理)                   │"
	@echo "│ 2) Playwright (E2Eテストフレームワーク)                 │"
	@echo "│ 3) すべてインストール                                  │"
	@echo "│ 0) パッケージメニューに戻る                            │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-3]: " choice; \
	case $$choice in \
		1) $(MAKE) install-packages-mysql-workbench ;; \
		2) $(MAKE) install-packages-playwright ;; \
		3) $(MAKE) install-packages-mysql-workbench && $(MAKE) install-packages-playwright ;; \
		0) $(MAKE) pkg ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) pkg-others ;; \
	esac

# IDE設定サブメニュー
.PHONY: conf-ide
conf-ide: ## IDE設定メニュー
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│                 💻 IDE設定メニュー                      │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) VSCode設定                                          │"
	@echo "│ 2) Cursor設定                                          │"
	@echo "│ 3) VSCode SuperCopilot設定                             │"
	@echo "│ 4) Cursor MCP Tools設定                               │"
	@echo "│ 0) 設定メニューに戻る                                  │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-4]: " choice; \
	case $$choice in \
		1) $(MAKE) setup-config-vscode ;; \
		2) $(MAKE) setup-config-cursor ;; \
		3) $(MAKE) setup-config-vscode-copilot ;; \
		4) $(MAKE) setup-config-mcp-tools ;; \
		0) $(MAKE) conf ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) conf-ide ;; \
	esac

# ==================== 便利なワンライナー ====================
.PHONY: status check-all update-all
# システム状態確認
status: ## システム状態の一覧表示
	@echo "📊 システム状態を確認中..."
	@echo ""
	@echo "🔍 Cursor IDE:"
	@$(MAKE) check-cursor-version
	@echo ""
	@echo "📦 インストール済みパッケージ:"
	@echo "- Homebrew: $$(command -v brew >/dev/null && echo '✅ インストール済み' || echo '❌ 未インストール')"
	@echo "- VSCode: $$(command -v code >/dev/null && echo '✅ インストール済み' || echo '❌ 未インストール')"
	@echo "- Git: $$(command -v git >/dev/null && echo '✅ '$$(git --version) || echo '❌ 未インストール')"

# 全体チェック
check-all: ## 全ての設定・インストール状況をチェック
	@echo "🔍 全体チェックを実行中..."
	@$(MAKE) status

# 全体アップデート
update-all: ## 全てのソフトウェアをアップデート
	@echo "🔄 全体アップデートを開始します..."
	@echo "1/3 システムパッケージ更新中..."
	@sudo apt update && sudo apt upgrade -y
	@echo "2/3 Cursor IDEアップデート中..."
	@$(MAKE) update-cursor
	@echo "3/3 Homebrewアップデート中..."
	@command -v brew >/dev/null && brew update && brew upgrade || echo "Homebrew未インストール"
	@echo "✅ 全体アップデートが完了しました！"

# 段階的セットアップ（実際のターゲット名を使用）
.PHONY: stage1 stage2 stage3 stage4 stage5
stage1: ## ステージ1: システム基盤セットアップ（Homebrew + 基本パッケージ）
	@echo "🚀 ステージ1: システム基盤セットアップを開始します..."
	@echo "   📦 Homebrew + 基本パッケージのインストール"
	@$(MAKE) install-packages-homebrew
	@$(MAKE) install-packages-fuse
	@echo "✅ ステージ1完了! 次は 'make stage2' でアプリケーションをインストールしてください"

stage2: ## ステージ2: 必須アプリケーションのインストール
	@echo "🚀 ステージ2: 必須アプリケーションのインストール..."
	@echo "   💻 IDE・エディタ・ブラウザなどの必須ツール"
	@$(MAKE) install-packages-apps
	@$(MAKE) install-packages-deb
	@$(MAKE) install-packages-cursor
	@$(MAKE) install-packages-wezterm
	@echo "✅ ステージ2完了! 次は 'make stage3' で設定ファイルをセットアップしてください"

stage3: ## ステージ3: 設定ファイル・dotfilesのセットアップ
	@echo "🚀 ステージ3: 設定ファイル・dotfilesのセットアップ..."
	@echo "   ⚙️  ZSH・Vim・WezTerm・VS Codeの設定"
	@$(MAKE) install
	@$(MAKE) setup-config-zsh
	@$(MAKE) setup-config-vim
	@$(MAKE) setup-config-wezterm
	@$(MAKE) setup-config-vscode
	@echo "✅ ステージ3完了! 次は 'make stage4' でシステム設定をセットアップしてください"

stage4: ## ステージ4: システム設定・GNOME設定
	@echo "🚀 ステージ4: システム設定・GNOME設定..."
	@echo "   🖥️  GNOME拡張機能・システムTweaks"
	@$(MAKE) setup-gnome-extensions
	@$(MAKE) setup-gnome-tweaks
	@$(MAKE) setup-system
	@echo "✅ ステージ4完了! 次は 'make stage5' でオプション機能をインストールしてください"

stage5: ## ステージ5: オプション機能（AI開発ツール・フォント等）
	@echo "🚀 ステージ5: オプション機能のインストール..."
	@echo "   🤖 AI開発ツール・フォント・その他ツール"
	@$(MAKE) install-packages-claude-ecosystem
	@$(MAKE) install-packages-cica-fonts
	@$(MAKE) install-packages-mysql-workbench
	@$(MAKE) setup-mozc
	@echo "✅ ステージ5完了! セットアップ完了です 🎉"

# 段階別の進捗確認
.PHONY: stage-status
stage-status: ## 各ステージの完了状況を確認
	@echo "📊 セットアップ進捗状況:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo -n "📦 ステージ1 (Homebrew): "
	@if command -v brew >/dev/null 2>&1; then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "💻 ステージ2 (アプリ): "
	@if command -v cursor >/dev/null 2>&1 && command -v wezterm >/dev/null 2>&1; then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "⚙️  ステージ3 (設定): "
	@if [ -f ~/.zshrc ] && [ -f ~/.vimrc ]; then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "🖥️  ステージ4 (GNOME): "
	@if command -v gnome-extensions >/dev/null 2>&1; then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo -n "🤖 ステージ5 (AI/その他): "
	@if command -v claude-code >/dev/null 2>&1; then echo "✅ 完了"; else echo "❌ 未完了"; fi
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 段階的セットアップのガイド
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

# 段階的セットアップの短縮形
.PHONY: s1 s2 s3 s4 s5 ss sg
s1: stage1    ## 短縮: ステージ1実行
s2: stage2    ## 短縮: ステージ2実行
s3: stage3    ## 短縮: ステージ3実行
s4: stage4    ## 短縮: ステージ4実行
s5: stage5    ## 短縮: ステージ5実行
ss: stage-status  ## 短縮: 進捗確認
sg: stage-guide   ## 短縮: セットアップガイド

# 次のステージの提案
.PHONY: next-stage
next-stage: ## 次に実行すべきステージを提案
	@echo "🔍 次のステージを確認中..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "📦 次は: make stage1 (または make s1)"; \
	elif ! command -v cursor >/dev/null 2>&1; then \
		echo "💻 次は: make stage2 (または make s2)"; \
	elif ! [ -f ~/.zshrc ]; then \
		echo "⚙️  次は: make stage3 (または make s3)"; \
	elif ! command -v gnome-extensions >/dev/null 2>&1; then \
		echo "🖥️  次は: make stage4 (または make s4)"; \
	elif ! command -v claude-code >/dev/null 2>&1; then \
		echo "🤖 次は: make stage5 (または make s5)"; \
	else \
		echo "🎉 全てのステージが完了しています!"; \
	fi

# ワンクリック連続実行（確認あり）
.PHONY: stage-all
stage-all: ## 全ステージを順次実行（各ステージ後に確認）
	@echo "⚠️  全5ステージを順次実行します。各ステージ後に継続確認があります。"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ]
	@$(MAKE) stage1
	@echo "ステージ1完了。ステージ2に進みますか？"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ]
	@$(MAKE) stage2
	@echo "ステージ2完了。ステージ3に進みますか？"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ]
	@$(MAKE) stage3
	@echo "ステージ3完了。ステージ4に進みますか？"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ]
	@$(MAKE) stage4
	@echo "ステージ4完了。ステージ5に進みますか？"
	@read -p "続行しますか？ (y/N): " confirm && [ "$$confirm" = "y" ]
	@$(MAKE) stage5
	@echo "🎉 全ステージ完了！"
