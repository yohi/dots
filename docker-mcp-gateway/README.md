# Docker MCP Gateway Manager

Docker MCPゲートウェイを管理するための包括的なシステムです。コンテナ化を通じてModel Context Protocol (MCP)サーバーのオーケストレーションを簡素化します。

## 🚀 機能

- **統合ゲートウェイ管理**: 単一のDockerゲートウェイを通じて複数のMCPサーバーを管理
- **設定移行**: 既存のMCPセットアップからシームレスに移行
- **Dockerオーケストレーション**: 自動化されたコンテナライフサイクル管理
- **サーバー管理**: MCPサーバーを動的に追加、削除、設定
- **ヘルス監視**: リアルタイムステータス監視とヘルスチェック
- **包括的なログ機能**: フィルタリングとリアルタイムフォロー機能を備えた一元化されたログ収集
- **CLIインターフェース**: すべての操作に対応する機能豊富なコマンドラインツール
- **設定検証**: 自動修正機能を備えた組み込みの検証
- **診断レポート**: 詳細なシステム診断とトラブルシューティング

## 📋 前提条件

- **Docker**: バージョン20.10以降
- **Node.js**: バージョン18以降
- **既存のMCP設定**: MCPサーバー定義を含む`cursor/mcp.json`ファイル

## 🛠️ インストール方法

### 1. 依存関係のインストール

```bash
cd .kiro/docker-mcp-gateway
npm install
```

### 2. プロジェクトのビルド

```bash
npm run build
```

### 3. CLIの実行権限設定

```bash
chmod +x dist/cli/index.js
```

### 4. CLIをグローバルにリンク（オプション）

```bash
npm link
```

または、エイリアスを作成：

```bash
alias docker-mcp-gateway="node .kiro/docker-mcp-gateway/dist/cli/index.js"
```

## 🚀 クイックスタート

### 1. 既存の設定を移行

```bash
# 移行のプレビュー（ドライラン）
docker-mcp-gateway migrate --dry-run

# 移行の実行
docker-mcp-gateway migrate
```

### 2. ゲートウェイの起動

```bash
docker-mcp-gateway start
```

### 3. ステータスの確認

```bash
docker-mcp-gateway status
```

### 4. ログの表示

```bash
# 最近のログを表示
docker-mcp-gateway logs

# リアルタイムでログをフォロー
docker-mcp-gateway logs --follow

# サーバーでフィルタリング
docker-mcp-gateway logs --server my-server --follow
```

### 5. ヘルスチェック

```bash
# 基本的なヘルスチェック
docker-mcp-gateway health

# 詳細なヘルス情報
docker-mcp-gateway health --detailed

# 継続的な監視
docker-mcp-gateway health --continuous --interval 10s
```

## 📖 コマンドリファレンス

### 移行コマンド

```bash
# 既存のMCP設定を移行
docker-mcp-gateway migrate [options]
  --dry-run          変更を加えずに移行をプレビュー
  --backup           移行前にバックアップを作成（デフォルト: true）
```

### ゲートウェイ管理

```bash
# ゲートウェイの起動
docker-mcp-gateway start [options]
  --config-file <path>    特定の設定ファイルを使用
  --port <port>           ゲートウェイポートを上書き
  --detach               デタッチモードで実行（デフォルト: true）

# ゲートウェイの停止
docker-mcp-gateway stop [options]
  --force                正常なシャットダウンなしで強制停止

# ゲートウェイの再起動
docker-mcp-gateway restart [options]
  --force                正常なシャットダウンなしで強制再起動

# ゲートウェイのステータス確認
docker-mcp-gateway status [options]
  --json                 ステータスをJSON形式で出力
  --watch                ステータスの変化を監視（5秒ごとに更新）
```

### サーバー管理

