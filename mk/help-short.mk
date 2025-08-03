# 簡潔なヘルプ機能

.PHONY: help-short
help-short: ## 簡潔なヘルプ表示
	@echo "🚀 Ubuntu開発環境セットアップ - 簡潔ヘルプ"
	@echo ""
	@echo "🎯 よく使うコマンド:"
	@echo "  make           - インタラクティブメニュー"
	@echo "  make m         - メニュー（短縮形）"
	@echo "  make quick     - クイックセットアップ"
	@echo "  make dev-setup - 開発者セットアップ"
	@echo "  make full      - フルセットアップ"
	@echo "  make u         - Cursorアップデート"
	@echo "  make c         - Cursorバージョン確認"
	@echo "  make status    - システム状態確認"
	@echo ""
	@echo "📂 カテゴリ別:"
	@echo "  make sys       - システム設定"
	@echo "  make pkg       - パッケージ管理"
	@echo "  make conf      - 設定ファイル"
	@echo "  make mgmt      - アップデート・管理"
	@echo ""
	@echo "📊 段階的セットアップ:"
	@echo "   make stage1 (s1)    - ステージ1: システム基盤"
	@echo "   make stage2 (s2)    - ステージ2: 必須アプリ"
	@echo "   make stage3 (s3)    - ステージ3: 設定ファイル"
	@echo "   make stage4 (s4)    - ステージ4: システム設定"
	@echo "   make stage5 (s5)    - ステージ5: オプション機能"
	@echo "   make stages         - 段階的セットアップメニュー"
	@echo "   make stage-status   - 進捗確認"
	@echo "   make next-stage     - 次のステージ提案"
	@echo ""
	@echo "💡 詳細: make help | 全メニュー: make menu"

.PHONY: quick-help
quick-help: help-short  ## エイリアス: 簡潔ヘルプ
