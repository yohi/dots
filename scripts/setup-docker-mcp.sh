#!/bin/bash
set -euo pipefail

# Target files
TARGETS=(
  "cursor/mcp.json"
  "claude/claude-settings.json"
  "opencode/opencode.jsonc"
  "opencode/antigravity.json"
  "gemini/Core/personas.json"
)

build_payload() {
  local target="$1"

  if [[ "$target" == "opencode/opencode.jsonc" ]]; then
    printf '%s' '{"mcp":{"docker":{"type":"local","command":["npx","-y","@docker/mcp-server"]}}}'
  else
    printf '%s' '{"mcpServers":{"docker":{"command":"npx","args":["-y","@docker/mcp-server"]}}}'
  fi
}

ensure_jsonc_parser() {
  if node -e 'require.resolve("jsonc-parser")' >/dev/null 2>&1; then
    return 0
  fi

  echo "⚠️  jsonc-parser が見つかりません。ローカルへインストールします..."
  if ! npm install --no-save jsonc-parser; then
    echo "❌ エラー: jsonc-parser のインストールに失敗しました。"
    echo "❌ setup-docker-mcp を中断します。"
    exit 1
  fi

  if ! node -e 'require.resolve("jsonc-parser")' >/dev/null 2>&1; then
    echo "❌ エラー: jsonc-parser の解決に失敗しました。"
    echo "❌ setup-docker-mcp を中断します。"
    exit 1
  fi
}

merge_payload_into_file() {
  local source_json="$1"
  local payload="$2"
  local dest_file="$3"
  local output_tmp
  local jq_filter

  if [[ "$dest_file" == "opencode/opencode.jsonc" ]]; then
    jq_filter='del(.mcpServers) * $p'
  else
    jq_filter='. * $p'
  fi

  output_tmp=$(mktemp)

  if ! jq --argjson p "$payload" "$jq_filter" "$source_json" > "$output_tmp"; then
    rm -f "$output_tmp"
    return 1
  fi

  if ! mv "$output_tmp" "$dest_file"; then
    rm -f "$output_tmp"
    return 1
  fi
}

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ エラー: jq がインストールされていません。インストールしてください。"
  exit 1
fi

# Check if node is installed
if ! command -v node >/dev/null 2>&1; then
  echo "❌ エラー: Node.js がインストールされていません。インストールしてください。"
  exit 1
fi

# Check if npm is installed (needed for jsonc-parser remediation)
if ! command -v npm >/dev/null 2>&1; then
  echo "❌ エラー: npm がインストールされていません。インストールしてください。"
  exit 1
fi

for FILE in "${TARGETS[@]}"; do
  PAYLOAD=$(build_payload "$FILE")

  # Ensure directory exists
  DIR=$(dirname "$FILE")
  if [ ! -d "$DIR" ]; then
    echo "📂 ディレクトリを作成中: $DIR..."
    mkdir -p "$DIR"
  fi

  if [ -f "$FILE" ]; then
    # Check if file is empty
    if [ ! -s "$FILE" ]; then
      echo "⚠️  ファイル $FILE は空です。初期設定で上書きします。"
      echo "$PAYLOAD" | jq . > "$FILE"
      continue
    fi

    echo "📋 $FILE を処理中..."

    # If file ends with .jsonc, parse safely with jsonc-parser
    if [[ "$FILE" == *.jsonc ]]; then
      ensure_jsonc_parser
      TMP=$(mktemp)

      if ! node scripts/parse-jsonc.js "$FILE" > "$TMP"; then
        echo "❌ エラー: JSONCファイル $FILE のパースに失敗しました"
        rm -f "$TMP"
        exit 1
      fi

      # Check if node succeeded (TMP not empty)
      if [ ! -s "$TMP" ]; then
        echo "❌ エラー: JSONCファイル $FILE のパース結果が空です"
        rm -f "$TMP"
        exit 1
      fi

      if ! merge_payload_into_file "$TMP" "$PAYLOAD" "$FILE"; then
        echo "❌ エラー: $FILE へのマージ処理に失敗しました"
        rm -f "$TMP"
        exit 1
      fi

      rm -f "$TMP"
    else
      # Standard JSON
      # Validate JSON first
      if jq . "$FILE" >/dev/null 2>&1; then
        if ! merge_payload_into_file "$FILE" "$PAYLOAD" "$FILE"; then
          echo "❌ エラー: $FILE へのマージ処理に失敗しました"
          exit 1
        fi
      else
        echo "⚠️  警告: $FILE は有効なJSONではありません。スキップします。"
        continue
      fi
    fi

    echo "✅ 更新しました: $FILE"
  else
    echo "✅ 作成しました: $FILE"
    echo "$PAYLOAD" | jq . > "$FILE"
  fi
done

echo "✅ Docker MCP設定の注入が完了しました。"