```bash
# MCPサーバーの追加
docker-mcp-gateway server add <server-id> [options]
  --image <image>        サーバー用のDockerイメージ
  --env <key=value>      環境変数
  --command <cmd>        実行するコマンド
  --name <name>          サーバーの表示名
  --auto-restart         自動再起動を有効化（デフォルト: true）

# MCPサーバーの削除
docker-mcp-gateway server remove <server-id> [options]
  --force                確認なしで強制削除

# MCPサーバーの一覧表示
docker-mcp-gateway server list [options]
  --json                JSON形式で出力

# 例: Pythonベースのサーバーを追加
docker-mcp-gateway server add my-python-server \
  --image python:3.11-slim \
  --command uvx mcp-server-package \
  --env API_KEY=your-key \
  --name "My Python Server"

# 例: Node.jsベースのMCPサーバーを追加
docker-mcp-gateway server add my-node-server \
  --image node:18-alpine \
  --command npx @some/mcp-server \
  --env NODE_ENV=production
```

### 設定管理

```bash
# 設定の検証
docker-mcp-gateway validate [options]
  --config-file <path>    特定の設定ファイルを検証
  --fix                  自動修正を試みる

# 設定の表示
docker-mcp-gateway config show [options]
  --format <format>      出力形式（yaml, json）

# 設定の編集（エディタでファイルを開く）
docker-mcp-gateway config edit
```

### 監視コマンド

```bash
# ログの表示
docker-mcp-gateway logs [options]
  --follow              ログ出力をフォロー
  --tail <lines>        表示する行数（デフォルト: 100）
  --server <server-id>  特定のサーバーのログを表示
  --level <level>       ログレベルでフィルタリング（debug, info, warn, error）
  --since <time>        指定時間以降のログを表示（例: "1h", "30m"）
  --until <time>        指定時間までのログを表示
  --json                ログをJSON形式で出力

# ヘルスチェック
docker-mcp-gateway health [options]
  --detailed            詳細なヘルス情報を表示
  --json                ヘルスステータスをJSON形式で出力
  --continuous          継続的なヘルス監視
  --interval <time>     ヘルスチェックの間隔（デフォルト: 30s）

# 例: 過去1時間のエラーログを表示
docker-mcp-gateway logs --level error --since 1h

# 例: 特定のサーバーのログをフォロー
docker-mcp-gateway logs --server my-server --follow

# 例: 10秒ごとの継続的なヘルスモニタリング
docker-mcp-gateway health --continuous --interval 10s
```

## 📁 設定構造

### ゲートウェイ設定 (`gateway-config.yaml`)

```yaml
version: "1.0.0"
gateway:
  port: 8080
  host: "0.0.0.0"
  logLevel: "info"
servers:
  my-python-server:
    id: "my-python-server"
    name: "Python MCP Server"
    image: "python:3.11-slim"
    command: ["uvx", "mcp-server-package"]
    environment:
      MCP_SERVER_ID: "my-python-server"
      API_KEY: "your-api-key"
    autoRestart: true
    healthCheck:
      command: ["echo", "health-check"]
      interval: 30000
      timeout: 5000
      retries: 3
  my-node-server:
    id: "my-node-server"
    name: "Node.js MCP Server"
    image: "node:18-alpine"
    command: ["npx", "@some/mcp-server"]
    environment:
      MCP_SERVER_ID: "my-node-server"
      NODE_ENV: "production"
    autoRestart: true
network:
  name: "mcp-gateway-network"
  driver: "bridge"
```

### オリジナルMCP設定 (`cursor/mcp.json`)

```json
{
  "mcpServers": {
    "my-python-server": {
      "command": "uvx",
      "args": ["mcp-server-package"],
      "env": {
        "API_KEY": "your-api-key"
      }
    },
    "my-node-server": {
      "command": "npx",
      "args": ["@some/mcp-server"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
```

## 🔄 移行プロセス

移行プロセスは既存のMCP設定をDocker MCP Gateway形式に自動的に変換します：

1. 既存の`cursor/mcp.json`を**読み込み**
2. 各MCPサーバー定義を**分析**
3. コマンドタイプに基づいて適切なDockerイメージを**決定**:
   - `uvx`コマンド → `python:3.11-slim`
   - `npx`コマンド → `node:18-alpine`
   - `docker`コマンド → `docker:latest`
   - その他 → `alpine:latest`
