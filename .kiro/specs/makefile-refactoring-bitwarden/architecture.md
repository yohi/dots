# Makefile アーキテクチャ設計書

## 1. デフォルトエントリポイント

### 1.1 エントリポイント定義

| 項目 | 値 |
|------|-----|
| **ファイル** | `Makefile` (リポジトリルート) |
| **デフォルトターゲット** | `help` (`all: help` として定義) |
| **実行方法** | `make` または `make help` |

### 1.2 ヘルプターゲットの動作

```bash
# 以下はすべて同等の動作
make          # デフォルトターゲット = help
make help     # 明示的なヘルプ呼び出し
make h        # 短縮エイリアス
```

### 1.3 ファイル構造

```
Makefile                    # エントリポイント (include のみ)
mk/
  variables.mk             # 共通変数定義
  help.mk                  # ヘルプメッセージ (公開ターゲット一覧)
  help-short.mk            # 短縮ヘルプ
  shortcuts.mk             # エイリアス定義
  system.mk                # システム設定ターゲット
  install.mk               # パッケージインストールターゲット
  setup.mk                 # 設定ファイルセットアップターゲット
  ...                      # その他ドメイン別ファイル
```

---

## 2. 公開ターゲット一覧

### 2.1 システム設定

| ターゲット | 説明 |
|-----------|------|
| `setup-system` | システムレベルの基本設定 |

### 2.2 パッケージインストール

| ターゲット | 説明 |
|-----------|------|
| `install-packages-homebrew` | Homebrewをインストール |
| `install-packages-apps` | Brewfileを使用してアプリケーションをインストール |
| `install-packages-deb` | DEBパッケージをインストール（IDE・ブラウザ含む） |
| `install-packages-flatpak` | Flatpakパッケージをインストール |
| `install-packages-fuse` | AppImage実行用のFUSEパッケージをインストール |
| `install-packages-wezterm` | WezTerm（AppImage版）をインストール |
| `install-packages-cursor` | Cursor IDEをインストール |
| `install-packages-claude-code` | Claude Code（AI コードエディタ）をインストール |
| `install-packages-claudia` | Claudia（Claude Code GUI）をインストール |
| `install-packages-superclaude` | SuperClaude（Claude Code フレームワーク）をインストール |
| `install-packages-claude-ecosystem` | Claude Code エコシステム一括インストール |
| `install-packages-cica-fonts` | Cica Nerd Fontsをインストール |
| `install-packages-mysql-workbench` | MySQL Workbenchをインストール |
| `install-packages-chrome-beta` | Google Chrome Betaをインストール |
| `install-packages-playwright` | Playwright E2Eテストフレームワークをインストール |
| `install-packages-clipboard` | クリップボード管理ツールをインストール |
| `install-packages-gemini-cli` | Gemini CLIをインストール |
| `install-packages-ccusage` | ccusage (bunx) をインストール |

### 2.3 設定ファイルセットアップ

| ターゲット | 説明 |
|-----------|------|
| `setup-config-vim` | VIMの設定をセットアップ |
| `setup-config-zsh` | ZSHの設定をセットアップ |
| `setup-config-wezterm` | WEZTERMの設定をセットアップ |
| `setup-config-vscode` | VS Codeの設定をセットアップ |
| `setup-config-vscode-copilot` | VS Code用のSuperCopilotフレームワークをセットアップ |
| `setup-config-cursor` | Cursorの設定をセットアップ |
| `setup-config-mcp-tools` | Cursor MCP Toolsの設定をセットアップ |
| `setup-config-git` | Git設定をセットアップ |
| `setup-config-docker` | Dockerの設定をセットアップ |
| `setup-config-development` | 開発環境の設定をセットアップ |
| `setup-config-shortcuts` | キーボードショートカットの設定をセットアップ |
| `setup-config-ime` | 日本語入力（IME）環境をセットアップ |
| `setup-config-claude` | Claude設定をセットアップ |
| `setup-config-lazygit` | Lazygitの設定をセットアップ |
| `setup-config-gnome-extensions` | Gnome Extensions の設定をセットアップ |
| `setup-config-gnome-tweaks` | Gnome Tweaks の設定をセットアップ |
| `setup-config-mozc` | Mozc入力メソッドの設定をセットアップ |
| `setup-config-mozc-ut-dictionaries` | Mozc UT辞書の設定を開始 |
| `setup-config-all` | すべての設定をセットアップ |

### 2.4 管理・バックアップ

| ターゲット | 説明 |
|-----------|------|
| `backup-config-gnome-tweaks` | Gnome Tweaks の設定をバックアップ |
| `export-config-gnome-tweaks` | Gnome Tweaks の設定をエクスポート |
| `fix-extensions-schema` | Gnome Extensions スキーマエラーを修復 |
| `update-cursor` | Cursor IDEを最新版にアップデート |
| `stop-cursor` | 実行中のCursor IDEを停止 |
| `check-cursor-version` | Cursor IDEのバージョン情報を確認 |
| `clean` | シンボリックリンクを削除 |
| `clean-repos` | リポジトリとGPGキーをクリーンアップ |
| `help` | ヘルプメッセージを表示 |

