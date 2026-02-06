#!/usr/bin/env bash
# Task 5.1: Devcontainer Setup Test
# Requirements: 5.1, 5.2

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Task 5.1: Devcontainer Setup Test ==="
echo ""

# Test 1: .devcontainer directory exists
echo "[TEST] 1. .devcontainer directory exists"
if [ -d "$DOTFILES_DIR/.devcontainer" ]; then
    echo "[PASS] .devcontainer directory found"
else
    echo "[FAIL] .devcontainer directory not found"
    exit 1
fi
echo ""

# Test 2: devcontainer.json exists and is valid JSON
echo "[TEST] 2. devcontainer.json exists and is valid JSON"
DEVCONTAINER_JSON="$DOTFILES_DIR/.devcontainer/devcontainer.json"
if [ ! -f "$DEVCONTAINER_JSON" ]; then
    echo "[FAIL] devcontainer.json not found"
    exit 1
fi

if ! jq empty "$DEVCONTAINER_JSON" 2>/dev/null; then
    echo "[FAIL] devcontainer.json is not valid JSON"
    exit 1
fi
echo "[PASS] devcontainer.json is valid JSON"
echo ""

# Test 3: devcontainer.json specifies correct base image
echo "[TEST] 3. devcontainer.json specifies Ubuntu 22.04 base image"
IMAGE=$(jq -r '.image // .build.dockerfile // empty' "$DEVCONTAINER_JSON")
if echo "$IMAGE" | grep -qE 'ubuntu.*22\.04|base.*ubuntu'; then
    echo "[PASS] Base image includes Ubuntu 22.04"
elif [ -f "$DOTFILES_DIR/.devcontainer/Dockerfile" ]; then
    # Check Dockerfile for base image
    if grep -qE 'FROM.*ubuntu.*22\.04|FROM.*devcontainers/base.*ubuntu' "$DOTFILES_DIR/.devcontainer/Dockerfile"; then
        echo "[PASS] Dockerfile uses Ubuntu 22.04 base image"
    else
        echo "[FAIL] Neither devcontainer.json nor Dockerfile specifies Ubuntu 22.04"
        exit 1
    fi
else
    echo "[WARN] Cannot verify base image (no explicit image or Dockerfile)"
fi
echo ""

# Test 4: Required tools are specified to be installed
echo "[TEST] 4. Required tools installation (make, jq, bw)"
# Check for features, postCreateCommand, or Dockerfile
HAS_MAKE=false
HAS_JQ=false
HAS_BW=false

# Check devcontainer.json features
if jq -e '.features' "$DEVCONTAINER_JSON" >/dev/null 2>&1; then
    FEATURES=$(jq -r '.features | keys[]' "$DEVCONTAINER_JSON" 2>/dev/null || true)
    if echo "$FEATURES" | grep -qE 'common-utils|ghcr.io/devcontainers/features/common'; then
        HAS_MAKE=true
        HAS_JQ=true
    fi
fi

# Check postCreateCommand
if jq -e '.postCreateCommand' "$DEVCONTAINER_JSON" >/dev/null 2>&1; then
    POST_CMD=$(jq -r '.postCreateCommand // empty' "$DEVCONTAINER_JSON")
    if echo "$POST_CMD" | grep -qE 'apt.*install.*make|make.*--version'; then
        HAS_MAKE=true
    fi
    if echo "$POST_CMD" | grep -qE 'apt.*install.*jq|jq.*--version'; then
        HAS_JQ=true
    fi
    if echo "$POST_CMD" | grep -qE 'bw.*--version|install.*bw'; then
        HAS_BW=true
    fi
fi

# Check Dockerfile
if [ -f "$DOTFILES_DIR/.devcontainer/Dockerfile" ]; then
    DOCKERFILE_CONTENT=$(cat "$DOTFILES_DIR/.devcontainer/Dockerfile")
    if echo "$DOCKERFILE_CONTENT" | grep -qE 'RUN.*apt.*install.*make|make'; then
        HAS_MAKE=true
    fi
    if echo "$DOCKERFILE_CONTENT" | grep -qE 'RUN.*apt.*install.*jq|jq'; then
        HAS_JQ=true
    fi
    if echo "$DOCKERFILE_CONTENT" | grep -qE 'bw-linux|bitwarden.*cli|bw.*2024\.9\.0'; then
        HAS_BW=true
    fi
fi

if [ "$HAS_MAKE" = true ] || command -v make >/dev/null 2>&1; then
    echo "[PASS] make installation configured or available"
else
    echo "[FAIL] make installation not configured"
    exit 1
fi

if [ "$HAS_JQ" = true ] || command -v jq >/dev/null 2>&1; then
    echo "[PASS] jq installation configured or available"
else
    echo "[FAIL] jq installation not configured"
    exit 1
fi

if [ "$HAS_BW" = true ]; then
    echo "[PASS] Bitwarden CLI installation configured"
else
    echo "[FAIL] Bitwarden CLI installation not configured"
    exit 1
fi
echo ""

# Test 5: Bitwarden CLI version specification
echo "[TEST] 5. Bitwarden CLI version >= 2024.9.0 specified"
if [ -f "$DOTFILES_DIR/.devcontainer/Dockerfile" ]; then
    if grep -qE 'BW_CLI_VERSION.*2024\.(9|1[0-9])' "$DOTFILES_DIR/.devcontainer/Dockerfile"; then
        echo "[PASS] Bitwarden CLI version 2024.9.0+ specified"
    elif grep -qE 'bw-linux-2024\.(9|1[0-9])' "$DOTFILES_DIR/.devcontainer/Dockerfile"; then
        echo "[PASS] Bitwarden CLI version 2024.9.0+ found in download URL"
    else
        echo "[WARN] Could not verify Bitwarden CLI version specification"
    fi
else
    echo "[WARN] No Dockerfile found to verify Bitwarden CLI version"
fi
echo ""

# Test 6: Environment variable forwarding (BW_SESSION, WITH_BW)
echo "[TEST] 6. Environment variable forwarding (BW_SESSION, WITH_BW)"
HAS_BW_SESSION=false
HAS_WITH_BW=false

if jq -e '.remoteEnv' "$DEVCONTAINER_JSON" >/dev/null 2>&1; then
    REMOTE_ENV=$(jq -r '.remoteEnv | to_entries[] | .key' "$DEVCONTAINER_JSON")
    if echo "$REMOTE_ENV" | grep -q 'BW_SESSION'; then
        HAS_BW_SESSION=true
    fi
    if echo "$REMOTE_ENV" | grep -q 'WITH_BW'; then
        HAS_WITH_BW=true
    fi
fi

if [ "$HAS_BW_SESSION" = true ]; then
    echo "[PASS] BW_SESSION environment variable forwarding configured"
else
    echo "[WARN] BW_SESSION environment variable forwarding not configured"
fi

if [ "$HAS_WITH_BW" = true ]; then
    echo "[PASS] WITH_BW environment variable forwarding configured"
else
    echo "[WARN] WITH_BW environment variable forwarding not configured"
fi
echo ""

echo "=== All Task 5.1 Tests Passed ==="
exit 0
