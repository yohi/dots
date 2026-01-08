# cc-sdd (Claude Code - Spec Driven Development) セットアップ用Makefile
# AI駆動開発ライフサイクル(AI-DLC)とSpec-Driven Developmentのワークフローを管理

# デフォルト設定
CC_SDD_VERSION := latest
CC_SDD_LANG := ja
CC_SDD_AGENT := claude

.PHONY: cc-sdd-check
cc-sdd-check: ## cc-sddのインストール状態を確認
	@echo "🔍 cc-sdd のインストール状態を確認中..."
	@echo ""
	@# Claude Codeの確認
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "⚠️  Claude Code がインストールされていません"; \
		echo "   'make install-packages-claude-code' でインストールできます"; \
	else \
		echo "✅ Claude Code: $$(claude --version)"; \
	fi
	@echo ""
	@# Node.jsの確認
	@if ! command -v node >/dev/null 2>&1; then \
		echo "❌ Node.js がインストールされていません"; \
		echo "   cc-sddの実行にはNode.jsが必要です"; \
	else \
		echo "✅ Node.js: $$(node --version)"; \
	fi
	@if ! command -v npx >/dev/null 2>&1; then \
		echo "❌ npx がインストールされていません"; \
	else \
		echo "✅ npx: $$(npx --version)"; \
	fi
	@echo ""
	@# cc-sdd関連ファイルの確認
	@if [ -d ".claude/commands/kiro" ]; then \
		echo "✅ Claude Code Kiroコマンド: .claude/commands/kiro/"; \
		echo "   インストール済みコマンド:"; \
		ls -1 .claude/commands/kiro/*.md 2>/dev/null | sed 's|.*/||' | sed 's/\.md$$//' | sed 's/^/     - \/kiro:/' || echo "     (なし)"; \
	else \
		echo "❌ Claude Code Kiroコマンドが見つかりません"; \
	fi
	@echo ""
	@if [ -d ".kiro" ]; then \
		echo "✅ Kiroディレクトリ: .kiro/"; \
		if [ -d ".kiro/steering" ]; then \
			echo "   ✅ ステアリング: .kiro/steering/"; \
		fi; \
		if [ -d ".kiro/specs" ]; then \
			echo "   ✅ 仕様: .kiro/specs/"; \
		fi; \
		if [ -d ".kiro/settings" ]; then \
			echo "   ✅ 設定: .kiro/settings/"; \
		fi; \
	else \
		echo "❌ Kiroディレクトリが見つかりません"; \
	fi
	@echo ""
	@if [ -f "CLAUDE.md" ]; then \
		echo "✅ CLAUDE.md が存在します"; \
	else \
		echo "❌ CLAUDE.md が見つかりません"; \
	fi

.PHONY: cc-sdd-install
cc-sdd-install: ## cc-sddをインストール(デフォルト: 日本語、Claude Code)
	@# 冪等性チェック: .claude/commands/kiro と .kiro が存在する場合はスキップ
	@if [ -d ".claude/commands/kiro" ] && [ -d ".kiro" ]; then \
		echo "$(call IDEMPOTENCY_SKIP_MSG,cc-sdd-install)"; \
		exit 0; \
	fi
	@echo "🚀 cc-sdd (Spec-Driven Development) のインストールを開始..."
	@echo ""
	@# Node.jsの確認
	@if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then \
		echo "❌ Node.js/npx がインストールされていません"; \
		echo "ℹ️  Node.jsをインストールしてください"; \
		exit 1; \
	fi
	@echo "✅ Node.js環境が利用可能です"
	@echo ""
	@# cc-sddの実行
	@echo "📦 cc-sdd をインストール中..."
	@echo "   バージョン: $(CC_SDD_VERSION)"
	@echo "   言語: $(CC_SDD_LANG)"
	@echo "   エージェント: $(CC_SDD_AGENT)"
	@echo ""
	@if [ "$(CC_SDD_VERSION)" = "next" ]; then \
		npx cc-sdd@next --$(CC_SDD_AGENT) --lang $(CC_SDD_LANG); \
	else \
		npx cc-sdd@latest --$(CC_SDD_AGENT) --lang $(CC_SDD_LANG); \
	fi
	@echo ""
	@echo "✅ cc-sdd のインストールが完了しました！"
	@echo ""
	@$(MAKE) cc-sdd-check

