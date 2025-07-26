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

# Cursor IDEのバージョン更新
# 使用方法:
#   make update-cursor           (stableトラック)
#   make update-cursor TRACK=latest  (latestトラック)
update-cursor:
	@echo "🔄 Cursor IDEのバージョン更新を開始します..."
	@TRACK_VALUE="$(if $(TRACK),$(TRACK),stable)" && \
	echo "📋 リリーストラック: $$TRACK_VALUE" && \
	CURRENT_VERSION="" && \
	NEW_VERSION="" && \
	UPDATE_NEEDED=false && \
	\
	echo "🔍 現在のCursor IDEバージョンを確認中..." && \
	if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "✅ 既存のCursor IDEが見つかりました"; \
		CURRENT_VERSION=$$(stat -c%Y /opt/cursor/cursor.AppImage 2>/dev/null || echo "unknown"); \
		echo "📅 現在のファイル更新日時: $$(date -d @$$CURRENT_VERSION '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo '不明')"; \
	else \
		echo "❌ Cursor IDEがインストールされていません"; \
		echo "💡 'make install-cursor' でインストールを行ってください"; \
		exit 1; \
	fi && \
	\
	echo "📦 最新版をダウンロード中..." && \
	cd /tmp && \
	rm -f cursor_new.AppImage cursor_download_info.json 2>/dev/null || true && \
	DOWNLOAD_SUCCESS=false && \
	\
	echo "🔍 最新バージョン情報を取得中..." && \
	if curl -s --max-time 30 "https://cursor.com/api/download?platform=linux-x64&releaseTrack=$$TRACK_VALUE" \
		-o cursor_download_info.json 2>/dev/null; then \
		DOWNLOAD_URL=$$(cat cursor_download_info.json | grep -o '"downloadUrl":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo ""); \
		VERSION=$$(cat cursor_download_info.json | grep -o '"version":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "unknown"); \
		if [ -n "$$DOWNLOAD_URL" ]; then \
			echo "📋 最新バージョン: $$VERSION"; \
			echo "🔗 ダウンロード中: $$DOWNLOAD_URL"; \
			if curl -L --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
				--max-time 120 --retry 3 --retry-delay 5 \
				-o cursor_new.AppImage "$$DOWNLOAD_URL" 2>/dev/null; then \
				FILE_SIZE=$$(stat -c%s cursor_new.AppImage 2>/dev/null || echo "0"); \
				if [ "$$FILE_SIZE" -gt 50000000 ]; then \
					echo "✅ 最新版のダウンロードが成功しました ($$(echo "scale=1; $$FILE_SIZE/1024/1024" | bc 2>/dev/null || echo "$$FILE_SIZE")MB)"; \
					chmod +x cursor_new.AppImage; \
					DOWNLOAD_SUCCESS=true; \
				else \
					echo "⚠️  ダウンロードファイルのサイズが小さすぎます ($$FILE_SIZE bytes)"; \
					rm -f cursor_new.AppImage; \
				fi; \
			else \
				echo "❌ ダウンロード失敗: $$DOWNLOAD_URL"; \
			fi; \
		else \
			echo "❌ APIレスポンスからダウンロードURLを取得できませんでした"; \
		fi; \
	else \
		echo "❌ Cursor APIからバージョン情報を取得できませんでした"; \
		echo "🔗 フォールバック: 古いダウンロードURLを試行中..."; \
		if curl -L --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
			--max-time 60 --retry 2 --retry-delay 3 \
			-o cursor_new.AppImage "https://downloader.cursor.sh/linux/appImage/x64" 2>/dev/null; then \
			FILE_SIZE=$$(stat -c%s cursor_new.AppImage 2>/dev/null || echo "0"); \
			if [ "$$FILE_SIZE" -gt 50000000 ]; then \
				echo "✅ フォールバックダウンロードが成功しました ($$(echo "scale=1; $$FILE_SIZE/1024/1024" | bc 2>/dev/null || echo "$$FILE_SIZE")MB)"; \
				chmod +x cursor_new.AppImage; \
				DOWNLOAD_SUCCESS=true; \
			else \
				echo "⚠️  ダウンロードファイルのサイズが小さすぎます ($$FILE_SIZE bytes)"; \
				rm -f cursor_new.AppImage; \
			fi; \
		else \
			echo "❌ フォールバックダウンロードも失敗しました"; \
		fi; \
	fi; \
	rm -f cursor_download_info.json 2>/dev/null || true; \
	\
	if [ "$$DOWNLOAD_SUCCESS" = "false" ]; then \
		echo ""; \
		echo "❌ すべての自動ダウンロードが失敗しました"; \
		echo ""; \
		echo "🔍 診断情報:"; \
		echo "   • downloader.cursor.sh - ドメインが存在しません"; \
		echo "   • cursor.com/download - 404エラーまたは不正なファイル"; \
		echo ""; \
		echo "📥 手動ダウンロード手順:"; \
		echo "1. ブラウザで https://cursor.com/ を開く"; \
		echo "2. 'Download for Linux' または 'Linux' ボタンをクリック"; \
		echo "3. ダウンロードした .AppImage ファイルを確認:"; \
		echo "   ls -la ~/Downloads/cursor*.AppImage"; \
		echo ""; \
		echo "4. 既存ファイルをバックアップ:"; \
		echo "   sudo cp /opt/cursor/cursor.AppImage /opt/cursor/cursor.AppImage.backup"; \
		echo ""; \
		echo "5. 新しいファイルを配置:"; \
		echo "   sudo cp ~/Downloads/cursor*.AppImage /opt/cursor/cursor.AppImage"; \
		echo "   sudo chmod +x /opt/cursor/cursor.AppImage"; \
		echo ""; \
		echo "6. 再度このコマンドを実行して更新を確認:"; \
		echo "   make update-cursor"; \
		echo ""; \
		echo "💡 ヒント: 最新のダウンロードURLが変更されている可能性があります"; \
		exit 1; \
	fi && \
	\
	echo "🔍 バージョン比較を実行中..." && \
	CURRENT_SIZE=$$(stat -c%s /opt/cursor/cursor.AppImage 2>/dev/null || echo "0") && \
	NEW_SIZE=$$(stat -c%s cursor_new.AppImage 2>/dev/null || echo "0") && \
	CURRENT_HASH=$$(sha256sum /opt/cursor/cursor.AppImage 2>/dev/null | cut -d' ' -f1 || echo "unknown") && \
	NEW_HASH=$$(sha256sum cursor_new.AppImage 2>/dev/null | cut -d' ' -f1 || echo "unknown") && \
	\
	CURRENT_HASH_SHORT=$$(echo "$$CURRENT_HASH" | cut -c1-16); \
	NEW_HASH_SHORT=$$(echo "$$NEW_HASH" | cut -c1-16); \
	echo "📊 ファイル比較結果:"; \
	echo "   現在: $$(echo "scale=1; $$CURRENT_SIZE/1024/1024" | bc 2>/dev/null || echo "$$CURRENT_SIZE")MB (SHA256: $$CURRENT_HASH_SHORT...)"; \
	echo "   最新: $$(echo "scale=1; $$NEW_SIZE/1024/1024" | bc 2>/dev/null || echo "$$NEW_SIZE")MB (SHA256: $$NEW_HASH_SHORT...)"; \
	\
	if [ "$$CURRENT_HASH" != "$$NEW_HASH" ]; then \
		echo "🔄 新しいバージョンが利用可能です"; \
		UPDATE_NEEDED=true; \
	else \
		echo "✅ Cursor IDEは既に最新バージョンです"; \
		UPDATE_NEEDED=false; \
	fi && \
	\
	if [ "$$UPDATE_NEEDED" = "true" ]; then \
		BACKUP_TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
		echo "📁 既存バージョンをバックアップ中..." && \
		sudo cp /opt/cursor/cursor.AppImage /opt/cursor/cursor.AppImage.backup.$$BACKUP_TIMESTAMP && \
		echo "🔄 新しいバージョンに更新中..." && \
		sudo mv cursor_new.AppImage /opt/cursor/cursor.AppImage && \
		sudo chmod +x /opt/cursor/cursor.AppImage && \
		echo "🔄 デスクトップエントリーを更新中..." && \
		sudo update-desktop-database 2>/dev/null || true && \
		echo "✅ Cursor IDEが正常に更新されました！"; \
		echo ""; \
		echo "📝 更新内容:"; \
		echo "   バックアップ: /opt/cursor/cursor.AppImage.backup.$$BACKUP_TIMESTAMP"; \
		echo "   新バージョン: SHA256 $$NEW_HASH_SHORT..."; \
		echo ""; \
		echo "🚀 Cursorを再起動して新しいバージョンをお楽しみください！"; \
	else \
		rm -f cursor_new.AppImage; \
		echo "ℹ️  更新の必要はありません"; \
	fi

