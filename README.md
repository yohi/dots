# 🚀 SuperClaude Framework for Cursor

Cursor向けに最適化されたSuperClaude Framework風の開発支援ルールセットです。

## 📖 概要

このプロジェクトは、[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)の機能をCursorのUser Rulesとして再現し、高度なAI駆動開発を実現します。

### ✨ 主な機能

- 🎭 **5つの専門ペルソナ**: アーキテクト、アナリスト、デベロッパー、テスター、DevOpsエンジニア
- 🛠️ **16のコマンド機能**: analyze、implement、design、test、troubleshoot等
- 📋 **ワークフロー統合**: プロジェクト全体の開発プロセス支援
- 🔒 **品質ゲート**: コード品質とセキュリティの自動チェック
- 🏗️ **アーキテクチャガイダンス**: スケーラブルな設計の支援

## 🚀 クイックスタート

### 1. ルールファイルをダウンロード
```bash
# このリポジトリをクローンまたはファイルをダウンロード
git clone <このリポジトリのURL>
```

### 2. Cursorに設定を適用

#### 基本設定（推奨）
1. Cursor → Settings → Rules
2. User Rulesタブを開く
3. `cursor/user-rules/basic.md`の内容をコピー&ペースト

#### 高度な設定（上級者向け）
- 基本設定の代わりに`cursor/user-rules/advanced.md`の内容を使用

#### 自動ペルソナ選択（最新機能）
```bash
# dotsプロジェクトから自動ペルソナ選択を適用
make setup-cursor-rules
```

### 3. 即座に使用開始
```
@developer implement
React + TypeScript でTODOアプリを作成してください。
```

## 📁 ファイル構成

```
📂 dots/
├── 📄 README.md                          # このファイル
├── 📂 cursor/
│   ├── 📂 user-rules/                    # User Rules（手動指定ペルソナ）
│   │   ├── 📄 README.md                  # User Rules使用ガイド
│   │   ├── 📄 basic.md                   # 基本ルールセット
│   │   ├── 📄 advanced.md                # エンタープライズ級ルールセット
│   │   └── 📄 template.txt               # 簡単貼り付け用テンプレート
│   ├── 📂 rules/                         # Project Rules（自動ペルソナ選択）
│   │   ├── 📄 README.md                  # 自動選択システムガイド
│   │   ├── 📄 *.mdc                      # 自動ペルソナ選択ルール
│   │   └── 📄 smart-persona-selector.mdc # AI判断型自動選択
│   ├── 📄 settings.json                  # Cursor基本設定
│   ├── 📄 keybindings.json               # キーバインド設定
│   └── 📄 mcp.json                       # MCP Tools設定
└── 📂 mk/
    └── 📄 setup.mk                       # make setup-cursor-rules
```

## 🎯 使用例

### ペルソナ切り替え方式
```
@architect システム全体の設計を検討したいです
@developer 認証機能を実装してください
@tester 単体テストを作成してください
@analyst コードをレビューしてください
@devops デプロイメント戦略を教えてください
```

### コマンド方式
```
design ECサイトの設計をしてください
implement ショッピングカート機能
test 実装されたAPIのテストケース作成
troubleshoot エラーの原因を特定してください
optimize パフォーマンスを改善してください
```

### 複合使用
```
@architect design
マイクロサービスアーキテクチャでECサイトを設計し、
その後各サービスの実装方針も検討してください。
```

## 🛠️ 対応分野

### フロントエンド
- React/Vue/Angular
- TypeScript/JavaScript
- Web標準（HTML/CSS）
- パフォーマンス最適化
- アクセシビリティ

### バックエンド
- Node.js/Python/Java/.NET
- API設計（REST/GraphQL）
- データベース設計
- セキュリティ実装
- スケーラビリティ

### インフラ・DevOps
- AWS/Azure/GCP
- Docker/Kubernetes
- CI/CD
- Infrastructure as Code
- 監視・ログ管理

### モバイル
- React Native/Flutter
- iOS/Android ネイティブ
- パフォーマンス最適化
- ストア最適化

### 機械学習・AI
- データパイプライン
- MLOps
- モデル最適化
- プライバシー保護

## 📚 ドキュメント

### 基本利用
- [セットアップガイド](cursor-superclaude-setup-guide.md) - 詳細な設定手順
- [基本ルール](cursor-superclaude-rules.md) - 基本的な機能とペルソナ

### 上級利用
- [高度なルール](cursor-superclaude-advanced.md) - 専門的機能と品質ゲート

## 🎓 ベストプラクティス

### 効果的な質問の仕方
1. **具体的なコンテキスト**: 技術スタック、環境、制約を明示
2. **明確な目標**: 何を達成したいかを具体的に
3. **現在の状況**: 既存コード、エラー、問題点を詳細に
4. **期待する結果**: 求める出力形式、詳細レベルを指定

### ペルソナ選択ガイド
- **設計・アーキテクチャ** → `@architect`
- **実装・コーディング** → `@developer`
- **コード分析・改善** → `@analyst`
- **テスト・品質保証** → `@tester`
- **インフラ・運用** → `@devops`

## 🔄 ワークフロー例

### 新機能開発
```
1. @architect design [機能要件]
2. @developer implement [設計に基づく実装]
3. @tester test [実装されたコードのテスト]
4. @analyst review [コード品質チェック]
5. @devops deploy [デプロイメント戦略]
```

### 既存コード改善
```
1. @analyst analyze [既存コード分析]
2. @architect refactor [リファクタリング設計]
3. @developer improve [改善実装]
4. @tester test [回帰テスト]
```

## 🆚 SuperClaude Framework vs Cursor版

| 項目               | SuperClaude Framework         | Cursor版                 |
| ------------------ | ----------------------------- | ------------------------ |
| 対象               | Claude Code専用               | Cursor専用               |
| 設定方法           | Python パッケージインストール | User Rules設定           |
| スラッシュコマンド | `/sc:command` 形式            | コマンドキーワード形式   |
| MCP統合            | 対応                          | 未対応（User Rules制約） |
| カスタマイズ       | 高度な設定可能                | ルール編集で対応         |
| 学習コスト         | 中程度                        | 低い                     |

## 🤝 コントリビューション

改善提案や新機能のアイデアがありましたら、お気軽にIssueまたはPull Requestを作成してください。

### 改善例
- 新しいペルソナの追加
- 特定分野の専門ルール
- ワークフロー最適化
- 使用例の追加

## 📜 ライセンス

MITライセンス - 詳細は[LICENSE](LICENSE)ファイルを参照

## 🙏 謝辞

本プロジェクトは[SuperClaude Framework](https://github.com/SuperClaude-Org/SuperClaude_Framework)からインスパイアされました。素晴らしいフレームワークを開発・公開してくださったSuperClaude-Orgチームに感謝いたします。

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

**⚡ 今すぐ始める**: `cursor-superclaude-rules.md`をUser Rulesにコピペして、AI駆動開発を体験してください！

**🎉 快適な開発環境をお楽しみください！**
