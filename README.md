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

## 📦 インストールされるもの

### 開発ツール
- Homebrew + Brewfile からのパッケージ
- Vim/Neovim 設定
- Zsh + Oh My Zsh 設定
- Git 設定
- Docker 設定

### アプリケーション
- ターミナルエミュレータ（Tilix、Wezterm）
- 開発用GUI ツール（DBeaver、MySQL Workbench、Insomnia）
- システムユーティリティ

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
