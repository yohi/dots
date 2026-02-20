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
- 🧠 **AI駆動開発支援**: `cc-sdd`による仕様駆動開発プロセスの導入

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
- `cursor/mcp.json.template` - 環境変数を参照するように設定済み（機密情報を含まないテンプレート）
- `.env` - .gitignoreに追加済み（実際の認証情報を記述）

#### 4. Cursor MCP サーバーのセットアップ

テンプレートから実際の `~/.cursor/mcp.json` を作成・同期する手順は以下の通りです：

1. **環境変数の設定**: `.env` ファイルに必要な認証情報（例: `BITBUCKET_APP_PASSWORD`）を記述します。
2. **テンプレートの同期**: `make setup-mcp-tools` を実行すると、`cursor/mcp.json.template` が `~/.cursor/mcp.json` にコピーされます。
   - 手動で行う場合: `cp cursor/mcp.json.template ~/.cursor/mcp.json`
3. **反映**: Cursor を再起動するか、MCP 設定画面で再読み込みしてください。

**⚠️ セキュリティ重要事項**:
- `.env` ファイルおよび `cursor/mcp.json` は絶対にコミットしないでください（既に `.gitignore` で除外設定済みです）。
- テンプレート `cursor/mcp.json.template` には機密情報を記述せず、必ず `${VARIABLE}` 形式でプレースホルダーを維持してください。

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
├── AGENTS.md      # AIエージェント向けガイドライン
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

### 🔄 冪等性（Idempotency）と強制再実行

セットアップ時間の短縮のため、`install-packages-apps` などの重い処理は一度完了するとマーカーが作成され、次回以降は自動的にスキップされます（`check_marker` 関数を使用）。

**`install-packages-apps` の役割**:
`Brewfile` に定義された多数のアプリケーションを一括インストールします。これには時間がかかるため、デフォルトでは再実行を防止しています。

**制御コマンド**:

- **強制再実行**: `FORCE=1` を指定すると、マーカーを無視して再実行します。`Brewfile` を更新した場合などに使用します。
  ```bash
  make FORCE=1 install-packages-apps
  ```

- **状態確認**: どのタスクが完了済みかを確認できます。
  ```bash
  make check-idempotency
  ```

- **マーカー削除**: 全ての完了状態をリセットします。
  ```bash
  make clean-markers
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

### 開発者向けテスト

dotfiles自体の開発を行う場合、以下のコマンドでテストを実行できます：

```bash
make test             # 全体テスト（単体・モック）
make test-unit        # 単体テスト
make test-bw-mock     # Bitwardenモックテスト
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

## 🤖 AIエージェントガイドライン

本リポジトリでの開発作業を行うAIエージェント（Claude Code, Cursor, Gemini CLI等）のためのガイドラインを [`AGENTS.md`](AGENTS.md) に策定しています。

**主な内容**:
- **言語ポリシー**: 全ての外部向け出力（コメント、ドキュメント、コミットメッセージ）は**日本語**で行うこと
- **ビルド・テスト**: `make test` や `./scripts/check-setup.sh` による検証手順
- **コード規約**: `.cursor/rules/makefile-organization.mdc` に基づくMakefileの構成ルール

AIエージェントとしてコードを変更する場合は、まずこのドキュメントを読み込み、指示に従ってください。

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

Cursor で MCP サーバーを利用するための設定ファイルです。

- **テンプレート**: `cursor/mcp.json.template`
- **生成先**: `~/.cursor/mcp.json`

`make setup-mcp-tools` を実行すると、テンプレートがターゲットの場所にコピーされます。

```bash
# 1. 環境変数をロード
source .env

# 2. 設定ファイルを同期（コピー）
make setup-mcp-tools

# (代替案) 手動でコピーする場合
# cp cursor/mcp.json.template ~/.cursor/mcp.json
```

**⚠️ 注意**: 生成された `~/.cursor/mcp.json` には、環境変数が展開された後の機密情報が含まれる可能性があるため、絶対にリポジトリにコミットしないでください（`.gitignore` で除外済みです）。設定を変更する場合は、テンプレート側（`cursor/mcp.json.template`）を編集することを推奨します。

