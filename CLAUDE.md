# 🤖 Claude Code - Ubuntu環境開発ガイド

このガイドは、このdotfilesリポジトリで構築されたUbuntu開発環境において、**Claude Code**（Claude with Code capabilities）を効率的に活用するためのガイドラインです。

---

## 📋 環境概要

このリポジトリで構築される開発環境には以下が含まれています：

### 🏗️ 主要コンポーネント
- **Neovim**: AI統合設定、LSP、プラグイン管理（Lazy.nvim）
- **VS Code + Cursor**: IDE環境、拡張機能、設定
- **Zsh + Powerlevel10k**: モダンシェル環境
- **Docker**: コンテナ開発環境（Rootless設定）
- **多言語サポート**: Python, Node.js, Go, Rust, PHP, Ruby等
- **GNOME環境**: Extensions, Tweaks, ショートカット設定

### 📁 ディレクトリ構造
```
~/dots/
├── vim/           # Neovim設定・プラグイン
├── vscode/        # VS Code設定・拡張機能
├── cursor/        # Cursor IDE設定
├── zsh/           # Zsh設定
├── wezterm/       # Wezterm設定
├── gnome-*/       # GNOME関連設定
├── Brewfile       # Homebrewパッケージ
└── Makefile       # セットアップスクリプト
```

#### Current Specifications
- **context-store-mcp**: AIエージェント向けMCPベース長期記憶システム - セッションを越えて情報を永続保存し、文脈に応じた検索を可能にする
- **aws-ssm-executor-plugin**: Rundeck Node Executor Plugin for executing commands on EC2 nodes via AWS Systems Manager (SSM)
- **rundeck-dev-environment**: Docker Compose based Rundeck development environment for plugin testing and validation

## 🚀 クイック開始

### 基本的な質問パターン

1. **設定の理解**
   ```
   "このNeovim設定でLSPはどのように構成されていますか？"
   "VS Code拡張機能の一覧を教えてください"
   ```

2. **トラブルシューティング**
   ```
   "フォントが正しく表示されない問題を解決してください"
   "Docker設定でエラーが発生しています"
   ```

3. **カスタマイズ**
   ```
   "Python開発に特化したNeovim設定を追加してください"
   "新しいGNOME拡張機能を設定に追加したい"
   ```

---

## 🔧 Neovim設定について

### プラグイン管理
- **プラグインマネージャー**: Lazy.nvim を使用
- **設定ファイル**: `vim/` ディレクトリ内に構造化

### LSP統合
- **言語サーバー**: 自動インストール・設定
- **補完**: nvim-cmp + AI統合
- **診断**: 各言語に適した linter/formatter

### AI統合機能
このNeovim設定には以下のAI機能が含まれています：
- コード補完
- ドキュメント生成
- リファクタリング支援

### よくあるタスク

#### プラグイン管理
```bash
# Neovim内で実行
:Lazy                    # プラグインマネージャーを開く
:Lazy install           # 新しいプラグインをインストール
:Lazy update            # プラグインを更新
:Lazy clean             # 未使用プラグインを削除
```

#### LSP管理
```bash
:LspInfo                # LSP情報を表示
:Mason                  # LSPサーバー管理
:MasonInstall <server>  # LSPサーバーをインストール
```

---

## 💻 VS Code & Cursor設定

### 拡張機能カテゴリ
- **Python開発**: Pylance, Debugpy, Django関連
- **Web開発**: TypeScript, React, Vue関連
- **コンテナ**: Docker, Remote Development
- **AI/補完**: GitHub Copilot関連
- **Git**: GitLens, Git Graph
- **ユーティリティ**: Bracket Pair Colorizer, Better Comments等

### 設定ファイル
- `vscode/settings.json`: エディタ設定
- `vscode/keybindings.json`: キーバインド
- `vscode/extensions.list`: インストール対象拡張機能

---

## 🐚 シェル環境（Zsh）