### 2.5 プリセット実行

| ターゲット | 説明 |
|-----------|------|
| `quick` | クイックセットアップ - 基本的な開発環境を素早くセットアップ |
| `dev-setup` | 開発者セットアップ - IDEとAI開発ツールを含む開発者向け環境 |
| `full` | フルセットアップ - 全ての機能を含む完全なセットアップ |
| `minimal` | ミニマルセットアップ - 最小限の構成でセットアップ |

### 2.6 段階的セットアップ

| ターゲット | 説明 |
|-----------|------|
| `stage1` | ステージ1: システム基盤セットアップ（Homebrew + 基本パッケージ） |
| `stage2` | ステージ2: 必須アプリケーションのインストール |
| `stage3` | ステージ3: 設定ファイル・dotfilesのセットアップ |
| `stage4` | ステージ4: システム設定・GNOME設定 |
| `stage5` | ステージ5: オプション機能（AI開発ツール・フォント等） |
| `stage-status` | 各ステージの完了状況を確認 |
| `stage-guide` | 段階的セットアップの完全ガイド |
| `stage-all` | 全ステージを順次実行（各ステージ後に確認） |
| `next-stage` | 次に実行すべきステージを提案 |

### 2.7 フォント管理

| ターゲット | 説明 |
|-----------|------|
| `fonts-setup` | 全フォント環境のセットアップ |
| `fonts-install` | 全種類のフォントをインストール |
| `fonts-list` | インストール済みフォント一覧 |
| `fonts-clean` | 一時ファイルのクリーンアップ |
| `fonts-update` | フォントの最新版への更新 |

### 2.8 メモリ管理

| ターゲット | 説明 |
|-----------|------|
| `memory-check` | 現在のメモリ使用状況を表示 |
| `memory-cleanup` | システムキャッシュをクリア |
| `memory-monitor` | リアルタイムメモリ監視 |
| `memory-optimize` | システムメモリ最適化設定を適用 |
| `memory-troubleshoot` | 問題のあるプロセスを特定 |
| `memory-fix` | 緊急メモリ修復 |
| `memory-info` | システム情報と推奨事項 |
| `help-memory` | メモリ管理コマンドの詳細ヘルプ |

### 2.9 AI開発ツール

| ターゲット | 説明 |
|-----------|------|
| `codex` | Codex CLIのインストールとセットアップ |
| `codex-install` | Codex CLIをインストール |
| `codex-update` | Codex CLIをアップデート |
| `codex-setup` | Codex CLIのセットアップを実行 |
| `superclaude-install` | Claude Code向けにインストール |
| `superclaude-check` | インストール状態を確認 |
| `superclaude-update` | 最新版に更新 |
| `superclaude-uninstall` | アンインストール |
| `superclaude-info` | フレームワーク情報を表示 |
| `cc-sdd-install` | インストール（日本語、Claude Code） |
| `cc-sdd-install-alpha` | アルファ版インストール（最新機能） |
| `cc-sdd-install-agent` | SubAgentsインストール |
| `cc-sdd-install-en` | 英語版インストール |
| `cc-sdd-check` | インストール状態を確認 |
| `cc-sdd-update` | 最新版に更新 |
| `cc-sdd-info` | 詳細情報を表示 |

### 2.10 内部/プライベートターゲット（ヘルプ非表示）

内部ターゲットは先頭にアンダースコアを付与して識別する:

| パターン | 用途 |
|---------|------|
| `_check-*` | 内部検証用ターゲット |
| `_setup-*` | 内部セットアップ処理 |
| `_install-*` | 内部インストール処理 |

---

## 3. エイリアス移行マップ

### 3.1 短縮エイリアス（永続維持）

以下の短縮エイリアスは後方互換性のために無期限に維持する:

| エイリアス | ターゲット | 説明 |
|-----------|-----------|------|
| `i` | `install` | dotfilesインストール |
| `s` | `setup` | セットアップ実行 |
| `c` | `check-cursor-version` | Cursorバージョン確認 |
| `u` | `update-cursor` | Cursorアップデート |
| `m` | `menu` | インタラクティブメニュー |
| `h` | `help` | ヘルプ表示 |
| `s1` | `stage1` | ステージ1実行 |
| `s2` | `stage2` | ステージ2実行 |
| `s3` | `stage3` | ステージ3実行 |
| `s4` | `stage4` | ステージ4実行 |
| `s5` | `stage5` | ステージ5実行 |
| `ss` | `stage-status` | 進捗確認 |
| `sg` | `stage-guide` | セットアップガイド |

