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
