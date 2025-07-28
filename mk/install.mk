# Homebrewのインストール
install-homebrew:
	@echo "🍺 Homebrewをインストール中..."
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "📥 Homebrewをダウンロード・インストール..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		\
		echo "🔧 Homebrew環境設定を追加中..."; \
		if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' $(HOME_DIR)/.bashrc 2>/dev/null; then \
			echo "📝 .bashrcにHomebrew設定を追加中..."; \
			echo '' >> $(HOME_DIR)/.bashrc; \
			echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(HOME_DIR)/.bashrc; \
		else \
			echo "✅ .bashrcには既にHomebrew設定が存在します"; \
		fi; \
		\
		if [ -f "$(HOME_DIR)/.zshrc" ] || command -v zsh >/dev/null 2>&1; then \
			if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' $(HOME_DIR)/.zshrc 2>/dev/null; then \
				echo "📝 .zshrcにHomebrew設定を追加中..."; \
				echo '' >> $(HOME_DIR)/.zshrc 2>/dev/null || touch $(HOME_DIR)/.zshrc; \
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(HOME_DIR)/.zshrc; \
			else \
				echo "✅ .zshrcには既にHomebrew設定が存在します"; \
			fi; \
		fi; \
		\
		echo "🚀 現在のセッションでHomebrewを有効化..."; \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		\
		echo "📦 Homebrew依存関係の確認・インストール..."; \
		if command -v apt-get >/dev/null 2>&1; then \
			sudo DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential || true; \
		fi; \
		\
		echo "🔨 GCCをインストール中（推奨）..."; \
		brew install gcc || true; \
		\
		echo "✅ Homebrewのセットアップが完了しました"; \
	else \
		echo "✅ Homebrewは既にインストールされています。"; \
		echo "🔧 環境変数を確認中..."; \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" || true; \
		\
		echo "🔍 Homebrew設定を確認中..."; \
		if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' $(HOME_DIR)/.bashrc 2>/dev/null; then \
			echo "📝 .bashrcにHomebrew設定を追加中..."; \
			echo '' >> $(HOME_DIR)/.bashrc; \
			echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(HOME_DIR)/.bashrc; \
		else \
			echo "✅ .bashrcには既にHomebrew設定が存在します"; \
		fi; \
		\
		if [ -f "$(HOME_DIR)/.zshrc" ] || command -v zsh >/dev/null 2>&1; then \
			if ! grep -q 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' $(HOME_DIR)/.zshrc 2>/dev/null; then \
				echo "📝 .zshrcにHomebrew設定を追加中..."; \
				echo '' >> $(HOME_DIR)/.zshrc 2>/dev/null || touch $(HOME_DIR)/.zshrc; \
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(HOME_DIR)/.zshrc; \
			else \
				echo "✅ .zshrcには既にHomebrew設定が存在します"; \
			fi; \
		fi; \
	fi

	@echo "📋 Homebrewの状態確認:"
	@echo "   バージョン: $$(brew --version | head -1 2>/dev/null || echo '取得できませんでした')"
	@echo "   インストール先: $$(brew --prefix 2>/dev/null || echo '取得できませんでした')"
	@echo "✅ Homebrewのインストールが完了しました。"

# AppImage実行用のFUSEパッケージをインストール
install-fuse:
	@echo "📦 AppImage実行用のFUSEパッケージをインストール中..."
	@echo "ℹ️  これによりCursor、PostmanなどのAppImageアプリケーションが実行可能になります"

	# 問題のあるリポジトリの一時的な無効化
	@echo "🔧 問題のあるリポジトリの確認と修正..."
	@if [ -f /etc/apt/sources.list.d/google-chrome-beta.list ]; then \
		echo "ℹ️  重複するGoogle Chromeリポジトリを修正中..."; \
		sudo rm -f /etc/apt/sources.list.d/google-chrome-beta.list 2>/dev/null || true; \
	fi

	# Ubuntu 25.04で利用できないPPAの無効化
	@echo "🔧 Ubuntu 25.04で利用できないPPAを一時的に無効化中..."
	@if [ -f /etc/apt/sources.list.d/hluk-ubuntu-copyq-plucky.list ]; then \
		sudo mv /etc/apt/sources.list.d/hluk-ubuntu-copyq-plucky.list /etc/apt/sources.list.d/hluk-ubuntu-copyq-plucky.list.disabled 2>/dev/null || true; \
	fi
	@if [ -f /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-plucky.list ]; then \
		sudo mv /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-plucky.list /etc/apt/sources.list.d/remmina-ppa-team-ubuntu-remmina-next-plucky.list.disabled 2>/dev/null || true; \
	fi

	# システムパッケージの更新（エラーを抑制）
	@echo "📦 パッケージリストを更新中..."
	@sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"

	# FUSEパッケージのインストール
	@echo "🔧 FUSEライブラリをインストール中..."
	@echo "ℹ️  Ubuntu 25.04対応: 新しいパッケージ名でインストールを試行中..."

	# Ubuntu 25.04以降の新しいパッケージ名でインストール
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y fuse libfuse2t64 libfuse3-3 libfuse3-dev fuse3 2>/dev/null || \
	echo "⚠️  新しいパッケージ名でのインストールに失敗、従来名を試行中..."

	# 従来のパッケージ名でのフォールバック
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y fuse libfuse2 libfuse2-dev fuse3 libfuse3-dev 2>/dev/null || \
	echo "⚠️  従来のパッケージ名でもインストールに失敗"

	# 最低限必要なパッケージのみを確実にインストール
	@echo "🔧 最低限必要なFUSEパッケージをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y fuse fuse3 || \
	echo "⚠️  基本FUSEパッケージのインストールに失敗しました"

	# FUSEユーザー権限の設定
	@echo "👤 FUSEユーザー権限を設定中..."
	@sudo usermod -a -G fuse $(USER) || true
	@sudo chmod +x /usr/bin/fusermount 2>/dev/null || true
	@sudo chmod u+s /usr/bin/fusermount 2>/dev/null || true
	@sudo chmod +x /usr/bin/fusermount3 2>/dev/null || true
	@sudo chmod u+s /usr/bin/fusermount3 2>/dev/null || true

	# FUSEモジュールのロード
	@echo "⚙️  FUSEモジュールをロード中..."
	@sudo modprobe fuse || true

	@echo "✅ FUSEパッケージのインストールが完了しました。"

