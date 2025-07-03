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
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $(HOME_DIR)/.zshrci; \
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
