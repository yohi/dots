#!/bin/bash
set -e

VERSION="v0.9.8"
ARCH="amd64"
OS="linux"

echo "Docker MCP Pluginをインストールします (バージョン: ${VERSION})"

# 既存のプラグインが存在する場合は削除
if [ -f ~/.docker/cli-plugins/docker-mcp ]; then
    echo "既存のDocker MCP Pluginを削除します"
    rm -f ~/.docker/cli-plugins/docker-mcp
fi

# プラグインディレクトリの作成
mkdir -p ~/.docker/cli-plugins

# プラグインのダウンロードと展開
echo "Docker MCP Pluginをダウンロードしています..."
wget -q https://github.com/docker/mcp-gateway/releases/download/${VERSION}/docker-mcp-${OS}-${ARCH}.tar.gz -O /tmp/docker-mcp.tar.gz
tar zxf /tmp/docker-mcp.tar.gz -C /tmp
mv /tmp/docker-mcp ~/.docker/cli-plugins/
chmod +x ~/.docker/cli-plugins/docker-mcp
rm -f /tmp/docker-mcp.tar.gz

# インストール確認
echo "インストール完了しました。バージョンを確認します："
docker mcp --version

echo "利用可能なMCPカタログを確認します："
docker mcp catalog ls

echo "インストール成功！"