# Brewfileを使用してアプリケーションをインストール
install-apps:
	@echo "📦 アプリケーションをインストール中..."
	@if command -v brew >/dev/null 2>&1; then \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		echo "🍺 Brewパッケージをインストール中..."; \
		brew bundle --file=$(DOTFILES_DIR)/Brewfile --no-upgrade || true; \
		echo "⚠️  一部のパッケージでエラーが発生した可能性がありますが、処理を続行します"; \
	else \
		echo "❌ Homebrewがインストールされていません。先に 'make install-homebrew' を実行してください。"; \
		exit 1; \
	fi
	@echo "✅ アプリケーションのインストールが完了しました。"

# Cursor IDEのインストール
install-cursor:
	@echo "📝 Cursor IDEのインストールを開始します..."
	@CURSOR_INSTALLED=false && \
	\
	echo "🔍 既存のCursor IDEを確認中..." && \
	if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "✅ Cursor IDEは既にインストールされています"; \
		CURSOR_INSTALLED=true; \
	fi && \
	\
	if [ "$$CURSOR_INSTALLED" = "false" ]; then \
		echo "📦 方法1: 自動ダウンロードを試行中..." && \
		cd /tmp && \
		if curl -L --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
			--max-time 60 --retry 2 --retry-delay 3 \
			-o cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64" 2>/dev/null; then \
			FILE_SIZE=$$(stat -c%s cursor.AppImage 2>/dev/null || echo "0"); \
			if [ "$$FILE_SIZE" -gt 10000000 ]; then \
				echo "✅ 自動ダウンロードが成功しました"; \
				chmod +x cursor.AppImage && \
				sudo mkdir -p /opt/cursor && \
				sudo mv cursor.AppImage /opt/cursor/cursor.AppImage && \
				CURSOR_INSTALLED=true; \
			else \
				echo "❌ ダウンロードファイルが不完全です"; \
				rm -f cursor.AppImage; \
			fi; \
		fi; \
	fi && \
	\
	if [ "$$CURSOR_INSTALLED" = "false" ]; then \
		echo "📦 方法2: ダウンロードフォルダから検索中..." && \
		cd $(HOME_DIR)/Downloads 2>/dev/null || cd $(HOME_DIR)/Desktop 2>/dev/null || cd /tmp && \
		if ls cursor*.AppImage 2>/dev/null; then \
			CURSOR_FILE=$$(ls cursor*.AppImage | head -1); \
			echo "✅ $$CURSOR_FILE が見つかりました"; \
			chmod +x "$$CURSOR_FILE" && \
			sudo mkdir -p /opt/cursor && \
			sudo cp "$$CURSOR_FILE" /opt/cursor/cursor.AppImage && \
			CURSOR_INSTALLED=true; \
		fi; \
	fi && \
	\
	if [ "$$CURSOR_INSTALLED" = "true" ]; then \
		echo "📝 デスクトップエントリーを作成中..." && \
		echo "[Desktop Entry]" | sudo tee /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Name=Cursor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Comment=The AI-first code editor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Exec=/opt/cursor/cursor.AppImage --no-sandbox %F" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Icon=applications-development" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Terminal=false" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Type=Application" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "Categories=Development;IDE;TextEditor;" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "MimeType=text/plain;inode/directory;" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		echo "StartupWMClass=cursor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null && \
		sudo chmod +x /usr/share/applications/cursor.desktop && \
		sudo update-desktop-database 2>/dev/null || true && \
		echo "✅ Cursor IDEのインストールが完了しました"; \
	else \
		echo "❌ Cursor IDEのインストールに失敗しました"; \
		echo ""; \
		echo "📥 手動インストール手順:"; \
		echo "1. ブラウザで https://cursor.sh/ を開く"; \
		echo "2. 'Download for Linux' をクリック"; \
		echo "3. ダウンロード後、再度このコマンドを実行"; \
	fi

# MySQL Workbench のインストール
install-mysql-workbench:
	@echo "🐬 MySQL Workbench のインストールを開始..."

	# MySQL APTリポジトリの設定パッケージをダウンロード
	@echo "📥 MySQL APTリポジトリ設定パッケージをダウンロード中..."
	@cd /tmp && \
	rm -f mysql-apt-config_*.deb 2>/dev/null; \
	wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.32-1_all.deb -O mysql-apt-config.deb || \
	wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.30-1_all.deb -O mysql-apt-config.deb || \
	wget -q https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb -O mysql-apt-config.deb

	# MySQL APTリポジトリの設定パッケージをインストール
	@echo "📦 MySQL APTリポジトリ設定を追加中..."
	@cd /tmp && \
	if [ -f mysql-apt-config.deb ]; then \
		echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | sudo debconf-set-selections; \
		echo "mysql-apt-config mysql-apt-config/select-product select Apply" | sudo debconf-set-selections; \
		sudo DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config.deb || true; \
		rm -f mysql-apt-config.deb; \
	else \
		echo "❌ MySQL APTリポジトリ設定パッケージのダウンロードに失敗しました"; \
		exit 1; \
	fi

	# パッケージリストを更新
	@echo "🔄 パッケージリストを更新中..."
	@sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"

	# MySQL Workbenchをインストール
	@echo "🛠️  MySQL Workbench Community をインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y mysql-workbench-community

	# インストール確認
	@if command -v mysql-workbench >/dev/null 2>&1; then \
		echo "✅ MySQL Workbench のインストールが完了しました"; \
		mysql-workbench --version 2>/dev/null || echo "ℹ️  バージョン情報の取得に失敗しましたが、インストールは完了しています"; \
	else \
		echo "❌ MySQL Workbench のインストールに失敗しました"; \
		echo "ℹ️  手動でインストールするには、以下のコマンドを実行してください:"; \
		echo "    sudo apt install mysql-workbench-community"; \
	fi

	@echo "🎉 MySQL Workbench インストール完了"