4. 適切なネットワーキングを備えたゲートウェイ設定を**生成**
5. 生成された設定を**検証**
6. 既存の設定の**バックアップを作成**
7. 新しいゲートウェイ設定を**保存**

## 🔍 監視とログ

### ログ管理

システムは包括的なログ機能を提供します：

- **一元化されたログ**: すべてのゲートウェイとサーバーのログを一箇所に集約
- **リアルタイムフォロー**: `--follow`オプションでログをリアルタイムに監視
- **フィルタリング**: レベル、サーバー、時間範囲でフィルタリング
- **構造化出力**: プログラムによる処理のためのJSON形式

### ヘルス監視

- **ゲートウェイのヘルス**: コンテナのステータス、応答性、稼働時間
- **サーバーのヘルス**: 個々のサーバーのステータスとヘルスチェック
- **システムメトリクス**: CPU、メモリ、ネットワーク使用量
- **継続的な監視**: リアルタイムのヘルス追跡

### 診断レポート

以下を含む包括的な診断レポートを生成：
- 現在のシステムステータス
- パフォーマンスメトリクス
- 最近のログ
- 設定の詳細
- トラブルシューティングの推奨事項

## 🐳 Docker統合

システムは自動的に以下を行います：

- 必要なDockerイメージを**取得**
- 分離されたDockerネットワークを**作成**
- コンテナのライフサイクルを**管理**
- ポートマッピングとボリュームを**処理**
- コンテナのヘルスを**監視**
- 自動再起動機能を**提供**
- コンテナのメトリクスとログを**収集**

## 🔍 使用可能なMCPサーバー

Docker MCP Pluginのカタログには135個以上のMCPサーバーが登録されています。主要なものを紹介します：

### 基本的なサーバー
- **fetch**: Webページの取得とマークダウン変換
- **filesystem**: ファイルシステム操作
- **sqlite**: SQLiteデータベース操作
- **github**: GitHub操作
- **slack**: Slack統合

### AI・検索サーバー
- **tavily**: AI検索エンジン
- **search**: 一般的な検索機能
- **anthropic**: Anthropic AI統合

### 開発ツール
- **terraform**: インフラストラクチャ管理
- **docker**: Docker操作
- **kubernetes**: Kubernetes管理
- **git**: Git操作

### クラウドサービス
- **aws**: AWS統合
- **azure**: Microsoft Azure統合
- **gcp**: Google Cloud Platform統合

### データベース
- **postgres**: PostgreSQL操作
- **mysql**: MySQL操作
- **redis**: Redis操作
- **mongodb**: MongoDB操作

## 🔧 カスタムサーバー追加

独自のMCPサーバーを追加する場合は、カスタムカタログファイルを使用：

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
    env:
      - API_KEY
      - OTHER_CONFIG
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

**Dockerが起動していない:**
```bash
# Dockerの状態確認
docker info

# Dockerサービス開始 (Linux)
sudo systemctl start docker
```

**環境変数が設定されていない:**
```bash
# .envファイルを確認・編集
./mcp-config.sh env
```

**サーバーが起動しない:**
```bash
# 利用可能なサーバーを確認
docker mcp catalog show

# サーバーの詳細情報
docker mcp server inspect <server-name>

# ログの確認
docker logs <container-name>
```

**ポート競合:**
```bash
# 使用中のポートを確認
netstat -tulpn | grep :8080

# 別のポートを使用
./mcp-config.sh remote 9000
```

# シェルを再起動するか、以下を実行
newgrp docker
```

### デバッグ

```bash
# 詳細な出力を有効化
docker-mcp-gateway --verbose status

# ゲートウェイのヘルスを確認
docker-mcp-gateway health --detailed

# すべてのログを表示
docker-mcp-gateway logs --tail 500

# 診断レポートを生成
docker-mcp-gateway health --detailed --json > diagnostic-report.json

