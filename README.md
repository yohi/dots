# 🚀 Ubuntu開発環境セットアップ dotfiles

> **包括的なUbuntu開発環境をワンクリックで構築**

Ubuntu開発環境のセットアップ用dotfilesリポジトリです。日本語環境完全対応、モダンな開発ツール、GUI設定まで含む包括的なセットアップスクリプト群を提供します。

<!-- TODO: スクリーンショット・デモ画像の追加
## 📸 スクリーンショット

### セットアップ前後の比較
![Before and After](docs/images/before-after-comparison.png)

### 完成した開発環境
![Development Environment](docs/images/development-environment.png)

### ターミナル環境（Zsh + Powerlevel10k）
![Terminal Setup](docs/images/terminal-setup.png)

### エディタ環境（Neovim + VS Code + Cursor）
![Editor Setup](docs/images/editor-setup.png)

### GNOME環境とExtensions
![GNOME Setup](docs/images/gnome-setup.png)

## 🎬 デモ動画

### ワンライナーインストールのデモ
![Installation Demo](docs/gifs/installation-demo.gif)

### 日本語入力のデモ
![Japanese Input Demo](docs/gifs/japanese-input-demo.gif)

### 開発環境の使用例
![Development Workflow](docs/gifs/development-workflow.gif)

---

**📝 注意**: 上記の画像・GIFファイルは今後追加予定です。
実際の環境セットアップ後にスクリーンショットを撮影し、
`docs/images/` および `docs/gifs/` ディレクトリに配置してください。

推奨画像サイズ:
- スクリーンショット: 1920x1080 (PNG形式)
- GIFアニメーション: 1280x720, 10-30秒, 最大5MB
-->

## 📚 目次

