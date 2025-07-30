#!/bin/bash

# Extract environment variables from existing cursor/mcp.json
# and create a template .env file for Docker MCP Gateway

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
MCP_CONFIG_FILE="$SCRIPT_DIR/../cursor/mcp.json"
ENV_TEMPLATE_FILE="$SCRIPT_DIR/.env.template"
ENV_FILE="$SCRIPT_DIR/.env"

# Create .env template based on existing MCP configuration
create_env_template() {
    echo "# Docker MCP Gateway Environment Variables"
    echo "# Generated from cursor/mcp.json"
    echo ""

    # Extract environment variables from mcp.json
    if [ -f "$MCP_CONFIG_FILE" ]; then
        echo "# --- Extracted from existing configuration ---"

        # Bitbucket credentials
        if grep -q "BITBUCKET_USERNAME\|BITBUCKET_APP_PASSWORD" "$MCP_CONFIG_FILE"; then
            echo ""
            echo "# Bitbucket MCP Server"
            grep -o '"BITBUCKET_USERNAME": "[^"]*"' "$MCP_CONFIG_FILE" | sed 's/"BITBUCKET_USERNAME": "\([^"]*\)"/bitbucket.username=\1/' || echo "bitbucket.username=dh_ohi"
            grep -o '"BITBUCKET_APP_PASSWORD": "[^"]*"' "$MCP_CONFIG_FILE" | sed 's/"BITBUCKET_APP_PASSWORD": "\([^"]*\)"/bitbucket.app_password=\1/' || echo "bitbucket.app_password=ATBBGD3tAf9ba4XHt2zRYwRTJEN4DB1FA43A"
        fi

        # Backlog credentials
        if grep -q "BACKLOG_DOMAIN\|BACKLOG_API_KEY" "$MCP_CONFIG_FILE"; then
            echo ""
            echo "# Backlog MCP Server"
            grep -o '"BACKLOG_DOMAIN": "[^"]*"' "$MCP_CONFIG_FILE" | head -1 | sed 's/"BACKLOG_DOMAIN": "\([^"]*\)"/backlog.domain=\1/' || echo "backlog.domain=d-head.backlog.com"
            grep -o '"BACKLOG_API_KEY": "[^"]*"' "$MCP_CONFIG_FILE" | head -1 | sed 's/"BACKLOG_API_KEY": "\([^"]*\)"/backlog.1.api_key=\1/' || echo "backlog.1.api_key=InjAOHd4KbWCmHQUYiLK8zvIGRJZwBlElw6pq2BO8HZFRaDQFm9nIKLpvZ8vg72j"

            # Second Backlog instance if exists
            if grep -q "presc-ec.backlog.com" "$MCP_CONFIG_FILE"; then
                echo "backlog.2.domain=presc-ec.backlog.com"
                grep -o '"BACKLOG_API_KEY": "[^"]*"' "$MCP_CONFIG_FILE" | tail -1 | sed 's/"BACKLOG_API_KEY": "\([^"]*\)"/backlog.2.api_key=\1/' || echo "backlog.2.api_key=d6HT41VKqDLBZ8nkRDUyGumdYs2ZOP6oirDIdO08cYS20DtuyKbnQJLFEXVXSbNJ"
            fi
        fi

        # AWS credentials
        if grep -q "AWS_PROFILE\|AWS_REGION" "$MCP_CONFIG_FILE"; then
            echo ""
            echo "# AWS MCP Servers"
            grep -o '"AWS_PROFILE": "[^"]*"' "$MCP_CONFIG_FILE" | sed 's/"AWS_PROFILE": "\([^"]*\)"/aws.profile=\1/' || echo "aws.profile=default"
            grep -o '"AWS_REGION": "[^"]*"' "$MCP_CONFIG_FILE" | sed 's/"AWS_REGION": "\([^"]*\)"/aws.region=\1/' || echo "aws.region=ap-northeast-1"
            grep -o '"AWS_DOCUMENTATION_PARTITION": "[^"]*"' "$MCP_CONFIG_FILE" | sed 's/"AWS_DOCUMENTATION_PARTITION": "\([^"]*\)"/aws.documentation_partition=\1/' || echo "aws.documentation_partition=aws"
        fi

        # GitHub token
        if grep -q "github_pat" "$MCP_CONFIG_FILE"; then
            echo ""
            echo "# GitHub MCP Server"
            grep -o 'github_pat_[^"]*' "$MCP_CONFIG_FILE" | head -1 | sed 's/\(.*\)/github.token=\1/' || echo "github.token=your_github_token_here"
        fi
    fi

    echo ""
    echo "# --- Common MCP Server Environment Variables ---"
    echo ""
    echo "# Tavily Search"
    echo "tavily.api_token=your_tavily_token_here"
    echo ""
    echo "# Slack"
    echo "slack.token=your_slack_token_here"
    echo ""
    echo "# OpenAI"
    echo "openai.api_key=your_openai_key_here"
    echo ""
    echo "# Anthropic"
    echo "anthropic.api_key=your_anthropic_key_here"
    echo ""
    echo "# Logging levels"
    echo "fastmcp.log_level=ERROR"
    echo ""
    echo "# Docker MCP Gateway specific"
    echo "mcp.gateway.log_level=info"
    echo "mcp.gateway.port=8080"
}

# Generate the template
create_env_template > "$ENV_TEMPLATE_FILE"

echo "✅ Environment template created: $ENV_TEMPLATE_FILE"

# Create actual .env file if it doesn't exist
if [ ! -f "$ENV_FILE" ]; then
    cp "$ENV_TEMPLATE_FILE" "$ENV_FILE"
    echo "✅ Environment file created: $ENV_FILE"
    echo "📝 Please edit $ENV_FILE to update your API keys and credentials"
else
    echo "ℹ️  Environment file already exists: $ENV_FILE"
    echo "📝 You can reference $ENV_TEMPLATE_FILE for updates"
fi
