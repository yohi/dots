# 🚀 Ubuntu開発環境セットアップ dotfiles

> **包括的なUbuntu開発環境をワンクリックで構築**

Ubuntu開発環境のセットアップ用dotfilesリポジトリです。日本語環境完全対応、モダンな開発ツール、GUI設定まで含む包括的なセットアップスクリプト群を提供します。

## ✨ 特徴

- 📱 **ワンライナーインストール**: `curl | bash`で完全自動セットアップ
- 🌏 **日本語環境完全対応**: フォント・入力メソッド・ロケール設定
- 🛠️ **モダン開発環境**: Neovim, Zsh, Docker, 最新言語環境
- 🎨 **GUI環境最適化**: GNOME Extensions, テーマ, ショートカット
- 🔧 **カスタマイズ可能**: モジュラー設計で必要な部分のみ選択可能

---

## 🚀 クイックスタート

### ワンライナーインストール

```bash
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash
```

### オプション指定

```bash
# 特定のブランチを指定
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash -s -- --branch develop

# インストール先ディレクトリを指定
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash -s -- --dir ~/my-dots

# ヘルプを表示
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash -s -- --help
```

---

## 📋 手動インストール

```bash
# 1. リポジトリをクローン
git clone https://github.com/yohi/dots.git ~/dots
cd ~/dots

# 2. 利用可能なコマンドを確認
make help

# 3. 推奨セットアップ手順
make system-setup      # システムレベルの基本設定（メモリ最適化含む）
make install-homebrew  # Homebrewをインストール
make setup-all         # すべての設定をセットアップ
```

---

## 🛠️ 主な機能

### 🔧 システム環境
- **日本語環境**: 完全な日本語サポート（フォント・入力・ロケール）
- **基本開発ツール**: build-essential, git, curl, wget等
- **CapsLock→Ctrl変換**: 開発者向けキーボード設定

### 📦 パッケージ管理
- **Homebrew**: Linux用パッケージマネージャー
- **APT**: システムパッケージ管理
- **Flatpak**: アプリケーション配布

### 🏗️ 開発環境
- **エディタ**: Neovim（AI統合設定）, VS Code, Cursor
- **シェル**: Zsh + Powerlevel10k + 便利プラグイン
- **ターミナル**: Wezterm, Tilix設定
- **言語環境**: Python, Node.js, Go, Rust, PHP, Ruby
- **コンテナ**: Docker + Docker Compose（Rootless設定）

### 🎨 GUI環境
- **GNOME Extensions**: 生産性向上拡張機能
- **テーマ・外観**: モダンなデスクトップ環境
- **ショートカット**: 効率的なキーボード操作

---

## 📦 インストールされるアプリケーション

<details>
<summary>🏗️ システムレベル（APT）</summary>

- **基本ツール**: build-essential, curl, file, wget, software-properties-common
- **日本語環境**: language-pack-ja, ubuntu-defaults-ja, fonts-noto-cjk, ibus-mozc
- **システムユーティリティ**: xdg-user-dirs-gtk, flatpak, gdebi, chrome-gnome-shell, xclip, xsel
- **フォント管理**: 自動ダウンロード・インストール (Nerd Fonts, Google Fonts, 日本語フォント)

</details>

<details>
<summary>🍺 Homebrew パッケージ</summary>

#### 開発ツール・言語
- **バージョン管理**: git-lfs, asdf, direnv, nodenv, node-build
- **プログラミング言語**: go, rust, lua, php, python, node, ruby, perl
- **Python関連**: flake8, mypy, pipenv, uv, pygobject3
- **コンパイラ・ビルドツール**: gcc, cmake, clang-format, tree-sitter

#### コマンドラインツール
- **ファイル操作**: fd, ripgrep, tree, pv, peco, fzf, p7zip
- **監視・管理**: ctop, lazydocker, lazygit, watchman
- **ネットワーク**: awscli, nghttp2, newrelic-cli
- **その他**: jq, xclip, srt, neo-cowsay, utern

#### データベース・開発サーバー
- **データベース**: mysql, postgresql@14
- **コンテナ**: docker, docker-compose
- **テスト**: jmeter
- **インフラ**: flux, dagger, mmctl

#### エディタ・ターミナル
- **エディタ**: neovim
- **ターミナル**: terminator, wezterm, zsh, zsh-autosuggestions, powerlevel10k
- **セキュリティ**: bitwarden-cli

</details>

<details>
<summary>💻 GUI アプリケーション</summary>

#### ブラウザ
- Google Chrome Stable/Beta, Chromium Browser

#### 開発環境・IDE
- Visual Studio Code, Cursor IDE

#### データベース・開発ツール
- DBeaver, MySQL Workbench, TablePlus, pgAdmin4, Insomnia, Postman