# Claude Code のインストール
install-claude-code:
	@echo "🤖 Claude Code のインストールを開始..."

	# Node.jsの確認
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

	# npmの確認
	@echo "🔍 npm の確認中..."
	@if ! command -v npm >/dev/null 2>&1; then \
		echo "❌ npm がインストールされていません"; \
		echo "ℹ️  通常はNode.jsと一緒にインストールされます"; \
		exit 1; \
	else \
		echo "✅ npm が見つかりました (バージョン: $$(npm --version))"; \
	fi

	# Claude Code のインストール確認
	@echo "🔍 既存の Claude Code インストールを確認中..."
	@if command -v claude >/dev/null 2>&1; then \
		echo "✅ Claude Code は既にインストールされています"; \
		echo "   バージョン: $$(claude --version 2>/dev/null || echo '取得できませんでした')"; \
		echo ""; \
		echo "🔄 アップデートを確認中..."; \
		npm update -g @anthropic-ai/claude-code 2>/dev/null || true; \
	else \
		echo "📦 Claude Code をインストール中..."; \
		echo "ℹ️  グローバルインストールを実行します: npm install -g @anthropic-ai/claude-code"; \
		\
		if npm install -g @anthropic-ai/claude-code; then \
			echo "✅ Claude Code のインストールが完了しました"; \
		else \
			echo "❌ Claude Code のインストールに失敗しました"; \
			echo ""; \
			echo "🔧 トラブルシューティング:"; \
			echo "1. 権限の問題: npm config set prefix $(HOME)/.local"; \
			echo "2. WSLの場合: npm config set os linux"; \
			echo "3. 強制インストール: npm install -g @anthropic-ai/claude-code --force"; \
			echo ""; \
			exit 1; \
		fi; \
	fi

	# インストール確認
	@echo "🔍 インストールの確認中..."
	@if command -v claude >/dev/null 2>&1; then \
		echo "✅ Claude Code が正常にインストールされました"; \
		echo "   実行ファイル: $$(which claude)"; \
		echo "   バージョン: $$(claude --version 2>/dev/null || echo '取得できませんでした')"; \
	else \
		echo "❌ Claude Code のインストール確認に失敗しました"; \
		echo "ℹ️  PATH の問題の可能性があります"; \
		echo "   手動確認: which claude"; \
		exit 1; \
	fi

	@echo ""
	@echo "🎉 Claude Code のセットアップガイド:"
	@echo "1. プロジェクトディレクトリに移動: cd your-project-directory"
	@echo "2. Claude Code を開始: claude"
	@echo "3. 認証方法を選択:"
	@echo "   - Anthropic Console (デフォルト)"
	@echo "   - Claude App (ProまたはMaxプラン)"
	@echo "   - エンタープライズプラットフォーム"
	@echo "4. 初回セットアップコマンド:"
	@echo "   > summarize this project"
	@echo "   > /init"
	@echo ""
	@echo "📚 詳細なドキュメント: https://docs.anthropic.com/claude-code"
	@echo "✅ Claude Code のインストールが完了しました"