**前提条件**:
- **uvx (uv runtime)**: Python ベースの MCP サーバー（SkillPort 等）の実行に必要です。
  - インストール: `curl -LsSf https://astral.sh/uv/install.sh | sh`
- **skillport-mcp**: エージェントスキルの検索・参照用 MCP サーバー。
  - インストール: `make install-skillport` を実行し、推奨バージョン (`@1.1.0`) をセットアップしてください。

**設定済みMCPサーバー**:
- **SkillPort MCP Server**: Agent Skills（Markdown + YAML）の検索とツール実行
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

### SuperClaude Framework for Claude Code設定

**🚀 Claude Code向けSuperClaudeフレームワーク** - AIとの対話を強化する包括的なフレームワーク

#### 📋 概要

SuperClaudeフレームワークは、Claude Codeでの開発体験を向上させる以下のコンポーネントを提供します:

- **Behavioral Modes**: タスク管理、ブレインストーミング、イントロスペクションなど
- **MCP Documentation**: Context7、Serena、Playwrightなどのドキュメント
- **Core Framework**: ビジネスパネル、フラグ、原則、ルールなど

#### 🔧 セットアップコマンド

```bash
# SuperClaudeフレームワークをインストール
make install-superclaude

# または短縮形
make claudecode

# インストール状態を確認
make check-superclaude

# フレームワーク情報を表示
make info-superclaude
```

#### 📦 インストール内容

フレームワークは以下のファイルを`~/.claude/`にセットアップします:

**Behavioral Modes**:
- `MODE_Brainstorming.md` - ブレインストーミングモード
- `MODE_Business_Panel.md` - ビジネスパネルモード
- `MODE_Introspection.md` - イントロスペクションモード
- `MODE_Orchestration.md` - オーケストレーションモード
- `MODE_Task_Management.md` - タスク管理モード
- `MODE_Token_Efficiency.md` - トークン効率化モード

**MCP Documentation**:
- `MCP_Context7.md` - Context7 MCPドキュメント
- `MCP_Magic.md` - Magic MCPドキュメント
- `MCP_Morphllm.md` - Morphllm MCPドキュメント
- `MCP_Playwright.md` - Playwright MCPドキュメント
- `MCP_Sequential.md` - Sequential MCPドキュメント
- `MCP_Serena.md` - Serena MCPドキュメント

**Core Framework**:
- `BUSINESS_PANEL_EXAMPLES.md` - ビジネスパネルの例
- `BUSINESS_SYMBOLS.md` - ビジネスシンボル
- `FLAGS.md` - フラグ定義
- `PRINCIPLES.md` - 原則
- `RULES.md` - ルール

#### 🔄 メンテナンスコマンド

```bash
# 最新版に更新
make update-superclaude

# アンインストール
make uninstall-superclaude
```

#### 📝 使用方法

SuperClaudeフレームワークをインストールすると、Claude Codeを起動した際に自動的にフレームワークが読み込まれます。`~/.claude/CLAUDE.md`に記載されている各モードやMCPドキュメントが利用可能になります。

#### 🔗 設定ファイル

- **メイン設定**: `~/.claude/CLAUDE.md` (dotfilesからシンボリックリンク)
- **ソース**: `~/dotfiles/claude/CLAUDE.md`

---

### cc-sdd (Spec-Driven Development) for Claude Code設定

**🚀 AI駆動開発ライフサイクル(AI-DLC) × Spec-Driven Development(SDD)** - プロトタイプから本番開発へ

#### 📋 概要

cc-sddは、Claude CodeにAI-DLC (AI-Driven Development Life Cycle)とSpec-Driven Development (SDD)のワークフローを導入するツールです。

**主な特徴**:
- 🚀 **AI-DLC手法** - 人間承認付きAIネイティブプロセス
- 📋 **仕様ファースト開発** - 包括的仕様を単一情報源として活用
- ⚡ **ボルト開発** - 週単位から時間単位の納期を実現
- 🧠 **永続的プロジェクトメモリ** - AIがセッション間でコンテキスト維持
- 🛠 **テンプレート柔軟性** - チームのドキュメント形式に合わせてカスタマイズ可能
- 🔄 **AIネイティブ+人間ゲート** - AI計画→人間検証→AI実装

#### 🔧 セットアップコマンド

