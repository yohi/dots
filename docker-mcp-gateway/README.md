# Docker MCP Gateway

Docker MCPゲートウェイを管理するための包括的なシステムです。コンテナ化を通じてModel Context Protocol (MCP)サーバーのオーケストレーションを簡素化します。

## 🚀 機能

- **統合ゲートウェイ管理**: 単一のDockerゲートウェイを通じて複数のMCPサーバーを管理
- **Dockerオーケストレーション**: 自動化されたコンテナライフサイクル管理
- **サーバー管理**: MCPサーバーを動的に追加、削除、設定
- **リモート対応**: SSEやStreamable HTTP経由でリモートからアクセス可能
- **シークレット管理**: APIキーなどの秘密情報を安全に管理
- **カスタムカタログ**: 独自のMCPサーバーカタログを定義可能

## 📋 前提条件

- **Docker**: バージョン20.10以降

## 🛠️ インストール方法

### 1. Docker MCP Pluginのインストール

```bash
# インストールスクリプトを実行
chmod +x ./install-docker-mcp-plugin.sh
./install-docker-mcp-plugin.sh
```

### 2. 環境変数の設定

```bash
# 環境変数テンプレートをコピー
cp env.template .env

# 必要なAPIキーを設定
vi .env
```

## 🚀 クイックスタート

### 1. MCPサーバーの有効化

```bash
# 基本的なWebフェッチツールを有効化
docker mcp server enable fetch

# Tavily検索サーバーを有効化
docker mcp server enable tavily
```

### 2. ゲートウェイの起動

```bash
# 標準入出力モードで起動（MCPクライアントから直接使用）
make start

# または、リモートモードで起動（ポート8080）
make start-remote
```

### 3. MCPクライアントでの設定

```json
{
  "mcpServers": {
    "MCP_DOCKER": {
      "command": "docker",
      "args": [
        "mcp",
        "gateway",
        "run",
        "--secrets",
        "./.env"
      ],
      "env": {}
    }
  }
}
```

### 4. ステータス確認

```bash
# 有効なサーバーの確認
docker mcp server list

# 有効なツールの確認
docker mcp tools list
```

## 📖 メイクファイルコマンド

Docker MCP Gatewayを簡単に管理するためのMakefileコマンド:

```bash
# インストール
make install

# 環境変数の設定
make setup

# MCP Gateway設定の生成
make config ARGS='--port 9000 --enable fetch --enable tavily'

# MCP Gatewayの起動（標準入出力）
make start

# MCP Gatewayの起動（リモートモード）
make start-remote

# MCPサーバーの有効化
make enable SERVER=fetch

# MCPサーバーの無効化
make disable SERVER=fetch

# 有効なサーバーの一覧表示
make status

# 利用可能なツールの表示
make tools

# 利用可能なカタログの表示
make catalog

# ヘルプを表示
make help
```

## 🔍 使用可能なMCPサーバー

Docker MCP Pluginのカタログには135個以上のMCPサーバーが登録されています。主要なものを紹介します：

### 基本的なサーバー
- **fetch**: Webページの取得とマークダウン変換
- **filesystem**: ファイルシステム操作
- **sqlite**: SQLiteデータベース操作
- **github**: GitHub操作

### AI・検索サーバー
- **tavily**: AI検索エンジン
- **anthropic**: Anthropic AI統合
- **openai**: OpenAI統合

## 🔧 カスタムMCPカタログ作成

独自のMCPサーバーを追加する場合は、カスタムカタログファイルを作成：

```yaml
version: 2
name: my-custom-catalog
displayName: My Custom MCP Catalog
registry:
  my-server:
    description: My custom MCP server
    title: My Server
    type: server
    image: my-custom-server:latest
```

カスタムカタログを使用するには：

```bash
docker mcp gateway run --catalog ./my-custom-catalog.yaml --servers my-server
```

## 🔍 トラブルシューティング

### よくある問題

**Docker MCP Pluginがインストールされていない:**
```bash
# インストールスクリプトを実行
./install-docker-mcp-plugin.sh

# バージョン確認
docker mcp --version
```

**APIキーが設定されていない:**
```bash
# .envファイルを確認・編集
vi .env
```

**ポート競合:**
```bash
# 使用中のポートを確認
netstat -tulpn | grep :8080

# 別のポートを使用
make config ARGS='--port 9000'
make start-remote
```

## 📞 サポート

問題や質問がある場合は、以下の方法でサポートを受けられます：

- [Docker MCP Gateway公式ドキュメント](https://docs.docker.com/mcp-gateway/)
- [MCP公式サイト](https://modelcontextprotocol.io/)

---

**楽しいコーディングを！ 🚀**
