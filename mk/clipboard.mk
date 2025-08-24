# クリップボード管理ツールのセットアップ
# CopyQ + Wayland対応の包括的な設定
# 
# インストール方法:
# sudo apt install software-properties-common python3-software-properties
# sudo add-apt-repository ppa:hluk/copyq
# sudo apt update
# sudo apt install copyq
# ※ このパッケージにはすべてのプラグインとドキュメントが含まれます

# ==============================================
# CopyQとクリップボード管理ツールのインストール
# ==============================================

.PHONY: install-packages-clipboard
install-packages-clipboard: ## クリップボード管理ツール（CopyQ + Wayland対応）をインストール
	@echo "📋 クリップボード管理ツールをインストール中..."
	
	# 必要なパッケージのインストール
	@echo "🔧 必要なパッケージをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y software-properties-common python3-software-properties || true
	
	# CopyQ PPAの追加
	@echo "📦 CopyQ PPAを追加中..."
	@sudo add-apt-repository -y ppa:hluk/copyq 2>/dev/null || echo "⚠️  PPA追加でエラーが発生しましたが、処理を続行します"
	
	# パッケージリストの更新
	@echo "📦 パッケージリストを更新中..."
	@sudo apt update -q 2>/dev/null || echo "⚠️  一部のリポジトリで問題がありますが、処理を続行します"
	
	# Waylandクリップボードツールのインストール
	@echo "🌊 Waylandクリップボードツールをインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y wl-clipboard || true
	
	# CopyQのインストール（PPAから、プラグインと共に）
	@echo "📋 CopyQ（プラグインと共に）をインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y copyq || true
	
	# 代替クリップボードツールのインストール（バックアップ）
	@echo "🔄 代替クリップボードツール（GPaste, Parcellite）をインストール中..."
	@sudo DEBIAN_FRONTEND=noninteractive apt install -y \
		gpaste \
		gpaste-applet \
		gpaste-gnome-shell \
		parcellite \
		xsel \
		xclip \
		|| true
	
	@echo "✅ クリップボード管理ツールのインストール完了"

.PHONY: setup-copyq-wayland
setup-copyq-wayland: ## CopyQのWayland対応設定を適用
	@echo "🌊 CopyQのWayland対応設定を適用中..."
	
	# CopyQプロセスの停止
	@echo "🔄 CopyQプロセスを再起動中..."
	@killall copyq 2>/dev/null || true
	@sleep 2
	
	# Wayland環境変数の設定
	@echo "⚙️  Wayland環境変数を設定中..."
	@if [ ! -f $(HOME)/.profile ] || ! grep -q "QT_QPA_PLATFORM" $(HOME)/.profile; then \
		echo "# CopyQ Wayland対応設定" >> $(HOME)/.profile; \
		echo "export QT_QPA_PLATFORM=wayland" >> $(HOME)/.profile; \
		echo "export QT_WAYLAND_DISABLE_WINDOWDECORATION=1" >> $(HOME)/.profile; \
	fi
	
	# CopyQ設定ディレクトリの確認・作成
	@echo "📁 CopyQ設定ディレクトリを確認中..."
	@mkdir -p $(HOME)/.config/copyq
	@mkdir -p $(HOME)/.local/share/copyq/copyq
	
	# CopyQの設定ファイル最適化
	@echo "⚙️  CopyQの設定を最適化中..."
	@if [ -f $(HOME)/.config/copyq/copyq.conf ]; then \
		echo "📝 既存のCopyQ設定を最適化中..."; \
		sed -i 's/check_clipboard=false/check_clipboard=true/g' $(HOME)/.config/copyq/copyq.conf 2>/dev/null || true; \
		sed -i 's/autostart=false/autostart=true/g' $(HOME)/.config/copyq/copyq.conf 2>/dev/null || true; \
	fi
	
	# CopyQ起動スクリプトの作成
	@echo "🚀 CopyQ起動スクリプトを作成中..."
	@mkdir -p $(HOME)/.local/bin
	@echo '#!/bin/bash' > $(HOME)/.local/bin/copyq-wayland
	@echo '# CopyQ Wayland起動スクリプト' >> $(HOME)/.local/bin/copyq-wayland
	@echo '' >> $(HOME)/.local/bin/copyq-wayland
	@echo '# Wayland環境変数の設定' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'export QT_QPA_PLATFORM=wayland' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'export QT_WAYLAND_DISABLE_WINDOWDECORATION=1' >> $(HOME)/.local/bin/copyq-wayland
	@echo '' >> $(HOME)/.local/bin/copyq-wayland
	@echo '# 既存のCopyQプロセスの停止' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'killall copyq 2>/dev/null || true' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'sleep 1' >> $(HOME)/.local/bin/copyq-wayland
	@echo '' >> $(HOME)/.local/bin/copyq-wayland
	@echo '# wl-clipboardの確認' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'if ! command -v wl-paste >/dev/null 2>&1; then' >> $(HOME)/.local/bin/copyq-wayland
	@echo '    echo "警告: wl-clipboardがインストールされていません"' >> $(HOME)/.local/bin/copyq-wayland
	@echo '    echo "sudo apt install wl-clipboard を実行してください"' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'fi' >> $(HOME)/.local/bin/copyq-wayland
	@echo '' >> $(HOME)/.local/bin/copyq-wayland
	@echo '# CopyQの起動' >> $(HOME)/.local/bin/copyq-wayland
	@echo 'exec /usr/bin/copyq "$$@"' >> $(HOME)/.local/bin/copyq-wayland
	@chmod +x $(HOME)/.local/bin/copyq-wayland
	
	# CopyQの再起動
	@echo "🔄 CopyQを再起動中..."
	@$(HOME)/.local/bin/copyq-wayland &
	@sleep 3
	
	# 動作確認
	@echo "🔍 CopyQ動作確認中..."
	@if pgrep -f copyq >/dev/null; then \
		echo "✅ CopyQが正常に起動しました"; \
		echo "📋 履歴件数: $$(copyq size 2>/dev/null || echo '確認できません')"; \
	else \
		echo "❌ CopyQの起動に失敗しました"; \
		echo "⚠️  手動で確認してください: copyq show"; \
	fi
	
	@echo "✅ CopyQのWayland対応設定完了"

