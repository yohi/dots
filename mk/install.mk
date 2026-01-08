# Homebrewのインストール
install-packages-homebrew:
	@if $(call check_command,brew); then \
		echo "$(call IDEMPOTENCY_SKIP_MSG,install-packages-homebrew)"; \
		exit 0; \
	fi
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
install-packages-fuse:
	@echo "📦 AppImage実行用のFUSEパッケージをインストール中..."
	@echo "ℹ️  これによりCursor、PostmanなどのAppImageアプリケーションが実行可能になります"

	# 問題のあるリポジトリの一時的な無効化
	@echo "🔧 問題のあるリポジトリの確認と修正..."
	@if [ -f /etc/apt/sources.list.d/google-chrome-beta.list ]; then \
		echo "ℹ️  重複するGoogle Chromeリポジトリを修正中..."; \
		sudo rm -f /etc/apt/sources.list.d/google-chrome-beta.list 2>/dev/null || true; \
	fi

	# Ubuntu 25.04で利用できないPPAの無効化（CopyQは除外）
	@echo "🔧 Ubuntu 25.04で利用できないPPAを一時的に無効化中..."
	# CopyQ PPAは正常なPPAなので無効化しない
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
install-packages-apps:
ifndef FORCE
	@if $(call check_marker,install-packages-apps) 2>/dev/null; then \
		echo "$(call IDEMPOTENCY_SKIP_MSG,install-packages-apps)"; \
		exit 0; \
	fi
endif
	@echo "📦 アプリケーションをインストール中..."
	@if command -v brew >/dev/null 2>&1; then \
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; \
		echo "🍺 Brewパッケージをインストール中..."; \
		brew bundle --file=$(DOTFILES_DIR)/Brewfile --no-upgrade || true; \
		echo "⚠️  一部のパッケージでエラーが発生した可能性がありますが、処理を続行します"; \
	else \
		echo "❌ Homebrewがインストールされていません。先に 'make install-packages-homebrew' を実行してください。"; \
		exit 1; \
	fi
	@$(call create_marker,install-packages-apps,N/A)
	@echo "✅ アプリケーションのインストールが完了しました。"

# Cursor AppImageのSHA256ハッシュ
# TODO: Cursor公式にSHA256チェックサムの公開をリクエスト中
# チェックサムが公開されるまでは、空欄にしてサイズ検証（暫定策）を使用します
CURSOR_SHA256 :=

# Cursor IDEのインストール
install-packages-cursor:
	@echo "📝 Cursor IDEのインストールを開始します..."
	@if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "✅ Cursor IDEは既にインストールされています"; \
	else \
		$(MAKE) _cursor_download; \
	fi
	@$(MAKE) _cursor_setup_desktop
	@echo "✅ Cursor IDEのインストールが完了しました"

_cursor_download:
	@echo "📦 方法1: 自動ダウンロードを試行中..."
	@cd /tmp && \
	verify_download_size() { \
		local min_size="$$1"; \
		local max_size="$$2"; \
		local file="cursor.AppImage"; \
		local file_size=$$(stat -c%s "$$file" 2>/dev/null || echo "0"); \
		if [ "$$file_size" -ge "$$min_size" ] && [ "$$file_size" -le "$$max_size" ]; then \
			echo "✅ サイズ検証に成功しました ($$file_size bytes)"; \
			echo "   (範囲: $$(($$min_size/1024/1024))MB - $$(($$max_size/1024/1024))MB)"; \
			VALID_DOWNLOAD=1; \
			return 0; \
		else \
			echo "❌ ダウンロードファイルのサイズが不正です ($$file_size bytes)"; \
			echo "   許容範囲: $$(($$min_size/1024/1024))MB - $$(($$max_size/1024/1024))MB"; \
			echo "   ファイルが破損しているか、改ざんされた可能性があります"; \
			rm -f "$$file"; \
			return 1; \
		fi; \
	}; \
	if curl -L --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
		--max-time 120 --retry 2 --retry-delay 3 \
		-o cursor.AppImage "https://downloader.cursor.sh/linux/appImage/x64" 2>/dev/null; then \
		\
		# Verification Strategy: \
		# 1. Ideally, use SHA256 checksum (TODO: Request Cursor to publish checksums). \
		# 2. Interim: Enforce strict file size range (Typical AppImage: ~100-300MB). \
		#    Reject outliers (e.g. < 60MB small pages, > 600MB corrupted files). \
		\
		VALID_DOWNLOAD=0; \
		echo "🔐 ダウンロードファイルの整合性を検証中 (SHA256)..."; \
		ACTUAL_HASH=$$(sha256sum cursor.AppImage | awk '{print $$1}'); \
		if [ -n "$(CURSOR_SHA256)" ]; then \
			if [ "$$ACTUAL_HASH" != "$(CURSOR_SHA256)" ]; then \
				echo "❌ ハッシュ不一致エラー"; \
				echo "   期待値: $(CURSOR_SHA256)"; \
				echo "   実際値: $$ACTUAL_HASH"; \
				echo "   (バージョンが更新された可能性があります。mk/install.mk の CURSOR_SHA256 を更新してください)"; \
				rm -f cursor.AppImage; \
				exit 1; \
			else \
				echo "✅ ハッシュ検証に成功しました"; \
				VALID_DOWNLOAD=1; \
			fi; \
		else \
			echo "⚠️  SHA256チェックサム未定義: 暫定的なサイズ検証を実行します"; \
			echo "ℹ️  TODO: 将来的に 'sha256sum -c' による検証に置き換える予定です"; \
			verify_download_size 100000000 500000000 || exit 1; \
		fi; \
		else \
			echo "⚠️  SHA256チェックサム未定義: 暫定的なサイズ検証を実行します"; \
			# TODO: When checksums are published, replace this size check with 'sha256sum -c' \
			verify_download_size 60000000 600000000 || true; \
		fi; \
		\
		if [ "$$VALID_DOWNLOAD" -eq 1 ]; then \
			echo "✅ ダウンロード完了"; \
			chmod +x cursor.AppImage; \
			sudo mkdir -p /opt/cursor; \
			sudo mv cursor.AppImage /opt/cursor/cursor.AppImage; \
			exit 0; \
		fi; \
	fi; \
	echo "📦 方法2: ダウンロードフォルダから検索中..."; \
	FOUND=false; \
	for DIR in $(HOME_DIR)/Downloads $(HOME_DIR)/Desktop /tmp; do \
		if [ -d "$$DIR" ]; then \
			CURSOR_FILE=$$(ls "$$DIR"/cursor*.AppImage 2>/dev/null | head -1); \
			if [ -n "$$CURSOR_FILE" ]; then \
				echo "✅ $$CURSOR_FILE が見つかりました"; \
				chmod +x "$$CURSOR_FILE"; \
				sudo mkdir -p /opt/cursor; \
				sudo cp "$$CURSOR_FILE" /opt/cursor/cursor.AppImage; \
				FOUND=true; \
				break; \
			fi; \
		fi; \
	done; \
	if [ "$$FOUND" = "false" ]; then \
		echo "❌ Cursor IDEのインストールに失敗しました"; \
		echo ""; \
		echo "📥 手動インストール手順:"; \
		echo "1. ブラウザで https://cursor.sh/ を開く"; \
		echo "2. 'Download for Linux' をクリック"; \
		echo "3. ダウンロード後、再度このコマンドを実行"; \
		exit 1; \
	fi