```bash
# cc-sddをインストール（日本語、Claude Code）
make cc-sdd-install

# または短縮形
make cc-sdd

# アルファ版インストール（最新機能）
make cc-sdd-install-alpha

# SubAgentsインストール（12コマンド + 9サブエージェント）
make cc-sdd-install-agent

# 英語版インストール
make cc-sdd-install-en

# インストール状態を確認
make cc-sdd-check

# 詳細情報を表示
make cc-sdd-info
```

#### 📦 提供されるコマンド

**仕様駆動開発ワークフロー**:
- `/kiro:spec-init <description>` - 機能仕様を初期化
- `/kiro:spec-requirements <feature>` - 要件を生成
- `/kiro:spec-design <feature>` - 技術設計を作成
- `/kiro:spec-tasks <feature>` - 実装タスクに分解
- `/kiro:spec-impl <feature> <tasks>` - TDDで実行
- `/kiro:spec-status <feature>` - 進捗を確認

**品質向上（既存コード向けオプション）**:
- `/kiro:validate-gap <feature>` - 既存機能と要件のギャップ分析
- `/kiro:validate-design <feature>` - 設計互換性をレビュー

**プロジェクトメモリとコンテキスト**:
- `/kiro:steering` - プロジェクトメモリを作成/更新
- `/kiro:steering-custom` - 専門ドメイン知識を追加

#### 🤖 対応AIエージェント

- **Claude Code** (デフォルト) - `make cc-sdd-install`
- **Claude Code SubAgents** (アルファ版) - `make cc-sdd-install-agent`
- **Gemini CLI** - `make cc-sdd-install-gemini`
- **Cursor IDE** - `make cc-sdd-install-cursor`
- **Codex CLI** (アルファ版) - `make cc-sdd-install-codex`
- **GitHub Copilot** (アルファ版) - `make cc-sdd-install-copilot`
- **Qwen Code** - `make cc-sdd-install-qwen`

#### 💡 使用例

**新規プロジェクト**:
```bash
/kiro:spec-init ユーザー認証システムをOAuthで構築
/kiro:spec-requirements auth-system
/kiro:spec-design auth-system
/kiro:spec-tasks auth-system
/kiro:spec-impl auth-system
```

**既存プロジェクト（推奨）**:
```bash
/kiro:steering
/kiro:spec-init 既存認証にOAuthを追加
/kiro:spec-requirements oauth-enhancement
/kiro:validate-gap oauth-enhancement
/kiro:spec-design oauth-enhancement
/kiro:validate-design oauth-enhancement
/kiro:spec-tasks oauth-enhancement
/kiro:spec-impl oauth-enhancement
```

#### 📂 インストール内容

- **Kiroコマンド**: `.claude/commands/kiro/` (11コマンド)
- **サブエージェント**: `.claude/agents/kiro/` (9サブエージェント、SubAgents版のみ)
- **Kiroディレクトリ**: `.kiro/` (steering, specs, settings)
- **設定ファイル**: `CLAUDE.md`

#### 🌐 対応言語

英語、日本語、繁体字中国語、簡体字中国語、スペイン語、ポルトガル語、ドイツ語、フランス語、ロシア語、イタリア語、韓国語、アラビア語（全12言語）

#### 📚 リソース

- **GitHubリポジトリ**: https://github.com/gotalab/cc-sdd
- **NPMパッケージ**: https://www.npmjs.com/package/cc-sdd
- **関連記事**: [Kiroの仕様書駆動開発プロセスをClaude Codeで徹底的に再現した](https://zenn.dev/gotalab/articles/3db0621ce3d6d2)

---

## 🧠 プロジェクトメモリ (Kiro Steering)

このプロジェクトはAIとの協調開発を最適化するため、`.kiro/steering/`にプロジェクトの「ステアリング（指針）」を保持しています。

- **product.md**: プロダクトのビジョンとコアバリュー
- **tech.md**: 技術スタックとアーキテクチャの決定事項
- **structure.md**: ディレクトリ構成と命名規則

AIエージェント（Claude Code, Gemini CLI, Cursor等）はこれらのドキュメントを参照して、プロジェクトの文脈に沿った一貫性のある提案・実装を行います。

---

**🎉 快適な開発環境をお楽しみください！**
