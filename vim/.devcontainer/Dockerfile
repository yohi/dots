FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        fd-find \
        git \
        nodejs \
        npm \
        python3 \
        python3-pip \
        python3-venv \
        ripgrep \
        unzip \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Neovim version pinning with checksum verification
ARG NVIM_VERSION=v0.10.3
ARG NVIM_SHA256=be189915a2a0da3615576e2db06a7c714aef0ae926b4da6107e589a3cc623e5c

RUN curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz" -o /tmp/nvim.tar.gz \
    && echo "${NVIM_SHA256}  /tmp/nvim.tar.gz" | sha256sum -c - \
    && mkdir -p /opt/nvim \
    && tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1 \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

RUN python3 -m pip install --no-cache-dir pynvim \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd
