# インタラクティブメニュー

# メインメニュー
menu:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│          🚀 Ubuntu開発環境セットアップメニュー           │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) 🔧 システム設定 (sys)                               │"
	@echo "│ 2) 📦 ソフトウェアインストール (pkg)                   │"
	@echo "│ 3) ⚙️  設定ファイル (conf)                             │"
	@echo "│ 4) 🔄 アップデート・管理 (mgmt)                        │"
	@echo "│ 5) 🎯 プリセット実行 (preset)                          │"
	@echo "│ 6) 📊 段階的セットアップ (stages)                       │"
	@echo "│ 7) 🧹 クリーンアップ (clean)                           │"
	@echo "│ 8) ❓ ヘルプ (help)                                    │"
	@echo "│ 0) 終了                                               │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@echo "💡 ヒント: 括弧内のコマンドでも直接実行可能です"
	@echo "   例: make sys, make pkg, make conf など"
	@echo ""
	@read -p "選択してください [0-8]: " choice; \
	case $$choice in \
		1) $(MAKE) sys ;; \
		2) $(MAKE) pkg ;; \
		3) $(MAKE) conf ;; \
		4) $(MAKE) mgmt ;; \
		5) $(MAKE) preset ;; \
		6) $(MAKE) stages ;; \
		7) $(MAKE) clean-menu ;; \
		8) $(MAKE) help ;; \
		0) echo "👋 お疲れさまでした！" ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) menu ;; \
	esac

# システム設定メニュー
sys:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│                🔧 システム設定メニュー                  │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) システムレベル基本設定                               │"
	@echo "│ 2) Gnome設定                                          │"
	@echo "│ 3) 日本語入力設定                                      │"
	@echo "│ 4) ショートカット設定                                  │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-4]: " choice; \
	case $$choice in \
		1) $(MAKE) setup-system ;; \
		2) $(MAKE) gnome-settings ;; \
		3) $(MAKE) setup-config-mozc ;; \
		4) $(MAKE) setup-config-shortcuts ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) sys ;; \
	esac

# パッケージインストールメニュー
pkg:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│             📦 ソフトウェアインストールメニュー          │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) 基本パッケージ (Homebrew + 基本ツール)               │"
	@echo "│ 2) 開発環境 (IDE・エディタ)                            │"
	@echo "│ 3) AI開発ツール (Claude・Cursor等)                     │"
	@echo "│ 4) フォント                                           │"
	@echo "│ 5) ブラウザ                                           │"
	@echo "│ 6) その他ツール                                       │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-6]: " choice; \
	case $$choice in \
		1) $(MAKE) pkg-basic ;; \
		2) $(MAKE) pkg-dev ;; \
		3) $(MAKE) pkg-ai ;; \
		4) $(MAKE) pkg-fonts ;; \
		5) $(MAKE) pkg-browser ;; \
		6) $(MAKE) pkg-others ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) pkg ;; \
	esac

# 設定ファイルメニュー
conf:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│               ⚙️  設定ファイルメニュー                  │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) シェル設定 (ZSH)                                    │"
	@echo "│ 2) エディタ設定 (Vim)                                  │"
	@echo "│ 3) ターミナル設定 (WezTerm)                            │"
	@echo "│ 4) IDE設定 (VSCode・Cursor)                           │"
	@echo "│ 5) Git設定                                            │"
	@echo "│ 6) 全設定一括適用                                      │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-6]: " choice; \
	case $$choice in \
		1) $(MAKE) setup-config-zsh ;; \
		2) $(MAKE) setup-config-vim ;; \
		3) $(MAKE) setup-config-wezterm ;; \
		4) $(MAKE) conf-ide ;; \
		5) $(MAKE) setup-config-git ;; \
		6) $(MAKE) setup-config-all ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) conf ;; \
	esac

