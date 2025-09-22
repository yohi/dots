#!/bin/bash

set -euo pipefail

# Add bun to the PATH if directory exists
if [ -d "${HOME}/.bun/bin" ]; then
    export PATH="${HOME}/.bun/bin:${PATH}"
fi

# Execute the ccusage command with robust error handling
if command -v bunx >/dev/null 2>&1; then
    bunx -y ccusage statusline --visual-burn-rate emoji
elif command -v bun >/dev/null 2>&1; then
    bun x ccusage statusline --visual-burn-rate emoji
else
    echo "❌ bun/bunx が見つかりません。先に 'make install-packages-ccusage' を実行してください。" >&2
    exit 1
fi