#### システム管理・ユーティリティ
- GNOME Tweaks, Extension Manager, Synaptic, Conky, Mainline, Meld, CopyQ

#### 生産性・コミュニケーション
- WPS Office, Mattermost, Slack, Discord

</details>

<details>
<summary>🔧 Visual Studio Code 拡張機能</summary>

- **Python開発**: Python, Pylance, Debugpy, Django関連
- **Docker**: Docker拡張機能セット
- **AI・補完**: GitHub Copilot, Copilot Chat
- **Git**: GitLens
- **Jupyter**: Jupyter関連パッケージ
- **コード品質**: Flake8, MyPy, Black
- **言語パック**: 日本語言語パック

</details>

---

## 🔐 機密情報の設定

### 環境変数の設定

CursorのMCP設定で機密情報を安全に管理するために、環境変数を使用します。

#### 1. 環境変数ファイルの作成

```bash
# .envファイルを作成（このファイルは.gitignoreに追加済み）
cat > .env << 'EOF'
# Bitbucket認証情報
BITBUCKET_USERNAME=your_username_here
BITBUCKET_APP_PASSWORD=your_app_password_here
EOF
```

#### 2. 環境変数の読み込み

```bash
# 現在のシェルセッションで読み込む
source .env

# または、~/.zshrcや~/.bashrcに追加して永続化
echo "source ~/dots/.env" >> ~/.zshrc
```

#### 3. 機密情報の確認

以下のファイルには機密情報が含まれていないことを確認してください：
- `cursor/mcp.json` - 環境変数を参照するように設定済み
- `.env` - .gitignoreに追加済み

**注意**: `.env`ファイルは絶対に公開リポジトリにコミットしないでください。

---

## 🔧 詳細設定

### 📁 設定ファイル配置

```
~/dots/
├── vim/           # Vim/Neovim設定
├── zsh/           # Zsh設定（.zshrc等）
├── wezterm/       # Wezterm設定
├── vscode/        # VS Code設定・拡張機能
├── cursor/        # Cursor IDE設定
├── gnome-*        # GNOME関連設定
├── Brewfile       # Homebrewパッケージリスト
└── Makefile       # セットアップスクリプト
```

### 📧 Git設定

Git設定時にメールアドレスが必要です：

```bash
# 環境変数で指定
EMAIL=your@email.com make setup-git

# または実行時に入力プロンプトで設定
make setup-git
```

### 🎯 部分的セットアップ

必要な部分のみセットアップする場合：

```bash
make setup-vim         # Vim/Neovim設定のみ
make setup-zsh         # Zsh設定のみ
make setup-docker      # Docker設定のみ
make install-apps      # アプリケーションのみ
```

---

## 💡 使用例

```bash
# 全体セットアップ（メール指定）
EMAIL=user@example.com make setup-all

# システム設定のみ
make system-setup

# 開発環境のみ
make setup-development

# GUI設定のみ
make setup-gnome-extensions
make setup-gnome-tweaks

# フォント管理
make fonts-setup       # 全フォントインストール
make fonts-install     # 個別インストール
make fonts-list        # インストール済み確認
make fonts-update      # 最新版への更新
```

---

## 🔤 フォント管理機能

**⚡ 自動フォント管理システム**
- リポジトリにフォントファイルを保存せず、必要時に自動ダウンロード
- ライセンスリスクを回避し、リポジトリサイズを最適化

### 利用可能なフォント

| カテゴリ | フォント名 | 用途 |
|---------|-----------|------|
| **Nerd Fonts** | JetBrainsMono, FiraCode, Hack, DejaVuSansMono | 開発・ターミナル |
| **Google Fonts** | Roboto, Open Sans, Source Code Pro, IBM Plex Mono | ウェブ・文書 |
| **日本語フォント** | Noto CJK, IBM Plex Sans JP | 日本語表示 |

### フォント管理コマンド

```bash
# 基本操作
make fonts-setup      # 全フォント環境セットアップ
make fonts-install    # 全種類フォントインストール
make fonts-list       # インストール済みフォント一覧
make fonts-clean      # 一時ファイルクリーンアップ

# 種類別インストール
make fonts-install-nerd      # Nerd Fonts のみ
make fonts-install-google    # Google Fonts のみ
make fonts-install-japanese  # 日本語フォントのみ

# メンテナンス
make fonts-update     # 最新版に更新（既存削除→再インストール）
make fonts-refresh    # フォントキャッシュ更新
make fonts-configure  # 推奨フォント設定適用

# デバッグ・管理
make fonts-debug      # フォント環境デバッグ情報
make fonts-backup     # フォント設定バックアップ
```

---

