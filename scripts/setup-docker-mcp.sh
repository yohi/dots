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

# Payload to merge
DOCKER_MCP_PACKAGE="@hypnosis/docker-mcp-server@1.4.1"
PAYLOAD_MCP="{\"mcp\":{\"docker\":{\"type\":\"local\",\"command\":[\"npx\",\"-y\",\"${DOCKER_MCP_PACKAGE}\"]}}}"
PAYLOAD_MCPSERVERS="{\"mcpServers\":{\"docker\":{\"command\":\"npx\",\"args\":[\"-y\",\"${DOCKER_MCP_PACKAGE}\"]}}}"

select_payload() {
  local json_file="$1"
  local target_file="$2"

  if jq -e '.mcp? | type == "object"' "$json_file" >/dev/null 2>&1; then
    printf '%s' "$PAYLOAD_MCP"
    return
  fi

  if jq -e '.mcpServers? | type == "object"' "$json_file" >/dev/null 2>&1; then
    printf '%s' "$PAYLOAD_MCPSERVERS"
    return
  fi

  if [ "$target_file" = "opencode/opencode.jsonc" ]; then
    printf '%s' "$PAYLOAD_MCP"
    return
  fi

  printf '%s' "$PAYLOAD_MCPSERVERS"
}

# Check if jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "❌ エラー: jq がインストールされていません。インストールしてください。"
  exit 1
fi

# Check if node/npx is installed
if ! command -v npx >/dev/null 2>&1; then
  echo "❌ エラー: npx (Node.js) がインストールされていません。インストールしてください。"
  exit 1
fi

# JSONCへの上書きはコメント消失を伴うため、明示フラグを必須にする
ALLOW_JSONC_OVERWRITE=0
for ARG in "$@"; do
  case "$ARG" in
    --allow-jsonc-overwrite)
      ALLOW_JSONC_OVERWRITE=1
      ;;
    *)
      echo "❌ エラー: 不明なオプションです: $ARG"
      echo "使い方: $0 [--allow-jsonc-overwrite]"
      exit 1
      ;;
  esac
done

for FILE in "${TARGETS[@]}"; do
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
      if [ "$FILE" = "opencode/opencode.jsonc" ]; then
        SELECTED_PAYLOAD="$PAYLOAD_MCP"
      else
        SELECTED_PAYLOAD="$PAYLOAD_MCPSERVERS"
      fi
      echo "$SELECTED_PAYLOAD" | jq . > "$FILE"
      continue
    fi

    echo "📋 $FILE を処理中..."
    TMP=$(mktemp)

    # If file ends with .jsonc, strip comments with strip-json-comments-cli
    if [[ "$FILE" == *.jsonc ]]; then
      if [ "$ALLOW_JSONC_OVERWRITE" -ne 1 ]; then
        echo "⚠️  警告: $FILE は JSONC です。この処理を実行するとコメントを削除して上書きします。"
        echo "ℹ️  続行するには --allow-jsonc-overwrite を指定して再実行してください。"
        rm "$TMP"
        continue
      fi

      echo "⚠️  注意: $FILE は --allow-jsonc-overwrite 指定によりコメントを削除して更新します。"

      # Use strip-json-comments-cli to remove comments safely (no eval)
      if ! npx -y strip-json-comments-cli "$FILE" > "$TMP"; then
        echo "❌ エラー: JSONCファイル $FILE のパースに失敗しました (strip-json-comments-cli)"
        rm "$TMP"
        exit 1
      fi

      # Check if output is not empty
      if [ ! -s "$TMP" ]; then
        echo "❌ エラー: JSONC変換後のファイルが空です"
        rm "$TMP"
        exit 1
      fi

      # Merge with jq
      SELECTED_PAYLOAD=$(select_payload "$TMP" "$FILE")
      jq --argjson p "$SELECTED_PAYLOAD" '. * $p' "$TMP" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

      rm "$TMP"
    else
      # Standard JSON
      # Validate JSON first
      if jq . "$FILE" >/dev/null 2>&1; then
        SELECTED_PAYLOAD=$(select_payload "$FILE" "$FILE")
        jq --argjson p "$SELECTED_PAYLOAD" '. * $p' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
        # TMP is moved, so no need to rm
      else
        echo "⚠️  警告: $FILE は有効なJSONではありません。スキップします。"
        rm "$TMP"
        continue
      fi
    fi

    echo "✅ 更新しました: $FILE"
  else
    echo "✅ 作成しました: $FILE"
    if [ "$FILE" = "opencode/opencode.jsonc" ]; then
      SELECTED_PAYLOAD="$PAYLOAD_MCP"
    else
      SELECTED_PAYLOAD="$PAYLOAD_MCPSERVERS"
    fi
    echo "$SELECTED_PAYLOAD" | jq . > "$FILE"
  fi
done

echo "✅ Docker MCP設定の注入が完了しました。"
