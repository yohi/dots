# Mozc関連のターゲット

# Mozc辞書の設定変数
MOZC_DICT_VERSION := 20240330
MOZC_DICT_FILENAME := mozcdic-ut-$(MOZC_DICT_VERSION).zip
MOZC_DICT_URL := https://github.com/utuhiro78/mozcdic-ut/releases/download/$(MOZC_DICT_VERSION)/$(MOZC_DICT_FILENAME)
MOZC_DICT_CHECKSUM := 0000000000000000000000000000000000000000000000000000000000000000  # 注意：実際のSHA256チェックサムに置き換える必要があります
MOZC_DICT_TXT := mozcdic-ut-$(MOZC_DICT_VERSION).txt
MOZC_CONFIG_DIR := $(HOME_DIR)/.config/mozc

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
	@if ! sudo DEBIAN_FRONTEND=noninteractive apt-get install -y wget unzip; then \
		echo "❌ エラー: 必要なパッケージのインストールに失敗しました"; \
		exit 1; \
	fi

	# 辞書ファイルのダウンロードとセットアップ
	@echo "⬇️  辞書ファイルをダウンロード中..."
	@mkdir -p $(MOZC_CONFIG_DIR)
	@cd $(MOZC_CONFIG_DIR) && \
	if [ ! -f "$(MOZC_DICT_FILENAME)" ]; then \
		if ! wget -O $(MOZC_DICT_FILENAME) "$(MOZC_DICT_URL)"; then \
			echo "❌ エラー: 辞書ファイルのダウンロードに失敗しました"; \
			exit 1; \
		fi; \
	fi

	# チェックサム検証
	@echo "🔍 ダウンロードしたファイルの整合性を検証中..."
	@cd $(MOZC_CONFIG_DIR) && \
	if [ -f "$(MOZC_DICT_FILENAME)" ]; then \
		ACTUAL_CHECKSUM=$$(sha256sum $(MOZC_DICT_FILENAME) | cut -d' ' -f1); \
		if [ "$$ACTUAL_CHECKSUM" != "$(MOZC_DICT_CHECKSUM)" ]; then \
			echo "❌ エラー: チェックサムが一致しません"; \
			echo "期待値: $(MOZC_DICT_CHECKSUM)"; \
			echo "実際値: $$ACTUAL_CHECKSUM"; \
			echo "ファイルが破損している可能性があります。"; \
			rm -f $(MOZC_DICT_FILENAME); \
			exit 1; \
		else \
			echo "✅ チェックサム検証が成功しました"; \
		fi; \
	else \
		echo "❌ エラー: 辞書ファイルが見つかりません"; \
		exit 1; \
	fi

	# 辞書ファイルの展開
	@echo "📂 辞書ファイルを展開中..."
	@cd $(MOZC_CONFIG_DIR) && \
	if ! unzip -o $(MOZC_DICT_FILENAME); then \
		echo "❌ エラー: 辞書ファイルの展開に失敗しました"; \
		exit 1; \
	fi

	# 辞書のインポート
	@echo "📥 辞書をインポート中..."
	@if command -v /usr/lib/mozc/mozc_tool >/dev/null 2>&1; then \
		if ! /usr/lib/mozc/mozc_tool --mode=dictionary_tool --dictionary_import_file=$(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT); then \
			echo "⚠️  辞書の自動インポートに失敗しました。手動でインポートしてください。"; \
			echo "ファイルパス: $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)"; \
		fi; \
	else \
		echo "⚠️  mozc_toolが見つかりません。手動でインポートしてください。"; \
		echo "ファイルパス: $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)"; \
	fi

	@echo "✅ Mozc UT辞書のセットアップが完了しました。"

# Mozc辞書のインポート状況確認
check-mozc-import-status:
	@echo "🔍 Mozc辞書のインポート状況を確認中..."
	@if [ -f "$(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)" ]; then \
		echo "✅ UT辞書ファイルが見つかりました: $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)"; \
		echo "📊 辞書ファイルの行数: $$(wc -l < $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT))"; \
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
	@if [ -f "$(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)" ]; then \
		echo "   ✅ 辞書ファイルが見つかりました: $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)"; \
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
	@echo "   - ファイルパス: $(MOZC_CONFIG_DIR)/$(MOZC_DICT_TXT)"
	@echo "   - 辞書名: 任意の名前（例: UT辞書）"
	@echo "   - フォーマット: Mozc"
	@echo ""
	@echo "4. 辞書の有効化:"
	@echo "   - インポートした辞書にチェックを入れて有効化"
	@echo "   - 「適用」ボタンをクリック"
	@echo ""
	@echo "✅ 手動セットアップの手順を表示しました。"

# Mozc UT辞書ファイルのチェックサム取得
get-mozc-dict-checksum:
	@echo "📋 Mozc UT辞書のチェックサムを取得中..."
	@echo "ℹ️  以下のコマンドを実行して実際のチェックサムを取得してください:"
	@echo ""
	@echo "1. 辞書ファイルをダウンロード:"
	@echo "   wget -O /tmp/$(MOZC_DICT_FILENAME) \"$(MOZC_DICT_URL)\""
	@echo ""
	@echo "2. チェックサムを取得:"
	@echo "   sha256sum /tmp/$(MOZC_DICT_FILENAME)"
	@echo ""
	@echo "3. 取得したチェックサムを mk/mozc.mk の MOZC_DICT_CHECKSUM 変数に設定"
	@echo ""
	@echo "⚠️  現在のチェックサム値はプレースホルダーです："
	@echo "   $(MOZC_DICT_CHECKSUM)"
	@echo ""
	@echo "✅ チェックサム取得方法を表示しました。"

# ========================================
# 新しい階層的な命名規則のターゲット
# ========================================

# Mozc関連設定系
setup-config-mozc: setup-mozc
setup-config-mozc-ut-dictionaries: setup-mozc-ut-dictionaries
setup-config-mozc-ut-dictionaries-manual: setup-mozc-ut-dictionaries-manual

# ========================================
# 後方互換性のためのエイリアス
# ========================================

# 古いターゲット名を維持（既に実装済み）
# setup-mozc: は既に実装済み
# setup-mozc-ut-dictionaries: は既に実装済み
# setup-mozc-ut-dictionaries-manual: は既に実装済み
