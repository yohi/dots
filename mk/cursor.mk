# ============================================================
# Cursor IDE セットアップ用Makefile
# Cursor IDEのインストール、アップデート、管理を担当
# ============================================================

# Cursor AppImageのSHA256ハッシュ
# TODO: Cursor公式にSHA256チェックサムの公開をリクエスト中
# チェックサムが公開されるまでは、空欄に設定されていますが、インストール時には
# CURSOR_NO_VERIFY_HASH=true を指定しない限りエラーとなります（セキュリティ強化）
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
				echo "   (バージョンが更新された可能性があります。mk/cursor.mk の CURSOR_SHA256 を更新してください)"; \
				rm -f cursor.AppImage; \
				exit 1; \
			else \
				echo "✅ ハッシュ検証に成功しました"; \
				VALID_DOWNLOAD=1; \
			fi; \
		else \
			if [ "$(CURSOR_NO_VERIFY_HASH)" = "true" ]; then \
				echo "⚠️  【セキュリティ警告】SHA256チェックサム検証をスキップします (ユーザー要求)"; \
				echo "ℹ️  TLS(HTTPS)による通信経路の保護と、ファイルサイズ検証による簡易チェックを実行します"; \
				echo "   ダウンロード元: https://downloader.cursor.sh (TLS origin verified by curl)"; \
				if verify_download_size 100000000 500000000; then VALID_DOWNLOAD=1; else exit 1; fi; \
			else \
				echo "❌ エラー: CURSOR_SHA256 が設定されていません"; \
				echo "   セキュリティポリシーにより、整合性検証のないインストールはブロックされました。"; \
				echo "   (Cursor公式からチェックサムが提供されていないため、現在はハッシュが空になっています)"; \
				echo ""; \
				echo "   【暫定的な対処方法】"; \
				echo "   TLS(HTTPS)の安全性とファイルサイズ検証のみでインストールを続行する場合は、"; \
				echo "   以下のコマンドを実行してください:"; \
				echo ""; \
				echo "   make install-packages-cursor CURSOR_NO_VERIFY_HASH=true"; \
				echo ""; \
				rm -f cursor.AppImage; \
				exit 1; \
			fi; \
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
			TMPDIR=$$(mktemp -d); \
			if [ -n "$$TMPDIR" ] && cd "$$TMPDIR"; then \
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
				fi; \
				cd /tmp; \
				rm -rf "$$TMPDIR"; \
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
	\
	# --no-sandbox フラグについて: \
	# 【背景】AppImageのChromiumベースアプリは、デフォルトでユーザー名前空間サンドボックスを要求します。 \
	# 古いカーネルやコンテナ環境など一部の環境では、unprivileged_userns_cloneが無効化されており、 \
	# サンドボックス起動に失敗する場合があります。その場合に限り --no-sandbox フラグが必要です。 \
	# \
	# 【推奨対処法】 \
	# 1. 可能であれば公式DEBパッケージまたはFlatpak版を使用してください \
	# 2. AppImageを使う場合は、unprivileged user namespacesを有効化してください: \
	#    sudo sysctl -w kernel.unprivileged_userns_clone=1 \
	#    永続化: echo 'kernel.unprivileged_userns_clone=1' | sudo tee -a /etc/sysctl.conf \
	# \
	# 【セキュリティリスク】 \
	# --no-sandbox はChromiumのセキュリティ機能を無効化するため、通常環境では使用すべきではありません。 \
	# \
	# 【条件付き適用】 \
	# どうしても必要な場合に限り、環境変数 TRUSTED_NO_SANDBOX=true を設定してインストールしてください: \
	#   make TRUSTED_NO_SANDBOX=true install-packages-cursor \
	\
	if [ "$(TRUSTED_NO_SANDBOX)" = "true" ]; then \
		echo "⚠️  警告: TRUSTED_NO_SANDBOX=true が設定されているため --no-sandbox フラグを適用します"; \
		echo "⚠️  セキュリティリスク: サンドボックス保護が無効化されます"; \
		echo "Exec=/opt/cursor/cursor.AppImage --no-sandbox %F" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	else \
		echo "Exec=/opt/cursor/cursor.AppImage %F" | sudo tee -a /usr/share/applications/cursor.desktop > /dev/null; \
	fi; \
	\
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
	echo "🔍 現在のCursor IDEを確認中..." && \
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
			if [ "$$FILE_SIZE" -ge 100000000 ] && [ "$$FILE_SIZE" -le 500000000 ]; then \
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

# SuperCursor (Cursor Framework) のインストール
install-packages-supercursor:
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
	@echo "🔧 SuperCursor セットアップ準備中..."
	@echo "ℹ️   フレームワークファイル、ペルソナ、コマンドをシンボリックリンクで構成します"
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
	echo "📁 必要なディレクトリを作成中..."; \
	mkdir -p $(HOME_DIR)/.cursor/ || true; \
	\
	echo "🔗 シンボリックリンクを作成中..."; \
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
	echo "✅ SuperCursor フレームワークのシンボリックリンク設定が完了しました"

	@echo "";
	@echo "🎉 SuperCursor のセットアップが完了しました！"
	@echo "";
	@echo "🚀 使用方法:"
	@echo "1. Cursor IDEを起動"
	@echo "2. SuperCursor コマンドを使用:"
	@echo "";
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
	@echo "";
	@echo "🎭 スマートペルソナ:"
	@echo "   🏗️  architect   - システム設計・アーキテクチャ"
	@echo "   🎨 developer   -実装開発"
	@echo "   📊 analyst     - コード分析・評価"
	@echo "   🧪 tester      - テスト設計・実装"
	@echo "   🚀 devops      - インフラ・デプロイ"
	@echo "";
	@echo "✅ SuperCursor のインストールが完了しました"

# ========================================
# エイリアス
# ========================================

.PHONY: install-cursor
install-cursor: install-packages-cursor  ## Cursor IDEをインストール(エイリアス)

.PHONY: install-supercursor
install-supercursor: install-packages-supercursor  ## SuperCursorをインストール(エイリアス)
