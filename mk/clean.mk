# Clean関連のターゲット

# リポジトリのクリーンアップ
clean-repos:
	@echo "🧹 リポジトリをクリーンアップ中..."
	@if [ -d "$(DOTFILES_DIR)/.git" ]; then \
		cd $(DOTFILES_DIR) && git clean -fd; \
		echo "✅ gitリポジトリがクリーンアップされました"; \
	else \
		echo "⚠️  gitリポジトリが見つかりません"; \
	fi

# 全体のクリーンアップ
clean:
	@echo "🧹 全体のクリーンアップを実行中..."
	
	# 一時ファイルのクリーンアップ
	@echo "🗑️  一時ファイルをクリーンアップ中..."
	@rm -f $(HOME_DIR)/.wget-hsts || true
	@rm -rf $(HOME_DIR)/.cache/pip || true
	@rm -rf $(HOME_DIR)/.npm/_cacache || true
	@rm -rf $(HOME_DIR)/.cache/yarn || true
	
	# Homebrewのクリーンアップ
	@echo "🍺 Homebrewをクリーンアップ中..."
	@if command -v brew >/dev/null 2>&1; then \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		brew cleanup || true; \
		echo "✅ Homebrewがクリーンアップされました"; \
	else \
		echo "⚠️  Homebrewが見つかりません"; \
	fi

	# APTキャッシュのクリーンアップ
	@echo "📦 APTキャッシュをクリーンアップ中..."
	@sudo apt-get autoremove -y || true
	@sudo apt-get autoclean || true

	# Docker関連のクリーンアップ
	@echo "🐳 Docker関連をクリーンアップ中..."
	@if command -v docker >/dev/null 2>&1; then \
		docker system prune -f || true; \
		echo "✅ Dockerがクリーンアップされました"; \
	else \
		echo "⚠️  Dockerが見つかりません"; \
	fi

	# ログファイルのクリーンアップ
	@echo "📋 ログファイルをクリーンアップ中..."
	@sudo find /var/log -name "*.log" -type f -exec truncate -s 0 {} \; 2>/dev/null || true
	@journalctl --vacuum-time=3d || true

	@echo "✅ 全体のクリーンアップが完了しました。"
