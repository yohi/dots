# フォント管理関連のターゲット
# フォントファイルのダウンロード・インストール・管理

# フォント管理変数
FONTS_DIR := $(HOME)/.local/share/fonts
FONTS_TEMP_DIR := /tmp/dotfiles-fonts
NERD_FONTS_VERSION := v3.1.1
GOOGLE_FONTS_API := https://fonts.google.com/download?family=

# PHONYターゲット
.PHONY: fonts-setup fonts-install fonts-install-nerd fonts-install-google fonts-install-japanese fonts-clean fonts-update fonts-list

# セキュリティ機能: zipファイル検証
define verify_zip_file
	@if [ -f "$(1)" ]; then \
		echo "🔍 $(1) を検証中..."; \
		if unzip -t "$(1)" >/dev/null 2>&1; then \
			echo "✅ $(1) 検証完了"; \
		else \
			echo "❌ エラー: $(1) は破損しています"; \
			exit 1; \
		fi; \
	else \
		echo "❌ エラー: $(1) が見つかりません"; \
		exit 1; \
	fi
endef

# フォント全体セットアップ
fonts-setup: fonts-install ## フォント環境の完全セットアップ

# 全フォントインストール
fonts-install: fonts-install-nerd fonts-install-google fonts-install-japanese ## 全種類のフォントをインストール
	@echo "✅ 全フォントのインストールが完了しました"
	@$(MAKE) fonts-refresh

# Nerd Fontsのインストール
fonts-install-nerd: ## Nerd Fonts (開発者向けアイコンフォント) をインストール
	@echo "🔤 Nerd Fontsをインストール中..."
	@mkdir -p $(FONTS_DIR) $(FONTS_TEMP_DIR)
	@cd $(FONTS_TEMP_DIR) && \
	echo "📥 JetBrainsMono Nerd Fontをダウンロード中..." && \
	if curl -fLo JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/JetBrainsMono.zip"; then \
		if [ -s JetBrainsMono.zip ]; then \
			echo "✅ JetBrainsMono ダウンロード完了 ($$(ls -lh JetBrainsMono.zip | awk '{print $$5}'))"; \
		else \
			echo "❌ エラー: JetBrainsMono ファイルが空です"; \
			exit 1; \
		fi; \
	else \
		echo "❌ エラー: JetBrainsMono Nerd Fontのダウンロードに失敗しました"; \
		echo "URL: https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/JetBrainsMono.zip"; \
		exit 1; \
	fi && \
	echo "📥 FiraCode Nerd Fontをダウンロード中..." && \
	if curl -fLo FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/FiraCode.zip"; then \
		echo "✅ FiraCode ダウンロード完了"; \
	else \
		echo "❌ エラー: FiraCode Nerd Fontのダウンロードに失敗しました"; \
		echo "URL: https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/FiraCode.zip"; \
		exit 1; \
	fi && \
	echo "📥 Hack Nerd Fontをダウンロード中..." && \
	if curl -fLo Hack.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/Hack.zip"; then \
		echo "✅ Hack ダウンロード完了"; \
	else \
		echo "❌ エラー: Hack Nerd Fontのダウンロードに失敗しました"; \
		echo "URL: https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/Hack.zip"; \
		exit 1; \
	fi && \
	echo "📥 DejaVuSansMono Nerd Fontをダウンロード中..." && \
	if curl -fLo DejaVuSansMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/DejaVuSansMono.zip"; then \
		echo "✅ DejaVuSansMono ダウンロード完了"; \
	else \
		echo "❌ エラー: DejaVuSansMono Nerd Fontのダウンロードに失敗しました"; \
		echo "URL: https://github.com/ryanoasis/nerd-fonts/releases/download/$(NERD_FONTS_VERSION)/DejaVuSansMono.zip"; \
		exit 1; \
	fi && \
	echo "📂 フォントファイルを個別に展開中..." && \
	for zipfile in JetBrainsMono.zip FiraCode.zip Hack.zip DejaVuSansMono.zip; do \
		if [ -f "$$zipfile" ]; then \
			echo "🔍 $$zipfile を検証中..."; \
			if unzip -t "$$zipfile" >/dev/null 2>&1; then \
				echo "✅ $$zipfile 検証完了"; \
				echo "🔓 $$zipfile を展開中..."; \
				if unzip -o "$$zipfile" -d $(FONTS_DIR)/; then \
					echo "✅ $$zipfile 展開完了"; \
				else \
					echo "❌ エラー: $$zipfile の展開に失敗しました"; \
					exit 1; \
				fi; \
			else \
				echo "❌ エラー: $$zipfile は破損しています"; \
				exit 1; \
			fi; \
		else \
			echo "❌ エラー: $$zipfile が見つかりません（ダウンロード失敗の可能性）"; \
			exit 1; \
		fi; \
	done && \
	echo "✅ Nerd Fontsのインストールが完了しました"

