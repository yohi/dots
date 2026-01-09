-- =====================================================================================
-- keymaps.lua - General keymaps migrated from rc/keymap.vim
-- =====================================================================================

local keymap = vim.keymap.set

-- Normal Mode

-- [;]を[:]に変換
keymap("n", ";", ":", { desc = "Enter command mode with semicolon" })

-- 分割画面移動
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to bottom split" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to top split" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- 検索結果ハイライトを消去
keymap("n", "<ESC><ESC>", ":nohlsearch<CR>", { desc = "Clear search highlight" })

-- 縦分割
keymap("n", "<LocalLeader>v", ":vsp<CR>", { desc = "Vertical split" })

-- 横分割
keymap("n", "<Leader>s", ":split<CR>:ls<CR>:buf", { desc = "Horizontal split with buffer list" })

-- すべて選択
keymap("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Normal ModeでもEnterで改行
keymap("n", "<CR>", "o<ESC>", { desc = "Insert newline without entering insert mode" })

-- F5: バッファ一覧表示と移動先番号入力待ち
keymap("n", "<F5>", ":ls<CR>:buf", { desc = "List buffers and prompt for buffer number" })

-- F6: バッファを削除
keymap("n", "<F6>", ":bw<CR>", { desc = "Delete current buffer" })

-- F7: 前のバッファに移動
keymap("n", "<F7>", ":bp<CR>", { desc = "Previous buffer" })

-- F8: 次のバッファに移動
keymap("n", "<F8>", ":bn<CR>", { desc = "Next buffer" })

-- Insert Mode

-- 基本操作
keymap("i", "<C-a>", "<Home>", { desc = "Move to start of line" })
keymap("i", "<C-e>", "<End>", { desc = "Move to end of line" })
keymap("i", "<C-d>", "<Del>", { desc = "Delete character under cursor" })
keymap("i", "<C-b>", "<BS>", { desc = "Delete character before cursor" })
keymap("i", "<C-?>", "<BS>", { desc = "Delete character before cursor (alternate)" })
keymap("i", "<C-q>", "<C-^>", { desc = "Toggle language input" })
keymap("i", "<C-h>", "<Left>", { desc = "Move left" })
keymap("i", "<C-j>", "<Down>", { desc = "Move down" })
keymap("i", "<C-k>", "<Up>", { desc = "Move up" })
keymap("i", "<C-l>", "<Right>", { desc = "Move right" })

-- Command Mode

-- 基本操作
keymap("c", "<C-a>", "<Home>", { desc = "Move to start of command" })
keymap("c", "<C-e>", "<End>", { desc = "Move to end of command" })
keymap("c", "<C-d>", "<Del>", { desc = "Delete character under cursor" })
keymap("c", "<C-b>", "<BS>", { desc = "Delete character before cursor" })
keymap("c", "<C-q>", "<C-^>", { desc = "Toggle language input" })
keymap("c", "<C-h>", "<Left>", { desc = "Move left" })
keymap("c", "<C-j>", "<Down>", { desc = "Navigate command history (down)" })
keymap("c", "<C-k>", "<Up>", { desc = "Navigate command history (up)" })
keymap("c", "<C-l>", "<Right>", { desc = "Move right" })

-- 貼り付け
keymap("c", "<C-p>", "<C-r>+", { desc = "Paste from clipboard" })
