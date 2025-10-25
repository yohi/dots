# Docker MCP Plugin Makefile
.PHONY: install setup config start stop status restart validate health logs

# インストール
install:
	@echo "Docker MCP Pluginをインストールします..."
	@bash ./install-docker-mcp-plugin.sh

# 環境変数設定
setup:
	@echo "環境変数を設定します..."
	@cp -n env.template .env 2>/dev/null || true
	@echo "環境変数ファイル (.env) を編集してください"
	@echo "必要なAPIキーを設定してください"

# 設定生成
config:
	@echo "MCP Gateway設定を生成します..."
	@bash ./mcp-config.sh $(ARGS)

# MCP Gateway起動（stdio）
start:
	@echo "MCP Gatewayを起動します (stdio)..."
	@docker mcp gateway run --secrets ./.env

# MCP Gateway起動（リモートモード）
start-remote:
	@echo "MCP Gatewayをリモートモードで起動します..."
	@docker mcp gateway run --transport streaming --port 8080 --secrets ./.env

# MCP Gateway停止
stop:
	@echo "MCP Gatewayを停止します..."
	@docker mcp gateway stop || true

# MCP Gateway状態確認
status:
	@echo "MCP Gateway状態:"
	@docker mcp server list

# MCP Gatewayツール一覧表示
tools:
	@echo "利用可能なMCPツール一覧:"
	@docker mcp tools list

# MCP Gatewayカタログ一覧表示
catalog:
	@echo "利用可能なMCPカタログ一覧:"
	@docker mcp catalog show

# MCP Gatewayサーバー有効化
enable:
	@if [ -z "$(SERVER)" ]; then \
		echo "ERROR: サーバー名を指定してください (例: make enable SERVER=fetch)"; \
		exit 1; \
	fi; \
	echo "MCP サーバー '$(SERVER)' を有効化します..."; \
	docker mcp server enable $(SERVER)

# MCP Gatewayサーバー無効化
disable:
	@if [ -z "$(SERVER)" ]; then \
		echo "ERROR: サーバー名を指定してください (例: make disable SERVER=fetch)"; \
		exit 1; \
	fi; \
	echo "MCP サーバー '$(SERVER)' を無効化します..."; \
	docker mcp server disable $(SERVER)

# ヘルプ表示
help:
	@echo "Docker MCP Gateway Makefile コマンド一覧:"
	@echo ""
	@echo "  make install          - Docker MCP Pluginをインストール"
	@echo "  make setup            - 環境変数テンプレートをセットアップ"
	@echo "  make config ARGS=...  - MCP Gateway設定を生成 (オプション: --port 8080 など)"
	@echo "  make start            - MCP Gatewayを標準入出力モードで起動"
	@echo "  make start-remote     - MCP Gatewayをリモートモードで起動 (port: 8080)"
	@echo "  make stop             - MCP Gatewayを停止"
	@echo "  make status           - MCP Gateway状態を表示"
	@echo "  make tools            - 有効化されたツール一覧を表示"
	@echo "  make catalog          - 利用可能なMCPカタログを表示"
	@echo "  make enable SERVER=X  - MCPサーバーXを有効化"
	@echo "  make disable SERVER=X - MCPサーバーXを無効化"
	@echo ""
	@echo "例:"
	@echo "  make config ARGS='--port 9000 --enable fetch --enable tavily --tools tavily:tavily-search'"
	@echo "  make enable SERVER=fetch"
	@echo ""