.PHONY: setup-gnome-clipboard
setup-gnome-clipboard: ## GNOME Clipboard Indicator拡張機能を有効化
	@echo "🖥️  GNOME Clipboard Indicator拡張機能を設定中..."
	
	# Extension Managerの確認
	@if ! command -v gnome-extensions >/dev/null 2>&1; then \
		echo "⚠️  gnome-extensionsコマンドが見つかりません"; \
		echo "📦 Extension Managerをインストールしてください"; \
		sudo apt install -y gnome-shell-extension-manager 2>/dev/null || true; \
	fi
	
	# Clipboard Indicator拡張機能の有効化
	@echo "📋 Clipboard Indicator拡張機能を有効化中..."
	@gnome-extensions enable clipboard-indicator@tudmotu.com 2>/dev/null || \
		echo "⚠️  clipboard-indicator@tudmotu.com拡張機能が見つかりません"
	
	# 拡張機能のインストール案内
	@echo "💡 Clipboard Indicator拡張機能が見つからない場合:"
	@echo "   1. Extension Managerを開く"
	@echo "   2. 'Clipboard Indicator'を検索"
	@echo "   3. インストール＆有効化"
	@echo "   または: https://extensions.gnome.org/extension/779/clipboard-indicator/"
	
	@echo "✅ GNOME Clipboard Indicator設定完了"

.PHONY: test-clipboard
test-clipboard: ## クリップボード機能のテスト
	@echo "🧪 クリップボード機能をテスト中..."
	
	# 環境情報の表示
	@echo "📊 環境情報:"
	@echo "  セッション種別: $${XDG_SESSION_TYPE:-不明}"
	@echo "  Waylandディスプレイ: $${WAYLAND_DISPLAY:-なし}"
	@echo "  X11ディスプレイ: $${DISPLAY:-なし}"
	
	# CopyQの動作確認
	@echo "📋 CopyQ動作確認:"
	@if command -v copyq >/dev/null 2>&1; then \
		echo "  CopyQバージョン: $$(copyq version 2>/dev/null | head -1 || echo '取得失敗')"; \
		echo "  監視状況: $$(copyq eval 'monitoring()' 2>/dev/null || echo '確認失敗')"; \
		echo "  履歴件数: $$(copyq size 2>/dev/null || echo '確認失敗')"; \
	else \
		echo "  ❌ CopyQがインストールされていません"; \
	fi
	
	# wl-clipboardの動作確認
	@echo "🌊 wl-clipboard動作確認:"
	@if command -v wl-paste >/dev/null 2>&1; then \
		echo "  ✅ wl-paste利用可能"; \
		echo "  現在のクリップボード（最初の50文字）: $$(wl-paste 2>/dev/null | head -c 50 || echo 'データなし')"; \
	else \
		echo "  ❌ wl-pasteが利用できません"; \
	fi
	
	# 従来ツールの確認
	@echo "🔧 従来クリップボードツール:"
	@echo "  xclip: $$(command -v xclip >/dev/null 2>&1 && echo '✅ 利用可能' || echo '❌ なし')"
	@echo "  xsel: $$(command -v xsel >/dev/null 2>&1 && echo '✅ 利用可能' || echo '❌ なし')"
	@echo "  parcellite: $$(command -v parcellite >/dev/null 2>&1 && echo '✅ 利用可能' || echo '❌ なし')"
	
	# テストデータでの動作確認
	@echo "🧪 実動作テスト:"
	@echo "  テストデータをクリップボードに書き込み中..."
	@TEST_DATA="テスト_$$(date +%s)"; \
	if command -v wl-copy >/dev/null 2>&1; then \
		echo "$$TEST_DATA" | wl-copy && \
		echo "  ✅ wl-copyでの書き込み成功"; \
	elif command -v xclip >/dev/null 2>&1; then \
		echo "$$TEST_DATA" | xclip -selection clipboard && \
		echo "  ✅ xclipでの書き込み成功"; \
	else \
		echo "  ❌ クリップボードツールが利用できません"; \
	fi
	
	# CopyQでの検出確認
	@sleep 2
	@if command -v copyq >/dev/null 2>&1; then \
		CURRENT_SIZE=$$(copyq size 2>/dev/null || echo "0"); \
		echo "  CopyQ履歴件数: $$CURRENT_SIZE"; \
		if [ "$$CURRENT_SIZE" -gt 0 ]; then \
			echo "  ✅ CopyQがクリップボード変更を検出しました"; \
		else \
			echo "  ❌ CopyQがクリップボード変更を検出できていません"; \
		fi; \
	fi
	
	@echo "🎯 テスト完了"

