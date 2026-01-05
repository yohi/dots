# Devcontainer 実装仕様書

## 概要

本ドキュメントは、Makefile自動化システムのテスト環境としてのDevcontainerの詳細な実装仕様を定義する。[requirements.md](./requirements.md) の §5「Devcontainer内のテスト環境」を補完し、具体的な実装詳細を提供する。

---

## 1. ベースイメージ仕様

### 1.1 選定イメージ

| 項目 | 値 |
|------|-----|
| **イメージ名** | `mcr.microsoft.com/devcontainers/base:ubuntu-22.04` |
| **Ubuntuバージョン** | 22.04 LTS (Jammy Jellyfish) |
| **サポート期限** | 2027年4月（Standard Support）/ 2032年4月（Extended Security Maintenance） |

### 1.2 選定理由

| 観点 | Ubuntu 22.04 | Ubuntu 24.04 | 判定 |
|------|-------------|--------------|------|
| **LTS安定性** | 2年以上の本番実績、エコシステム成熟 | 2024年4月リリース、一部パッケージで非互換報告あり | 22.04 優位 |
| **Homebrew互換性** | 完全サポート | サポートされるが一部formulaで問題報告 | 22.04 優位 |
| **Docker/DevcontainerベースイメージでのMicrosoft公式サポート** | 公式イメージあり | 公式イメージあり（2024年後半より） | 同等 |
| **依存パッケージ互換性** | `libc6`, `libssl` 等の互換性確保 | glibc 2.39 への移行による一部非互換 | 22.04 優位 |
| **CI/CD環境との一貫性** | GitHub Actions ubuntu-22.04 runner との整合性 | ubuntu-24.04 runner は2024年後半から利用可能 | 22.04 優位 |

**結論:** Ubuntu 22.04 LTS を採用。24.04 LTS への移行は 2025年Q2 以降にエコシステムの成熟を確認後検討する。

### 1.3 カスタムDockerfile

```dockerfile
# .devcontainer/Dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Build arguments
ARG BW_CLI_VERSION=2024.9.0
ARG NODE_VERSION=20

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV BW_CLI_VERSION=${BW_CLI_VERSION}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    jq \
    git \
    make \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js (for npm-based tools)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Bitwarden CLI
RUN curl -L "https://github.com/bitwarden/clients/releases/download/cli-v${BW_CLI_VERSION}/bw-linux-${BW_CLI_VERSION}.zip" -o /tmp/bw.zip \
    && unzip /tmp/bw.zip -d /usr/local/bin \
    && chmod +x /usr/local/bin/bw \
    && rm /tmp/bw.zip \
    && bw --version

# Install Homebrew dependencies (for Linux)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    procps \
    file \
    && rm -rf /var/lib/apt/lists/*

# Create marker directory
RUN mkdir -p /home/vscode/.local/state/dots \
    && chown -R vscode:vscode /home/vscode/.local

# Set working directory
WORKDIR /workspaces/dots

# Switch to non-root user
USER vscode
```

---

## 2. devcontainer.json 構成

### 2.1 完全な devcontainer.json