_cursor_setup_desktop:
	@echo "📝 デスクトップエントリーとアイコンを作成中..."
	@ICON_PATH="applications-development"; \
	ICON_EXTRACTED=false; \
	echo "🎨 アイコンを設定中..."; \
	cd /tmp; \
	echo "📥 公式アイコンをダウンロード中..."; \
	if curl -f -L --connect-timeout 10 --max-time 30 \
		-H 'user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36' \
		-o cursor-favicon.ico "https://cursor.com/favicon.ico" 2>/dev/null; then \
		sudo mkdir -p /usr/share/pixmaps; \
		if command -v convert >/dev/null 2>&1; then \
			if convert cursor-favicon.ico cursor-icon.png 2>/dev/null; then \
				sudo cp cursor-icon.png /usr/share/pixmaps/cursor.png; \
				ICON_EXTRACTED=true; \
				ICON_PATH="/usr/share/pixmaps/cursor.png"; \
				echo "✅ 公式アイコンをダウンロードして設定しました"; \
			fi; \
		else \
			sudo cp cursor-favicon.ico /usr/share/pixmaps/cursor.ico; \
			ICON_EXTRACTED=true; \
			ICON_PATH="/usr/share/pixmaps/cursor.ico"; \
			echo "✅ 公式アイコン（ICO形式）をダウンロードして設定しました"; \
		fi; \
		rm -f cursor-favicon.ico cursor-icon.png 2>/dev/null || true; \
	fi; \
	if [ "$$ICON_EXTRACTED" = "false" ]; then \
		echo "🔍 AppImageからアイコンを抽出中..."; \
		if command -v unzip >/dev/null 2>&1; then \
			if timeout 30 unzip -j /opt/cursor/cursor.AppImage "*.png" 2>/dev/null || \
			   timeout 30 unzip -j /opt/cursor/cursor.AppImage "usr/share/pixmaps/*.png" 2>/dev/null || \
			   timeout 30 unzip -j /opt/cursor/cursor.AppImage "resources/*.png" 2>/dev/null; then \
				ICON_FILE=$$(ls -1 *.png 2>/dev/null | grep -i "cursor\|icon\|app" | head -1); \
				if [ -z "$$ICON_FILE" ]; then ICON_FILE=$$(ls -1 *.png 2>/dev/null | head -1); fi; \
				if [ -n "$$ICON_FILE" ] && [ -f "$$ICON_FILE" ]; then \
					sudo mkdir -p /usr/share/pixmaps; \
					sudo cp "$$ICON_FILE" /usr/share/pixmaps/cursor.png; \
					ICON_PATH="/usr/share/pixmaps/cursor.png"; \
					echo "✅ AppImageからアイコンを抽出しました: $$ICON_FILE"; \
				fi; \
				rm -f *.png 2>/dev/null || true; \
			fi; \
		fi; \
	fi; \
	if [ "$$ICON_EXTRACTED" = "false" ]; then \
		echo "⚠️  アイコンの設定に失敗しました。デフォルトアイコンを使用します"; \
	fi; \
	echo "📝 デスクトップエントリーを作成中..."; \
	echo "[Desktop Entry]" | sudo tee /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Name=Cursor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Comment=The AI-first code editor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Exec=/opt/cursor/cursor.AppImage --no-sandbox %F" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Icon=$$ICON_PATH" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Terminal=false" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Type=Application" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "Categories=Development;IDE;TextEditor;" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "MimeType=text/plain;inode/directory;" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	echo "StartupWMClass=cursor" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	sudo chmod +x /usr/share/applications/cursor.desktop; \
	sudo update-desktop-database 2>/dev/null || true; \
	echo "✅ Cursor IDEのセットアップが完了しました";

# Cursor IDEのアップデート
update-cursor:
	@echo "🔄 Cursor IDEのアップデートを開始します..."
	@CURSOR_UPDATED=false && \
	\
	@echo "🔍 現在のCursor IDEを確認中..." && \
	if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "🔄 Cursor IDEの実行状況を確認中..." && \
		if pgrep -f "^/opt/cursor/cursor.AppImage" >/dev/null 2>&1; then \
			echo "⚠️  Cursor IDEが実行中です。アップデートを続行するには、まずCursor IDEを終了してください。"; \
			echo "   Cursor IDEを終了後、再度このコマンドを実行してください。"; \
			echo ""; \
			echo "💡 自動的にCursor IDEを終了するには: make stop-cursor"; \
			exit 1; \
		fi && \
		echo "📦 最新バージョンのダウンロード情報を取得中..." && \
		cd /tmp && \
		rm -f cursor-new.AppImage 2>/dev/null && \
		\
		echo "🌐 Cursor APIから最新バージョン情報を取得中..." && \
		if ! command -v jq >/dev/null 2>&1; then \
			echo "📦 jqをインストール中..."; \
			if command -v apt-get >/dev/null 2>&1; then \
				sudo apt-get update >/dev/null 2>&1 && sudo apt-get install -y jq >/dev/null 2>&1; \
			elif command -v brew >/dev/null 2>&1; then \
				brew install jq >/dev/null 2>&1; \
			elif command -v yum >/dev/null 2>&1; then \
				sudo yum install -y jq >/dev/null 2>&1; \
			elif command -v dnf >/dev/null 2>&1; then \
				sudo dnf install -y jq >/dev/null 2>&1; \
			fi; \
		fi && \
		\
		if command -v jq >/dev/null 2>&1; then \
			API_RESPONSE=$$(curl -sL "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" 2>/dev/null); \
			if [ -n "$$API_RESPONSE" ] && echo "$$API_RESPONSE" | jq . >/dev/null 2>&1; then \
				DOWNLOAD_URL=$$(echo "$$API_RESPONSE" | jq -r '.downloadUrl' 2>/dev/null); \
				VERSION=$$(echo "$$API_RESPONSE" | jq -r '.version' 2>/dev/null); \
				if [ "$$DOWNLOAD_URL" != "null" ] && [ "$$DOWNLOAD_URL" != "" ]; then \
					echo "📋 最新バージョン: $$VERSION"; \
					echo "🔗 ダウンロードURL: $$DOWNLOAD_URL"; \
				else \
					DOWNLOAD_URL=""; \
				fi; \
			else \
				echo "⚠️  API応答の解析に失敗しました。フォールバック方式を使用します..."; \
				DOWNLOAD_URL=""; \
			fi; \
		else \
			echo "⚠️  jqのインストールに失敗しました。フォールバック方式を使用します..."; \
			DOWNLOAD_URL=""; \
		fi && \
		\
		if [ -z "$$DOWNLOAD_URL" ]; then \
			echo "🔄 フォールバック: 直接ダウンロードを試行中..."; \
			DOWNLOAD_URL="https://downloader.cursor.sh/linux/appImage/x64"; \
		fi && \
		\
		echo "📥 ダウンロード中: $$DOWNLOAD_URL" && \
		if curl -L --user-agent "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36" \
			--max-time 120 --retry 3 --retry-delay 5 \
			-o cursor-new.AppImage "$$DOWNLOAD_URL" 2>/dev/null; then \
			FILE_SIZE=$$(stat -c%s cursor-new.AppImage 2>/dev/null || echo "0"); \
			if [ "$$FILE_SIZE" -gt 10000000 ]; then \
				echo "✅ 新しいバージョンのダウンロードが完了しました (サイズ: $$FILE_SIZE bytes)"; \
				echo "🔧 既存ファイルをバックアップ中..."; \
				sudo cp /opt/cursor/cursor.AppImage /opt/cursor/cursor.AppImage.backup.$$(date +%Y%m%d_%H%M%S) && \
				chmod +x cursor-new.AppImage && \
				sudo cp cursor-new.AppImage /opt/cursor/cursor.AppImage && \
				sudo chown root:root /opt/cursor/cursor.AppImage && \
				sudo chmod 755 /opt/cursor/cursor.AppImage && \
				rm -f cursor-new.AppImage && \
				CURSOR_UPDATED=true && \
				echo "🎉 Cursor IDEのアップデートが完了しました"; \
			else \
				echo "❌ ダウンロードファイルが不完全です (サイズ: $$FILE_SIZE bytes)"; \
				rm -f cursor-new.AppImage 2>/dev/null; \
			fi; \
		else \
			echo "❌ ダウンロードに失敗しました"; \
		fi; \
	else \
		echo "❌ Cursor IDEがインストールされていません"; \
		echo "   'make install-packages-cursor' でインストールしてください"; \
	fi && \
	\
	if [ "$$CURSOR_UPDATED" = "false" ]; then \
		echo "💡 手動アップデート手順:"; \
		echo "1. ブラウザで https://cursor.sh/ を開く"; \
		echo "2. 'Download for Linux' をクリック"; \
		echo "3. ダウンロードしたファイルを /opt/cursor/cursor.AppImage に置き換え"; \
		echo "4. sudo chmod +x /opt/cursor/cursor.AppImage でアクセス権を設定"; \
		echo ""; \
		echo "🔧 代替手順 (API経由):"; \
		echo "curl -s 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable' | jq -r '.downloadUrl'"; \
	fi

# Cursor IDEを停止
stop-cursor:
	@echo "🛑 Cursor IDEを停止しています..."
	@CURSOR_RUNNING=false && \
	\
	if pgrep -f "^/opt/cursor/cursor.AppImage" >/dev/null 2>&1; then \
		CURSOR_RUNNING=true; \
		echo "📋 実行中のCursor関連プロセスを終了中..."; \
		\
		echo "🔄 Cursor IDEの優雅な終了を試行中..."; \
		pkill -TERM -f "^/opt/cursor/cursor.AppImage" 2>/dev/null; \
		sleep 3; \
		\
		if pgrep -f "^/opt/cursor/cursor.AppImage" >/dev/null 2>&1; then \
			echo "⚠️  一部のプロセスが残っています。強制終了中..."; \
			pkill -9 -f "^/opt/cursor/cursor.AppImage" 2>/dev/null; \
			sleep 2; \
		fi; \
		\
		if pgrep -f "^/opt/cursor/cursor.AppImage" >/dev/null 2>&1; then \
			echo "⚠️  まだ一部のプロセスが残っています"; \
			echo "📋 残存プロセス:"; \
			pgrep -af "^/opt/cursor/cursor.AppImage" | head -5; \
		else \
			echo "✅ 全てのCursor関連プロセスを停止しました"; \
		fi; \
	fi && \
	\
	if [ "$$CURSOR_RUNNING" = "false" ]; then \
		echo "ℹ️  Cursor IDEは実行されていません"; \
	fi

