# Docker MCP Gateway Makefile targets
# Include this in your main Makefile

.PHONY: docker-mcp-install docker-mcp-setup docker-mcp-start docker-mcp-remote docker-mcp-check docker-mcp-show docker-mcp-env

# Docker MCP Plugin installation
docker-mcp-install:
	@echo "🚀 Installing Docker MCP Plugin..."
	@cd docker-mcp-gateway && ./install-docker-mcp-plugin.sh

# Setup recommended MCP servers
docker-mcp-setup: docker-mcp-install
	@echo "⚙️  Setting up Docker MCP Gateway..."
	@cd docker-mcp-gateway && ./mcp-config.sh setup
	@cd docker-mcp-gateway && ./extract-env.sh
	@cd docker-mcp-gateway && ./mcp-config.sh cursor

# Check Docker MCP status
docker-mcp-check:
	@echo "🔍 Checking Docker MCP Gateway status..."
	@cd docker-mcp-gateway && ./mcp-config.sh check

# Show current configuration
docker-mcp-show:
	@echo "📋 Showing Docker MCP Gateway configuration..."
	@cd docker-mcp-gateway && ./mcp-config.sh show

# Create/update environment file
docker-mcp-env:
	@echo "🔐 Setting up environment variables..."
	@cd docker-mcp-gateway && ./extract-env.sh

# Start gateway in stdio mode (for Cursor)
docker-mcp-start:
	@echo "🚀 Starting Docker MCP Gateway (stdio mode)..."
	@cd docker-mcp-gateway && ./mcp-config.sh start

# Start gateway in remote mode
docker-mcp-remote:
	@echo "🌐 Starting Docker MCP Gateway (remote mode)..."
	@cd docker-mcp-gateway && ./mcp-config.sh remote 8080

# Complete setup from scratch
docker-mcp-init: docker-mcp-install docker-mcp-setup
	@echo ""
	@echo "✅ Docker MCP Gateway setup complete!"
	@echo ""
	@echo "📋 Next steps:"
	@echo "  1. Edit docker-mcp-gateway/.env to add your API keys"
	@echo "  2. Update cursor/mcp.json with docker-mcp-gateway/cursor/mcp-docker.json"
	@echo "  3. Run 'make docker-mcp-start' to start the gateway"
	@echo ""

# Help for Docker MCP targets
docker-mcp-help:
	@echo "Docker MCP Gateway Make targets:"
	@echo ""
	@echo "  docker-mcp-init     Complete setup from scratch"
	@echo "  docker-mcp-install  Install Docker MCP Plugin"
	@echo "  docker-mcp-setup    Setup recommended MCP servers"
	@echo "  docker-mcp-check    Check installation and status"
	@echo "  docker-mcp-show     Show current configuration"
	@echo "  docker-mcp-env      Create/update environment file"
	@echo "  docker-mcp-start    Start gateway (stdio mode)"
	@echo "  docker-mcp-remote   Start gateway (remote mode)"
	@echo "  docker-mcp-help     Show this help"
	@echo ""
