#!/bin/bash
set -e

# 設定用変数
PORT=8080
TRANSPORT="streaming"  # 'sse' または 'streaming'
SECRETS_FILE="./.env"
CUSTOM_CATALOG=""
ENABLED_SERVERS=()
ENABLED_TOOLS=()
VERBOSE=false

# ヘルプ表示
function show_help {
  echo "Docker MCP Gateway 設定ツール"
  echo ""
  echo "使用方法: $0 [オプション]"
  echo ""
  echo "オプション:"
  echo "  -h, --help                このヘルプを表示"
  echo "  -p, --port PORT           ポート番号を指定 (デフォルト: $PORT)"
  echo "  -t, --transport TYPE      トランスポートタイプを指定 ('sse' または 'streaming', デフォルト: $TRANSPORT)"
  echo "  -s, --secrets FILE        シークレットファイルのパスを指定 (デフォルト: $SECRETS_FILE)"
  echo "  -c, --catalog FILE        カスタムMCPカタログファイルのパスを指定"
  echo "  -e, --enable SERVER       有効化するMCPサーバー名を指定 (複数指定可能)"
  echo "  --tools SERVER:TOOL       有効化するツールを指定 (例: 'fetch:*', 'tavily:tavily-search')"
  echo "  -v, --verbose             詳細なログ出力を有効化"
  echo ""
  echo "例:"
  echo "  $0 --port 9000 --enable fetch --enable tavily --tools tavily:tavily-search"
  echo "  $0 --transport sse --catalog ./my-catalog.yaml"
  echo ""
}

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_help
      exit 0
      ;;
    -p|--port)
      PORT="$2"
      shift 2
      ;;
    -t|--transport)
      TRANSPORT="$2"
      shift 2
      ;;
    -s|--secrets)
      SECRETS_FILE="$2"
      shift 2
      ;;
    -c|--catalog)
      CUSTOM_CATALOG="$2"
      shift 2
      ;;
    -e|--enable)
      ENABLED_SERVERS+=("$2")
      shift 2
      ;;
    --tools)
      ENABLED_TOOLS+=("$2")
      shift 2
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    *)
      echo "不明なオプション: $1"
      show_help
      exit 1
      ;;
  esac
done

# 設定ファイル生成
CONFIG_FILE="docker-mcp-config.json"
echo "MCP設定ファイルを生成します: $CONFIG_FILE"

# 基本コマンド
CMD_ARGS=("mcp", "gateway", "run")

# オプションの追加
if [[ -n "$CUSTOM_CATALOG" ]]; then
  CMD_ARGS+=("--catalog" "$CUSTOM_CATALOG")
fi

if [[ -f "$SECRETS_FILE" ]]; then
  CMD_ARGS+=("--secrets" "$SECRETS_FILE")
fi

if [[ ${#ENABLED_SERVERS[@]} -gt 0 ]]; then
  for server in "${ENABLED_SERVERS[@]}"; do
    CMD_ARGS+=("--servers" "$server")
  done
fi

if [[ ${#ENABLED_TOOLS[@]} -gt 0 ]]; then
  for tool in "${ENABLED_TOOLS[@]}"; do
    CMD_ARGS+=("--tools" "$tool")
  done
fi

if [[ "$TRANSPORT" != "stdio" ]]; then
  CMD_ARGS+=("--transport" "$TRANSPORT" "--port" "$PORT")
fi

if [[ "$VERBOSE" == true ]]; then
  CMD_ARGS+=("--verbose")
fi

# JSON設定ファイルの作成
cat > "$CONFIG_FILE" << EOL
{
  "mcpServers": {
    "MCP_DOCKER": {
      "command": "docker",
      "args": $(printf '%s\n' "$(jq -cn --argjson args "$(printf '%s\n' "${CMD_ARGS[@]}" | jq -R . | jq -s .)" '$args')"),
      "env": {}
    }
  }
}
EOL

echo "設定ファイルが生成されました。"
echo "以下のコマンドでDocker MCP Gatewayを実行できます:"
echo "docker $(printf '%s ' "${CMD_ARGS[@]}")"
echo ""
echo "MCPクライアントで以下の設定ファイルを使用してください:"
cat "$CONFIG_FILE"