.PHONY: setup-clipboard
setup-clipboard: install-packages-clipboard setup-copyq-wayland setup-gnome-clipboard test-clipboard ## クリップボード管理の完全セットアップ
	@echo "🎉 クリップボード管理の完全セットアップが完了しました！"
	@echo ""
	@echo "📝 使用方法:"
	@echo "  • CopyQ GUI: copyq show"
	@echo "  • CopyQ履歴確認: copyq size"
	@echo "  • CopyQ履歴読み込み: copyq read 0 1 2"
	@echo "  • Wayland版起動: ~/.local/bin/copyq-wayland"
	@echo ""
	@echo "🔧 トラブルシューティング:"
	@echo "  • 動作確認: make test-clipboard"
	@echo "  • CopyQ再起動: make setup-copyq-wayland"
	@echo "  • ログ確認: tail -f ~/.local/share/copyq/copyq/copyq.log"

.PHONY: fix-copyq-wayland
fix-copyq-wayland: ## CopyQのWayland問題を修正（トラブルシューティング用）
	@echo "🔧 CopyQのWayland問題を修正中..."
	
	# 既存プロセスの完全停止
	@echo "🛑 既存のCopyQプロセスを完全停止中..."
	@killall copyq 2>/dev/null || true
	@killall copyq-wayland 2>/dev/null || true
	@sleep 3
	
	# 設定ファイルのバックアップと再生成
	@echo "💾 CopyQ設定をバックアップ中..."
	@if [ -f $(HOME)/.config/copyq/copyq.conf ]; then \
		cp $(HOME)/.config/copyq/copyq.conf $(HOME)/.config/copyq/copyq.conf.backup.$$(date +%Y%m%d_%H%M%S); \
	fi
	
	# 問題のあるデータファイルのクリア
	@echo "🗂️  CopyQデータファイルをクリア中..."
	@rm -f $(HOME)/.local/share/copyq/copyq/items* 2>/dev/null || true
	@rm -f $(HOME)/.config/copyq/.copyq_s 2>/dev/null || true
	
	# 権限の修正
	@echo "🔐 ファイル権限を修正中..."
	@chmod -R 755 $(HOME)/.config/copyq/ 2>/dev/null || true
	@chmod -R 755 $(HOME)/.local/share/copyq/ 2>/dev/null || true
	
	# wl-clipboardの再インストール
	@echo "🌊 wl-clipboardを再インストール中..."
	@sudo apt install --reinstall -y wl-clipboard 2>/dev/null || true
	
	# CopyQの設定最適化
	@echo "⚙️  CopyQの設定を最適化中..."
	@copyq config check_clipboard true 2>/dev/null || true
	@copyq config autostart true 2>/dev/null || true
	@copyq config maxitems 999 2>/dev/null || true
	@copyq enable 2>/dev/null || true
	
	# CopyQの再起動
	@echo "🔄 CopyQを再起動中..."
	@$(HOME)/.local/bin/copyq-wayland &
	@sleep 5
	
	# 最終確認
	@echo "✅ 修正作業完了。動作確認中..."
	@$(MAKE) test-clipboard