#!/bin/bash

# このスクリプトは、GitHub Actions の CI/CD ワークフローファイル (.github/workflows/ci.yml) を生成します。
# PR作成時にLintチェックなどの基本的なテストを実行するためのものです。

set -euo pipefail

WORKFLOW_DIR=".github/workflows"
WORKFLOW_FILE="${WORKFLOW_DIR}/ci.yml"

# ワークフローディレクトリの作成
if [ ! -d "${WORKFLOW_DIR}" ]; then
  mkdir -p "${WORKFLOW_DIR}"
  echo "Created directory: ${WORKFLOW_DIR}"
fi

# ワークフローファイルの生成
cat <<EOF > "${WORKFLOW_FILE}"
name: CI

on:
  pull_request:

jobs:
  lint:
    # 1 vCPU Linux runner (ubuntu-slim) is used for cost efficiency.
    # See: https://github.blog/changelog/2025-10-28-1-vcpu-linux-runner-now-available-in-github-actions-in-public-preview/
    runs-on: ubuntu-slim
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install ShellCheck
        run: sudo apt-get update && sudo apt-get install -y shellcheck

      - name: Run ShellCheck
        run: shellcheck switch-opencode-pattern.sh
EOF

echo "Generated GitHub Actions workflow: ${WORKFLOW_FILE}"
echo "This workflow uses 'ubuntu-slim' runner as per best practices for lightweight tasks."
echo "Reference: https://github.blog/changelog/2025-10-28-1-vcpu-linux-runner-now-available-in-github-actions-in-public-preview/"