.PHONY: cc-sdd-install-alpha
cc-sdd-install-alpha: ## cc-sddアルファ版をインストール（最新機能）
	@$(MAKE) cc-sdd-install CC_SDD_VERSION=next

.PHONY: cc-sdd-install-agent
cc-sdd-install-agent: ## cc-sdd SubAgentsをインストール（アルファ版必須）
	@echo "🚀 cc-sdd SubAgents のインストールを開始..."
	@echo ""
	@if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then \
		echo "❌ Node.js/npx がインストールされていません"; \
		exit 1; \
	fi
	@echo "📦 cc-sdd SubAgents をインストール中（アルファ版）..."
	@npx cc-sdd@next --claude-agent --lang $(CC_SDD_LANG)
	@echo ""
	@echo "✅ cc-sdd SubAgents のインストールが完了しました！"
	@echo ""
	@if [ -d ".claude/agents/kiro" ]; then \
		echo "📋 インストールされたサブエージェント:"; \
		ls -1 .claude/agents/kiro/*.md 2>/dev/null | sed 's|.*/||' | sed 's/\.md$$//' | sed 's/^/   - /' || echo "   (なし)"; \
	fi

.PHONY: cc-sdd-install-en
cc-sdd-install-en: ## cc-sddをインストール（英語版）
	@$(MAKE) cc-sdd-install CC_SDD_LANG=en

.PHONY: cc-sdd-install-gemini
cc-sdd-install-gemini: ## cc-sddをGemini CLI向けにインストール
	@$(MAKE) cc-sdd-install CC_SDD_AGENT=gemini

.PHONY: cc-sdd-install-cursor
cc-sdd-install-cursor: ## cc-sddをCursor IDE向けにインストール
	@$(MAKE) cc-sdd-install CC_SDD_AGENT=cursor

.PHONY: cc-sdd-install-codex
cc-sdd-install-codex: ## cc-sddをCodex CLI向けにインストール（アルファ版）
	@$(MAKE) cc-sdd-install CC_SDD_VERSION=next CC_SDD_AGENT=codex

.PHONY: cc-sdd-install-copilot
cc-sdd-install-copilot: ## cc-sddをGitHub Copilot向けにインストール（アルファ版）
	@$(MAKE) cc-sdd-install CC_SDD_VERSION=next CC_SDD_AGENT=copilot

.PHONY: cc-sdd-install-qwen
cc-sdd-install-qwen: ## cc-sddをQwen Code向けにインストール
	@$(MAKE) cc-sdd-install CC_SDD_AGENT=qwen

.PHONY: cc-sdd-update
cc-sdd-update: ## cc-sddを最新版に更新
	@echo "🔄 cc-sdd を更新中..."
	@echo ""
	@npx cc-sdd@latest --$(CC_SDD_AGENT) --lang $(CC_SDD_LANG)
	@echo ""
	@echo "✅ cc-sdd の更新が完了しました"

.PHONY: cc-sdd-update-alpha
cc-sdd-update-alpha: ## cc-sddアルファ版を更新
	@echo "🔄 cc-sdd アルファ版を更新中..."
	@echo ""
	@npx cc-sdd@next --$(CC_SDD_AGENT) --lang $(CC_SDD_LANG)
	@echo ""
	@echo "✅ cc-sdd アルファ版の更新が完了しました"

