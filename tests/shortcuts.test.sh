#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

target_file="mk/shortcuts.mk"
allowed_targets=(
  i
  s
  c
  u
  m
  h
  claudecode
  s1
  s2
  s3
  s4
  s5
  ss
  sg
)

mapfile -t actual_targets < <(
  grep -E '^[A-Za-z0-9_-]+:' "$target_file" | cut -d: -f1 | sort -u
)
mapfile -t expected_targets < <(printf "%s\n" "${allowed_targets[@]}" | sort -u)

missing=()
unexpected=()

for name in "${expected_targets[@]}"; do
  if ! printf '%s\n' "${actual_targets[@]}" | grep -Fxq "$name"; then
    missing+=("$name")
  fi
done

for name in "${actual_targets[@]}"; do
  if ! printf '%s\n' "${expected_targets[@]}" | grep -Fxq "$name"; then
    unexpected+=("$name")
  fi
done

if ((${#missing[@]})); then
  echo "[FAIL] mk/shortcuts.mk に不足している短縮エイリアス: ${missing[*]}" >&2
fi

if ((${#unexpected[@]})); then
  echo "[FAIL] mk/shortcuts.mk に短縮エイリアス以外のターゲットが含まれています: ${unexpected[*]}" >&2
fi

if ((${#missing[@]} + ${#unexpected[@]})); then
  exit 1
fi

declare -A alias_map=(
  [i]="install"
  [s]="setup"
  [c]="check-cursor-version"
  [u]="update-cursor"
  [m]="menu"
  [h]="help"
  [claudecode]="install-superclaude"
  [s1]="stage1"
  [s2]="stage2"
  [s3]="stage3"
  [s4]="stage4"
  [s5]="stage5"
  [ss]="stage-status"
  [sg]="stage-guide"
)

for alias in "${!alias_map[@]}"; do
  expected="${alias_map[$alias]}"
  if ! grep -Eq "^${alias}:[[:space:]]+${expected}(\\b|[[:space:]])" "$target_file"; then
    echo "[FAIL] ${alias} -> ${expected} のエイリアス定義が見つかりません" >&2
    exit 1
  fi
done

echo "[PASS] mk/shortcuts.mk の短縮エイリアス定義は期待どおりです。"
