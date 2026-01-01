FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN printf "nameserver 1.1.1.1\nnameserver 8.8.8.8\n" > /etc/resolv.conf

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

RUN curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz \
    && mkdir -p /opt/nvim \
    && tar -xzf /tmp/nvim.tar.gz -C /opt/nvim --strip-components=1 \
    && ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim \
    && rm /tmp/nvim.tar.gz

RUN python3 -m pip install --no-cache-dir pynvim \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd
