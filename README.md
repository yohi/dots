# dotfiles

Ubuntu開発環境のセットアップ用dotfilesリポジトリです。

## 🚀 クイックスタート（ワンライナーインストール）

以下のコマンドを実行するだけで、リポジトリのクローンからセットアップまでを自動実行できます：

```bash
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash
```

### その他のオプション

特定のブランチを指定してインストール：
```bash
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash -s -- --branch develop
```

インストール先ディレクトリを指定：
```bash
curl -fsSL https://raw.githubusercontent.com/yohi/dots/main/install.sh | bash -s -- --dir ~/my-dots
```

## 📋 手動インストール

1. リポジトリをクローン：
```bash
git clone https://github.com/yohi/dots.git ~/dots
cd ~/dots
```

2. 利用可能なコマンドを確認：
```bash
make help
```

3. 推奨セットアップ手順：
```bash
# システムレベルの基本設定
make system-setup

# Homebrewをインストール
make install-homebrew

# すべての設定をセットアップ
make setup-all
```

## 🛠️ 主な機能

- **システム設定**: 日本語環境、基本開発ツール、CapsLock→Ctrl変換
- **パッケージ管理**: Homebrew、APT、Flatpak対応
- **開発環境**: Vim/Neovim、Zsh、Git、Docker設定
- **アプリケーション**: 開発用ツール、GUI アプリケーション

## 📦 インストールされるアプリケーション

### 🏗️ システムレベル（APT）
- **基本ツール**: build-essential, curl, file, wget, software-properties-common
- **日本語環境**: language-pack-ja, ubuntu-defaults-ja
- **システムユーティリティ**: xdg-user-dirs-gtk, flatpak, gdebi, chrome-gnome-shell, xclip, xsel

### 🍺 Homebrew パッケージ（Brewfile）

#### 開発ツール・言語
- **バージョン管理**: git-lfs, asdf, direnv, nodenv, node-build
- **プログラミング言語**: 
  - go, rust, lua, luajit, luarocks
  - php, composer, python-tk@3.9, python-yq, cython
  - node, deno, yarn
  - ruby, perl
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

#### ユーティリティ・ライブラリ
- **フォント**: font-cica, font-noto-sans-cjk-jp
- **システムライブラリ**: ncurses, libedit, openssl@3, unzip, glib
- **GUI関連**: at-spi2-core, pkgconf, cairo, mesa, freeglut, gtk+, gtk+3, pango, librsvg, vte3
- **その他**: mercurial, netpbm, gobject-introspection, dlib

#### エディタ・ターミナル
- **エディタ**: neovim
- **ターミナル**: terminator, wezterm, zsh, zsh-autosuggestions, powerlevel10k
- **セキュリティ**: bitwarden-cli

### 💻 GUI アプリケーション（DEBパッケージ）

#### ブラウザ
- Google Chrome Stable
- Google Chrome Beta

#### 開発環境・IDE
- Visual Studio Code
- Cursor IDE (AppImage)

#### データベース・開発ツール
- DBeaver Community Edition
- MySQL Workbench
- TablePlus
- pgAdmin4 Desktop
- Insomnia (API Client)
- Postman (API Development Environment)

#### ターミナルエミュレータ
- Tilix
- Terminator

#### システム管理・ユーティリティ
- Synaptic Package Manager
- GNOME Tweaks
- GNOME Shell Extension Manager
- Conky
- Mainline (Kernel管理)
- Meld (差分比較)
- CopyQ (クリップボード管理)
- Blueman (Bluetooth管理)

#### リモート・ネットワーク
- Remmina (リモートデスクトップ)
  - RDPプラグイン
  - Secret プラグイン

#### 生産性・オフィス
- WPS Office
- Mattermost Desktop
- Slack Desktop
- Discord

#### 開発・デバッグ
- KCachegrind (プロファイリング)
- AWS Session Manager Plugin

### 🔧 Visual Studio Code 拡張機能
- **Python開発**: ms-python.python, ms-python.vscode-pylance, ms-python.debugpy
- **Django**: batisteo.vscode-django, bigonesystems.django, thebarkman.vscode-djaneiro
- **Docker**: docker.docker, ms-azuretools.vscode-docker, ms-vscode-remote.remote-containers
- **AI・補完**: github.copilot, github.copilot-chat
- **Git**: eamodio.gitlens
- **Jupyter**: ms-toolsai.jupyter (関連パッケージ含む)
- **コード品質**: ms-python.flake8, ms-python.mypy-type-checker
- **ユーティリティ**: kevinrose.vsc-python-indent, njpwerner.autodocstring, njqdev.vscode-python-typehint
- **言語パック**: ms-ceintl.vscode-language-pack-ja

### ⚙️ 設定・dotfiles
- **Vim/Neovim**: カスタム設定、プラグイン管理
- **Zsh**: Oh My Zsh, Powerlevel10k テーマ、自動補完
- **Wezterm**: ターミナルエミュレータ設定
- **Git**: ユーザー設定、SSH鍵生成
- **Docker**: Rootless Docker設定
- **Tilix**: ターミナル設定（dconf）
- **キーボードショートカット**: GNOME環境のカスタムショートカット設定
- **Logiops**: Logicoolマウス設定（設定ファイルがある場合）

### 📝 セットアップされる環境
- **日本語環境**: 完全な日本語サポート
- **開発環境**: Python, Node.js, Go, Rust, PHP, Ruby
- **コンテナ環境**: Docker + Docker Compose (Rootless)
- **シェル環境**: Zsh + Powerlevel10k + 便利なプラグイン
- **エディタ環境**: Neovim + カスタム設定
- **ターミナル環境**: Wezterm + Tilix の設定

## 🔧 カスタマイズ

各設定ファイルは以下のディレクトリに配置されています：

- `vim/` - Vim/Neovim設定
- `zsh/` - Zsh設定
- `wezterm/` - Wezterm設定
- `Brewfile` - Homebrewパッケージリスト
- `Makefile` - セットアップスクリプト

## 📧 Git設定

Git設定時にメールアドレスが必要です。以下の方法で指定できます：

環境変数で指定：
```bash
EMAIL=your@email.com make setup-git
```

または実行時に入力プロンプトで設定可能です。

## 💡 使用例

```bash
# 全体セットアップ（メール指定）
EMAIL=user@example.com make setup-all

# 特定の設定のみ
make setup-vim
make setup-zsh
make setup-wezterm
```

## 🔄 更新方法

```bash
cd ~/dots
git pull
make setup-all
```

## ⚠️ 注意事項

- Ubuntu 22.04 LTS での動作を想定しています
- システム設定の変更後は再起動を推奨します
- 一部のインストールにはsudo権限が必要です

## 📝 ライセンス

MIT License