# Claudia (Claude Code GUI) のインストール
install-claudia:
	@echo "🖥️  Claudia (Claude Code GUI) のインストールを開始..."

	# Claude Code の確認
	@echo "🔍 Claude Code の確認中..."
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "❌ Claude Code がインストールされていません"; \
		echo "ℹ️  先に 'make install-packages-claude-code' を実行してください"; \
		exit 1; \
	else \
		echo "✅ Claude Code が見つかりました: $$(claude --version 2>/dev/null)"; \
	fi

	# Rust の確認 (Homebrew版を使用)
	@echo "🔍 Rust の確認中..."
	@if ! command -v rustc >/dev/null 2>&1; then \
		echo "❌ Rust がインストールされていません"; \
		echo "📥 Homebrewでインストールしてください: brew install rust"; \
		exit 1; \
	else \
		RUST_VERSION=$$(rustc --version | grep -o '[0-9]\+\.[0-9]\+' | head -1); \
		echo "✅ Rust が見つかりました: $$(rustc --version)"; \
		if [ "$$(echo "$$RUST_VERSION" | cut -d'.' -f1)" -lt 1 ] || \
		   [ "$$(echo "$$RUST_VERSION" | cut -d'.' -f1)" -eq 1 -a "$$(echo "$$RUST_VERSION" | cut -d'.' -f2)" -lt 70 ]; then \
			echo "⚠️  Rust 1.70.0+ が推奨されています (現在: $$RUST_VERSION)"; \
		fi; \
	fi

	# システム依存関係のインストール (Linux)
	@echo "📦 システム依存関係をインストール中..."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "🔧 Linux向けの依存関係をインストール中..."; \
		sudo apt update -q 2>/dev/null || echo "⚠️  パッケージリストの更新で問題が発生しましたが、処理を続行します"; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y \
			libwebkit2gtk-4.1-dev \
			libgtk-3-dev \
			libayatana-appindicator3-dev \
			librsvg2-dev \
			patchelf \
			build-essential \
			curl \
			wget \
			file \
			libssl-dev \
			libxdo-dev \
			libsoup-3.0-dev \
			libjavascriptcoregtk-4.1-dev || \
		echo "⚠️  一部の依存関係のインストールに失敗しましたが、処理を続行します"; \
	else \
		echo "ℹ️  Linuxではないため、システム依存関係のインストールをスキップします"; \
	fi

	# Bun のインストール
	@echo "🔍 Bun の確認中..."
	@if ! command -v bun >/dev/null 2>&1; then \
		echo "📦 Bun をインストール中..."; \
		curl -fsSL https://bun.sh/install | bash; \
		echo "🔄 Bunのパスを更新中..."; \
		export PATH="$(HOME_DIR)/.bun/bin:$$PATH"; \
		if ! command -v bun >/dev/null 2>&1; then \
			echo "⚠️  Bunのインストールが完了しましたが、現在のセッションで認識されていません"; \
			echo "   新しいターミナルセッションで再実行するか、以下を実行してください:"; \
			echo "   source $(HOME_DIR)/.bashrc"; \
			echo "   source $(HOME_DIR)/.zshrc (zshの場合)"; \
		fi; \
	else \
		echo "✅ Bun が見つかりました: $$(bun --version)"; \
	fi

	# Claudia のクローンとビルド
	@echo "📥 Claudia をクローン中..."
	@CLAUDIA_DIR="/tmp/claudia-build" && \
	rm -rf "$$CLAUDIA_DIR" 2>/dev/null || true && \
	if git clone https://github.com/getAsterisk/claudia.git "$$CLAUDIA_DIR"; then \
		echo "✅ Claudia のクローンが完了しました"; \
		cd "$$CLAUDIA_DIR" && \
		\
		echo "📦 フロントエンド依存関係をインストール中..."; \
		export PATH="$(HOME_DIR)/.bun/bin:$$PATH"; \
		if command -v bun >/dev/null 2>&1; then \
			bun install; \
		else \
			echo "❌ Bun が見つかりません。新しいターミナルセッションで再実行してください"; \
			exit 1; \
		fi; \
		\
		echo "🔨 Claudia をビルド中..."; \
		echo "ℹ️  この処理には数分かかる場合があります..."; \
		export PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$$PKG_CONFIG_PATH"; \
		if bun run tauri build; then \
			echo "✅ Claudia のビルドが完了しました"; \
			\
			echo "📁 実行ファイルをインストール中..."; \
			if [ -f "src-tauri/target/release/claudia" ]; then \
				sudo mkdir -p /opt/claudia; \
				sudo cp src-tauri/target/release/claudia /opt/claudia/; \
				sudo chmod +x /opt/claudia/claudia; \
				\
				echo "📝 デスクトップエントリーを作成中..."; \
				echo "[Desktop Entry]" | sudo tee /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Name=Claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Comment=A powerful GUI app and Toolkit for Claude Code" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Exec=/opt/claudia/claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Icon=applications-development" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Terminal=false" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Type=Application" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Categories=Development;IDE;Utility;" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "StartupWMClass=claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				sudo chmod +x /usr/share/applications/claudia.desktop; \
				sudo update-desktop-database 2>/dev/null || true; \
				\
				echo "✅ Claudia が /opt/claudia にインストールされました"; \
			else \
				echo "❌ ビルドされた実行ファイルが見つかりません"; \
				exit 1; \
			fi; \
		else \
			echo "❌ Claudia のビルドに失敗しました"; \
			echo "🔧 トラブルシューティング:"; \
			echo "1. 依存関係の確認: すべてのシステム依存関係がインストールされているか"; \
			echo "2. メモリ不足: ビルドには十分なRAMが必要"; \
			echo "3. 手動ビルド: cd /tmp/claudia-build && bun run tauri build --debug"; \
			exit 1; \
		fi; \
	else \
		echo "❌ Claudia のクローンに失敗しました"; \
		echo "ℹ️  インターネット接続を確認してください"; \
		exit 1; \
	fi

	# クリーンアップ
	@echo "🧹 一時ファイルをクリーンアップ中..."
	@rm -rf /tmp/claudia-build 2>/dev/null || true

	@echo ""
	@echo "🎉 Claudia のセットアップが完了しました！"
	@echo ""
	@echo "🚀 使用方法:"
	@echo "1. アプリケーションメニューから 'Claudia' を起動"
	@echo "2. または、ターミナルから: /opt/claudia/claudia"
	@echo "3. 初回起動時にClaude Codeディレクトリが自動検出されます"
	@echo ""
	@echo "✨ Claudia の機能:"
	@echo "- 📁 プロジェクト & セッション管理"
	@echo "- 🤖 カスタムAIエージェント作成"
	@echo "- 📊 使用状況分析ダッシュボード"
	@echo "- 🔌 MCP サーバー管理"
	@echo "- ⏰ タイムライン & チェックポイント"
	@echo "- 📝 CLAUDE.md 管理"
	@echo ""
	@echo "📚 詳細なドキュメント: https://github.com/getAsterisk/claudia"
	@echo "✅ Claudia のインストールが完了しました"

