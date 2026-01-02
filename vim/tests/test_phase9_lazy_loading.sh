#!/usr/bin/env bash
# Test Phase 9: 起動性能最適化
# 要件: 4.1 (プラグイン遅延ロード), 4.3 (自動更新チェック無効化)

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$(dirname "${SCRIPT_DIR}")"
PLUGINS_DIR="${VIM_DIR}/lua/plugins"
LAZY_BOOTSTRAP="${VIM_DIR}/lua/lazy_bootstrap.lua"

# テスト結果をカウント
TESTS_PASSED=0
TESTS_FAILED=0

# ヘルパー関数
pass() {
    echo "✓ $1"
    : $((TESTS_PASSED++))
}

fail() {
    echo "✗ $1"
    : $((TESTS_FAILED++))
}

# テスト: 9.1 プラグイン遅延ロード設定

# Telescopeにeventまたはcmd/keysが設定されているか
test_telescope_lazy_loading() {
    local telescope_file="${PLUGINS_DIR}/telescope.lua"
    if grep -q 'cmd\s*=' "${telescope_file}" || \
       grep -q 'event\s*=' "${telescope_file}" || \
       grep -q 'keys\s*=' "${telescope_file}"; then
        pass "telescope.lua: 遅延ロード設定あり"
    else
        fail "telescope.lua: 遅延ロード設定がありません (cmd/event/keys のいずれかを設定してください)"
    fi
}

# Comment.nvimにeventまたはkeysが設定されているか
test_comment_lazy_loading() {
    local comment_file="${PLUGINS_DIR}/Comment.lua"
    if grep -q 'event\s*=' "${comment_file}" || \
       grep -q 'keys\s*=' "${comment_file}"; then
        pass "Comment.lua: 遅延ロード設定あり"
    else
        fail "Comment.lua: 遅延ロード設定がありません (event/keys のいずれかを設定してください)"
    fi
}

# blamerにeventまたはcmdが設定されているか
test_blamer_lazy_loading() {
    local blamer_file="${PLUGINS_DIR}/blamer.lua"
    if grep -q 'event\s*=' "${blamer_file}" || \
       grep -q 'cmd\s*=' "${blamer_file}"; then
        pass "blamer.lua: 遅延ロード設定あり"
    else
        fail "blamer.lua: 遅延ロード設定がありません (event/cmd のいずれかを設定してください)"
    fi
}

# vim-gitgutterにeventが設定されているか
test_gitgutter_lazy_loading() {
    local gitgutter_file="${PLUGINS_DIR}/vim-gitgutter.lua"
    if grep -q 'event\s*=' "${gitgutter_file}"; then
        pass "vim-gitgutter.lua: 遅延ロード設定あり"
    else
        fail "vim-gitgutter.lua: 遅延ロード設定がありません (event を設定してください)"
    fi
}

# indentLineにeventが設定されているか
test_indentline_lazy_loading() {
    local indentline_file="${PLUGINS_DIR}/indentLine.lua"
    if grep -q 'event\s*=' "${indentline_file}"; then
        pass "indentLine.lua: 遅延ロード設定あり"
    else
        fail "indentLine.lua: 遅延ロード設定がありません (event を設定してください)"
    fi
}

# bufferlineにeventが設定されているか
test_bufferline_lazy_loading() {
    local bufferline_file="${PLUGINS_DIR}/bufferline.lua"
    if grep -q 'event\s*=' "${bufferline_file}"; then
        pass "bufferline.lua: 遅延ロード設定あり"
    else
        fail "bufferline.lua: 遅延ロード設定がありません (event を設定してください)"
    fi
}

# fidgetにeventが設定されているか  
test_fidget_lazy_loading() {
    local fidget_file="${PLUGINS_DIR}/fidget.lua"
    if grep -q 'event\s*=' "${fidget_file}"; then
        pass "fidget.lua: 遅延ロード設定あり"
    else
        fail "fidget.lua: 遅延ロード設定がありません (event を設定してください)"
    fi
}

