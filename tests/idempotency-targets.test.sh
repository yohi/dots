#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v rg >/dev/null 2>&1; then
	echo "rg is required for this test"
	exit 1
fi

assert_pattern() {
	local file="$1"
	local pattern="$2"
	local desc="$3"

	if ! rg -n "$pattern" "$ROOT_DIR/$file" >/dev/null; then
		echo "Expected $desc"
		echo "  file: $file"
		echo "  pattern: $pattern"
		exit 1
	fi
}

cases=(
	"mk/install.mk|IDEMPOTENCY_SKIP_MSG,install-packages-homebrew|install-packages-homebrew skip message"
	"mk/install.mk|IDEMPOTENCY_SKIP_MSG,install-packages-apps|install-packages-apps skip message"
	"mk/install.mk|IDEMPOTENCY_SKIP_MSG,install-packages-deb|install-packages-deb skip message"
	"mk/setup.mk|IDEMPOTENCY_SKIP_MSG,setup-config-vim|setup-config-vim skip message"
	"mk/setup.mk|IDEMPOTENCY_SKIP_MSG,setup-config-zsh|setup-config-zsh skip message"
	"mk/setup.mk|IDEMPOTENCY_SKIP_MSG,setup-config-git|setup-config-git skip message"
	"mk/system.mk|IDEMPOTENCY_SKIP_MSG,setup-system|setup-system skip message"
	"mk/bitwarden.mk|IDEMPOTENCY_SKIP_MSG,setup-config-secrets|setup-config-secrets skip message"
	"mk/codex.mk|IDEMPOTENCY_SKIP_MSG,codex|codex skip message"
	"mk/superclaude.mk|IDEMPOTENCY_SKIP_MSG,install-superclaude|install-superclaude skip message"
	"mk/cc-sdd.mk|IDEMPOTENCY_SKIP_MSG,cc-sdd-install|cc-sdd-install skip message"
)

for entry in "${cases[@]}"; do
	IFS='|' read -r file pattern desc <<< "$entry"
	assert_pattern "$file" "$pattern" "$desc"
done

marker_cases=(
	"mk/system.mk|check_marker,setup-system|setup-system marker check"
	"mk/system.mk|create_marker,setup-system|setup-system marker create"
	"mk/bitwarden.mk|check_marker,setup-config-secrets|setup-config-secrets marker check"
	"mk/bitwarden.mk|create_marker,setup-config-secrets|setup-config-secrets marker create"
)

for entry in "${marker_cases[@]}"; do
	IFS='|' read -r file pattern desc <<< "$entry"
	assert_pattern "$file" "$pattern" "$desc"
done

echo "All idempotency target checks passed."