```json
{
  "name": "dots-devcontainer",
  "build": {
    "dockerfile": "Dockerfile",
    "context": "..",
    "args": {
      "BW_CLI_VERSION": "2024.9.0",
      "NODE_VERSION": "20"
    }
  },
  
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {
      "installZsh": true,
      "configureZshAsDefaultShell": true,
      "installOhMyZsh": true,
      "username": "vscode",
      "userUid": "1000",
      "userGid": "1000"
    },
    "ghcr.io/devcontainers/features/docker-in-docker:2": {
      "version": "latest",
      "moby": true
    }
  },

  "customizations": {
    "vscode": {
      "extensions": [
        "EditorConfig.EditorConfig",
        "timonwong.shellcheck",
        "mads-hartmann.bash-ide-vscode",
        "redhat.vscode-yaml"
      ],
      "settings": {
        "terminal.integrated.defaultProfile.linux": "zsh",
        "files.eol": "\n"
      }
    }
  },

  "remoteEnv": {
    "BW_SESSION": "${localEnv:BW_SESSION}",
    "WITH_BW": "${localEnv:WITH_BW}",
    "BW_CLIENTID": "${localEnv:BW_CLIENTID}",
    "BW_CLIENTSECRET": "${localEnv:BW_CLIENTSECRET}",
    "XDG_STATE_HOME": "/home/vscode/.local/state"
  },

  "mounts": [
    "source=${localEnv:HOME}/.config/bw-session,target=/home/vscode/.config/bw-session,type=bind,consistency=cached"
  ],

  "postCreateCommand": "/workspaces/dots/.devcontainer/scripts/post-create.sh",
  "postStartCommand": "/workspaces/dots/.devcontainer/scripts/post-start.sh",

  "remoteUser": "vscode",
  "containerUser": "vscode",

  "forwardPorts": [],
  
  "portsAttributes": {},

  "hostRequirements": {
    "cpus": 2,
    "memory": "4gb",
    "storage": "16gb"
  }
}
```

### 2.2 postCreateCommand 詳細

**ファイル:** `.devcontainer/scripts/post-create.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "========================================"
echo "Devcontainer Post-Create Setup"
echo "========================================"

# ----------------------------------------
# 1. 依存関係の検証
# ----------------------------------------
echo ""
echo "[Step 1/5] Verifying dependencies..."

verify_command() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "  [✓] $name: $($cmd --version 2>/dev/null | head -1 || echo 'installed')"
    else
        echo "  [✗] $name: NOT INSTALLED"
        return 1
    fi
}

verify_command make "GNU Make"
verify_command bw "Bitwarden CLI"
verify_command jq "jq"
verify_command git "Git"
verify_command node "Node.js"
verify_command npm "npm"

# ----------------------------------------
# 2. マーカーディレクトリの初期化
# ----------------------------------------
echo ""
echo "[Step 2/5] Initializing marker directory..."

MARKER_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/dots"
mkdir -p "$MARKER_DIR"
echo "  Marker directory: $MARKER_DIR"

# ----------------------------------------
# 3. 依存関係チェック (make check-deps)
# ----------------------------------------
echo ""
echo "[Step 3/5] Running dependency check..."

if [ -f "/workspaces/dots/Makefile" ]; then
    cd /workspaces/dots
    if make check-deps 2>/dev/null; then
        echo "  [✓] All dependencies satisfied"
    else
        echo "  [!] Some dependencies may be missing (non-critical)"
    fi
else
    echo "  [SKIP] Makefile not found, skipping check-deps"
fi

# ----------------------------------------
# 4. テスト用モックデータのセットアップ
# ----------------------------------------
echo ""
echo "[Step 4/5] Setting up test mock data..."

MOCK_DIR="/workspaces/dots/.devcontainer/mocks"
if [ -d "$MOCK_DIR" ]; then
    echo "  Mock directory exists: $MOCK_DIR"
else
    mkdir -p "$MOCK_DIR"
    echo "  Created mock directory: $MOCK_DIR"
fi

# モック bw コマンドの作成（実際のBitwarden未設定時用）
if [ ! -f "$MOCK_DIR/bw-mock" ]; then
    cat > "$MOCK_DIR/bw-mock" << 'MOCK_EOF'
#!/bin/bash
# Mock Bitwarden CLI for testing
case "$1" in
    status)
        echo '{"status":"unlocked","userEmail":"test@example.com"}'
        ;;
    get)
        case "$3" in
            "github-token")
                echo '{"login":{"password":"mock-github-token-12345"}}'
                ;;
            *)
                echo '{"login":{"password":"mock-secret-value"}}'
                ;;
        esac
        ;;
    unlock)
        echo "mock-session-key-for-testing"
        ;;
    *)
        echo "Mock bw: unknown command $1"
        exit 1
        ;;
esac
MOCK_EOF
    chmod +x "$MOCK_DIR/bw-mock"
    echo "  Created mock bw command"
fi

# ----------------------------------------
# 5. Bitwarden CLI 疎通確認（WITH_BW=1 の場合のみ）
# ----------------------------------------
echo ""
echo "[Step 5/5] Checking Bitwarden integration..."

if [ "${WITH_BW:-0}" = "1" ]; then
    if [ -n "${BW_SESSION:-}" ]; then
        bw_status=$(BW_SESSION="$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error")
        if [ "$bw_status" = "unlocked" ]; then
            echo "  [✓] Bitwarden session is active and unlocked"
        else
            echo "  [!] Bitwarden status: $bw_status"
            echo "      You may need to refresh your session"
        fi
    else
        echo "  [!] WITH_BW=1 but BW_SESSION is not set"
        echo "      Run: eval \$(make bw-unlock WITH_BW=1)"
    fi
else
    echo "  [SKIP] Bitwarden integration disabled (WITH_BW not set)"
    echo "         To enable: export WITH_BW=1"
fi

echo ""
echo "========================================"
echo "Post-Create Setup Complete"
echo "========================================"
echo ""
echo "Available test commands:"
echo "  make test              - Run all tests"
echo "  make test-bw-mock      - Run Bitwarden tests with mock"
echo "  make test-bw-integration WITH_BW=1  - Run integration tests"
echo ""
```