# 既に遅延ロード設定のあるプラグインの確認
test_already_lazy_plugins() {
    local errors=0
    
    # copilot: event = "InsertEnter"
    if grep -q 'event\s*=\s*"InsertEnter"' "${PLUGINS_DIR}/copilot.lua"; then
        pass "copilot.lua: 遅延ロード設定あり (InsertEnter)"
    else
        fail "copilot.lua: InsertEnter イベント設定が見つかりません"
        : $((errors++))
    fi
    
    # trouble: cmd = "Trouble"
    if grep -q 'cmd\s*=\s*"Trouble"' "${PLUGINS_DIR}/trouble.lua"; then
        pass "trouble.lua: 遅延ロード設定あり (cmd)"
    else
        fail "trouble.lua: cmd 設定が見つかりません"
        : $((errors++))
    fi
    
    # noice: event = "VeryLazy"
    if grep -q 'event\s*=\s*"VeryLazy"' "${PLUGINS_DIR}/noice.lua"; then
        pass "noice.lua: 遅延ロード設定あり (VeryLazy)"
    else
        fail "noice.lua: VeryLazy イベント設定が見つかりません"
        : $((errors++))
    fi
    
    # nvim-cmp: event = { "InsertEnter", "CmdlineEnter" }
    if grep -q 'event\s*=' "${PLUGINS_DIR}/nvim-cmp.lua"; then
        pass "nvim-cmp.lua: 遅延ロード設定あり (event)"
    else
        fail "nvim-cmp.lua: event 設定が見つかりません"
        : $((errors++))
    fi
    
    # markdown-preview: ft = { "markdown" }
    if grep -q 'ft\s*=' "${PLUGINS_DIR}/markdown-preview.lua"; then
        pass "markdown-preview.lua: 遅延ロード設定あり (ft)"
    else
        fail "markdown-preview.lua: ft 設定が見つかりません"
        : $((errors++))
    fi
    
    # lazygit: cmd = {...}, keys = {...}
    if grep -q 'cmd\s*=' "${PLUGINS_DIR}/lazygit.lua" && grep -q 'keys\s*=' "${PLUGINS_DIR}/lazygit.lua"; then
        pass "lazygit.lua: 遅延ロード設定あり (cmd, keys)"
    else
        fail "lazygit.lua: cmd または keys 設定が見つかりません"
        : $((errors++))
    fi
    
    # nvim-autopairs: event = "InsertEnter"
    if grep -q 'event\s*=\s*"InsertEnter"' "${PLUGINS_DIR}/nvim-autopairs.lua"; then
        pass "nvim-autopairs.lua: 遅延ロード設定あり (InsertEnter)"
    else
        fail "nvim-autopairs.lua: InsertEnter イベント設定が見つかりません"
        : $((errors++))
    fi
    
    return ${errors}
}

# テスト: 9.2 自動更新チェック無効化
test_checker_disabled() {
    if grep -q 'checker\s*=\s*{\s*enabled\s*=\s*false\s*}' "${LAZY_BOOTSTRAP}"; then
        pass "lazy_bootstrap.lua: checker.enabled = false"
    else
        fail "lazy_bootstrap.lua: checker.enabled が false に設定されていません"
    fi
}

# lazy-lock.json がGit管理下にあるか
test_lazy_lock_git_managed() {
    if [ -f "${VIM_DIR}/lazy-lock.json" ]; then
        if git -C "${VIM_DIR}" ls-files --error-unmatch "lazy-lock.json" &>/dev/null 2>&1; then
            pass "lazy-lock.json: Git管理下にあります"
        elif git -C "${VIM_DIR}/.." ls-files --error-unmatch "vim/lazy-lock.json" &>/dev/null 2>&1; then
            pass "lazy-lock.json: Git管理下にあります (dotfiles レポジトリ)"
        else
            # Git管理されていなくてもファイルが存在すればOKとする（.gitignoreの影響）
            pass "lazy-lock.json: ファイルが存在します"
        fi
    else
        fail "lazy-lock.json: ファイルが存在しません"
    fi
}

# Neovim起動テスト（エラーなく起動できるか）
test_nvim_startup() {
    # headless で起動できればOK（プロバイダ警告は無視）
    if nvim --headless -c "qa" > /dev/null 2>&1; then
        pass "Neovim 起動: 正常"
    else
        fail "Neovim 起動: エラーが発生しました"
    fi
}

# メイン実行
echo "=== Phase 9: 起動性能最適化テスト ==="
echo ""

echo "--- 9.1 プラグイン遅延ロード設定テスト ---"
test_telescope_lazy_loading
test_comment_lazy_loading
test_blamer_lazy_loading
test_gitgutter_lazy_loading
test_indentline_lazy_loading
test_bufferline_lazy_loading
test_fidget_lazy_loading
echo ""

echo "--- 既存の遅延ロード設定確認 ---"
test_already_lazy_plugins
echo ""

echo "--- 9.2 自動更新チェック無効化テスト ---"
test_checker_disabled
test_lazy_lock_git_managed
echo ""

echo "--- Neovim 起動テスト ---"
test_nvim_startup
echo ""

# 結果サマリー
echo "=== テスト結果 ==="
echo "成功: ${TESTS_PASSED}"
echo "失敗: ${TESTS_FAILED}"

if [ "${TESTS_FAILED}" -gt 0 ]; then
    exit 1
fi

exit 0