.PHONY: cc-sdd-info
cc-sdd-info: ## cc-sddの情報を表示
	@echo "ℹ️  cc-sdd - Spec-Driven Development for Claude Code"
	@echo ""
	@echo "📖 概要:"
	@echo "   cc-sddは、Claude Code向けのAI駆動開発ライフサイクル(AI-DLC)と"
	@echo "   Spec-Driven Development(SDD)ワークフローを提供します"
	@echo ""
	@echo "✨ 主な機能:"
	@echo "   - 🚀 AI-DLC手法 - 人間承認付きAIネイティブプロセス"
	@echo "   - 📋 仕様ファースト開発 - 包括的仕様を単一情報源として活用"
	@echo "   - ⚡ ボルト開発 - 週単位から時間単位の納期実現"
	@echo "   - 🧠 永続的プロジェクトメモリ - AIがセッション間でコンテキスト維持"
	@echo "   - 🛠 テンプレート柔軟性 - チームのドキュメント形式に合わせてカスタマイズ"
	@echo "   - 🔄 AIネイティブ+人間ゲート - AI計画→人間検証→AI実装"
	@echo ""
	@echo "📋 提供されるコマンド（11種類）:"
	@echo "   【仕様駆動開発ワークフロー】"
	@echo "     /kiro:spec-init <description>         - 機能仕様を初期化"
	@echo "     /kiro:spec-requirements <feature>     - 要件を生成"
	@echo "     /kiro:spec-design <feature>           - 技術設計を作成"
	@echo "     /kiro:spec-tasks <feature>            - 実装タスクに分解"
	@echo "     /kiro:spec-impl <feature> <tasks>     - TDDで実行"
	@echo "     /kiro:spec-status <feature>           - 進捗を確認"
	@echo ""
	@echo "   【品質向上（既存コード向けオプション）】"
	@echo "     /kiro:validate-gap <feature>          - 既存機能と要件のギャップ分析"
	@echo "     /kiro:validate-design <feature>       - 設計互換性をレビュー"
	@echo ""
	@echo "   【プロジェクトメモリとコンテキスト】"
	@echo "     /kiro:steering                        - プロジェクトメモリを作成/更新"
	@echo "     /kiro:steering-custom                 - 専門ドメイン知識を追加"
	@echo ""
	@echo "🤖 対応AIエージェント:"
	@echo "   - Claude Code (デフォルト)"
	@echo "   - Claude Code SubAgents (アルファ版)"
	@echo "   - Gemini CLI"
	@echo "   - Cursor IDE"
	@echo "   - Codex CLI (アルファ版)"
	@echo "   - GitHub Copilot (アルファ版)"
	@echo "   - Qwen Code"
	@echo ""
	@echo "🌐 対応言語（12言語）:"
	@echo "   en (英語), ja (日本語), zh-TW (繁体字), zh (簡体字),"
	@echo "   es (スペイン語), pt (ポルトガル語), de (ドイツ語), fr (フランス語),"
	@echo "   ru (ロシア語), it (イタリア語), ko (韓国語), ar (アラビア語)"
	@echo ""
	@echo "🔧 Makefileコマンド:"
	@echo "   make cc-sdd-install              - インストール（日本語、Claude Code）"
	@echo "   make cc-sdd-install-alpha        - アルファ版インストール"
	@echo "   make cc-sdd-install-agent        - SubAgentsインストール"
	@echo "   make cc-sdd-install-en           - 英語版インストール"
	@echo "   make cc-sdd-install-gemini       - Gemini CLI向けインストール"
	@echo "   make cc-sdd-install-cursor       - Cursor IDE向けインストール"
	@echo "   make cc-sdd-install-codex        - Codex CLI向けインストール"
	@echo "   make cc-sdd-install-copilot      - GitHub Copilot向けインストール"
	@echo "   make cc-sdd-install-qwen         - Qwen Code向けインストール"
	@echo "   make cc-sdd-check                - インストール状態を確認"
	@echo "   make cc-sdd-update               - 最新版に更新"
	@echo "   make cc-sdd-update-alpha         - アルファ版を更新"
	@echo "   make cc-sdd-info                 - この情報を表示"
	@echo ""
	@echo "📚 リソース:"
	@echo "   GitHubリポジトリ: https://github.com/gotalab/cc-sdd"
	@echo "   NPMパッケージ: https://www.npmjs.com/package/cc-sdd"
	@echo "   関連記事: https://zenn.dev/gotalab/articles/3db0621ce3d6d2"
	@echo ""
	@echo "💡 クイックスタート例:"
	@echo "   # 新規プロジェクト"
	@echo "   /kiro:spec-init ユーザー認証システムをOAuthで構築"
	@echo "   /kiro:spec-requirements auth-system"
	@echo "   /kiro:spec-design auth-system"
	@echo "   /kiro:spec-tasks auth-system"
	@echo "   /kiro:spec-impl auth-system"
	@echo ""
	@echo "   # 既存プロジェクト（推奨）"
	@echo "   /kiro:steering"
	@echo "   /kiro:spec-init 既存認証にOAuthを追加"
	@echo "   /kiro:spec-requirements oauth-enhancement"
	@echo "   /kiro:validate-gap oauth-enhancement"
	@echo "   /kiro:spec-design oauth-enhancement"
	@echo "   /kiro:validate-design oauth-enhancement"
	@echo "   /kiro:spec-tasks oauth-enhancement"
	@echo "   /kiro:spec-impl oauth-enhancement"

.PHONY: cc-sdd
cc-sdd: cc-sdd-install ## cc-sddをインストール（エイリアス）