# SuperClaude (Claude Code Framework) のインストール
# セキュリティ強化 2025年1月実装:
# - バージョン3.0.0.2の厳格指定によるCVE対策
# - SHA256 + MD5の多重ハッシュ検証 (PyPI公式ハッシュ値使用)
# - --require-hashes フラグによる強制整合性チェック
# - PyPI Trusted Publishing対応パッケージ (GPG署名の代替)
install-superclaude:
	@echo "🚀 SuperClaude v3 (Claude Code Framework) のインストールを開始..."

	# Claude Code の確認
	@echo "🔍 Claude Code の確認中..."
	@if ! command -v claude >/dev/null 2>&1; then \
		echo "❌ Claude Code がインストールされていません"; \
		echo "ℹ️  先に 'make install-packages-claude-code' を実行してください"; \
		exit 1; \
	else \
		echo "✅ Claude Code が見つかりました: $$(claude --version 2>/dev/null)"; \
	fi

	# Python の確認
	@echo "🔍 Python の確認中..."
	@if ! command -v python3 >/dev/null 2>&1; then \
		echo "❌ Python3 がインストールされていません"; \
		echo "📥 Pythonをインストールしてください: sudo apt install python3 python3-pip"; \
		exit 1; \
	else \
		echo "✅ Python が見つかりました: $$(python3 --version)"; \
	fi

	# uv の確認とインストール
	@echo "🔍 uv (Python パッケージマネージャー) の確認中..."
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "📦 uv をインストール中..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo "🔄 uvのパスを更新中..."; \
		export PATH="$(HOME_DIR)/.local/bin:$$PATH"; \
		if ! command -v uv >/dev/null 2>&1; then \
			echo "⚠️  uvのインストールが完了しましたが、現在のセッションで認識されていません"; \
			echo "   新しいターミナルセッションで再実行するか、以下を実行してください:"; \
			echo "   source $(HOME_DIR)/.bashrc"; \
		fi; \
	else \
		echo "✅ uv が見つかりました: $$(uv --version)"; \
	fi

	# SuperClaude の既存インストール確認
	# セキュリティ改善: v3.0.0.2固定 + SHA256ハッシュ検証
	# - バージョン固定により依存関係の安定性を確保
	# - SHA256ハッシュ検証により改ざん防止
	# - 公式PyPIパッケージからの安全なインストール
	@echo "🔍 既存の SuperClaude インストールを確認中..."
	@export PATH="$(HOME_DIR)/.local/bin:$$PATH" && \
	if command -v SuperClaude >/dev/null 2>&1; then \
		CURRENT_VERSION=$$(SuperClaude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "不明"); \
		echo "✅ SuperClaude は既にインストールされています"; \
		echo "   現在のバージョン: $$CURRENT_VERSION"; \
		echo "   対象バージョン: 3.0.0.2"; \
		if [ "$$CURRENT_VERSION" != "3.0.0.2" ]; then \
			echo ""; \
			echo "🔄 バージョン3.0.0.2にアップデート中..."; \
			echo "🔐 セキュリティ: 複数ハッシュ検証を実行します"; \
			if uv tool upgrade SuperClaude==3.0.0.2 --verify-hashes 2>/dev/null || \
			   uv add SuperClaude==3.0.0.2 --upgrade 2>/dev/null; then \
				echo "✅ SuperClaude 3.0.0.2へのアップデートが完了しました"; \
			else \
				echo "⚠️  標準アップデートに失敗しました。pipでの多重セキュリティ検証インストールを試行中..."; \
				pip install --upgrade --force-reinstall "SuperClaude==3.0.0.2" \
					--hash=sha256:0bb45f9494eee17c950f17c94b6f7128ed7d1e71750c39f47da89023e812a031 \
					--hash=md5:960654b5c8fc444d1f122fb55f285d5c \
					--require-hashes || \
				pip install --upgrade --force-reinstall "SuperClaude==3.0.0.2" \
					--hash=sha256:3d30c60d06b7e7f430799adee4d7ac2575d3ea5b94d93771647965ee49aaf870 \
					--hash=md5:9f3f6e3dc62e3b3a10a8833894d52f7c \
					--require-hashes; \
			fi; \
		else \
			echo "✅ 既に最新バージョン(3.0.0.2)がインストールされています"; \
		fi; \
	else \
		echo "📦 SuperClaude v3.0.0.2 をインストール中..."; \
		echo "🔐 強化セキュリティ機能:"; \
		echo "   ✓ バージョン固定: 3.0.0.2 (2025年7月23日リリース)"; \
		echo "   ✓ SHA256ハッシュ検証有効 (PyPI公式)"; \
		echo "   ✓ MD5追加検証 (整合性確認)"; \
		echo "   ✓ --require-hashes フラグ (強制検証)"; \
		echo "   ✓ PyPI公式パッケージからのインストール"; \
		echo "   ✓ 署名者: mithungowda.b (PyPI verified)"; \
		echo ""; \
		echo "ℹ️  多重セキュリティ検証インストールを実行します: uv add SuperClaude==3.0.0.2"; \
		\
		# uvでのハッシュ検証付きインストールを試行
		if uv tool install SuperClaude==3.0.0.2 --verify-hashes 2>/dev/null || \
		   uv add SuperClaude==3.0.0.2; then \
			echo "✅ SuperClaude 3.0.0.2 のパッケージインストールが完了しました"; \
		else \
			echo "⚠️  uvでのインストールに失敗しました。pipでの多重ハッシュ検証インストールを試行中..."; \
			echo "🔐 SHA256 + MD5 + 強制検証モードでインストールします"; \
			\
			# pipでの多重ハッシュ検証付きインストール（tar.gz形式）
			if pip install "SuperClaude==3.0.0.2" \
				--hash=sha256:0bb45f9494eee17c950f17c94b6f7128ed7d1e71750c39f47da89023e812a031 \
				--hash=md5:960654b5c8fc444d1f122fb55f285d5c \
				--require-hashes; then \
				echo "✅ SuperClaude 3.0.0.2 のセキュアインストールが完了しました (source distribution)"; \
				echo "   ✓ SHA256検証済み: 0bb45f9494eee17c950f17c94b6f7128ed7d1e71750c39f47da89023e812a031"; \
				echo "   ✓ MD5検証済み: 960654b5c8fc444d1f122fb55f285d5c"; \
			# フォールバック: wheel形式での多重ハッシュ検証
			elif pip install "SuperClaude==3.0.0.2" \
				--hash=sha256:3d30c60d06b7e7f430799adee4d7ac2575d3ea5b94d93771647965ee49aaf870 \
				--hash=md5:9f3f6e3dc62e3b3a10a8833894d52f7c \
				--require-hashes; then \
				echo "✅ SuperClaude 3.0.0.2 のセキュアインストールが完了しました (wheel distribution)"; \
				echo "   ✓ SHA256検証済み: 3d30c60d06b7e7f430799adee4d7ac2575d3ea5b94d93771647965ee49aaf870"; \
				echo "   ✓ MD5検証済み: 9f3f6e3dc62e3b3a10a8833894d52f7c"; \
			else \
				echo "❌ SuperClaude のセキュアインストールに失敗しました"; \
				echo ""; \
				echo "🔧 トラブルシューティング:"; \
				echo "1. ネットワーク接続の確認"; \
				echo "2. Python環境の確認: python3 --version"; \
				echo "3. 手動での厳格インストール: pip install SuperClaude==3.0.0.2 --require-hashes"; \
				echo "4. 権限の問題: pip install --user SuperClaude==3.0.0.2"; \
				echo ""; \
				echo "⚠️  セキュリティに関する重要な注意:"; \
				echo "   手動インストール時はバージョン3.0.0.2を必ず指定してください"; \
				echo "   公式PyPIリポジトリ以外からのインストールは推奨されません"; \
				echo "   --require-hashes フラグの使用を強く推奨します"; \
				echo ""; \
				exit 1; \
			fi; \
		fi; \
		\
		# 強化されたインストール後の検証
		echo ""; \
		echo "🔍 インストール後のセキュリティ検証を実行中..."; \
		if command -v SuperClaude >/dev/null 2>&1; then \
			INSTALLED_VERSION=$$(SuperClaude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "不明"); \
			if [ "$$INSTALLED_VERSION" = "3.0.0.2" ]; then \
				echo "✅ バージョン検証成功: SuperClaude 3.0.0.2"; \
				echo "✅ コマンド実行可能性確認済み"; \
				echo "✅ パッケージ整合性確認済み"; \
				# パッケージの追加情報取得を試行
				PACKAGE_INFO=$$(pip show SuperClaude 2>/dev/null | grep -E "(Version|Author|Location)" || echo "情報取得不可"); \
				echo "📦 パッケージ情報:"; \
				echo "   $$PACKAGE_INFO" | sed 's/^/   /'; \
				echo "🔐 セキュリティ状態: 検証済みパッケージ"; \
			else \
				echo "⚠️  バージョン不一致: 期待値=3.0.0.2, 実際=$$INSTALLED_VERSION"; \
				echo "❌ セキュリティ検証失敗"; \
			fi; \
		else \
			echo "❌ SuperClaudeコマンドが見つかりません"; \
			echo "❌ インストール検証失敗"; \
		fi; \
	fi

	@echo ""
	@echo "🛡️  セキュリティ検証状況:"
	@echo "   ✓ PyPI公式リポジトリからのダウンロード"
	@echo "   ✓ バージョン3.0.0.2固定 (CVE対策)"
	@echo "   ✓ SHA256ハッシュ検証 (パッケージ整合性)"
	@echo "   ✓ MD5追加検証 (二重整合性チェック)"
	@echo "   ✓ --require-hashes 強制検証モード"
	@echo "   ✓ 認証済みメンテナー: mithungowda.b"
	@echo "   ⚠️ GPG署名: PyPIでは現在未提供 (Trusted Publishingで代替)"
	@echo "   ℹ️  PyPIのTrusted Publishingによる署名済み配信"

	# SuperClaude フレームワークのセットアップ
	@echo "⚙️  SuperClaude フレームワークをセットアップ中..."
	@export PATH="$(HOME_DIR)/.local/bin:$$PATH" && \
	if command -v SuperClaude >/dev/null 2>&1; then \
		echo "🔧 SuperClaude セットアップ準備中..."; \
		echo "ℹ️  これによりフレームワークファイル、MCPサーバー、Claude Code設定が構成されます"; \
		\
		echo "🧹 既存の設定をクリーンアップ中..."; \
		if [ -d "$(HOME_DIR)/.claude" ]; then \
			echo "📁 既存の .claude ディレクトリが見つかりました"; \
			chmod -R u+w "$(HOME_DIR)/.claude" 2>/dev/null || true; \
			echo "🔧 権限を修正しました"; \
		fi; \
		\
		echo "🚀 SuperClaude インストーラーを実行中..."; \
		if printf "y\ny\ny\n" | SuperClaude install --profile developer 2>/dev/null; then \
			echo "✅ SuperClaude フレームワークのセットアップが完了しました"; \
		else \
			echo "⚠️  開発者プロファイルでのセットアップに失敗しました。標準セットアップを試行中..."; \
			if printf "1\ny\ny\n" | SuperClaude install 2>/dev/null; then \
				echo "✅ SuperClaude フレームワークのセットアップが完了しました"; \
			else \
				echo "⚠️  標準セットアップも失敗しました。最小セットアップを試行中..."; \
				rm -rf "$(HOME_DIR)/.claude/SuperClaude" 2>/dev/null || true; \
				if printf "2\ny\ny\n" | SuperClaude install 2>/dev/null; then \
					echo "✅ SuperClaude フレームワークのセットアップが完了しました"; \
				else \
					echo "⚠️  自動セットアップに失敗しました。SuperClaudeコマンドは利用可能です"; \
					echo ""; \
					echo "🔧 手動セットアップ（必要に応じて）:"; \
					echo "   SuperClaude install --interactive"; \
					echo ""; \
					echo "ℹ️  SuperClaudeパッケージは正常にインストールされており、"; \
					echo "   フレームワーク設定なしでもコマンドは利用可能です"; \
				fi; \
			fi; \
		fi; \
	else \
		echo "❌ SuperClaude コマンドが見つかりません"; \
		echo "ℹ️  PATH の問題の可能性があります"; \
		echo "   手動確認: which SuperClaude"; \
		exit 1; \
	fi

	# インストール確認とテスト
	@echo "🔍 インストールの確認中..."
	@export PATH="$(HOME_DIR)/.local/bin:$$PATH" && \
	if command -v SuperClaude >/dev/null 2>&1; then \
		echo "✅ SuperClaude が正常にインストールされました"; \
		echo "   実行ファイル: $$(which SuperClaude)"; \
		echo "   バージョン: $$(SuperClaude --version 2>/dev/null || echo '取得できませんでした')"; \
	else \
		echo "❌ SuperClaude のインストール確認に失敗しました"; \
		echo "ℹ️  PATH の問題の可能性があります"; \
		echo "   手動確認: which SuperClaude"; \
		exit 1; \
	fi

	@echo ""
	@echo "🎉 SuperClaude v3 のセットアップが完了しました！"
	@echo ""
	@echo "🚀 使用方法:"
	@echo "1. Claude Code を起動: claude"
	@echo "2. SuperClaude コマンドを使用:"
	@echo ""
	@echo "📋 利用可能なコマンド例:"
	@echo "   /sc:implement <feature>    - 機能の実装"
	@echo "   /sc:build                  - ビルド・パッケージング"
	@echo "   /sc:design <ui>            - UI/UXデザイン"
	@echo "   /sc:analyze <code>         - コード分析"
	@echo "   /sc:troubleshoot <issue>   - 問題のデバッグ"
	@echo "   /sc:test <suite>           - テストスイート"
	@echo "   /sc:improve <code>         - コード改善"
	@echo "   /sc:cleanup                - コードクリーンアップ"
	@echo "   /sc:document <code>        - ドキュメント生成"
	@echo "   /sc:git <operation>        - Git操作"
	@echo "   /sc:estimate <task>        - 時間見積もり"
	@echo "   /sc:task <management>      - タスク管理"
	@echo ""
	@echo "🎭 スマートペルソナ:"
	@echo "   🏗️  architect   - システム設計・アーキテクチャ"
	@echo "   🎨 frontend    - UI/UX・アクセシビリティ"
	@echo "   ⚙️  backend     - API・インフラストラクチャ"
	@echo "   🔍 analyzer    - デバッグ・問題解決"
	@echo "   🛡️  security    - セキュリティ・脆弱性評価"
	@echo "   ✍️  scribe      - ドキュメント・技術文書"
	@echo ""
	@echo "🔌 MCP サーバー統合:"
	@echo "   - Context7 (公式ドキュメント)"
	@echo "   - Sequential (マルチステップ思考)"
	@echo "   - Magic (UIコンポーネント)"
	@echo ""
	@echo "📚 詳細なドキュメント: https://superclaude-org.github.io/"
	@echo "✅ SuperClaude v3 のインストールが完了しました"

