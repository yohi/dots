local config_dir = vim.fn.stdpath("config")
local legacy_init = config_dir .. "/init.vim"

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.fn.filereadable(legacy_init) == 1 then
  vim.cmd("source " .. legacy_init)
else
  vim.notify("legacy init.vim was not found; compatibility mode skipped", vim.log.levels.WARN)
end
