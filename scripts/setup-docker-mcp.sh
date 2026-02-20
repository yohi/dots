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
PAYLOAD='{"mcpServers":{"docker":{"command":"npx","args":["-y","@docker/mcp-server"]}}}'

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
      echo "$PAYLOAD" | jq . > "$FILE"
      continue
    fi

    echo "📋 $FILE を処理中..."
    TMP=$(mktemp)

    # If file ends with .jsonc, parse safely with jsonc-parser
    if [[ "$FILE" == *.jsonc ]]; then
      # Use Node + jsonc-parser to parse JSONC and output standard JSON
      node -e '
        const fs = require("fs");
        const { parse, printParseErrorCode } = require("jsonc-parser");
        const file = process.argv[1];
        try {
          const content = fs.readFileSync(file, "utf8");
          const errors = [];
          const json = parse(content, errors, {
            allowTrailingComma: true,
            disallowComments: false,
          });

          if (errors.length > 0 || typeof json === "undefined") {
            const first = errors[0];
            const message = first
              ? `Invalid JSONC (${printParseErrorCode(first.error)} at offset ${first.offset})`
              : "Invalid JSONC";
            throw new Error(message);
          }

          console.log(JSON.stringify(json));
        } catch (e) {
          console.error("Error parsing " + file, e);
          process.exit(1);
        }
      ' "$FILE" > "$TMP"

      # Check if node succeeded (TMP not empty)
      if [ ! -s "$TMP" ]; then
        echo "❌ エラー: JSONCファイル $FILE のパースに失敗しました"
        rm "$TMP"
        exit 1
      fi

      # Merge with jq
      # Use * for recursive merge (requires jq 1.6+)
      jq --argjson p "$PAYLOAD" '. * $p' "$TMP" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

      rm "$TMP"
    else
      # Standard JSON
      # Validate JSON first
      if jq . "$FILE" >/dev/null 2>&1; then
        jq --argjson p "$PAYLOAD" '. * $p' "$FILE" > "$TMP" && mv "$TMP" "$FILE"
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
    echo "$PAYLOAD" | jq . > "$FILE"
  fi
done

echo "✅ Docker MCP設定の注入が完了しました。"