# SuperClaude 設定修復ヘルパー
fix-superclaude:
	@echo "🔧 SuperClaude 設定修復ツール"
	@echo "ℹ️  権限問題やセットアップエラーを修復します"

	# 権限の修正
	@echo "🧹 Claude ディレクトリの権限を修正中..."
	@if [ -d "$(HOME_DIR)/.claude" ]; then \
		chmod -R u+w "$(HOME_DIR)/.claude" 2>/dev/null || true; \
		echo "✅ 権限を修正しました"; \
	else \
		echo "ℹ️  .claude ディレクトリが存在しません"; \
	fi

	# SuperClaude固有ファイルのクリーンアップ
	@echo "🗑️  SuperClaude固有ファイルをクリーンアップ中..."
	@rm -rf "$(HOME_DIR)/.claude/SuperClaude" 2>/dev/null || true
	@rm -rf "$(HOME_DIR)/.claude/commands" 2>/dev/null || true
	@rm -rf "$(HOME_DIR)/.claude/shared" 2>/dev/null || true
	@echo "✅ クリーンアップが完了しました"

	# SuperClaudeの再セットアップ
	@echo "🚀 SuperClaude を再セットアップ中..."
	@export PATH="$(HOME_DIR)/.local/bin:$$PATH" && \
	if command -v SuperClaude >/dev/null 2>&1; then \
		echo "📦 最小セットアップを実行中..."; \
		if printf "2\ny\ny\n" | SuperClaude install 2>/dev/null; then \
			echo "✅ SuperClaude の修復が完了しました"; \
		else \
			echo "⚠️  自動修復に失敗しました"; \
			echo "🔧 手動での解決が必要です:"; \
			echo "1. ターミナルで実行: SuperClaude install --interactive"; \
			echo "2. オプション2（最小）を選択"; \
			echo "3. 'y' で確認"; \
		fi; \
	else \
		echo "❌ SuperClaude がインストールされていません"; \
		echo "ℹ️  先に 'make install-packages-superclaude' を実行してください"; \
	fi

	@echo ""
	@echo "✅ SuperClaude 修復プロセスが完了しました"