### 2.3 postStartCommand 詳細

**ファイル:** `.devcontainer/scripts/post-start.sh`

```bash
#!/bin/bash
set -euo pipefail

echo "========================================"
echo "Devcontainer Post-Start Check"
echo "========================================"

# ----------------------------------------
# 1. ビルド成果物の確認・再生成
# ----------------------------------------
echo ""
echo "[Step 1/3] Checking build artifacts..."

cd /workspaces/dots

# help ターゲットの動作確認
if make help > /dev/null 2>&1; then
    echo "  [✓] Makefile is functional"
else
    echo "  [!] Makefile may have issues"
fi

# ----------------------------------------
# 2. Bitwarden セッション状態の確認
# ----------------------------------------
echo ""
echo "[Step 2/3] Checking Bitwarden session status..."

if [ "${WITH_BW:-0}" = "1" ] && [ -n "${BW_SESSION:-}" ]; then
    bw_status=$(BW_SESSION="$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error")
    case "$bw_status" in
        unlocked)
            echo "  [✓] Bitwarden session: active"
            ;;
        locked)
            echo "  [!] Bitwarden session: locked"
            echo "      Run: eval \$(make bw-unlock WITH_BW=1)"
            ;;
        *)
            echo "  [!] Bitwarden session: $bw_status"
            echo "      Session may have expired. Re-authenticate if needed."
            ;;
    esac
else
    echo "  [SKIP] Bitwarden not configured"
fi

# ----------------------------------------
# 3. テストスイートの準備状態確認
# ----------------------------------------
echo ""
echo "[Step 3/3] Verifying test environment..."

# テストターゲットの存在確認
if grep -q "^test:" Makefile 2>/dev/null || grep -q "^test:" mk/*.mk 2>/dev/null; then
    echo "  [✓] Test targets available"
else
    echo "  [!] Test targets may not be defined yet"
fi

echo ""
echo "========================================"
echo "Ready for development"
echo "========================================"
```

---

## 3. Bitwarden クレデンシャル連携

### 3.1 クレデンシャル提供方式の選択肢

| 方式 | 環境 | 設定方法 | セキュリティレベル | 推奨度 |
|------|------|---------|-----------------|-------|
| **環境変数フォワード** | ローカルDevcontainer | `remoteEnv` で転送 | 中（ホストの環境変数に依存） | ★★★ |
| **Secrets API** | GitHub Codespaces | Codespaces Secrets で設定 | 高（暗号化保存） | ★★★ |
| **バインドマウント** | ローカルDevcontainer | セッションファイルをマウント | 中（ファイルパーミッション依存） | ★★☆ |
| **手動入力** | 全環境 | コンテナ内で `bw unlock` 実行 | 高（毎回認証） | ★☆☆ |

