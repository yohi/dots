#!/bin/bash

# Docker MCP Gateway Configuration Manager
# Manages MCP servers using Docker MCP Plugin

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
MCP_CONFIG_FILE="$SCRIPT_DIR/../cursor/mcp.json"
ENV_FILE="$SCRIPT_DIR/.env"
CATALOG_FILE="$SCRIPT_DIR/custom-catalog.yaml"

# 色付きログ出力
log_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_warn() {
    echo -e "\033[0;33m[WARN]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Docker MCP Pluginがインストールされているかチェック
check_docker_mcp() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi

    if ! docker mcp --version &> /dev/null; then
        log_error "Docker MCP Plugin is not installed"
        log_info "Please run: ./install-docker-mcp-plugin.sh"
        exit 1
    fi

    log_success "Docker MCP Plugin is available"
}

# 現在の設定を表示
show_current_config() {
    log_info "Current Docker MCP configuration:"

    echo ""
    log_info "Available catalogs:"
    docker mcp catalog ls || log_warn "No catalogs available"

    echo ""
    log_info "Enabled servers:"
    docker mcp server list || log_warn "No servers enabled"

    echo ""
    log_info "Available tools:"
    docker mcp tools list || log_warn "No tools available"
}

# 推奨MCPサーバーを有効化
setup_recommended_servers() {
    log_info "Setting up recommended MCP servers..."

    # 基本的なMCPサーバー
    local servers=(
        "fetch"
        "filesystem"
        "sqlite"
        "github"
        "slack"
    )

    for server in "${servers[@]}"; do
        log_info "Enabling server: $server"
        if docker mcp server enable "$server" 2>/dev/null; then
            log_success "✅ Enabled: $server"
        else
            log_warn "⚠️  Failed to enable or already enabled: $server"
        fi
    done
}

# 環境変数ファイルを作成
create_env_file() {
    log_info "Creating environment file for secrets..."

    cat > "$ENV_FILE" << 'EOF'
# Docker MCP Gateway Environment Variables
# Add your API keys and secrets here

# GitHub (if using github server)
# github.token=your_github_token_here

# Slack (if using slack server)
# slack.token=your_slack_token_here

# Tavily (if using tavily server)
# tavily.api_token=your_tavily_token_here

# Bitbucket (if using bitbucket server)
# bitbucket.username=your_username
# bitbucket.app_password=your_app_password

# AWS (if using aws servers)
# aws.access_key_id=your_access_key
# aws.secret_access_key=your_secret_key
# aws.region=ap-northeast-1

# Backlog (if using backlog server)
# backlog.domain=your-domain.backlog.com
# backlog.api_key=your_api_key
EOF

    log_success "Environment file created: $ENV_FILE"
    log_info "Please edit this file to add your API keys and secrets"
}

# カスタムカタログファイルを作成
create_custom_catalog() {
    log_info "Creating custom catalog for additional servers..."

    cat > "$CATALOG_FILE" << 'EOF'
version: 2
name: custom-mcp-catalog
displayName: Custom MCP Catalog
registry:
  # Bitbucket MCP Server
  bitbucket:
    description: Bitbucket MCP Server for repository management
    title: Bitbucket
    type: server
    image: ghcr.io/diamondhead/mcp-bitbucket:latest
    env:
      - BITBUCKET_USERNAME
      - BITBUCKET_APP_PASSWORD

  # Backlog MCP Server
  backlog:
    description: Backlog MCP Server for project management
    title: Backlog
    type: server
    image: ghcr.io/nulab/backlog-mcp-server:latest
    env:
      - BACKLOG_DOMAIN
      - BACKLOG_API_KEY

  # Terraform MCP Server
  terraform:
    description: Terraform MCP Server for infrastructure management
    title: Terraform
    type: server
    image: hashicorp/terraform-mcp-server:latest

  # AWS Documentation MCP Server
  aws-docs:
    description: AWS Documentation MCP Server
    title: AWS Documentation
    type: server
    image: ghcr.io/awslabs/aws-documentation-mcp-server:latest
    env:
      - AWS_DOCUMENTATION_PARTITION
EOF

    log_success "Custom catalog created: $CATALOG_FILE"
}

# Gateway用のCursor設定を生成
generate_cursor_config() {
    log_info "Generating Cursor configuration for Docker MCP Gateway..."

    local cursor_config_file="$SCRIPT_DIR/../cursor/mcp-docker.json"

    cat > "$cursor_config_file" << 'EOF'
{
  "mcpServers": {
    "docker-mcp-gateway": {
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
EOF

    log_success "Cursor configuration created: $cursor_config_file"
    log_info "To use this configuration, replace or merge with your existing cursor/mcp.json"
}

# ゲートウェイを起動
start_gateway() {
    log_info "Starting Docker MCP Gateway..."

    if [ ! -f "$ENV_FILE" ]; then
        log_warn "Environment file not found, creating default..."
        create_env_file
    fi

    log_info "Starting gateway with secrets file: $ENV_FILE"
    log_info "Use Ctrl+C to stop the gateway"

    # ゲートウェイを起動
    docker mcp gateway run --secrets "$ENV_FILE"
}

# ゲートウェイをリモートモードで起動
start_gateway_remote() {
    local port="${1:-8080}"

    log_info "Starting Docker MCP Gateway in remote mode on port $port..."

    if [ ! -f "$ENV_FILE" ]; then
        log_warn "Environment file not found, creating default..."
        create_env_file
    fi

    log_info "Gateway will be accessible at: http://localhost:$port"
    log_info "Use Ctrl+C to stop the gateway"

    # リモートモードでゲートウェイを起動
    docker mcp gateway run --transport streaming --port "$port" --secrets "$ENV_FILE"
}

# ヘルプメッセージ
show_help() {
    cat << 'EOF'
Docker MCP Gateway Configuration Manager

Usage: ./mcp-config.sh [COMMAND]

Commands:
    check           Check Docker MCP Plugin installation
    show            Show current configuration
    setup           Setup recommended MCP servers
    env             Create environment file for secrets
    catalog         Create custom catalog file
    cursor          Generate Cursor configuration
    start           Start gateway in stdio mode
    remote [PORT]   Start gateway in remote mode (default port: 8080)
    help            Show this help message

Examples:
    ./mcp-config.sh check           # Check installation
    ./mcp-config.sh setup           # Setup recommended servers
    ./mcp-config.sh start           # Start gateway for Cursor
    ./mcp-config.sh remote 9000     # Start remote gateway on port 9000

For more information about Docker MCP Plugin:
    docker mcp --help
EOF
}

# メイン処理
main() {
    case "${1:-help}" in
        "check")
            check_docker_mcp
            ;;
        "show")
            check_docker_mcp
            show_current_config
            ;;
        "setup")
            check_docker_mcp
            setup_recommended_servers
            ;;
        "env")
            create_env_file
            ;;
        "catalog")
            create_custom_catalog
            ;;
        "cursor")
            generate_cursor_config
            ;;
        "start")
            check_docker_mcp
            start_gateway
            ;;
        "remote")
            check_docker_mcp
            start_gateway_remote "$2"
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

main "$@"