- [✨ 特徴](#-特徴)
- [🚀 クイックスタート](#-クイックスタート)
- [📋 手動インストール](#-手動インストール)
- [🛠️ 主な機能](#️-主な機能)
- [📦 インストールされるアプリケーション](#-インストールされるアプリケーション)
- [🔐 機密情報の設定](#-機密情報の設定)
- [🔧 詳細設定](#-詳細設定)
- [💡 使用例](#-使用例)
- [🔤 フォント管理機能](#-フォント管理機能)
- [🧪 テスト・検証](#-テスト検証)
- [🐛 トラブルシューティング](#-トラブルシューティング)
- [🤝 貢献](#-貢献)
- [📄 ライセンス](#-ライセンス)
- [🌟 対応環境](#-対応環境)
- [📱 アプリケーション設定](#-アプリケーション設定)

## ✨ 特徴

- 📱 **ワンライナーインストール**: `curl | bash`で完全自動セットアップ
- 🌏 **日本語環境完全対応**: フォント・入力メソッド・ロケール設定
- 🛠️ **モダン開発環境**: Neovim, Zsh, Docker, 最新言語環境
- 🎨 **GUI環境最適化**: GNOME Extensions, テーマ, ショートカット
- ⌨️ **キーボード問題対策**: SHIFTキー固定モード自動解除（詳細: [sticky-keys/README.md](sticky-keys/README.md)）
- 🔧 **カスタマイズ可能**: モジュラー設計で必要な部分のみ選択可能

---

## 🚀 クイックスタート

> **⚡ 3分で完了！** Ubuntu開発環境を即座にセットアップ

### 🎯 推奨：ワンライナーインストール

**初回ユーザーはこちら** - 完全自動セットアップ：

```bash
curl -fsSL https://raw.githubusercontent.com/yohi/dots/master/install.sh | bash
```

**✨ このコマンド1つで以下が自動実行されます：**
- 📦 システムパッケージの更新・インストール
- 🍺 Homebrewとモダン開発ツールのセットアップ
- 🎨 GNOME環境の最適化
- 🌏 日本語環境の完全設定
- ⌨️ 開発者向けキーボード設定
- 🔧 エディタ・ターミナル・シェルの設定

### 🔧 カスタムオプション

```bash
# 特定のブランチを指定
curl -fsSL https://raw.githubusercontent.com/yohi/dots/master/install.sh | bash -s -- --branch develop

# インストール先ディレクトリを指定
curl -fsSL https://raw.githubusercontent.com/yohi/dots/master/install.sh | bash -s -- --dir ~/my-dots

# ヘルプを表示
curl -fsSL https://raw.githubusercontent.com/yohi/dots/master/install.sh | bash -s -- --help
```

### 🔒 セキュリティ強化オプション（推奨）

**サプライチェーン攻撃対策** - 固定コミットSHAでの検証：

```bash
# 1. スクリプトをダウンロード
curl -fsSL https://raw.githubusercontent.com/yohi/dots/<COMMIT_SHA>/install.sh -o /tmp/install.sh

# 2. ハッシュ値を確認（READMEに記載されているハッシュと照合）
sha256sum /tmp/install.sh

# 3. 検証後に実行
bash /tmp/install.sh
```

### ✅ インストール完了後の確認

```bash
# 環境が正しくセットアップされたかチェック
cd ~/dots && ./scripts/check-setup.sh
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
make system-setup      # システムレベルの基本設定
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
- **SHIFTキー固定モード対策**: 自動解除・ホットキー・デスクトップショートカット（詳細: [sticky-keys/README.md](sticky-keys/README.md)）

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

# 機密ファイルの権限を制限（重要）
chmod 600 .env
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

**⚠️ セキュリティ重要事項**:
- `.env`ファイルは絶対に公開リポジトリにコミットしないでください
- `chmod 600 .env` で権限を制限し、所有者のみ読み書き可能にしてください
- 代替案：Bitwarden/OSキーリング/Pass等の秘匿ストレージ併用を推奨
- 定期的なアプリパスワードのローテーション・破棄を実施してください

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

## 🧪 テスト・検証

### 環境確認スクリプト

セットアップが正しく完了したかを確認するための包括的なテストスクリプトが用意されています：

```bash
# 環境全体の健全性チェック
./scripts/check-setup.sh
```

**チェック項目**:
- ✅ システム情報（OS、アーキテクチャ）
- ✅ 基本コマンド（git, make, curl, gcc等）
- ✅ Homebrew環境とパッケージ
- ✅ フォント設定（日本語フォント、Nerd Fonts）
- ✅ エディタ設定（Neovim, VS Code, Cursor）
- ✅ シェル環境（Zsh, Powerlevel10k）
- ✅ Docker環境
- ✅ 日本語環境（ロケール、入力メソッド）
- ✅ GNOME環境とExtensions
- ✅ dotfiles設定
- ✅ システムパフォーマンス

### 個別テストコマンド

```bash
# 特定の機能をテスト
make fonts-list          # インストール済みフォント確認
make fonts-debug         # フォント環境デバッグ
brew doctor              # Homebrew環境診断
nvim --version           # Neovimバージョン確認
zsh --version            # Zshバージョン確認
docker --version         # Dockerバージョン確認
```

### テスト結果の解釈

スクリプト実行後の終了コード：
- **0**: 全てのテストが成功
- **1**: 重要な機能に問題あり（要修正）
- **2**: 警告レベルの問題あり（推奨改善）

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

### 💬 FAQ（よくある質問）

<details>
<summary><strong>Q: インストールが途中で止まってしまいました</strong></summary>

**A:** 以下の手順で復旧してください：

```bash
# 1. 一時ファイルをクリーンアップ
cd ~/dots && make clean

# 2. システムパッケージを更新
sudo apt update && sudo apt upgrade

# 3. 再度セットアップを実行
make setup-all
```
</details>

<details>
<summary><strong>Q: 日本語入力ができません</strong></summary>

**A:** 以下を確認してください：

```bash
# 1. Mozcがインストールされているか確認
ibus list-engines | grep mozc

# 2. IBusの再起動
ibus restart

# 3. 入力メソッドの設定
im-config -n ibus

# 4. システム再起動後に設定を確認
```
</details>

<details>
<summary><strong>Q: フォントが正しく表示されません</strong></summary>

**A:** フォント関連の問題を解決：

```bash
# 1. フォントキャッシュを更新
make fonts-refresh

# 2. フォントの再インストール
make fonts-install

# 3. フォント設定のデバッグ
make fonts-debug
```
</details>

<details>
<summary><strong>Q: VS Code/Cursorの設定が反映されません</strong></summary>

**A:** エディタ設定を再適用：

```bash
# VS Code設定の再適用
make setup-vscode

# Cursor設定の再適用
make setup-cursor

# 設定ファイルの確認
ls -la ~/.config/Code/User/
ls -la ~/.config/Cursor/User/
```
</details>

<details>
<summary><strong>Q: Dockerが動作しません</strong></summary>

**A:** Docker関連の問題を解決：

```bash
# 1. Dockerサービスの状態確認
sudo systemctl status docker

# 2. Dockerサービスの開始
sudo systemctl start docker

# 3. ユーザーをdockerグループに追加
sudo usermod -aG docker $USER

# 4. ログアウト・ログインして設定を反映
```
</details>

<details>
<summary><strong>Q: SHIFTキーが固定されて困ります</strong></summary>

**A:** SHIFTキー固定モード（Sticky Keys）を無効化：

```bash
# 1. 即座に無効化
./sticky-keys/fix-sticky-keys-instant.sh

# 2. 恒久的な無効化設定
make setup-sticky-keys-fix

# 詳細は sticky-keys/README.md を参照
```
</details>

<details>
<summary><strong>Q: 特定の機能だけをインストールしたい</strong></summary>

**A:** 部分的なセットアップが可能です：

```bash
# 利用可能なコマンドを確認
make help

# 例：Vim設定のみ
make setup-vim

# 例：フォントのみ
make fonts-install

# 例：GNOME設定のみ
make setup-gnome-extensions
```
</details>

<details>
<summary><strong>Q: 設定をカスタマイズしたい</strong></summary>

**A:** 各設定ファイルを直接編集できます：

```bash
# Vim/Neovim設定
~/.config/nvim/

# Zsh設定
~/.zshrc

# VS Code設定
~/.config/Code/User/settings.json

# 変更後は設定を再適用
make setup-all
```
</details>

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
