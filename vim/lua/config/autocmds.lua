-- =====================================================================================
-- autocmds.lua: Autocommand definitions migrated from rc/basic.vim
-- =====================================================================================

-- JSON syntax highlighting optimization
-- Disable syntax highlighting for large JSON files (>1000 lines)
local json_highlight_group = vim.api.nvim_create_augroup("VimrcHighlight", { clear = true })
vim.api.nvim_create_autocmd("Syntax", {
  group = json_highlight_group,
  pattern = "json",
  callback = function()
    if vim.fn.line("$") > 1000 then
      vim.cmd("syntax off")
    end
  end,
  desc = "Disable syntax highlighting for large JSON files",
})

-- Various file-type settings
local various_autocmd_group = vim.api.nvim_create_augroup("MyVariousAutoCommand", { clear = true })

-- Disable automatic line wrapping
vim.api.nvim_create_autocmd("FileType", {
  group = various_autocmd_group,
  pattern = "*",
  callback = function()
    vim.opt_local.textwidth = 0
  end,
  desc = "Disable automatic line wrapping",
})

-- Disable automatic comment insertion on new lines
vim.api.nvim_create_autocmd("FileType", {
  group = various_autocmd_group,
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
  desc = "Disable automatic comment insertion",
})

-- Auto-change directory to file's directory
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufEnter" }, {
  group = various_autocmd_group,
  pattern = "*",
  callback = function()
    local filepath = vim.fn.expand("%:p:h")
    if filepath ~= "" then
      vim.cmd("lcd " .. vim.fn.fnameescape(filepath))
    end
  end,
  desc = "Change directory to file's directory",
})

-- WezTerm IME integration
-- Only enable if running in WezTerm
if vim.env.TERM_PROGRAM == "WezTerm" then
  local wezterm_ime_group = vim.api.nvim_create_augroup("WezTermIME", { clear = true })

  -- Helper function to encode a string to base64 (pure Lua implementation)
  local function base64_encode(data)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = {}
    
    -- Process every 3 bytes
    for i = 1, #data, 3 do
      local byte1 = string.byte(data, i)
      local byte2 = string.byte(data, i + 1)
      local byte3 = string.byte(data, i + 2)
      
      -- Combine the 3 bytes into a 24-bit number
      local combined = bit.lshift(byte1, 16) + bit.lshift(byte2 or 0, 8) + (byte3 or 0)
      
      -- Extract four 6-bit groups
      local b1 = bit.rshift(bit.band(combined, 0xFC0000), 18) + 1
      local b2 = bit.rshift(bit.band(combined, 0x03F000), 12) + 1
      local b3 = bit.rshift(bit.band(combined, 0x000FC0), 6) + 1
      local b4 = bit.band(combined, 0x00003F) + 1
      
      table.insert(result, string.sub(b64chars, b1, b1))
      table.insert(result, string.sub(b64chars, b2, b2))
      table.insert(result, byte2 and string.sub(b64chars, b3, b3) or "=")
      table.insert(result, byte3 and string.sub(b64chars, b4, b4) or "=")
    end
    
    return table.concat(result)
  end
  
  -- Helper function to set WezTerm user variable for IME control
  local function set_wezterm_mode(mode)
    -- Base64-encode the mode value as required by WezTerm SetUserVar
    local encoded_mode = base64_encode(mode)
    vim.fn.system(string.format('printf "\\033]1337;SetUserVar=NVIM_MODE=%s\\007"', encoded_mode))
  end

  -- Normal mode: IME OFF
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = wezterm_ime_group,
    callback = function()
      set_wezterm_mode("n")
    end,
    desc = "WezTerm: Set IME OFF on leaving insert mode",
  })

  -- Insert mode: IME ON
  vim.api.nvim_create_autocmd("InsertEnter", {
    group = wezterm_ime_group,
    callback = function()
      set_wezterm_mode("i")
    end,
    desc = "WezTerm: Set IME ON on entering insert mode",
  })

  -- Command-line mode: IME ON
  vim.api.nvim_create_autocmd("CmdlineEnter", {
    group = wezterm_ime_group,
    callback = function()
      set_wezterm_mode("c")
    end,
    desc = "WezTerm: Set IME ON on entering command-line mode",
  })

  -- Leaving command-line mode: IME OFF
  vim.api.nvim_create_autocmd("CmdlineLeave", {
    group = wezterm_ime_group,
    callback = function()
      set_wezterm_mode("n")
    end,
    desc = "WezTerm: Set IME OFF on leaving command-line mode",
  })

  -- Vim startup: Normal mode (IME OFF)
  vim.api.nvim_create_autocmd("VimEnter", {
    group = wezterm_ime_group,
    callback = function()
      set_wezterm_mode("n")
    end,
    desc = "WezTerm: Set IME OFF on Neovim startup",
  })
end