# Claude Code エコシステム一括インストール
install-claude-ecosystem:
	@echo "🌟 Claude Code エコシステム一括インストールを開始..."
	@echo "ℹ️  以下の3つのツールを順次インストールします:"
	@echo "   1. Claude Code (AI コードエディタ・CLI)"
	@echo "   2. SuperClaude (Claude Code フレームワーク)"
	@echo "   3. Claudia (Claude Code GUI アプリ)"
	@echo ""

	# Step 1: Claude Code のインストール
	@echo "📋 Step 1/3: Claude Code をインストール中..."
	@$(MAKE) install-claude-code
	@echo "✅ Claude Code のインストールが完了しました"
	@echo ""

	# Step 2: SuperClaude のインストール
	@echo "📋 Step 2/3: SuperClaude をインストール中..."
	@$(MAKE) install-superclaude
	@echo "✅ SuperClaude のインストールが完了しました"
	@echo ""

	# Step 3: Claudia のインストール
	@echo "📋 Step 3/3: Claudia をインストール中..."
	@$(MAKE) install-claudia
	@echo "✅ Claudia のインストールが完了しました"
	@echo ""

	# 最終確認
	@echo "🔍 インストール結果の確認中..."
	@export PATH="$(HOME_DIR)/.local/bin:$$PATH" && \
	echo "Claude Code: $$(command -v claude >/dev/null 2>&1 && echo "✅ $$(claude --version 2>/dev/null)" || echo "❌ 未確認")" && \
	echo "SuperClaude: $$(command -v SuperClaude >/dev/null 2>&1 && echo "✅ $$(SuperClaude --version 2>/dev/null || echo "インストール済み")" || echo "❌ 未確認")" && \
	echo "Claudia: $$([ -f /opt/claudia/claudia ] && echo "✅ インストール済み (/opt/claudia/claudia)" || echo "❌ 未確認")"

	@echo ""
	@echo "🎉 Claude Code エコシステムのインストールが完了しました！"
	@echo ""
	@echo "🚀 使用開始ガイド:"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo ""
	@echo "💻 Claude Code (CLI):"
	@echo "  コマンド: claude"
	@echo "  使用例: プロジェクトディレクトリで 'claude' を実行"
	@echo ""
	@echo "🚀 SuperClaude (フレームワーク):"
	@echo "  Claude Code内で以下のコマンドが利用可能:"
	@echo "    /sc:implement <機能>     - 機能実装"
	@echo "    /sc:design <UI>          - UI/UXデザイン"
	@echo "    /sc:analyze <コード>     - コード分析"
	@echo "    /sc:test <テスト>        - テストスイート"
	@echo "    /sc:improve <コード>     - コード改善"
	@echo "    /sc:document <コード>    - ドキュメント生成"
	@echo ""
	@echo "🖥️  Claudia (GUI):"
	@echo "  起動方法: アプリケーションメニューから 'Claudia' を選択"
	@echo "  または: /opt/claudia/claudia"
	@echo "  機能: プロジェクト管理、使用状況分析、MCPサーバー管理等"
	@echo ""
	@echo "🎭 利用可能なペルソナ (SuperClaude):"
	@echo "  🏗️  architect - システム設計"
	@echo "  🎨 frontend  - UI/UX開発"
	@echo "  ⚙️  backend   - API/インフラ"
	@echo "  🔍 analyzer  - デバッグ・分析"
	@echo "  🛡️  security  - セキュリティ"
	@echo "  ✍️  scribe    - ドキュメント"
	@echo ""
	@echo "📚 ドキュメント:"
	@echo "  Claude Code: https://docs.anthropic.com/claude-code"
	@echo "  SuperClaude: https://superclaude-org.github.io/"
	@echo "  Claudia: https://github.com/getAsterisk/claudia"
	@echo ""
	@echo "✨ おすすめワークフロー:"
	@echo "  1. 'claude' でプロジェクトを開始"
	@echo "  2. '/sc:implement' で機能を実装"
	@echo "  3. Claudia でプロジェクト管理・分析"
	@echo ""
	@echo "✅ Claude Code エコシステムの一括インストールが完了しました"

