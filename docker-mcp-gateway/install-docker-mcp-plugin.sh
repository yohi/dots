#!/bin/bash

# Docker MCP Plugin installer
# Based on: https://qiita.com/moritalous/items/8789a37b7db451cc1dba

set -e

echo "🚀 Installing Docker MCP Plugin..."

# Docker MCP Pluginの最新バージョンを取得
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/mcp-gateway/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
    echo "❌ Failed to get latest version. Using v0.9.8 as fallback."
    LATEST_VERSION="v0.9.8"
fi

echo "📦 Installing Docker MCP Plugin version: $LATEST_VERSION"

# プラットフォームを自動検出
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# アーキテクチャをDocker MCP Plugin形式に変換
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# ダウンロードURL
DOWNLOAD_URL="https://github.com/docker/mcp-gateway/releases/download/${LATEST_VERSION}/docker-mcp-${PLATFORM}-${ARCH}.tar.gz"

echo "📥 Downloading from: $DOWNLOAD_URL"

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Docker MCP Pluginをダウンロード
wget "$DOWNLOAD_URL" -O docker-mcp.tar.gz

# ファイルを解凍
tar zxvf docker-mcp.tar.gz

# Docker CLIプラグインディレクトリを作成
mkdir -p ~/.docker/cli-plugins

# プラグインを移動
mv docker-mcp ~/.docker/cli-plugins/

# 実行権限を付与
chmod +x ~/.docker/cli-plugins/docker-mcp

# 一時ディレクトリを削除
cd /
rm -rf "$TEMP_DIR"

# インストール確認
echo "✅ Docker MCP Plugin installed successfully!"
echo "🔍 Version check:"
docker mcp --version

echo ""
echo "🎉 Installation complete! You can now use 'docker mcp' commands."
echo ""
echo "📋 Next steps:"
echo "1. Check available catalogs: docker mcp catalog ls"
echo "2. Browse servers: docker mcp catalog show"
echo "3. Enable a server: docker mcp server enable <server-name>"
echo "4. Start gateway: docker mcp gateway run"