# Cursor IDE更新の便利なエイリアス
update-cursor-stable:
	@make update-cursor TRACK=stable

update-cursor-latest:
	@make update-cursor TRACK=latest

# Cursor IDEのバージョン情報を確認
check-cursor-version:
	@echo "🔍 Cursor IDEバージョン情報を確認中..."
	@if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "✅ Cursor IDEが見つかりました"; \
		FILE_SIZE=$$(stat -c%s /opt/cursor/cursor.AppImage 2>/dev/null || echo "0"); \
		FILE_DATE=$$(stat -c%Y /opt/cursor/cursor.AppImage 2>/dev/null || echo "0"); \
		FILE_HASH=$$(sha256sum /opt/cursor/cursor.AppImage 2>/dev/null | cut -d' ' -f1 || echo "unknown"); \
		FILE_HASH_SHORT=$$(echo "$$FILE_HASH" | cut -c1-16); \
		FORMATTED_DATE=$$(date -d @$$FILE_DATE '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo '不明'); \
		echo "📊 インストール情報:"; \
		echo "   ファイルサイズ: $$(echo "scale=1; $$FILE_SIZE/1024/1024" | bc 2>/dev/null || echo "$$FILE_SIZE")MB"; \
		echo "   更新日時: $$FORMATTED_DATE"; \
		echo "   SHA256ハッシュ: $$FILE_HASH_SHORT..."; \
		echo "   インストール先: /opt/cursor/cursor.AppImage"; \
		echo ""; \
		echo "💡 最新版へ更新するには: make update-cursor"; \
	else \
		echo "❌ Cursor IDEがインストールされていません"; \
		echo "💡 インストールするには: make install-cursor"; \
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