### 3.2 環境変数フォワード方式（推奨）

#### ホスト側の事前準備

```bash
# 1. ホスト環境でBitwardenにログイン
bw login

# 2. セッションをアンロックして環境変数に設定
export BW_SESSION=$(bw unlock --raw)

# 3. WITH_BW フラグを有効化
export WITH_BW=1

# 4. Devcontainerを起動
# VS Code: "Reopen in Container" または
# CLI: devcontainer up --workspace-folder .
```

#### devcontainer.json 設定

```json
{
  "remoteEnv": {
    "BW_SESSION": "${localEnv:BW_SESSION}",
    "WITH_BW": "${localEnv:WITH_BW}",
    "BW_CLIENTID": "${localEnv:BW_CLIENTID}",
    "BW_CLIENTSECRET": "${localEnv:BW_CLIENTSECRET}"
  }
}
```

#### 環境変数一覧

| 変数名 | 必須 | 説明 | 用途 |
|--------|------|------|------|
| `BW_SESSION` | 統合テストで必須 | アンロック済みセッションキー | シークレット取得操作 |
| `WITH_BW` | 任意 | Bitwarden連携の有効化フラグ | `1` で有効化 |
| `BW_CLIENTID` | API認証時 | BitwardenのAPI Client ID | 非対話的ログイン |
| `BW_CLIENTSECRET` | API認証時 | BitwardenのAPI Client Secret | 非対話的ログイン |

### 3.3 バインドマウント方式（代替）

セッションファイルを使用する場合の構成:

#### ホスト側の準備

```bash
# セッションファイル用ディレクトリ作成
mkdir -p ~/.config/bw-session
chmod 700 ~/.config/bw-session

# セッションをファイルに保存（注意: セキュリティリスクあり）
bw unlock --raw > ~/.config/bw-session/session
chmod 600 ~/.config/bw-session/session
```

#### devcontainer.json 設定

```json
{
  "mounts": [
    "source=${localEnv:HOME}/.config/bw-session,target=/home/vscode/.config/bw-session,type=bind,consistency=cached"
  ]
}
```

#### コンテナ内での使用

```bash
# セッションファイルから読み込み
export BW_SESSION=$(cat ~/.config/bw-session/session)
```

**注意:** この方式はセッションキーがファイルシステムに永続化されるため、セキュリティリスクが高い。開発環境限定で使用すること。

### 3.4 GitHub Codespaces での設定

#### Codespaces Secrets の設定

1. リポジトリの Settings → Secrets and variables → Codespaces
2. 以下のシークレットを追加:
   - `BW_SESSION`: アンロック済みセッションキー
   - `BW_CLIENTID`: (オプション) API Client ID
   - `BW_CLIENTSECRET`: (オプション) API Client Secret

#### devcontainer.json での参照

```json
{
  "remoteEnv": {
    "BW_SESSION": "${containerEnv:BW_SESSION}",
    "WITH_BW": "1"
  }
}
```

---

## 4. セッション永続化と有効期限管理

### 4.1 セッションライフサイクル