### 3.2 レガシーターゲット互換マップ

旧命名規則のターゲットに対するエイリアスを定義し、後方互換性を維持する:

| 旧ターゲット名 | 新ターゲット名 | 動作 |
|---------------|---------------|------|
| `install-homebrew` | `install-packages-homebrew` | エイリアスとして動作、警告なし |
| `install-apps` | `install-packages-apps` | エイリアスとして動作、警告なし |
| `install-deb` | `install-packages-deb` | エイリアスとして動作、警告なし |
| `install-flatpak` | `install-packages-flatpak` | エイリアスとして動作、警告なし |
| `install-fuse` | `install-packages-fuse` | エイリアスとして動作、警告なし |
| `install-wezterm` | `install-packages-wezterm` | エイリアスとして動作、警告なし |
| `install-cursor` | `install-packages-cursor` | エイリアスとして動作、警告なし |
| `install-claude-code` | `install-packages-claude-code` | エイリアスとして動作、警告なし |
| `install-cica-fonts` | `install-packages-cica-fonts` | エイリアスとして動作、警告なし |
| `install-mysql-workbench` | `install-packages-mysql-workbench` | エイリアスとして動作、警告なし |
| `install-chrome-beta` | `install-packages-chrome-beta` | エイリアスとして動作、警告なし |
| `install-playwright` | `install-packages-playwright` | エイリアスとして動作、警告なし |
| `install-clipboard` | `install-packages-clipboard` | エイリアスとして動作、警告なし |
| `install-gemini-cli` | `install-packages-gemini-cli` | エイリアスとして動作、警告なし |
| `setup-vim` | `setup-config-vim` | エイリアスとして動作、警告なし |
| `setup-zsh` | `setup-config-zsh` | エイリアスとして動作、警告なし |
| `setup-wezterm` | `setup-config-wezterm` | エイリアスとして動作、警告なし |
| `setup-vscode` | `setup-config-vscode` | エイリアスとして動作、警告なし |
| `setup-cursor` | `setup-config-cursor` | エイリアスとして動作、警告なし |
| `setup-git` | `setup-config-git` | エイリアスとして動作、警告なし |
| `setup-docker` | `setup-config-docker` | エイリアスとして動作、警告なし |
| `setup-ime` | `setup-config-ime` | エイリアスとして動作、警告なし |
| `setup-claude` | `setup-config-claude` | エイリアスとして動作、警告なし |
| `setup-all` | `setup-config-all` | エイリアスとして動作、警告なし |
| `gnome-settings` | `setup-gnome-settings` | エイリアスとして動作、警告なし |
| `gnome-extensions` | `setup-gnome-extensions` | エイリアスとして動作、警告なし |
| `gnome-tweaks` | `setup-gnome-tweaks` | エイリアスとして動作、警告なし |
| `setup-mozc` | `setup-config-mozc` | エイリアスとして動作、警告なし |
| `claudecode` | `superclaude-install` | エイリアスとして動作、警告なし |
| `cc-sdd` | `cc-sdd-install` | エイリアスとして動作、警告なし |

### 3.3 エイリアスポリシー

1. **後方互換性優先:** すべての既存エイリアスは無期限に維持する
2. **警告なし:** レガシーターゲット呼び出し時に廃止予定の警告は表示しない
3. **ドキュメント更新:** ヘルプメッセージでは新命名規則を優先表示し、旧名称は「後方互換性のために利用可能」と注記
4. **新規開発:** 新規ターゲットは必ずハイフン区切りの命名規則に従う

---

## 4. 命名規則

### 4.1 ターゲット命名パターン

```
{action}-{domain}-{target}
```

| 要素 | 説明 | 例 |
|-----|------|-----|
| `{action}` | 動詞（install, setup, update, check, clean, export, backup） | `install`, `setup` |
| `{domain}` | ドメイン/カテゴリ（packages, config, gnome） | `packages`, `config` |
| `{target}` | 対象（homebrew, vim, cursor） | `homebrew`, `vim` |

### 4.2 動詞プレフィックス一覧

| プレフィックス | 用途 |
|--------------|------|
| `install-` | パッケージ/ソフトウェアのインストール |
| `setup-` | 設定ファイルのセットアップ、環境構築 |
| `update-` | 既存ソフトウェアの更新 |
| `check-` | 状態確認、バージョン確認 |
| `clean-` | クリーンアップ、削除 |
| `export-` | 設定のエクスポート |
| `backup-` | バックアップ作成 |
| `fix-` | 問題修復 |
| `stop-` | プロセス停止 |

---

## 5. 承認履歴

| 日付 | 承認者 | 項目 |
|-----|-------|------|
| - | - | 初版作成 |

---

## 6. 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|-----|---------|
| 1.0 | 2026-01-05 | 初版作成 - エントリポイント、公開ターゲット一覧、エイリアス移行マップを定義 |
