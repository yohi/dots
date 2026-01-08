# Devcontainer for dots - Makefile automation system
# Base image: Ubuntu 22.04 LTS (Microsoft official devcontainer image)
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Bitwarden CLI version
ARG BW_CLI_VERSION=2024.9.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    make \
    jq \
    curl \
    unzip \
    git \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Bitwarden CLI
RUN curl -L "https://github.com/bitwarden/clients/releases/download/cli-v${BW_CLI_VERSION}/bw-linux-${BW_CLI_VERSION}.zip" -o /tmp/bw.zip \
    && unzip /tmp/bw.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/bw \
    && rm /tmp/bw.zip

# Verify installations
RUN make --version && echo "make: OK" \
    && jq --version && echo "jq: OK" \
    && bw --version && echo "bw: OK"

# Set working directory
WORKDIR /workspaces/dots