```
┌─────────────────────────────────────────────────────────────────┐
│                    Bitwarden Session Lifecycle                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Host Environment]                                              │
│       │                                                          │
│       ▼                                                          │
│  ┌─────────────┐                                                 │
│  │  bw login   │ ← マスターパスワード認証                        │
│  └──────┬──────┘                                                 │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────┐                                                 │
│  │  bw unlock  │ → BW_SESSION 生成                               │
│  └──────┬──────┘                                                 │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────┐                     │
│  │  export BW_SESSION=$(bw unlock --raw)   │                     │
│  └──────┬──────────────────────────────────┘                     │
│         │                                                        │
│         │  remoteEnv forwarding                                  │
│         ▼                                                        │
│  ┌─────────────────────────────────────────┐                     │
│  │         Devcontainer Environment         │                    │
│  │  ┌───────────────────────────────────┐  │                     │
│  │  │  $BW_SESSION available            │  │                     │
│  │  │  make bw-get-item-* works         │  │                     │
│  │  └───────────────────────────────────┘  │                     │
│  └─────────────────────────────────────────┘                     │
│                                                                  │
│  [Session Expiration: ~15 minutes of inactivity]                 │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────┐                     │
│  │  Session expired → Re-unlock required   │                     │
│  │  eval $(make bw-unlock WITH_BW=1)       │                     │
│  └─────────────────────────────────────────┘                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 セッション有効期限

| 条件 | デフォルト有効期限 | 延長方法 |
|------|------------------|---------|
| アイドル状態 | 約15分 | `bw sync` などのAPIコール実行 |
| アクティブ使用 | 無制限（ログアウトまで） | 継続的なAPI操作 |
| Vault timeout設定（Bitwardenアプリ） | ユーザー設定依存 | Vaultタイムアウト設定変更 |

### 4.3 自動セッションリフレッシュ

コンテナ内で定期的にセッションを維持するためのヘルパースクリプト:

**ファイル:** `.devcontainer/scripts/bw-keepalive.sh`

```bash
#!/bin/bash
# Bitwarden セッションキープアライブ
# 使用方法: nohup .devcontainer/scripts/bw-keepalive.sh &

INTERVAL=600  # 10分ごと

while true; do
    if [ -n "${BW_SESSION:-}" ]; then
        status=$(BW_SESSION="$BW_SESSION" bw status 2>/dev/null | jq -r '.status' 2>/dev/null)
        if [ "$status" = "unlocked" ]; then
            # sync コマンドでセッションを延長
            BW_SESSION="$BW_SESSION" bw sync > /dev/null 2>&1
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Session refreshed"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Session expired or locked"
            break
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] BW_SESSION not set"
        break
    fi
    sleep $INTERVAL
done
```

### 4.4 セッション期限切れ時の復旧手順

```bash
# 1. 現在のセッション状態を確認
bw status

# 2. 期限切れの場合、ホスト環境で再アンロック
# (ホストターミナルで実行)
export BW_SESSION=$(bw unlock --raw)

# 3. Devcontainerを再起動して環境変数を再転送
# VS Code: "Rebuild Container" または
# CLI: devcontainer up --workspace-folder . --remove-existing-container

# または、コンテナ内で直接アンロック（マスターパスワード入力が必要）
eval $(make bw-unlock WITH_BW=1)
```

---

## 5. ホスト環境の前提条件

### 5.1 必須要件

| 要件 | 最小バージョン | 確認コマンド | インストール方法 |
|------|--------------|-------------|----------------|
| Docker Desktop / Docker Engine | 24.0+ | `docker --version` | https://docs.docker.com/get-docker/ |
| VS Code | 1.85+ | `code --version` | https://code.visualstudio.com/ |
| Dev Containers 拡張機能 | 0.327.0+ | VS Code拡張パネルで確認 | `code --install-extension ms-vscode-remote.remote-containers` |

### 5.2 推奨要件（Bitwarden連携使用時）

| 要件 | 最小バージョン | 確認コマンド | インストール方法 |
|------|--------------|-------------|----------------|
| Bitwarden CLI | 2024.9.0+ | `bw --version` | `brew install bitwarden-cli` または `npm install -g @bitwarden/cli` |
| jq | 1.6+ | `jq --version` | `brew install jq` / `apt install jq` |

### 5.3 ホスト環境チェックスクリプト

**ファイル:** `.devcontainer/scripts/check-host-prerequisites.sh`

```bash
#!/bin/bash
# ホスト環境の前提条件チェック
# 使用方法: ./.devcontainer/scripts/check-host-prerequisites.sh

echo "========================================"
echo "Host Prerequisites Check"
echo "========================================"

errors=0

# Docker
echo -n "Docker: "
if command -v docker > /dev/null 2>&1; then
    docker_version=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    echo "[✓] $docker_version"