# Google Fontsのインストール
fonts-install-google: ## Google Fonts (ウェブフォント) をインストール
	@echo "🌐 Google Fontsをインストール中..."
	@mkdir -p $(FONTS_DIR) $(FONTS_TEMP_DIR)
	@cd $(FONTS_TEMP_DIR) && \
	echo "📥 Robotoをダウンロード中..." && \
	if curl -fLo Roboto.zip "$(GOOGLE_FONTS_API)Roboto"; then \
		echo "✅ Roboto ダウンロード完了"; \
	else \
		echo "❌ エラー: Robotoのダウンロードに失敗しました"; \
		echo "URL: $(GOOGLE_FONTS_API)Roboto"; \
		exit 1; \
	fi && \
	echo "📥 Open Sansをダウンロード中..." && \
	if curl -fLo OpenSans.zip "$(GOOGLE_FONTS_API)Open+Sans"; then \
		echo "✅ Open Sans ダウンロード完了"; \
	else \
		echo "❌ エラー: Open Sansのダウンロードに失敗しました"; \
		echo "URL: $(GOOGLE_FONTS_API)Open+Sans"; \
		exit 1; \
	fi && \
	echo "📥 Source Code Proをダウンロード中..." && \
	if curl -fLo SourceCodePro.zip "$(GOOGLE_FONTS_API)Source+Code+Pro"; then \
		echo "✅ Source Code Pro ダウンロード完了"; \
	else \
		echo "❌ エラー: Source Code Proのダウンロードに失敗しました"; \
		echo "URL: $(GOOGLE_FONTS_API)Source+Code+Pro"; \
		exit 1; \
	fi && \
	echo "📥 IBM Plex Monoをダウンロード中..." && \
	if curl -fLo IBMPlexMono.zip "$(GOOGLE_FONTS_API)IBM+Plex+Mono"; then \
		echo "✅ IBM Plex Mono ダウンロード完了"; \
	else \
		echo "❌ エラー: IBM Plex Monoのダウンロードに失敗しました"; \
		echo "URL: $(GOOGLE_FONTS_API)IBM+Plex+Mono"; \
		exit 1; \
	fi && \
	echo "📂 フォントファイルを個別に展開中..." && \
	for zipfile in Roboto.zip OpenSans.zip SourceCodePro.zip IBMPlexMono.zip; do \
		if [ -f "$$zipfile" ]; then \
			echo "🔍 $$zipfile を検証中..."; \
			if unzip -t "$$zipfile" >/dev/null 2>&1; then \
				echo "✅ $$zipfile 検証完了"; \
				echo "🔓 $$zipfile を展開中..."; \
				if unzip -o "$$zipfile" -d $(FONTS_DIR)/; then \
					echo "✅ $$zipfile 展開完了"; \
				else \
					echo "❌ エラー: $$zipfile の展開に失敗しました"; \
					exit 1; \
				fi; \
			else \
				echo "❌ エラー: $$zipfile は破損しています"; \
				exit 1; \
			fi; \
		else \
			echo "❌ エラー: $$zipfile が見つかりません（ダウンロード失敗の可能性）"; \
			exit 1; \
		fi; \
	done && \
	echo "✅ Google Fontsのインストールが完了しました"

# 日本語フォントのインストール
fonts-install-japanese: ## 日本語フォントをインストール
	@echo "🇯🇵 日本語フォントをインストール中..."
	@mkdir -p $(FONTS_DIR) $(FONTS_TEMP_DIR)

	# Noto CJK (APTから)
	@echo "📦 Noto CJK フォントをAPTからインストール中..."
	@sudo apt update >/dev/null 2>&1 || true
	@sudo apt install -y fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-color-emoji || echo "⚠️ APTからのインストールに失敗しました"

	# IBM Plex Sans JP (手動ダウンロード)
	@cd $(FONTS_TEMP_DIR) && \
	echo "📥 IBM Plex Sans JPをダウンロード中..." && \
	if curl -fLo IBMPlexSansJP.zip "$(GOOGLE_FONTS_API)IBM+Plex+Sans+JP"; then \
		echo "✅ IBM Plex Sans JP ダウンロード完了"; \
	else \
		echo "❌ エラー: IBM Plex Sans JPのダウンロードに失敗しました"; \
		echo "URL: $(GOOGLE_FONTS_API)IBM+Plex+Sans+JP"; \
		exit 1; \
	fi && \
	echo "📂 フォントファイルを展開中..." && \
	if unzip -o IBMPlexSansJP.zip -d $(FONTS_DIR)/; then \
		echo "✅ 日本語フォントのインストールが完了しました"; \
	else \
		echo "❌ エラー: フォントファイルの展開に失敗しました"; \
		exit 1; \
	fi