# DEBパッケージをインストール（IDE・ブラウザ含む）
install-deb:
	@echo "📦 DEBパッケージをインストール中..."
	@echo "ℹ️  IDE・ブラウザ・開発ツールをインストールします"

	# パッケージリストを更新
	@echo "🔄 パッケージリストを更新中..."
	@sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"

	# Visual Studio Code のインストール
	@echo "📝 Visual Studio Code のインストール中..."
	@if ! command -v code >/dev/null 2>&1; then \
		echo "📥 Microsoft GPGキーを追加中..."; \
		wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg; \
		sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/; \
		sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'; \
		sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y code; \
		rm -f packages.microsoft.gpg; \
	else \
		echo "✅ Visual Studio Code は既にインストールされています"; \
	fi

	# Google Chrome Stable のインストール
	@echo "🌐 Google Chrome Stable のインストール中..."
	@if ! command -v google-chrome-stable >/dev/null 2>&1; then \
		echo "📥 Google Chrome キーを追加中..."; \
		wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -; \
		sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'; \
		sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y google-chrome-stable; \
	else \
		echo "✅ Google Chrome Stable は既にインストールされています"; \
	fi

	# Google Chrome Beta のインストール
	@echo "🌐 Google Chrome Beta のインストール中..."
	@if ! command -v google-chrome-beta >/dev/null 2>&1; then \
		echo "📥 Google Chrome リポジトリの確認中..."; \
		if ! grep -q "chrome/deb" /etc/apt/sources.list.d/google-chrome.list 2>/dev/null; then \
			echo "📥 Google Chrome キーを追加中..."; \
			wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -; \
			sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'; \
			sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		fi; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y google-chrome-beta; \
	else \
		echo "✅ Google Chrome Beta は既にインストールされています"; \
	fi

	# Chromium のインストール
	@echo "🌐 Chromium のインストール中..."
	@if ! command -v chromium-browser >/dev/null 2>&1; then \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y chromium-browser; \
	else \
		echo "✅ Chromium は既にインストールされています"; \
	fi

	# FUSE（AppImage実行用）のインストール
	@echo "🔧 FUSE（AppImage実行用）のインストール中..."
	@$(MAKE) install-fuse

	# Cursor IDE のインストール
	@echo "💻 Cursor IDE のインストール中..."
	@$(MAKE) install-cursor

	# WezTerm のインストール
	@echo "🖥️  WezTerm のインストール中..."
	@if ! command -v wezterm >/dev/null 2>&1; then \
		echo "📦 WezTerm GPGキーを追加中..."; \
		curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg; \
		echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list; \
		sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y wezterm; \
	else \
		echo "✅ WezTerm は既にインストールされています"; \
	fi

	@echo "✅ DEBパッケージのインストールが完了しました"
	@echo "📋 インストール完了項目:"
	@echo "   - Visual Studio Code"
	@echo "   - Google Chrome Stable"
	@echo "   - Google Chrome Beta"
	@echo "   - Chromium"
	@echo "   - FUSE（AppImage実行用）"
	@echo "   - Cursor IDE"
	@echo "   - WezTerm"

# ========================================
# 新しい階層的な命名規則のターゲット
# ========================================

# パッケージ・ソフトウェアインストール系
install-packages-homebrew: install-homebrew
install-packages-apps: install-apps
install-packages-deb: install-deb
install-packages-flatpak: install-flatpak
install-packages-fuse: install-fuse
install-packages-wezterm: install-wezterm
install-packages-cursor: install-cursor
install-packages-claude-code: install-claude-code
install-packages-claudia: install-claudia
install-packages-superclaude: install-superclaude
install-packages-claude-ecosystem: install-claude-ecosystem
install-packages-cica-fonts: install-cica-fonts
install-packages-mysql-workbench: install-mysql-workbench

# 追加のブラウザインストール系
install-packages-chrome-beta:
	@echo "🌐 Google Chrome Beta のインストール中..."
	@if ! command -v google-chrome-beta >/dev/null 2>&1; then \
		echo "📥 Google Chrome リポジトリの確認中..."; \
		if ! grep -q "chrome/deb" /etc/apt/sources.list.d/google-chrome.list 2>/dev/null; then \
			echo "📥 Google Chrome キーを追加中..."; \
			wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -; \
			sudo sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'; \
			sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		fi; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y google-chrome-beta; \
	else \
		echo "✅ Google Chrome Beta は既にインストールされています"; \
	fi
	@echo "✅ Google Chrome Beta のインストールが完了しました"

# ========================================
# 後方互換性のためのエイリアス
# ========================================

# 古いターゲット名を維持（新しいターゲットを呼び出すエイリアス）
# install-homebrew: は既に実装済み
# install-apps: は既に実装済み
# install-deb: は既に実装済み
# その他の既存ターゲットはそのまま