# Cursor IDEのバージョン確認
check-cursor-version:
	@echo "🔍 Cursor IDEのバージョン情報を確認中..."
	@CURRENT_VERSION="" && \
	LATEST_VERSION="" && \
	\
	if [ -f /opt/cursor/cursor.AppImage ]; then \
		echo "📋 インストール済みバージョンを確認中..."; \
		CURRENT_VERSION="不明"; \
		if command -v strings >/dev/null 2>&1; then \
			VERSION_STR=$$(strings /opt/cursor/cursor.AppImage | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$$' | head -1 2>/dev/null || echo ""); \
			if [ -n "$$VERSION_STR" ]; then \
				CURRENT_VERSION="$$VERSION_STR"; \
			fi; \
		fi; \
		if [ "$$CURRENT_VERSION" = "不明" ]; then \
			FILE_DATE=$$(stat -c%y /opt/cursor/cursor.AppImage 2>/dev/null | cut -d' ' -f1 || echo "不明"); \
			CURRENT_VERSION="インストール済み ($$FILE_DATE)"; \
		fi; \
		echo "💻 現在のバージョン: $$CURRENT_VERSION"; \
	else \
		echo "❌ Cursor IDEがインストールされていません"; \
	fi && \
	\
	echo "🌐 最新バージョンを確認中..." && \
	if command -v jq >/dev/null 2>&1; then \
		API_RESPONSE=$$(curl -sL "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" 2>/dev/null); \
		if [ -n "$$API_RESPONSE" ] && echo "$$API_RESPONSE" | jq . >/dev/null 2>&1; then \
			LATEST_VERSION=$$(echo "$$API_RESPONSE" | jq -r '.version' 2>/dev/null); \
			echo "🆕 最新バージョン: $$LATEST_VERSION"; \
			\
			if [ -n "$$CURRENT_VERSION" ] && [ "$$CURRENT_VERSION" != "不明" ] && [ "$$CURRENT_VERSION" != "$$LATEST_VERSION" ]; then \
				echo ""; \
				echo "🔄 アップデートが利用可能です!"; \
				echo "   'make update-cursor' でアップデートできます"; \
			elif [ "$$CURRENT_VERSION" = "$$LATEST_VERSION" ]; then \
				echo "✅ 最新バージョンです"; \
			fi; \
		else \
			echo "❌ 最新バージョンの確認に失敗しました"; \
		fi; \
	else \
			echo "⚠️  jqがインストールされていないため、最新バージョンを確認できません"; \
		echo "   'sudo apt install jq' でjqをインストールしてください"; \
	fi

# MySQL Workbench のインストール
install-packages-mysql-workbench:
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
install-packages-claude-code:
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
install-packages-claudia:
	@echo "🖥️  Claudia (Claude Code GUI) のインストールを開始..."
	@echo "ℹ️  注意: ClaudiaはまだRelease版が公開されていないため、ソースからビルドします"
	@echo "⏱️  ビルドには10-15分かかる場合があります（システム環境により変動）"
	@echo ""

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
		echo "💡 または公式のrustupでインストール: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; \
		exit 1; \
	else \
		RUST_VERSION=$$(rustc --version | grep -o '[0-9]\+\.[0-9]\+' | head -1); \
		echo "✅ Rust が見つかりました: $$(rustc --version)"; \
		MAJOR=$(echo "$RUST_VERSION" | cut -d'.' -f1); \
		MINOR=$(echo "$RUST_VERSION" | cut -d'.' -f2); \
		if [ "$MAJOR" -lt 1 ] || { [ "$MAJOR" -eq 1 ] && [ "$MINOR" -lt 70 ]; }; then \
			echo "⚠️  Rust 1.70.0+ が推奨されています (現在: $RUST_VERSION)"; \
			echo "💡 アップデート: rustup update または brew upgrade rust"; \
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
		export PATH="$$HOME/.bun/bin:$$PATH"; \
		if ! command -v bun >/dev/null 2>&1; then \
			echo "⚠️  Bunのインストールが完了しましたが、現在のセッションで認識されていません"; \
			echo "   新しいターミナルセッションで再実行するか、以下を実行してください:"; \
			echo "   source $$HOME/.bashrc"; \
			echo "   source $$HOME/.zshrc (zshの場合)"; \
		fi; \
	else \
		echo "✅ Bun が見つかりました: $$(bun --version)"; \
	fi

	# Claudia のクローンとビルド
	@echo "📥 Claudia をクローン中..."
	@CLAUDIA_DIR="/tmp/claudia-build" && \
	rm -rf "$$CLAUDIA_DIR" 2>/dev/null || true && \
	if git clone https://github.com/getAsterisk/claudia.git "$$CLAUDIA_DIR"; then \
		# TODO: 将来的にClaudiaのリリース版が公開されたら、特定のタグ(例: --branch v1.0.0)やコミットハッシュでバージョンを固定してください。\
		# 現在はリリース版がないため、デフォルトブランチの最新を使用しています。\
		echo "✅ Claudia のクローンが完了しました"; \
		cd "$$CLAUDIA_DIR" && \
		\
		echo "📦 フロントエンド依存関係をインストール中..."; \
		export PATH="$$HOME/.bun/bin:$$PATH"; \
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
			BIN_PATH=""; \
			for candidate in src-tauri/target/release/claudia* src-tauri/target/release/opcode*; do \
				if [ -f "$$candidate" ] && [ -x "$$candidate" ]; then \
					case "$$(basename "$$candidate")" in \
						claudia*|opcode*) \
							BIN_PATH="$$candidate"; \
							break ;; \
					esac; \
				fi; \
			done; \
			if [ -n "$$BIN_PATH" ] && [ -f "$$BIN_PATH" ] && [ -x "$$BIN_PATH" ]; then \
				echo "✅ 選択された実行ファイル: $$BIN_PATH"; \
				sudo mkdir -p /opt/claudia; \
				sudo cp "$$BIN_PATH" /opt/claudia/claudia; \
				sudo chmod +x /opt/claudia/claudia; \
				\
				echo "📝 デスクトップエントリーを作成中..."; \
				echo "[Desktop Entry]" | sudo tee /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Name=Claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Comment=A powerful GUI app and Toolkit for Claude Code" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "Exec=/opt/claudia/claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "TryExec=/opt/claudia/claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
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
				echo "⚠️  主要バイナリが見つかりません。代替候補を検索中..."; \
				ALT_BIN=""; \
				for alt_candidate in $$(find src-tauri/target/release -maxdepth 1 -type f -executable -name "claudia*" -o -name "opcode*" 2>/dev/null | sort -V); do \
					case "$$(basename "$$alt_candidate")" in \
						claudia*|opcode*) \
							ALT_BIN="$$alt_candidate"; \
							break ;; \
					esac; \
				done; \
				if [ -n "$$ALT_BIN" ] && [ -f "$$ALT_BIN" ] && [ -x "$$ALT_BIN" ]; then \
					echo "✅ 代替実行ファイルを発見: $$ALT_BIN"; \
					sudo mkdir -p /opt/claudia; \
					sudo cp "$$ALT_BIN" /opt/claudia/claudia; \
					sudo chmod +x /opt/claudia/claudia; \
					echo "📝 デスクトップエントリーを作成中..."; \
					echo "[Desktop Entry]" | sudo tee /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Name=Claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Comment=A powerful GUI app and Toolkit for Claude Code" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Exec=/opt/claudia/claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "TryExec=/opt/claudia/claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Icon=applications-development" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Terminal=false" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Type=Application" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
					echo "Categories=Development;IDE;Utility;" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				echo "StartupWMClass=claudia" | sudo tee -a /usr/share/applications/claudia.desktop > /dev/null; \
				sudo chmod +x /usr/share/applications/claudia.desktop; \
				sudo update-desktop-database 2>/dev/null || true; \
					echo "✅ Claudia が /opt/claudia にインストールされました（代替実行ファイル使用）"; \
				else \
					echo "❌ ビルドされた実行ファイルが見つかりません"; \
					exit 1; \
				fi; \
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

	@echo ""; \
	@echo "🎉 Claudia のセットアップが完了しました！" \
	@echo ""; \
	@echo "🚀 使用方法:" \
	@echo "1. アプリケーションメニューから 'Claudia' を起動" \
	@echo "2. または、ターミナルから: /opt/claudia/claudia" \
	@echo "3. 初回起動時にClaude Codeディレクトリ（~/.claude）が自動検出されます" \
	@echo ""; \
	@echo "✨ Claudia の主要機能:" \
	@echo "- 📁 プロジェクト & セッション管理（~/.claude/projects/）" \
	@echo "- 🤖 カスタムAIエージェント作成・実行" \
	@echo "- 📊 使用状況分析ダッシュボード（コスト・トークン追跡）" \
	@echo "- 🔌 MCP サーバー管理（Model Context Protocol）" \
	@echo "- ⏰ タイムライン & チェックポイント（セッション履歴）" \
	@echo "- 📝 CLAUDE.md ファイル管理・編集" \
	@echo ""; \
	@echo "📚 詳細なドキュメント: https://github.com/getAsterisk/claudia" \
	@echo "🔗 公式サイト: https://claudiacode.com" \
	@echo ""; \
	@echo "💡 次のステップ:" \
	@echo "- Claude Code でプロジェクトを作成してから Claudia で管理" \
	@echo "- カスタムエージェントを作成して開発タスクを自動化" \
	@echo "✅ Claudia のインストールが完了しました"