# フォントキャッシュの更新
fonts-refresh: ## フォントキャッシュを更新
	@echo "🔄 フォントキャッシュを更新中..."
	@fc-cache -fv >/dev/null 2>&1 || echo "⚠️ フォントキャッシュの更新に失敗しました"
	@echo "✅ フォントキャッシュが更新されました"

# インストール済みフォントの一覧表示
fonts-list: ## インストール済みフォントを一覧表示
	@echo "📝 インストール済みフォント一覧:"
	@echo ""
	@echo "🔤 Nerd Fonts:"
	@fc-list | grep -i "nerd\|jetbrains\|fira\|hack\|dejavu" | cut -d: -f2 | sort | uniq || echo "  なし"
	@echo ""
	@echo "🌐 Google Fonts:"
	@fc-list | grep -i "roboto\|open sans\|source code\|ibm plex" | cut -d: -f2 | sort | uniq || echo "  なし"
	@echo ""
	@echo "🇯🇵 日本語フォント:"
	@fc-list | grep -i "noto\|cjk\|japanese\|jp" | cut -d: -f2 | sort | uniq || echo "  なし"
	@echo ""

# フォント関連一時ファイルのクリーンアップ
fonts-clean: ## フォント関連の一時ファイルを削除
	@echo "🧹 フォント一時ファイルを削除中..."
	@rm -rf $(FONTS_TEMP_DIR)
	@echo "✅ 一時ファイルが削除されました"

# フォント更新 (既存削除→再インストール)
fonts-update: fonts-clean ## フォントを最新版に更新
	@echo "🔄 フォントを更新中..."
	@read -p "既存のフォントファイルを削除して再インストールしますか？ [y/N]: " confirm && \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		echo "🗑️ 既存フォントファイルを削除中..."; \
		find $(FONTS_DIR) -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.woff" -o -name "*.woff2" \) -delete 2>/dev/null || true; \
		$(MAKE) fonts-install; \
	else \
		echo "❌ 更新がキャンセルされました"; \
	fi

# フォント環境のデバッグ情報
fonts-debug: ## フォント環境のデバッグ情報を表示
	@echo "🔍 フォント環境のデバッグ情報:"
	@echo ""
	@echo "📁 フォントディレクトリ: $(FONTS_DIR)"
	@echo "📊 フォント統計:"
	@echo "  総フォント数: $$(fc-list | wc -l)"
	@echo "  TTFファイル数: $$(find $(FONTS_DIR) -name "*.ttf" 2>/dev/null | wc -l)"
	@echo "  OTFファイル数: $$(find $(FONTS_DIR) -name "*.otf" 2>/dev/null | wc -l)"
	@echo ""
	@echo "💾 ディスク使用量:"
	@du -sh $(FONTS_DIR) 2>/dev/null || echo "  計算できませんでした"
	@echo ""
	@echo "🔧 フォント設定:"
	@echo "  fontconfig version: $$(fc-cache --version 2>/dev/null | head -1 || echo '不明')"
	@echo "  設定ファイル: $$(find ~/.config/fontconfig -name "*.conf" 2>/dev/null | wc -l) 個"

# フォント設定ファイルのバックアップ
fonts-backup: ## フォント設定をバックアップ
	@echo "💾 フォント設定をバックアップ中..."
	@backup_dir="$(HOME)/.config/fontconfig-backup-$$(date +%Y%m%d_%H%M%S)" && \
	mkdir -p "$$backup_dir" && \
	if [ -d "$(HOME)/.config/fontconfig" ]; then \
		cp -r "$(HOME)/.config/fontconfig"/* "$$backup_dir/" 2>/dev/null || true; \
		echo "✅ バックアップ完了: $$backup_dir"; \
	else \
		echo "⚠️ fontconfig設定ディレクトリが見つかりません"; \
	fi

# 推奨フォント設定の適用
fonts-configure: ## 推奨フォント設定を適用
	@echo "⚙️ 推奨フォント設定を適用中..."
	@mkdir -p $(HOME)/.config/fontconfig/conf.d
	@echo '<?xml version="1.0"?>' > $(HOME)/.config/fontconfig/fonts.conf
	@echo '<!DOCTYPE fontconfig SYSTEM "fonts.dtd">' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '<fontconfig>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  <!-- 日本語フォント優先順位 -->' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  <alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <family>serif</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>Noto Serif CJK JP</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>DejaVu Serif</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    </prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  </alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  <alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <family>sans-serif</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>Noto Sans CJK JP</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>DejaVu Sans</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    </prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  </alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  <alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <family>monospace</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    <prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>JetBrainsMono Nerd Font</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>FiraCode Nerd Font</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>Noto Sans Mono CJK JP</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '      <family>DejaVu Sans Mono</family>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '    </prefer>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '  </alias>' >> $(HOME)/.config/fontconfig/fonts.conf
	@echo '</fontconfig>' >> $(HOME)/.config/fontconfig/fonts.conf
	@$(MAKE) fonts-refresh
	@echo "✅ フォント設定が適用されました"