## 🧠 メモリ最適化・パフォーマンス

**⚡ 統合メモリ最適化システム**
- リアルタイムメモリ監視
- 安全なスワップクリア機能  
- システムキャッシュ最適化
- Chrome/ブラウザ最適化支援

### 基本的な使用方法

```bash
# 現在のメモリ状況を確認
make memory-status

# 包括的なメモリ最適化（推奨）
make memory-optimize

# スワップを安全にクリア
make memory-clear-swap
```

### メモリ最適化コマンド

```bash
# 状況確認
make memory-status              # 現在のメモリ使用状況を表示
make memory-help                # 詳細ヘルプを表示

# 基本最適化
make memory-optimize            # 包括的なメモリ最適化（推奨）
make memory-clear-swap          # スワップを安全にクリア
make memory-clear-cache         # システムキャッシュをクリア
make memory-optimize-swappiness # スワップ積極度を最適化

# アプリケーション最適化
make memory-optimize-chrome     # Chrome関連最適化情報を表示

# 監視システム
make memory-setup-monitoring    # メモリ監視システムをセットアップ
make memory-start-monitoring    # メモリ監視サービスを開始
make memory-stop-monitoring     # メモリ監視サービスを停止

# 緊急時
make memory-emergency-cleanup   # 緊急メモリクリーンアップ
```

### 推奨メンテナンスフロー

```bash
# 1. 定期的な状況確認（週次推奨）
make memory-status

# 2. 包括的最適化（週次推奨）
make memory-optimize

# 3. 必要に応じてスワップクリア
make memory-clear-swap

# 4. 監視システム設定（初回のみ）
make memory-setup-monitoring
make memory-start-monitoring
```

### 特徴

- **安全性**: スワップクリア前に利用可能メモリを自動チェック
- **包括性**: システムキャッシュ、スワップ、アプリケーション最適化を統合
- **監視**: バックグラウンドでのメモリ使用量監視とアラート
- **Chrome最適化**: メモリを大量消費するChromeプロセスの最適化支援

詳細は [`docs/MEMORY_OPTIMIZATION.md`](docs/MEMORY_OPTIMIZATION.md) を参照してください。

---

## 🐛 トラブルシューティング

### よくある問題

1. **パッケージインストールエラー**
   ```bash
   make clean-repos  # リポジトリクリーンアップ
   sudo apt update   # パッケージリスト更新
   ```

2. **フォントが表示されない**
   ```bash
   make fonts-refresh    # フォントキャッシュ更新
   make fonts-list       # インストール済みフォント確認
   make fonts-debug      # フォント環境のデバッグ情報
   ```

3. **GNOME設定が反映されない**
   ```bash
   make backup-gnome-tweaks  # 現在の設定をバックアップ
   make setup-gnome-tweaks   # 設定を再適用
   ```

### ログの確認

```bash
# システムログ
journalctl -f

# インストールログ
tail -f /var/log/apt/history.log
```

---

## 🤝 貢献

プルリクエストやIssueを歓迎します。改善点があれば気軽にお知らせください。

### 開発環境

```bash
git clone https://github.com/yohi/dots.git
cd dots
make help  # 利用可能なコマンドを確認
```

---

## 📄 ライセンス

MIT License

---

## 🌟 対応環境

- **OS**: Ubuntu 20.04+（24.04, 25.04対応）
- **デスクトップ**: GNOME
- **アーキテクチャ**: x86_64, ARM64

---

## 📱 アプリケーション設定

### Cursor設定

- **設定ファイル**: `cursor/settings.json`
- **キーバインド**: `cursor/keybindings.json`
- **場所**: `~/.config/Cursor/User/`

```bash
make setup-cursor
```

### Cursor MCP Tools設定

- **設定ファイル**: `cursor/mcp.json`
- **場所**: `~/.cursor/mcp.json`

```bash
make setup-mcp-tools
```

**設定済みMCPサーバー**:
- **Bitbucket MCP Server**: BitbucketのPR管理・コメント機能
- **Playwright MCP Server**: ウェブブラウザの自動化
- **AWS Documentation MCP Server**: AWS文書の検索・参照
- **Terraform MCP Server**: Terraform設定の管理
- **ECS MCP Server**: AWS ECSの管理

**使用方法**:
1. Cursorを起動
2. Composerでチャット開始
3. 「Available Tools」にMCPツールが表示される
4. 必要に応じてツールを名前で指定して使用

### VSCode設定

- **設定ファイル**: `vscode/settings.json`
- **キーバインド**: `vscode/keybindings.json`
- **拡張機能**: `vscode/extensions.list`
- **場所**: `~/.config/Code/User/`

```bash
make setup-vscode
```

**🎉 快適な開発環境をお楽しみください！**