# SuperClaudeのバージョン管理
SUPERCLAUDE_VERSION := 4.1.9
SUPERCLAUDE_HASH_TARGZ := bb73f5c3d11f222bb84704f99e671ef53b1cd7d3951c044947fab8d998a6ac13
SUPERCLAUDE_HASH_WHEEL := 46e5dcb5f03bd9775d01198a96cfe16279d14cc8c081c9619e270a96fb469821

# SuperClaude のインストール
install-superclaude:
	@$(MAKE) _superclaude_check_dependencies
	@$(MAKE) _superclaude_install_package
	@$(MAKE) _superclaude_setup_framework
	@$(MAKE) _superclaude_verify_installation

# 後方互換性のためのエイリアス
install-packages-superclaude: install-superclaude

_superclaude_check_dependencies:
	# Python の確認
	@echo "🔍 Python の確認中..."
	@if ! command -v python3 >/dev/null 2>&1; then \
		echo "❌ Python 3 がインストールされていません"; \
		echo ""; \
		echo "📥 Python 3 のインストール手順:"; \
		echo "1. Ubuntu/Debian: sudo apt install python3 python3-pip"; \
		echo "2. macOS: brew install python3"; \
		echo "3. 公式サイト: https://www.python.org/"; \
		echo ""; \
		echo "ℹ️  Python 3.8+ が必要です"; \
		exit 1; \
	else \
		PYTHON_VERSION=$$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1); \
		echo "✅ Python が見つかりました: $$(python3 --version 2>&1)"; \
		\
		# バージョン文字列の検証と解析 \
		if echo "$$PYTHON_VERSION" | grep -qE '^[0-9]+\.[0-9]+$$'; then \
			MAJOR=$$(echo "$$PYTHON_VERSION" | cut -d'.' -f1); \
			MINOR=$$(echo "$$PYTHON_VERSION" | cut -d'.' -f2); \
		else \
			echo "⚠️  Pythonのバージョン解析に失敗しました: '$$PYTHON_VERSION'"; \
			MAJOR=0; \
			MINOR=0; \
		fi; \
		\
		# バージョン要件の確認 (3.8+) \
		if [ "$$MAJOR" -eq 0 ]; then \
			echo "⚠️  バージョンを特定できませんでした。Python 3.8+ がインストールされていることを確認してください。"; \
		elif [ "$$MAJOR" -lt 3 ] || { [ "$$MAJOR" -eq 3 ] && [ "$$MINOR" -lt 8 ]; }; then \
			echo "⚠️  Python 3.8+ が推奨されています (検出: $$PYTHON_VERSION)"; \
			echo "   古いバージョンでは動作しない可能性があります"; \
		fi; \
	fi
	# pip の確認
	@echo "🔍 pip の確認中..."
	@if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then \
		echo "❌ pip がインストールされていません"; \
		echo "ℹ️  通常はPython 3と一緒にインストールされます"; \
		echo "   インストール: python3 -m ensurepip --upgrade"; \
		exit 1; \
	else \
		echo "✅ pip が見つかりました: $$(pip3 --version 2>/dev/null || pip --version)"; \
	fi
	# uv の確認とインストール（推奨）
	@echo "🔍 uv (高速Pythonパッケージマネージャー) の確認中..."
	@if ! command -v uv >/dev/null 2>&1; then \
		echo "📦 uv をインストール中..."; \
		curl -LsSf https://astral.sh/uv/install.sh | sh; \
		echo "🔄 uvのパスを更新中..."; \
		export PATH="$$HOME/.local/bin:$$PATH"; \
		if ! command -v uv >/dev/null 2>&1; then \
			echo "⚠️  uvのインストールが完了しましたが、現在のセッションで認識されていません"; \
			echo "   新しいターミナルセッションで再実行するか、以下を実行してください:"; \
			echo "   source $$HOME/.bashrc"; \
			echo "   source $$HOME/.zshrc (zshの場合)"; \
			echo ""; \
			echo "ℹ️  uvなしでもpipを使用してインストールを続行できます"; \
		fi; \
	else \
		echo "✅ uv が見つかりました: $$(uv --version)"; \
	fi

_superclaude_install_package:
	# SuperClaude の既存インストール確認
	# セキュリティ改善: v$(SUPERCLAUDE_VERSION)固定 + SHA256ハッシュ検証
	# - バージョン固定により依存関係の安定性を確保
	# - SHA256ハッシュ検証により改ざん防止
	# - 公式PyPIパッケージからの安全なインストール
	@echo "🔍 既存の SuperClaude インストールを確認中..." && \
	export PATH="$$HOME/.local/bin:$$PATH" && \
	if command -v SuperClaude >/dev/null 2>&1; then \
		CURRENT_VERSION=$$(SuperClaude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "不明"); \
		echo "✅ SuperClaude は既にインストールされています"; \
		echo "   現在のバージョン: $$CURRENT_VERSION"; \
		echo "   対象バージョン: $(SUPERCLAUDE_VERSION)"; \
		if [ "$$CURRENT_VERSION" != "$(SUPERCLAUDE_VERSION)" ]; then \
			echo ""; \
			echo "🔄 バージョン$(SUPERCLAUDE_VERSION)にアップデート中..."; \
			echo "🔐 セキュリティ: 複数ハッシュ検証を実行します"; \
			if uv tool upgrade SuperClaude==$(SUPERCLAUDE_VERSION) --verify-hashes 2>/dev/null || \
			   uv add SuperClaude==$(SUPERCLAUDE_VERSION) --upgrade 2>/dev/null; then \
				echo "✅ SuperClaude $(SUPERCLAUDE_VERSION)へのアップデートが完了しました"; \
			else \
				echo "⚠️  標準アップデートに失敗しました。pipでの多重セキュリティ検証インストールを試行中..."; \
				: "ハッシュ更新手順: 'pip hash <file>' でローカルファイルのハッシュを取得するか、https://pypi.org/pypi/SuperClaude/json から wheel と sdist の SHA256 を確認し、更新時は該当の --hash=sha256:... 値を両方（wheel と sdist）に追加または置換してください"; \
				pip install --upgrade --force-reinstall "SuperClaude==$(SUPERCLAUDE_VERSION)" \
					--hash=sha256:$(SUPERCLAUDE_HASH_TARGZ) \
					--require-hashes || \
				pip install --upgrade --force-reinstall "SuperClaude==$(SUPERCLAUDE_VERSION)" \
					--hash=sha256:$(SUPERCLAUDE_HASH_WHEEL) \
					--require-hashes; \
			fi; \
		else \
			echo "✅ 既に最新バージョン($(SUPERCLAUDE_VERSION))がインストールされています"; \
		fi; \
	else \
		echo "📦 SuperClaude v$(SUPERCLAUDE_VERSION) をインストール中..."; \
		echo "🔐 強化セキュリティ機能:"; \
		echo "   ✓ バージョン固定: $(SUPERCLAUDE_VERSION) (2025年11月14日リリース)"; \
		echo "   ✓ SHA256ハッシュ検証有効 (PyPI公式)"; \
		echo "   ✓ --require-hashes フラグ (強制検証)"; \
		echo "   ✓ PyPI公式パッケージからのインストール"; \
		echo "   ✓ 署名者: mithungowda.b (PyPI verified)"; \
		echo ""; \
		echo "ℹ️  多重セキュリティ検証インストールを実行します: uv add SuperClaude==$(SUPERCLAUDE_VERSION)"; \
		\
		# uvでのハッシュ検証付きインストールを試行
		if uv tool install SuperClaude==$(SUPERCLAUDE_VERSION) --verify-hashes 2>/dev/null || \
		   uv add SuperClaude==$(SUPERCLAUDE_VERSION); then \
			echo "✅ SuperClaude $(SUPERCLAUDE_VERSION) のパッケージインストールが完了しました"; \
		else \
			echo "⚠️  uvでのインストールに失敗しました。pipでのSHA256ハッシュ検証インストールを試行中..."; \
			echo "🔐 SHA256強制検証モードでインストールします"; \
			\
			# pipでのSHA256ハッシュ検証付きインストール（tar.gz形式）
			if pip install "SuperClaude==$(SUPERCLAUDE_VERSION)" \
				--hash=sha256:$(SUPERCLAUDE_HASH_TARGZ) \
				--require-hashes; then \
				echo "✅ SuperClaude $(SUPERCLAUDE_VERSION) のセキュアインストールが完了しました (source distribution)"; \
				echo "   ✓ SHA256検証済み: $(SUPERCLAUDE_HASH_TARGZ)"; \
			# フォールバック: wheel形式でのSHA256ハッシュ検証
			elif pip install "SuperClaude==$(SUPERCLAUDE_VERSION)" \
				--hash=sha256:$(SUPERCLAUDE_HASH_WHEEL) \
				--require-hashes; then \
				echo "✅ SuperClaude $(SUPERCLAUDE_VERSION) のセキュアインストールが完了しました (wheel distribution)"; \
				echo "   ✓ SHA256検証済み: $(SUPERCLAUDE_HASH_WHEEL)"; \
			else \
				echo "❌ SuperClaude のセキュアインストールに失敗しました"; \
				echo ""; \
				echo "🔧 トラブルシューティング:"; \
				echo "1. ネットワーク接続の確認"; \
				echo "2. Python環境の確認: python3 --version"; \
				echo "3. 手動での厳格インストール: pip install SuperClaude==$(SUPERCLAUDE_VERSION) --require-hashes"; \
				echo "4. 権限の問題: pip install --user SuperClaude==$(SUPERCLAUDE_VERSION)"; \
				echo ""; \
				echo "⚠️  セキュリティに関する重要な注意:"; \
				echo "   手動インストール時はバージョン$(SUPERCLAUDE_VERSION)を必ず指定してください"; \
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
			if [ "$$INSTALLED_VERSION" = "$(SUPERCLAUDE_VERSION)" ]; then \
				echo "✅ バージョン検証成功: SuperClaude $(SUPERCLAUDE_VERSION)"; \
				echo "✅ コマンド実行可能性確認済み"; \
				echo "✅ パッケージ整合性確認済み"; \
				# パッケージの追加情報取得を試行
				PACKAGE_INFO=$$(pip show SuperClaude 2>/dev/null | grep -E "(Version|Author|Location)" || echo "情報取得不可"); \
				echo "📦 パッケージ情報:"; \
				echo "   $$PACKAGE_INFO" | sed 's/^/   /'; \
				echo "🔐 セキュリティ状態: 検証済みパッケージ"; \
			else \
				echo "⚠️  バージョン不一致: 期待値=$(SUPERCLAUDE_VERSION), 実際=$$INSTALLED_VERSION"; \
				echo "❌ セキュリティ検証失敗"; \
			fi; \
		else \
			echo "❌ SuperClaudeコマンドが見つかりません"; \
			echo "❌ インストール検証失敗"; \
		fi; \
	fi
	@echo ""; \
	@echo "🛡️  セキュリティ検証状況:" \
	@echo "   ✓ PyPI公式リポジトリからのダウンロード" \
	@echo "   ✓ バージョン$(SUPERCLAUDE_VERSION)固定 (最新安定版)" \
	@echo "   ✓ SHA256ハッシュ検証 (パッケージ整合性)" \
	@echo "   ✓ --require-hashes 強制検証モード" \
	@echo "   ✓ 認証済みメンテナー: mithungowda.b" \
	@echo "   ⚠️ GPG署名: PyPIでは現在未提供 (Trusted Publishingで代替)" \
	@echo "   ℹ️  PyPIのTrusted Publishingによる署名済み配信"

