local config_dir = vim.fn.stdpath("config")
local legacy_init = config_dir .. "/init.vim"

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

-- lazy.nvim プラグインマネージャーの読み込み
local ok, err = pcall(require, "lazy")
if not ok then
  vim.notify("Failed to load lazy.nvim: " .. tostring(err), vim.log.levels.ERROR)
end

-- 移行済みの設定モジュールを読み込む
-- Phase 4.2: Autocmd migration
local ok_autocmds, err_autocmds = pcall(require, "config.autocmds")
if not ok_autocmds then
  vim.notify("Failed to load config.autocmds: " .. tostring(err_autocmds), vim.log.levels.ERROR)
end


-- レガシーinit.vimの読み込み（互換性モード）
if vim.fn.filereadable(legacy_init) == 1 then
  vim.cmd.source(vim.fn.fnameescape(legacy_init))
else
  vim.notify("legacy init.vim was not found; compatibility mode skipped", vim.log.levels.WARN)
end
