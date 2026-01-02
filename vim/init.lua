-- =====================================================================================
-- init.lua - Neovim エントリポイント
-- =====================================================================================
-- 設計書 Phase 7: エントリポイントの完成
-- ロード順序: options → keymaps → autocmds → lazy
-- すべてのモジュールは pcall でラップし、エラー時もNeovimが起動できるようにする
-- =====================================================================================

local config_dir = vim.fn.stdpath("config")

-- 必要なディレクトリ構造を作成（冪等）
local required_dirs = {
  config_dir .. "/lua/config",
  config_dir .. "/lua/utils",
}
for _, dir in ipairs(required_dirs) do
  vim.fn.mkdir(dir, "p")
end

-- Leader キーの設定（プラグインロード前に実行する必要がある）
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- =====================================================================================
-- 設定モジュールのロード（順序厳守）
-- =====================================================================================

-- 1. 基本オプション設定
local ok_options, err_options = pcall(require, "config.options")
if not ok_options then
  vim.notify("Failed to load config.options: " .. tostring(err_options), vim.log.levels.ERROR)
end

-- 2. キーマップ設定
local ok_keymaps, err_keymaps = pcall(require, "config.keymaps")
if not ok_keymaps then
  vim.notify("Failed to load config.keymaps: " .. tostring(err_keymaps), vim.log.levels.ERROR)
end

-- 3. 自動コマンド設定
local ok_autocmds, err_autocmds = pcall(require, "config.autocmds")
if not ok_autocmds then
  vim.notify("Failed to load config.autocmds: " .. tostring(err_autocmds), vim.log.levels.ERROR)
end

-- 4. プラグイン管理 (lazy.nvim)
local ok_lazy, err_lazy = pcall(require, "lazy_bootstrap")
if not ok_lazy then
  vim.notify("Failed to load lazy.nvim: " .. tostring(err_lazy), vim.log.levels.ERROR)
end