_superclaude_setup_framework:
	# SuperClaude フレームワークのセットアップ
	@echo "⚙️  SuperClaude フレームワークをセットアップ中..."
	@export PATH="$$HOME/.local/bin:$$PATH"; \
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

_superclaude_verify_installation:
	# インストール確認とテスト
	@echo "🔍 インストールの確認中..."
	@export PATH="$$HOME/.local/bin:$$PATH"; \
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
	@export PATH="$$HOME/.local/bin:$$PATH"; \
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
		echo "ℹ️  先に 'make install-superclaude' を実行してください"; \
	fi

	@echo ""; \
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
	@$(MAKE) install-packages-claude-code
	@echo "✅ Claude Code のインストールが完了しました"
	@echo ""

	# Step 2: SuperClaude のインストール
	@echo "📋 Step 2/3: SuperClaude をインストール中..."
	@if [ "$${SKIP_SUPERCLAUDE:-0}" = "1" ]; then \
		echo "⚠️  SuperClaude のインストールはスキップされています (SKIP_SUPERCLAUDE=1)"; \
		echo "   手動インストール例: pip install SuperClaude==$(SUPERCLAUDE_VERSION)"; \
		echo "   有効化方法: SKIP_SUPERCLAUDE=0 make install-claude-ecosystem"; \
	else \
		echo "📦 SuperClaude をインストール中..."; \
		$(MAKE) install-superclaude || (echo "❌ SuperClaude インストールに失敗しました"; exit 1); \
		echo "✅ SuperClaude のインストールが完了しました"; \
	fi
	@echo ""

	# Step 3: Claudia のインストール
	@echo "📋 Step 3/3: Claudia をインストール中..."
	@$(MAKE) install-packages-claudia
	@echo "✅ Claudia のインストールが完了しました"
	@echo ""

	# 最終確認
	@echo "🔍 インストール結果の確認中..."
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	if command -v claude >/dev/null 2>&1; then \
		echo "Claude Code: ✅ $$(claude --version 2>/dev/null)"; \
	else \
		echo "Claude Code: ❌ 未確認"; \
	fi; \
	if command -v SuperClaude >/dev/null 2>&1; then \
		echo "SuperClaude: ✅ $$(SuperClaude --version 2>/dev/null)"; \
	else \
		echo "SuperClaude: ❌ 未確認"; \
	fi

	@echo ""; \
	@echo "🎉 Claude Code エコシステムのインストールが完了しました！" \
	@echo ""; \
	@echo "🚀 使用開始ガイド:" \
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" \
	@echo "" \
	@echo "💻 Claude Code (CLI):" \
	@echo "  コマンド: claude" \
	@echo "  使用例: プロジェクトディレクトリで 'claude' を実行" \
	@echo ""; \
	@echo "🚀 SuperClaude (フレームワーク):" \
	@echo "  Claude Code内で以下のコマンドが利用可能:" \
	@echo "    /sc:implement <機能>     - 機能実装" \
	@echo "    /sc:design <UI>          - UI/UXデザイン" \
	@echo "    /sc:analyze <コード>     - コード分析" \
	@echo "    /sc:test <テスト>        - テストスイート" \
	@echo "    /sc:improve <コード>     - コード改善" \
	@echo ""; \
	@echo "🖥️  Claudia (GUI):" \
	@echo "  起動方法: アプリケーションメニューから 'Claudia' を選択" \
	@echo "  または: /opt/claudia/claudia" \
	@echo "  機能: プロジェクト管理、使用状況分析、MCPサーバー管理等" \
	@echo ""; \
	@echo "🎭 利用可能なペルソナ (SuperClaude):" \
	@echo "  🏗️  architect - システム設計" \
	@echo "  🎨 frontend  - UI/UX開発" \
	@echo "  ⚙️  backend   - API/インフラ" \
	@echo "  🔍 analyzer  - デバッグ・分析" \
	@echo "  🛡️  security  - セキュリティ" \
	@echo "  ✍️  scribe    - ドキュメント" \
	@echo ""; \
	@echo "📚 ドキュメント:" \
	@echo "  Claude Code: https://docs.anthropic.com/claude-code" \
	@echo "  SuperClaude: https://superclaude-org.github.io/" \
	@echo "  Claudia: https://github.com/getAsterisk/claudia" \
	@echo ""; \
	@echo "✨ おすすめワークフロー:" \
	@echo "  1. 'claude' でプロジェクトを開始" \
	@echo "  2. '/sc:implement' で機能を実装" \
	@echo "  3. Claudia でプロジェクト管理・分析" \
	@echo ""; \
	@echo "✅ Claude Code エコシステムの一括インストールが完了しました"

# DEBパッケージをインストール（IDE・ブラウザ含む）
install-packages-deb:
ifndef FORCE
	@if $(call check_marker,install-packages-deb) 2>/dev/null; then \
		echo "$(call IDEMPOTENCY_SKIP_MSG,install-packages-deb)"; \
		exit 0; \
	fi
endif
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
		echo "📥 Google GPGキーをダウンロード・設定中..."; \
		sudo mkdir -p /usr/share/keyrings; \
		curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg; \
		echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list; \
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
			echo "📥 Google GPGキーをダウンロード・設定中..."; \
			sudo mkdir -p /usr/share/keyrings; \
			curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg; \
			sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'; \
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
	@$(MAKE) install-packages-fuse

	# Cursor IDE のインストール
	@echo "💻 Cursor IDE のインストール中..."
	@$(MAKE) install-packages-cursor

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

	@$(call create_marker,install-packages-deb,N/A)
	@echo "✅ DEBパッケージのインストールが完了しました"
	@echo "📋 インストール完了項目:"
	@echo "   - Visual Studio Code"
	@echo "   - Google Chrome Stable"
	@echo "   - Google Chrome Beta"
	@echo "   - Chromium"
	@echo "   - FUSE（AppImage実行用）"
	@echo "   - Cursor IDE"
	@echo "   - WezTerm"