# アップデート・管理メニュー
mgmt:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│              🔄 アップデート・管理メニュー               │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) Cursor IDEアップデート                              │"
	@echo "│ 2) Cursor IDEバージョン確認                            │"
	@echo "│ 3) Cursor IDE停止                                      │"
	@echo "│ 4) システム全体アップデート                            │"
	@echo "│ 5) 設定バックアップ                                   │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-5]: " choice; \
	case $$choice in \
		1) $(MAKE) update-cursor ;; \
		2) $(MAKE) check-cursor-version ;; \
		3) $(MAKE) stop-cursor ;; \
		4) echo "🔄 システム全体アップデート..."; sudo apt update && sudo apt upgrade ;; \
		5) $(MAKE) backup-config-gnome-tweaks ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) mgmt ;; \
	esac

# プリセット実行メニュー
preset:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│               🎯 プリセット実行メニュー                  │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) クイックセットアップ (基本環境)                      │"
	@echo "│ 2) 開発者セットアップ (開発環境重視)                    │"
	@echo "│ 3) フルセットアップ (全機能)                           │"
	@echo "│ 4) ミニマルセットアップ (最小構成)                      │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-4]: " choice; \
	case $$choice in \
		1) $(MAKE) quick ;; \
		2) $(MAKE) dev-setup ;; \
		3) $(MAKE) full ;; \
		4) $(MAKE) minimal ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) preset ;; \
	esac

# クリーンアップメニュー
clean-menu:
	@echo "┌─────────────────────────────────────────────────────────┐"
	@echo "│               🧹 クリーンアップメニュー                  │"
	@echo "├─────────────────────────────────────────────────────────┤"
	@echo "│ 1) 一時ファイル削除                                    │"
	@echo "│ 2) リポジトリクリーンアップ                            │"
	@echo "│ 3) システムキャッシュクリア                            │"
	@echo "│ 4) 全クリーンアップ                                   │"
	@echo "│ 0) メインメニューに戻る                                │"
	@echo "└─────────────────────────────────────────────────────────┘"
	@echo ""
	@read -p "選択してください [0-4]: " choice; \
	case $$choice in \
		1) $(MAKE) clean ;; \
		2) $(MAKE) clean-repos ;; \
		3) echo "🧹 システムキャッシュをクリア中..."; sudo apt autoclean && sudo apt autoremove ;; \
		4) $(MAKE) clean && $(MAKE) clean-repos ;; \
		0) $(MAKE) menu ;; \
		*) echo "❌ 無効な選択です"; $(MAKE) clean-menu ;; \
	esac

# 段階的セットアップメニュー
stages:
	@echo "🎯 段階的セットアップメニュー"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "📊 0) セットアップ進捗状況を確認     make stage-status (ss)"
	@echo "📖 1) セットアップガイドを表示       make stage-guide  (sg)"
	@echo "🔍 2) 次のステージを確認            make next-stage"
	@echo ""
	@echo "📦 3) ステージ1: システム基盤       make stage1 (s1)"
	@echo "💻 4) ステージ2: 必須アプリ         make stage2 (s2)"
	@echo "⚙️  5) ステージ3: 設定ファイル       make stage3 (s3)"
	@echo "🖥️  6) ステージ4: システム設定       make stage4 (s4)"
	@echo "🤖 7) ステージ5: オプション機能      make stage5 (s5)"
	@echo ""
	@echo "🚀 8) 全ステージ連続実行            make stage-all"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo -n "選択 (0-8, Enter=戻る): "
	@read choice; \
	case $$choice in \
		0) $(MAKE) stage-status ;; \
		1) $(MAKE) stage-guide ;; \
		2) $(MAKE) next-stage ;; \
		3) $(MAKE) stage1 ;; \
		4) $(MAKE) stage2 ;; \
		5) $(MAKE) stage3 ;; \
		6) $(MAKE) stage4 ;; \
		7) $(MAKE) stage5 ;; \
		8) $(MAKE) stage-all ;; \
		*) echo "メインメニューに戻ります" ;; \
	esac
