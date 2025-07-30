#!/bin/bash
set -e

# 環境変数テンプレートファイルが存在するか確認
ENV_TEMPLATE=".env.template"
ENV_FILE=".env"

if [ ! -f "$ENV_TEMPLATE" ]; then
  echo "エラー: $ENV_TEMPLATE ファイルが見つかりません"
  exit 1
fi

# .env ファイルが既に存在する場合はバックアップを作成
if [ -f "$ENV_FILE" ]; then
  BACKUP_FILE="$ENV_FILE.$(date +%Y%m%d_%H%M%S).bak"
  echo "既存の $ENV_FILE ファイルを $BACKUP_FILE にバックアップします"
  cp "$ENV_FILE" "$BACKUP_FILE"
fi

# テンプレートから新しい .env ファイルを作成
cp "$ENV_TEMPLATE" "$ENV_FILE"
echo "$ENV_FILE ファイルが作成されました"
echo "以下のコマンドで環境変数を編集してください:"
echo "  vi $ENV_FILE"
echo ""
echo "必要なAPIキーを設定してください。例:"
echo "  tavily.api_token=tvly-YOUR_API_KEY"
echo "  anthropic.api_key=YOUR_API_KEY"
echo ""