else
    echo "[✗] Not installed"
    ((errors++))
fi

# Docker daemon
echo -n "Docker daemon: "
if docker info > /dev/null 2>&1; then
    echo "[✓] Running"
else
    echo "[✗] Not running"
    ((errors++))
fi

# VS Code (optional)
echo -n "VS Code: "
if command -v code > /dev/null 2>&1; then
    code_version=$(code --version | head -1)
    echo "[✓] $code_version"
else
    echo "[-] Not installed (optional)"
fi

# Dev Containers extension
echo -n "Dev Containers extension: "
if code --list-extensions 2>/dev/null | grep -q "ms-vscode-remote.remote-containers"; then
    echo "[✓] Installed"
else
    echo "[-] Not installed (install with: code --install-extension ms-vscode-remote.remote-containers)"
fi

# Bitwarden CLI (optional)
echo -n "Bitwarden CLI: "
if command -v bw > /dev/null 2>&1; then
    bw_version=$(bw --version)
    echo "[✓] $bw_version"
    
    # Bitwarden login status
    echo -n "Bitwarden status: "
    bw_status=$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "error")
    case "$bw_status" in
        unlocked)
            echo "[✓] Unlocked and ready"
            ;;
        locked)
            echo "[!] Logged in but locked (run: export BW_SESSION=\$(bw unlock --raw))"
            ;;
        unauthenticated)
            echo "[!] Not logged in (run: bw login)"
            ;;
        *)
            echo "[!] Unknown status: $bw_status"
            ;;
    esac
else
    echo "[-] Not installed (optional, for Bitwarden integration)"
fi

# jq (optional)
echo -n "jq: "
if command -v jq > /dev/null 2>&1; then
    jq_version=$(jq --version)
    echo "[✓] $jq_version"
else
    echo "[-] Not installed (optional)"
fi

echo ""
echo "========================================"
if [ $errors -eq 0 ]; then
    echo "All required prerequisites met!"
    echo "Run: code . --folder-uri vscode-remote://dev-container+$(printf '%s' "$PWD" | xxd -p)/workspaces/dots"
    exit 0
else
    echo "Missing $errors required prerequisite(s)"
    exit 1
fi
```

---

## 6. 代替ワークフロー

### 6.1 Bitwarden なしでの開発

Bitwarden連携を使用せずにDevcontainerを利用する場合:

```bash
# Devcontainerを起動（Bitwarden統合なし）
# WITH_BW を設定しない、または WITH_BW=0 を明示

# テスト実行（モック使用）
make test-bw-mock

# Bitwarden関連のターゲットはスキップ
make install  # Bitwarden連携部分は自動スキップ
```

### 6.2 GitHub Codespaces での開発

```bash
# 1. GitHub Codespaces でリポジトリを開く
# (ブラウザまたはVS Codeから)

# 2. Codespaces Secrets が設定済みの場合、自動的に利用可能
echo $BW_SESSION  # Codespaces Secretから注入される

# 3. テスト実行
make test-bw-integration WITH_BW=1
```

### 6.3 CI環境での使用

**GitHub Actions ワークフロー例:**

```yaml
# .github/workflows/test-devcontainer.yml
name: Devcontainer Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-22.04
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Devcontainer
        uses: devcontainers/ci@v0.3
        with:
          imageName: dots-devcontainer
          cacheFrom: dots-devcontainer
          push: never
          runCmd: |
            make check-deps
            make test-bw-mock
      
      - name: Integration Tests (with Bitwarden)
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        uses: devcontainers/ci@v0.3
        env:
          BW_SESSION: ${{ secrets.BW_SESSION }}
          WITH_BW: "1"
        with:
          imageName: dots-devcontainer
          cacheFrom: dots-devcontainer
          push: never
          runCmd: |
            make test-bw-integration WITH_BW=1
```

### 6.4 ローカルDocker Compose での開発

Devcontainer以外でコンテナ環境を使用する場合:

**ファイル:** `docker-compose.dev.yml`

```yaml
version: '3.8'