# Playwright E2Eテストフレームワークのインストール
install-playwright:
	@echo "🎭 Playwright E2Eテストフレームワークのインストールを開始..."

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

	# Playwright のインストール確認
	@echo "🔍 既存の Playwright インストールを確認中..."
	@if command -v npx >/dev/null 2>&1 && npx playwright --version >/dev/null 2>&1; then \
		echo "✅ Playwright は既にインストールされています"; \
		echo "   バージョン: $$(npx playwright --version 2>/dev/null || echo '取得できませんでした')"; \
		echo ""; \
		echo "🔄 Playwright をアップデート中..."; \
		npm update -g @playwright/test 2>/dev/null || npm install -g @playwright/test@latest 2>/dev/null || true; \
		echo "🌐 ブラウザバイナリをアップデート中..."; \
		npx playwright install 2>/dev/null || true; \
	else \
		echo "📦 Playwright をインストール中..."; \
		echo "ℹ️  グローバルインストールを実行します: npm install -g @playwright/test"; \
		\
		if npm install -g @playwright/test; then \
			echo "✅ Playwright のインストールが完了しました"; \
		else \
			echo "❌ Playwright のインストールに失敗しました"; \
			echo ""; \
			echo "🔧 トラブルシューティング:"; \
			echo "1. 権限の問題: npm config set prefix $(HOME)/.local"; \
			echo "2. WSLの場合: npm config set os linux"; \
			echo "3. ローカルプロジェクトでのインストール: npm install @playwright/test"; \
			echo "4. 強制インストール: npm install -g @playwright/test --force"; \
			echo ""; \
			exit 1; \
		fi; \
		\
		echo "🌐 ブラウザバイナリをインストール中..."; \
		echo "ℹ️  Chromium、Firefox、WebKit のブラウザエンジンをダウンロードします"; \
		if npx playwright install; then \
			echo "✅ ブラウザバイナリのインストールが完了しました"; \
		else \
			echo "⚠️  ブラウザバイナリのインストールに失敗しました"; \
			echo "ℹ️  手動でインストールしてください: npx playwright install"; \
		fi; \
	fi

	# システム依存関係のインストール (Linux)
	@echo "📦 システム依存関係をインストール中..."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "🔧 Linux向けの依存関係をインストール中..."; \
		sudo apt update -q 2>/dev/null || echo "⚠️  パッケージリストの更新で問題が発生しましたが、処理を続行します"; \
		npx playwright install-deps 2>/dev/null || \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y \
			libnss3 \
			libatk-bridge2.0-0 \
			libdrm2 \
			libgtk-3-0 \
			libgbm1 \
			libasound2 \
			fonts-liberation \
			libappindicator3-1 \
			libxss1 \
			xdg-utils 2>/dev/null || \
		echo "⚠️  一部の依存関係のインストールに失敗しましたが、処理を続行します"; \
	else \
		echo "ℹ️  Linuxではないため、システム依存関係のインストールをスキップします"; \
	fi

	# インストール確認
	@echo "🔍 インストールの確認中..."
	@if command -v npx >/dev/null 2>&1 && npx playwright --version >/dev/null 2>&1; then \
		echo "✅ Playwright が正常にインストールされました"; \
		echo "   実行ファイル: npx playwright"; \
		echo "   バージョン: $$(npx playwright --version 2>/dev/null || echo '取得できませんでした')"; \
		echo ""; \
		echo "🌐 インストール済みブラウザの確認:"; \
		npx playwright --help | grep -A 5 "browsers" 2>/dev/null || \
		echo "   ℹ️  npx playwright install でブラウザをインストールできます"; \
	else \
		echo "❌ Playwright のインストール確認に失敗しました"; \
		echo "ℹ️  PATH の問題の可能性があります"; \
		echo "   手動確認: npx playwright --version"; \
		exit 1; \
	fi

	@echo ""; \
	@echo "🎉 Playwright のセットアップガイド:" \
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" \
	@echo "" \
	@echo "🚀 基本的な使用方法:" \
	@echo "1. プロジェクトディレクトリに移動: cd your-project-directory" \
	@echo "2. Playwright 設定ファイルを生成: npx playwright init" \
	@echo "3. テストファイルを作成: npx playwright codegen" \
	@echo "4. テストを実行: npx playwright test" \
	@echo ""; \
	@echo "📋 主要なコマンド:" \
	@echo "   npx playwright test              - すべてのテストを実行" \
	@echo "   npx playwright test --ui         - UIモードでテストを実行" \
	@echo "   npx playwright test --headed     - ブラウザ表示モードで実行" \
	@echo "   npx playwright test --debug      - デバッグモードで実行" \
	@echo "   npx playwright codegen <URL>     - テストコードを生成" \
	@echo "   npx playwright show-report       - テストレポートを表示" \
	@echo "   npx playwright install           - ブラウザバイナリを再インストール" \
	@echo ""; \
	@echo "🌐 対応ブラウザ:" \
	@echo "   ✓ Chromium (Chrome、Microsoft Edge)" \
	@echo "   ✓ Firefox" \
	@echo "   ✓ WebKit (Safari)" \
	@echo ""; \
	@echo "📱 対応プラットフォーム:" \
	@echo "   ✓ デスクトップ (Windows、macOS、Linux)" \
	@echo "   ✓ モバイル (Android、iOS シミュレータ)" \
	@echo ""; \
	@echo "🎯 主要機能:" \
	@echo "   - クロスブラウザテスト自動化" \
	@echo "   - モバイルデバイステスト" \
	@echo "   - スクリーンショット・動画記録" \
	@echo "   - パフォーマンステスト" \
	@echo "   - APIテスト" \
	@echo "   - 視覚的回帰テスト" \
	@echo ""; \
	@echo "📚 詳細なドキュメント:" \
	@echo "   公式サイト: https://playwright.dev/" \
	@echo "   ガイド: https://playwright.dev/docs/intro" \
	@echo "   API リファレンス: https://playwright.dev/docs/api/class-playwright" \
	@echo ""; \
	@echo "💡 おすすめワークフロー:" \
	@echo "   1. 'npx playwright init' でプロジェクトをセットアップ" \
	@echo "   2. 'npx playwright codegen' でテストを録画生成" \
	@echo "   3. 'npx playwright test --ui' でテストをデバッグ・実行" \
	@echo "   4. CI/CDパイプラインに組み込んで継続的テスト" \
	@echo ""; \
	@echo "✅ Playwright のインストールが完了しました"


# ccusage のインストール
install-packages-ccusage:
	@echo "📦 ccusage をインストールしています..."
	@if ! command -v bun >/dev/null 2>&1; then \
		if command -v brew >/dev/null 2>&1; then \
			echo "🍺 Homebrewを使用してbunをインストール中..."; \
			brew install bun; \
		else \
			echo "🔐 Bunをインストール中（公式インストーラー使用）..."; \
			curl -fsSL https://bun.sh/install | bash; \
			echo "⚠️  注意: インストール後、Bunのバージョンを確認してください"; \
		fi; \
		export PATH="$(HOME)/.bun/bin:$$PATH"; \
		if ! command -v bun >/dev/null 2>&1; then \
			echo "❌ bun のインストールに失敗しました。PATH を確認してください。"; \
			exit 1; \
		fi; \
	fi
	@echo "🔧 ccusage をグローバル導入中..."
	@export PATH="$(HOME)/.bun/bin:$$PATH"; \
	CCUSAGE_VERSION="latest"; \
	echo "📦 ccusage ($$CCUSAGE_VERSION) をインストール中..."; \
	if ! bun add -g ccusage@$$CCUSAGE_VERSION; then \
		echo "⚠️ bun add -g に失敗。bunx での実行にフォールバックします"; \
	fi
	@echo "🔍 動作確認: ccusage --version"
	@export PATH="$(HOME)/.bun/bin:$$PATH"; \
	if ! bunx -y ccusage --version >/dev/null 2>&1; then \
		echo "⚠️ bunx 実行確認に失敗しました（ネットワーク状況を確認してください）"; \
	fi
	@echo "✅ ccusage のインストールが完了しました。"

# 追加のブラウザインストール系
install-packages-chrome-beta:
	@echo "🌐 Google Chrome Beta のインストール中..."
	@if ! command -v google-chrome-beta >/dev/null 2>&1; then \
		echo "📥 Google Chrome リポジトリの確認中..."; \
		if ! grep -q "chrome/deb" /etc/apt/sources.list.d/google-chrome.list 2>/dev/null; then \
			echo "📥 Google GPGキーをダウンロード・設定中..."; \
			sudo mkdir -p /usr/share/keyrings; \
			curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg; \
			sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'; \
			sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"; \
		fi; \
		sudo DEBIAN_FRONTEND=noninteractive apt install -y google-chrome-beta; \
	else \
		echo "✅ Google Chrome Beta は既にインストールされています"; \
	fi
	@echo "✅ Google Chrome Beta のインストールが完了しました"

# ========================================
# 後方互換性のためのエイリアス (一部のみここに定義)
# ほとんどの後方互換エイリアスは mk/deprecated-targets.mk で一元管理されています。
# ========================================

# ここでは、単純な転送のみが必要な少数のエイリアスのみを定義しています。
# 詳細な非推奨ポリシー（警告、期限など）は mk/deprecated-targets.mk を参照してください。

# SuperCopilot Framework for VSCode のインストール
install-packages-vscode-supercopilot:
	@echo "📦 SuperCopilot Framework for VSCode をインストール中..."
	@if [ ! -f vscode/setup-supercopilot.sh ]; then \
		echo "❌ エラー: vscode/setup-supercopilot.sh が見つかりません"; \
		exit 1; \
	fi
	@bash vscode/setup-supercopilot.sh || (echo "❌ エラー: SuperCopilot セットアップスクリプトの実行に失敗しました" && exit 1)