### 機能
- **Powerlevel10k**: 高速でカスタマイズ可能なプロンプト
- **自動補完**: zsh-autosuggestions
- **履歴管理**: 拡張された履歴機能
- **エイリアス**: 開発効率化のためのショートカット

### 設定ファイル
- `zsh/.zshrc`: メイン設定
- `zsh/.p10k.zsh`: Powerlevel10k設定

---

## 🐳 Docker環境

### 特徴
- **Rootless Docker**: セキュアな設定
- **Docker Compose**: マルチコンテナ管理
- **開発環境**: 各言語用コンテナ設定

---

## 🎯 Claude Code活用のベストプラクティス

### 1. 設定ファイルの編集

**良い例**:
```
"vim/init.lua にPython用のLSP設定を追加して、
pylsp の設定でflake8とmypyを有効にしてください"
```

**避けるべき例**:
```
"Vimの設定を変更して"
```

### 2. 問題の報告

**良い例**:
```
"Homebrewでインストールしたパッケージが
PATH に追加されていません。zsh設定を確認して修正してください。
現在のPATH: [実際のPATH]"
```

**避けるべき例**:
```
"パッケージが動かない"
```

### 3. 新機能の追加

**良い例**:
```
"Django開発用の設定を追加したいです：
- VS Code用Django拡張機能
- Neovim用django-vim設定
- 開発用Docker Compose設定
Makefileにもセットアップターゲットを追加してください"
```

### 4. デバッグ支援

**良い例**:
```
"make setup-vim が以下のエラーで失敗します：
[エラーメッセージをペースト]
vim/配下のファイルをチェックして問題を特定してください"
```

---

## 📝 開発フロー

### 1. 新しいプロジェクト開始
```bash
cd ~/dots
make help                    # 利用できるコマンドを確認
make setup-development       # 開発環境の設定
```

### 2. 特定の言語環境セットアップ
```bash
# Python環境
make setup-python

# Node.js環境
make setup-nodejs

# Docker環境
make setup-docker
```

### 3. IDE設定の適用
```bash
make setup-vscode           # VS Code設定
make setup-vim              # Neovim設定
make setup-cursor           # Cursor設定
```

---

## 🛠️ トラブルシューティング

### よくある問題

1. **フォントの問題**
   - IBM Plex Sans, Cica Nerd Fontsのインストール確認
   - フォントキャッシュの更新: `fc-cache -f`

2. **LSPエラー**
   - Mason経由でのLSPサーバー再インストール
   - Node.js/npm のバージョン確認

3. **Docker権限エラー**
   - Rootless Docker設定の確認
   - ユーザーのdockerグループ追加

### ログ確認
```bash
# システムログ
journalctl -f

# アプリケーションログ
tail -f ~/.local/share/nvim/lsp.log
```

---

## 📚 参考情報

### 設定ファイルの場所
- **Neovim**: `~/.config/nvim/` → `~/dots/vim/`
- **VS Code**: `~/.config/Code/User/` → `~/dots/vscode/`
- **Zsh**: `~/.zshrc` → `~/dots/zsh/.zshrc`
- **Git**: `~/.gitconfig` → Makefile内で設定

### 重要なMakeターゲット
```bash
make help                   # ヘルプ表示
make system-setup          # システム基本設定
make install-homebrew      # Homebrew インストール
make setup-all             # 全体セットアップ
make clean                 # 設定のクリーンアップ
```

---

## 🔄 更新・メンテナンス

### 定期的な更新
```bash
cd ~/dots
git pull                   # 最新版を取得
make setup-all             # 設定を再適用
```

### 設定のバックアップ
```bash
make backup-gnome-tweaks   # GNOME設定のバックアップ
make export-gnome-tweaks   # GNOME設定のエクスポート
```

---

**このガイドを参考に、Claude Codeを活用して効率的な開発環境を構築・維持してください！** 🚀