services:
  dots-dev:
    build:
      context: .
      dockerfile: .devcontainer/Dockerfile
    volumes:
      - .:/workspaces/dots
      - ~/.config/bw-session:/home/vscode/.config/bw-session:ro
    environment:
      - WITH_BW=${WITH_BW:-0}
      - BW_SESSION=${BW_SESSION:-}
    working_dir: /workspaces/dots
    command: sleep infinity
```

```bash
# 使用方法
docker-compose -f docker-compose.dev.yml up -d
docker-compose -f docker-compose.dev.yml exec dots-dev make test
```

---

## 7. トラブルシューティング

### 7.1 よくある問題と解決策

| 問題 | 原因 | 解決策 |
|------|------|--------|
| `BW_SESSION` がコンテナ内で空 | ホスト環境で未設定 | ホストで `export BW_SESSION=$(bw unlock --raw)` を実行後、コンテナ再起動 |
| `bw status` が `locked` を返す | セッション期限切れ | コンテナ内で `eval $(make bw-unlock WITH_BW=1)` を実行 |
| Devcontainerビルドエラー | Dockerfile構文エラー、ネットワーク問題 | `docker build .devcontainer/` で詳細エラーを確認 |
| `postCreateCommand` 失敗 | スクリプトの権限不足 | `chmod +x .devcontainer/scripts/*.sh` を実行 |
| 環境変数が反映されない | remoteEnv 設定ミス | devcontainer.json の `remoteEnv` セクションを確認 |

### 7.2 デバッグコマンド

```bash
# コンテナ内の環境変数確認
env | grep -E '^(BW_|WITH_)'

# Bitwarden CLIの詳細状態
bw status --raw | jq .

# Devcontainerログ確認 (VS Codeの場合)
# Command Palette → "Dev Containers: Show Container Log"

# Docker ログ確認
docker logs $(docker ps -q --filter "label=devcontainer.local_folder=$(pwd)")
```

---

## 8. 受け入れ基準

本実装仕様に基づく Devcontainer 環境は、以下の受け入れ基準を満たすものとする。

### 8.1 ベースイメージ

1. The Devcontainer shall use `mcr.microsoft.com/devcontainers/base:ubuntu-22.04` as the base image.
2. The Devcontainer shall install Bitwarden CLI version 2024.9.0 or later during the build phase.
3. The Devcontainer shall include all required dependencies (make, jq, git, node, npm) in the base image.

### 8.2 初期化コマンド

1. The `postCreateCommand` shall execute dependency verification and display the results.
2. The `postCreateCommand` shall create and initialize the marker directory for idempotency.
3. The `postCreateCommand` shall set up mock data for testing without Bitwarden.
4. The `postStartCommand` shall verify the Makefile is functional.
5. The `postStartCommand` shall check and report Bitwarden session status when `WITH_BW=1`.

### 8.3 クレデンシャル連携

1. The Devcontainer shall forward `BW_SESSION` from the host environment via `remoteEnv`.
2. The Devcontainer shall support GitHub Codespaces Secrets for `BW_SESSION`.
3. The Devcontainer shall optionally support bind-mount for session file access.
4. When `BW_SESSION` is not set, the Devcontainer shall allow mock-based testing without errors.

### 8.4 セッション管理

1. The Devcontainer documentation shall describe the session lifecycle and expiration behavior.
2. The Devcontainer shall provide a keepalive script for maintaining active sessions.
3. When a session expires, the Devcontainer shall provide clear instructions for re-authentication.

### 8.5 ホスト前提条件

1. The documentation shall specify minimum Docker version requirements.
2. The documentation shall provide a prerequisites check script for host validation.
3. The documentation shall describe alternative workflows for environments without Bitwarden.

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|-----|---------|
| 1.0 | 2026-01-05 | 初版作成 - ベースイメージ、初期化コマンド、クレデンシャル連携、セッション管理、ホスト前提条件を定義 |