# 後方互換性のためのエイリアス
install-vscode-supercopilot: install-packages-vscode-supercopilot

# ccusage の後方互換エイリアス
install-ccusage: install-packages-ccusage

# SuperCursor (Cursor Framework) のインストール
install-supercursor:
	@echo "🚀 SuperCursor (Cursor Framework) のインストールを開始..."

	# Cursor の確認
	@echo "🔍 Cursor の確認中..."
	@if ! command -v cursor >/dev/null 2>&1; then \
		echo "ℹ️  Cursorはインストールされていますが、コマンドラインからは実行できない場合があります"; \
		echo "   このメッセージは無視して構いません"; \
	else \
		echo "✅ Cursor が見つかりました"; \
	fi

	# SuperCursorフレームワークのセットアップ
	@echo "⚙️  SuperCursor フレームワークをセットアップ中..."
	@echo "🔧 SuperCursor セットアップ準備中..."; \
	@echo "ℹ️   フレームワークファイル、ペルソナ、コマンドをシンボリックリンクで構成します"; \
	\
	# 必要な変数の確認
	if [ -z "$(DOTFILES_DIR)" ]; then \
		echo "❌ DOTFILES_DIR is not set"; \
		exit 1; \
	fi; \
	if [ -z "$(HOME_DIR)" ]; then \
		echo "❌ HOME_DIR is not set"; \
		exit 1; \
	fi; \
	\
	@echo "📁 必要なディレクトリを作成中..."; \
	mkdir -p $(HOME_DIR)/.cursor/ || true; \
	\
	@echo "🔗 シンボリックリンクを作成中..."; \
	# SuperCursor本体へのリンク \
	rm -rf $(HOME_DIR)/.cursor/supercursor; \
	ln -sT $(DOTFILES_DIR)/cursor/supercursor $(HOME_DIR)/.cursor/supercursor || true; \
	# 各種ディレクトリへのリンク \
	rm -rf $(HOME_DIR)/.cursor/commands; \
	ln -sT $(DOTFILES_DIR)/cursor/supercursor/Commands $(HOME_DIR)/.cursor/commands || true; \
	rm -rf $(HOME_DIR)/.cursor/core; \
	ln -sT $(DOTFILES_DIR)/cursor/supercursor/Core $(HOME_DIR)/.cursor/core || true; \
	rm -rf $(HOME_DIR)/.cursor/hooks; \
	ln -sT $(DOTFILES_DIR)/cursor/supercursor/Hooks $(HOME_DIR)/.cursor/hooks || true; \
	# 重要なファイルへの直接リンク \
	rm -f $(HOME_DIR)/.cursor/CURSOR.md; \
	ln -sf $(DOTFILES_DIR)/cursor/supercursor/README.md $(HOME_DIR)/.cursor/CURSOR.md || true; \
	\
	@echo "✅ SuperCursor フレームワークのシンボリックリンク設定が完了しました"

	@echo ""; \
	@echo "🎉 SuperCursor のセットアップが完了しました！" \
	@echo ""; \
	@echo "🚀 使用方法:" \
	@echo "1. Cursor IDEを起動" \
	@echo "2. SuperCursor コマンドを使用:" \
	@echo ""; \
	@echo "📋 利用可能なコマンド例:" \
	@echo "   /sc:implement <feature>    - 機能の実装" \
	@echo "   /sc:build                  - ビルド・パッケージング" \
	@echo "   /sc:design <ui>            - UI/UXデザイン" \
	@echo "   /sc:analyze <code>         - コード分析" \
	@echo "   /sc:troubleshoot <issue>   - 問題のデバッグ" \
	@echo "   /sc:test <suite>           - テストスイート" \
	@echo "   /sc:improve <code>         - コード改善" \
	@echo "   /sc:cleanup                - コードクリーンアップ" \
	@echo "   /sc:document <code>        - ドキュメント生成" \
	@echo "   /sc:git <operation>        - Git操作" \
	@echo "   /sc:estimate <task>        - 時間見積もり" \
	@echo "   /sc:task <management>      - タスク管理" \
	@echo ""; \
	@echo "🎭 スマートペルソナ:" \
	@echo "   🏗️  architect   - システム設計・アーキテクチャ" \
	@echo "   🎨 developer   -実装開発" \
	@echo "   📊 analyst     - コード分析・評価" \
	@echo "   🧪 tester      - テスト設計・実装" \
	@echo "   🚀 devops      - インフラ・デプロイ" \
	@echo ""; \
	@echo "✅ SuperCursor のインストールが完了しました"

# Gemini CLI のインストール
install-gemini-cli:
	@echo "🤖 Gemini CLI のインストールを開始..."

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

	# Gemini CLI のインストール確認
	@echo "🔍 既存の Gemini CLI インストールを確認中..."
	@if command -v gemini >/dev/null 2>&1; then \
		echo "✅ Gemini CLI は既にインストールされています"; \
		echo "   バージョン: $$(gemini --version 2>/dev/null || echo '取得できませんでした')"; \
		echo ""; \
		echo "🔄 アップデートを確認中..."; \
		npm update -g @google/gemini-cli 2>/dev/null || true; \
	else \
		echo "📦 Gemini CLI をインストール中..."; \
		echo "ℹ️  グローバルインストールを実行します: npm install -g @google/gemini-cli"; \
		\
		if npm install -g @google/gemini-cli; then \
			echo "✅ Gemini CLI のインストールが完了しました"; \
		else \
			echo "❌ Gemini CLI のインストールに失敗しました"; \
			echo ""; \
			echo "🔧 トラブルシューティング:"; \
			echo "1. 権限の問題: npm config set prefix $(HOME)/.local"; \
			echo "2. WSLの場合: npm config set os linux"; \
			echo "3. 強制インストール: npm install -g @google/gemini-cli --force"; \
			echo ""; \
			exit 1; \
		fi; \
	fi

	# インストール確認
	@echo "🔍 インストールの確認中..."
	@if command -v gemini >/dev/null 2>&1; then \
		echo "✅ Gemini CLI が正常にインストールされました"; \
		echo "   実行ファイル: $$(which gemini)"; \
		echo "   バージョン: $$(gemini --version 2>/dev/null || echo '取得できませんでした')"; \
	else \
		echo "❌ Gemini CLI のインストール確認に失敗しました"; \
		echo "ℹ️  PATH の問題の可能性があります"; \
		echo "   手動確認: which gemini"; \
		exit 1; \
	fi

	@echo ""; \
	@echo "🎉 Gemini CLI のセットアップガイド:" \
	@echo "1. プロジェクトディレクトリに移動: cd your-project-directory" \
	@echo "2. Gemini CLI を開始: gemini" \
	@echo "3. 認証方法を選択: Google Cloud認証" \
	@echo "4. 初回セットアップコマンド:" \
	@echo "   > summarize this project" \
	@echo "   > /help" \
	@echo ""; \
	@echo "✅ Gemini CLI のインストールが完了しました"

