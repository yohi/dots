# Mozc関連のターゲット

# Mozcの設定
setup-mozc:
	@echo "⌨️  Mozcの設定を実行中..."

	# Mozcのインストール
	@echo "📦 Mozcをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fcitx5-mozc mozc-utils-gui || true

	# Fcitx5の設定
	@echo "🔧 Fcitx5を設定中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get install -y fcitx5 fcitx5-config-qt || true

	# 環境変数の設定
	@echo "🌍 環境変数を設定中..."
	@if ! grep -q "GTK_IM_MODULE=fcitx" $(HOME_DIR)/.profile 2>/dev/null; then \
		echo "export GTK_IM_MODULE=fcitx" >> $(HOME_DIR)/.profile; \
	fi
	@if ! grep -q "QT_IM_MODULE=fcitx" $(HOME_DIR)/.profile 2>/dev/null; then \
		echo "export QT_IM_MODULE=fcitx" >> $(HOME_DIR)/.profile; \
	fi
	@if ! grep -q "XMODIFIERS=@im=fcitx" $(HOME_DIR)/.profile 2>/dev/null; then \
		echo "export XMODIFIERS=@im=fcitx" >> $(HOME_DIR)/.profile; \
	fi

	# Fcitx5の自動起動設定
	@echo "🚀 Fcitx5の自動起動を設定中..."
	@mkdir -p $(HOME_DIR)/.config/autostart
	@if [ ! -f "$(HOME_DIR)/.config/autostart/fcitx5.desktop" ]; then \
		echo "[Desktop Entry]" > $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "Type=Application" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "Exec=fcitx5" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "Hidden=false" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "NoDisplay=false" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "X-GNOME-Autostart-enabled=true" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "Name=Fcitx5" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
		echo "Comment=Start Fcitx5 Input Method" >> $(HOME_DIR)/.config/autostart/fcitx5.desktop; \
	fi

	@echo "✅ Mozcの設定が完了しました。"
	@echo "ℹ️  ログアウト・ログインしてからMozcを使用してください。"

# Mozc UT辞書のセットアップ
setup-mozc-ut-dictionaries:
	@echo "📚 Mozc UT辞書をセットアップ中..."

	# 必要なパッケージのインストール
	@echo "📦 必要なパッケージをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip || true

	# 辞書ファイルのダウンロードとセットアップ
	@echo "⬇️  辞書ファイルをダウンロード中..."
	@mkdir -p $(HOME_DIR)/.config/mozc
	@cd $(HOME_DIR)/.config/mozc && \
	if [ ! -f "mozcdic-ut-20240330.zip" ]; then \
		wget -O mozcdic-ut-20240330.zip "https://github.com/utuhiro78/mozcdic-ut/releases/download/20240330/mozcdic-ut-20240330.zip" || true; \
	fi
	@cd $(HOME_DIR)/.config/mozc && \
	if [ -f "mozcdic-ut-20240330.zip" ]; then \
		unzip -o mozcdic-ut-20240330.zip || true; \
	fi

	# 辞書のインポート
	@echo "📥 辞書をインポート中..."
	@if command -v /usr/lib/mozc/mozc_tool >/dev/null 2>&1; then \
		/usr/lib/mozc/mozc_tool --mode=dictionary_tool --dictionary_import_file=$(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt || true; \
	else \
		echo "⚠️  mozc_toolが見つかりません。手動でインポートしてください。"; \
	fi

	@echo "✅ Mozc UT辞書のセットアップが完了しました。"

# Mozc辞書のインポート状況確認
check-mozc-import-status:
	@echo "🔍 Mozc辞書のインポート状況を確認中..."
	@if [ -f "$(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt" ]; then \
		echo "✅ UT辞書ファイルが見つかりました: $(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt"; \
		echo "📊 辞書ファイルの行数: $$(wc -l < $(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt)"; \
	else \
		echo "⚠️  UT辞書ファイルが見つかりません。setup-mozc-ut-dictionariesを実行してください。"; \
	fi

	@if command -v /usr/lib/mozc/mozc_tool >/dev/null 2>&1; then \
		echo "✅ mozc_toolが利用可能です"; \
	else \
		echo "⚠️  mozc_toolが見つかりません。Mozcが正しくインストールされていない可能性があります。"; \
	fi

	@echo "ℹ️  辞書の手動インポートが必要な場合は、以下のコマンドを実行してください:"; \
	echo "    /usr/lib/mozc/mozc_tool --mode=dictionary_tool"; \
	echo "    または Mozcの辞書ツールを使用してください。"

# Mozc UT辞書の手動セットアップ
setup-mozc-ut-dictionaries-manual:
	@echo "📚 Mozc UT辞書の手動セットアップを開始中..."
	@echo "ℹ️  以下の手順で辞書をインポートしてください:"
	@echo ""
	@echo "1. 辞書ファイルの確認:"
	@if [ -f "$(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt" ]; then \
		echo "   ✅ 辞書ファイルが見つかりました: $(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt"; \
	else \
		echo "   ⚠️  辞書ファイルが見つかりません。setup-mozc-ut-dictionariesを先に実行してください。"; \
		exit 1; \
	fi
	@echo ""
	@echo "2. 辞書ツールの起動:"
	@echo "   以下のコマンドを実行してMozc辞書ツールを起動してください:"
	@echo "   /usr/lib/mozc/mozc_tool --mode=dictionary_tool"
	@echo ""
	@echo "3. 辞書のインポート:"
	@echo "   - 辞書ツールで「管理」→「新規辞書にインポート」を選択"
	@echo "   - ファイルパス: $(HOME_DIR)/.config/mozc/mozcdic-ut-20240330.txt"
	@echo "   - 辞書名: 任意の名前（例: UT辞書）"
	@echo "   - フォーマット: Mozc"
	@echo ""
	@echo "4. 辞書の有効化:"
	@echo "   - インポートした辞書にチェックを入れて有効化"
	@echo "   - 「適用」ボタンをクリック"
	@echo ""
	@echo "✅ 手動セットアップの手順を表示しました。"
