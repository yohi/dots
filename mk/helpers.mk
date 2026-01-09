# ============================================================
# Helpers: 共通チェック関数・ユーティリティ
# ============================================================

# Node.js の確認 (18+ required)
check-nodejs:
	@echo "🔍 Node.js の確認中..."
	@if ! command -v node >/dev/null 2>&1; then \
		echo "❌ Node.js がインストールされていません"; \
		echo ""; \
		echo "📥 Node.js のインストール手順:"; \
		echo "1. Homebrewを使用: brew install node"; \
		echo "2. NodeVersionManager(nvm)を使用: https://github.com/nvm-sh/nvm"; \
		echo "3. 公式サイト: https://nodejs.org/"; \
		echo ""; \
		echo "ℹ️  Node.js 18+ が必要です"; \
		exit 1; \
	else \
		NODE_VERSION=$$(node --version | cut -d'v' -f2 | cut -d'.' -f1); \
		echo "✅ Node.js が見つかりました (バージョン: $$(node --version))"; \
		if [ "$$NODE_VERSION" -lt 18 ]; then \
			echo "⚠️  Node.js 18+ が推奨されています (現在: $$(node --version))"; \
			echo "   古いバージョンでも動作する可能性がありますが、問題が発生する場合があります"; \
		fi; \
	fi