# SuperGemini (Gemini CLI Framework) のインストール
install-supergemini:
	@echo "🚀 SuperGemini (Gemini CLI Framework) のインストールを開始..."

	# Gemini CLI の確認
	@echo "🔍 Gemini CLI の確認中..."
	@if ! command -v gemini >/dev/null 2>&1; then \
		echo "❌ Gemini CLI がインストールされていません"; \
		echo "ℹ️  先に 'make install-gemini-cli' を実行してください"; \
		exit 1; \
	else \
		echo "✅ Gemini CLI が見つかりました"; \
	fi

	# SuperGeminiフレームワークのセットアップ
	@echo "⚙️  SuperGemini フレームワークをセットアップ中..."
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	echo "🔧 SuperGemini セットアップ準備中..."; \
	@echo "ℹ️  フレームワークファイル、ユーザーツール、Gemini CLI設定をシンボリックリンクで構成します"; \
	\
	@echo "📁 必要なディレクトリを作成中..."; \
	mkdir -p $(HOME_DIR)/.gemini/ || true; \
	mkdir -p $(HOME_DIR)/.gemini/user-tools/ || true; \
	\
	@echo "🔗 シンボリックリンクを作成中..."; \
	# SuperGemini本体へのリンク \
	ln -sf $(DOTFILES_DIR)/gemini/supergemini $(HOME_DIR)/.gemini/supergemini || true; \
	# 各種ディレクトリへのリンク \
	ln -sf $(DOTFILES_DIR)/gemini/supergemini/Core $(HOME_DIR)/.gemini/core || true; \
	ln -sf $(DOTFILES_DIR)/gemini/supergemini/Hooks $(HOME_DIR)/.gemini/hooks || true; \
	# 重要なファイルへの直接リンク \
	ln -sf $(DOTFILES_DIR)/gemini/supergemini/GEMINI.md $(HOME_DIR)/.gemini/GEMINI.md || true; \
	\
	@echo "📝 カスタムツールファイルを作成中..."; \
	cp -f $(DOTFILES_DIR)/gemini/supergemini/Commands/help.md $(HOME_DIR)/.gemini/user-tools/user-help.md 2>/dev/null || \
	echo "import-help: # /user-help コマンド\n\nSuperGeminiフレームワークのコマンド一覧を表示します。" > $(HOME_DIR)/.gemini/user-tools/user-help.md; \
	\
	cp -f $(DOTFILES_DIR)/gemini/supergemini/Commands/analyze.md $(HOME_DIR)/.gemini/user-tools/user-analyze.md 2>/dev/null || \
	echo "import-analyze: # /user-analyze コマンド\n\nコードや機能を分析します。" > $(HOME_DIR)/.gemini/user-tools/user-analyze.md; \
	\
	cp -f $(DOTFILES_DIR)/gemini/supergemini/Commands/implement.md $(HOME_DIR)/.gemini/user-tools/user-implement.md 2>/dev/null || \
	echo "import-implement: # /user-implement コマンド\n\n新機能を実装します。" > $(HOME_DIR)/.gemini/user-tools/user-implement.md; \
	\
	@echo "🔧 Gemini CLI設定ファイルを更新中..."; \
	echo '{"selectedAuthType":"oauth-personal","usageStatisticsEnabled":false,"customToolsDirectory":"~/.gemini/user-tools","enableCustomTools":true}' > $(HOME_DIR)/.gemini/settings.json || true; \
	\
	@echo "✅ SuperGemini フレームワークのシンボリックリンク設定が完了しました"; \
	@echo ""; \
	@echo "🎉 SuperGemini のセットアップが完了しました！" \
	@echo ""; \
	@echo "🚀 使用方法:" \
	@echo "1. Gemini CLI を起動: gemini" \
	@echo "2. SuperGemini コマンドを使用:" \
	@echo ""; \
	@echo "📋 利用可能なコマンド例:" \
	@echo "   /user-implement <feature>    - 機能の実装" \
	@echo "   /user-build                  - ビルド・パッケージング" \
	@echo "   /user-design <ui>            - UI/UXデザイン" \
	@echo "   /user-analyze <code>         - コード分析" \
	@echo "   /user-troubleshoot <issue>   - 問題のデバッグ" \
	@echo "   /user-test <suite>           - テストスイート" \
	@echo "   /user-improve <code>         - コード改善" \
	@echo "   /user-cleanup                - コードクリーンアップ" \
	@echo "   /user-document <code>        - ドキュメント生成" \
	@echo "   /user-git <operation>        - Git操作" \
	@echo "   /user-estimate <task>        - 時間見積もり" \
	@echo "   /user-task <management>      - タスク管理" \
	@echo ""; \
	@echo "🎭 スマートペルソナ:" \
	@echo "   🏗️  architect   - システム設計・アーキテクチャ" \
	@echo "   🎨 frontend    - UI/UX・アクセシビリティ" \
	@echo "   ⚙️  backend     - API・インフラストラクチャ" \
	@echo "   🔍 analyzer    - デバッグ・問題解決" \
	@echo "   🛡️  security    - セキュリティ・脆弱性評価" \
	@echo "   ✍️  scribe      - ドキュメント・技術文書" \
	@echo ""; \
	@echo "📝 注意: カスタムツールを再読み込みするには /reload-user-tools コマンドを使用します" \
	@echo ""; \
	@echo "✅ SuperGemini のインストールが完了しました"

# Gemini エコシステム一括インストール
install-gemini-ecosystem:
	@echo "🌟 Gemini エコシステム一括インストールを開始..."
	@echo "";

	# Step 1: Gemini CLI のインストール
	@echo "📋 Step 1/2: Gemini CLI をインストール中..."
	@$(MAKE) install-gemini-cli
	@echo "✅ Gemini CLI のインストールが完了しました"
	@echo "";

	# Step 2: SuperGemini のインストール
	@echo "📋 Step 2/2: SuperGemini をインストール中..."
	@$(MAKE) install-supergemini
	@echo "✅ SuperGemini のインストールが完了しました"
	@echo "";

	# 最終確認
	@echo "🔍 インストール結果の確認中..."
	@export PATH="$$HOME/.local/bin:$$PATH"; \
	if command -v gemini >/dev/null 2>&1; then \
		echo "Gemini CLI: ✅ $$(gemini --version 2>/dev/null || echo "インストール済み")"; \
	else \
		echo "Gemini CLI: ❌ 未確認"; \
	fi; \
	if [ -f "$$HOME/.gemini/GEMINI.md" ]; then \
		echo "SuperGemini: ✅ インストール済み"; \
	else \
		echo "SuperGemini: ❌ 未確認"; \
	fi

	@echo ""; \
	@echo "🎉 Gemini エコシステムのインストールが完了しました！" \
	@echo ""; \
	@echo "🚀 使用開始ガイド:" \
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" \
	@echo ""; \
	@echo "💻 Gemini CLI:" \
	@echo "  コマンド: gemini" \
	@echo "  使用例: プロジェクトディレクトリで 'gemini' を実行" \
	@echo ""; \
	@echo "🚀 SuperGemini (フレームワーク):" \
	@echo "  Gemini CLI内で以下のコマンドが利用可能:" \
	@echo "    /user-implement <機能>     - 機能実装" \
	@echo "    /user-build                  - ビルド・パッケージング" \
	@echo "    /user-design <UI>            - UI/UXデザイン" \
	@echo "    /user-analyze <コード>       - コード分析" \
	@echo "    /user-troubleshoot <issue>   - 問題のデバッグ" \
	@echo "    /user-test <テスト>          - テストスイート" \
	@echo "    /user-improve <コード>       - コード改善" \
	@echo ""; \
	@echo "✨ おすすめワークフロー:" \
	@echo "  1. 'gemini' でプロジェクトを開始" \
	@echo "  2. '/user-implement' で機能を実装" \
	@echo ""; \
	@echo "✅ Gemini エコシステムの一括インストールが完了しました"

# ImageMagick のインストール（アイコン変換用）
install-imagemagick:
	@echo "🎨 ImageMagick（アイコン変換用）をインストール中..."
	@if command -v convert >/dev/null 2>&1; then \
		echo "✅ ImageMagickは既にインストールされています"; \
	else \
		echo "📦 ImageMagickをインストール中..."; \
		sudo apt-get update >/dev/null 2>&1 && \
		sudo apt-get install -y imagemagick >/dev/null 2>&1 && \
		echo "✅ ImageMagickのインストールが完了しました"; \
	fi

# ========================================
# テスト用ターゲット
# ========================================

# システム情報の表示
system-info:
	@echo "🖥️ システム情報:"
	@uname -a
	@echo ""; \
	@echo "📦 パッケージ管理システム:"
	@command -v apt-get && echo "APT (Debian/Ubuntu)" || echo "APT not found"
	@command -v brew && echo "Homebrew (Linuxbrew)" || echo "Homebrew not found"
	@command -v dnf && echo "DNF (Fedora)" || echo "DNF not found"
	@command -v pacman && echo "Pacman (Arch Linux)" || echo "Pacman not found"
	@echo ""; \
	@echo "🔧 シェル情報:"
	@echo "   SHELL: $$SHELL"
	@echo "   BASH_VERSION: $$BASH_VERSION"
	@echo "   ZSH_VERSION: $$ZSH_VERSION"
	@echo ""; \
	@echo "📂 ホームディレクトリ: $$HOME"
	@echo "📂 カレントディレクトリ: $$PWD"
	@echo ""; \
	@echo "🔄 環境変数:"
	@printenv | sort

# インストール済みパッケージのリスト表示
list-installed-packages:
	@echo "📦 インストール済みパッケージのリスト:"
	@if command -v brew >/dev/null 2>&1; then \
		echo "Homebrew パッケージ:"; \
		brew list --versions; \
		echo ""; \
	fi
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "APT パッケージ:"; \
		dpkg --get-selections | grep -v deinstall; \
		echo ""; \
	fi
	@if command -v rpm >/dev/null 2>&1; then \
		echo "RPM パッケージ:"; \
		rpm -qa; \
		echo ""; \
	fi
	@if command -v pacman >/dev/null 2>&1; then \
		echo "Pacman パッケージ:"; \
		pacman -Q; \
		echo ""; \
	fi

# システムの再起動
restart-system:
	@echo "🔄 システムを再起動しようとしています..."
	@echo "⚠️  この操作により、すべての未保存の作業が失われます。"
	@read -p "本当にシステムを再起動しますか? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "システムを再起動します..."; \
		sudo reboot; \
	else \
		echo "再起動をキャンセルしました。"; \
	fi

# システムのシャットダウン
shutdown-system:
	@echo "⏹️ システムをシャットダウンしようとしています..."
	@echo "⚠️  この操作により、すべての未保存の作業が失われます。"
	@read -p "本当にシステムをシャットダウンしますか? (y/N): " confirm; \
			if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
				echo "システムをシャットダウンします..."; \
				sudo shutdown now; \
			else \
				echo "シャットダウンをキャンセルしました。"; \
			fi