# Dockerコンテナを直接検査
docker ps -a --filter label=mcp-gateway=true
```

## 🏗️ 開発

### プロジェクト構造

```
docker-mcp-gateway/
├── src/
│   ├── types/
│   │   └── interfaces.ts          # 型定義
│   ├── services/
│   │   ├── configuration-manager.ts  # 設定管理
│   │   ├── gateway-orchestrator.ts   # Dockerオーケストレーション
│   │   ├── server-manager.ts         # サーバー管理
│   │   └── monitoring-service.ts     # 監視とログ
│   ├── cli/
│   │   ├── index.ts               # CLIエントリーポイント
│   │   └── commands/              # CLIコマンド実装
│   │       ├── health.ts          # ヘルスチェックコマンド
│   │       ├── logs.ts            # ログ表示コマンド
│   │       ├── migrate.ts         # 移行コマンド
│   │       ├── restart.ts         # 再起動コマンド
│   │       ├── start.ts           # 開始コマンド
│   │       ├── status.ts          # ステータス確認コマンド
│   │       ├── stop.ts            # 停止コマンド
│   │       └── validate.ts        # 検証コマンド
│   └── index.ts                   # メインライブラリエントリーポイント
├── dist/                          # コンパイル済み出力
├── logs/                          # アプリケーションログ
├── package.json                   # Node.js プロジェクト設定
├── tsconfig.json                  # TypeScript設定
└── README.md                      # このファイル
```

## 🏗️ 開発情報

### プロジェクト構造

```
docker-mcp-gateway/
├── install-docker-mcp-plugin.sh  # Docker MCP Pluginインストーラー
├── mcp-config.sh                 # 設定管理スクリプト
├── custom-catalog.yaml          # カスタムMCPカタログ
├── .env                         # 環境変数（秘密情報）
├── package.json                 # Node.js プロジェクト設定
└── README.md                    # このファイル
```

### 開発とテスト

```bash
# Docker MCP Pluginのインストール
npm run install-plugin

# 設定のセットアップ
npm run mcp-setup

# 動作確認
npm run mcp-check

# ゲートウェイの起動
npm run mcp-start
```

## 🤝 コントリビューション

このプロジェクトへの貢献を歓迎します！

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📝 ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- [Docker MCP Gateway](https://github.com/docker/mcp-gateway) - 公式Docker MCP Gateway
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP標準仕様
- [Docker](https://www.docker.com/) - コンテナ化プラットフォーム

## 📞 サポート

問題や質問がある場合は、以下の方法でサポートを受けられます：

- [Issues](https://github.com/yohi/dots/issues) - GitHubのIssue機能
- [Docker MCP Gateway公式ドキュメント](https://docs.docker.com/mcp-gateway/)
- [MCP公式サイト](https://modelcontextprotocol.io/)

---

**楽しいコーディングを！ 🚀**

// 既存設定の移行
await manager.migrate();

// ゲートウェイの開始
await manager.start();

// サーバーの追加
await manager.addServer({
  id: 'my-server',
  name: 'My Custom Server',
  image: 'python:3.11-slim',
  command: ['uvx', 'my-mcp-server'],
  environment: { API_KEY: 'secret' },
  autoRestart: true
});

// メトリクスの取得
const metrics = await manager.getMetrics();

// ヘルスチェックの実行
const health = await manager.performHealthCheck();

// ログの取得
const logs = await manager.getLogs({ level: 'error', limit: 100 });
```

## 🤝 コントリビューション

1. 既存のコードスタイルとパターンに従う
2. 新機能にはテストを追加する
3. API変更に関するドキュメントを更新する
4. リリースにはセマンティックバージョニングを使用する

## 📄 ライセンス

MITライセンス - 詳細はLICENSEファイルを参照してください。

## 🔗 関連プロジェクト

- [Docker MCP Gateway](https://docs.docker.com/ai/mcp-gateway/) - Docker MCP Gateway公式ドキュメント
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP仕様とドキュメント

---

**注意**: これはDocker MCP Gatewayの管理ツールです。正常に機能するには公式Docker MCP Gatewayイメージが必要です。
