# Vim/Neovim Development Steering

This document guides development for the Vim/Neovim configuration within the dotfiles.

## Project Structure

The configuration is now fully Lua-based, following modern Neovim patterns:

- `vim/init.lua`: Entry point. Loads config modules and lazy.nvim in order.
- `vim/lua/config/`: Configuration modules (options, keymaps, autocmds).
- `vim/lua/plugins/`: Individual plugin specifications (Lazy.nvim).
- `vim/lua/utils/`: Utility modules (e.g., apikey.lua).
- `vim/lua/lazy_bootstrap.lua`: Lazy.nvim bootstrap and setup.

### Load Order (Strictly Enforced)
1. `config/options.lua` - Basic Neovim options
2. `config/keymaps.lua` - General keymaps
3. `config/autocmds.lua` - Autocommands
4. `lazy_bootstrap.lua` - Plugin manager initialization

## Configuration Patterns

### 1. Module Loading
All modules are loaded via `pcall` for resilience:
```lua
local ok, err = pcall(require, "config.options")
if not ok then
  vim.notify("Failed to load config.options: " .. tostring(err), vim.log.levels.ERROR)
end
```

### 2. Plugin Management (Lazy.nvim)
- **Manager**: `lazy.nvim` configured in `vim/lua/lazy_bootstrap.lua`.
- **Declaration**: Plugins are defined in `vim/lua/plugins/*.lua`.
- **Pattern**: Return a table or list of tables from each plugin file.
- **Auto-update disabled**: `checker = { enabled = false }` (Requirement 4.3)
```lua
return {
  "username/repo",
  config = function()
    -- setup code
  end
}
```

### 3. Setting Allocation
- **General Settings**: Place in `vim/lua/config/options.lua`.
- **Key Mappings**: Place in `vim/lua/config/keymaps.lua` (general) or plugin config (plugin specific).
- **Autocommands**: Place in `vim/lua/config/autocmds.lua`.
- **LSP/Autocompletion**: Managed via `lua/plugins/lsp_cfg.lua`.

### 4. API Key Management
Use `utils/apikey.lua` for secure API key retrieval:
```lua
local apikey = require("utils.apikey")
local result = apikey.get_api_key("OPENAI_API_KEY", "OpenAI Plugin")
if result.valid then
  -- use result.key
end
```

### 5. Integration Patterns
- **WezTerm IME**: Integration in `vim/lua/config/autocmds.lua`.
- **AI Tools**: Configurations for Copilot, Avante, etc., in `vim/lua/plugins/`.

## Best Practices

- **New Plugins**: Always use Lua and `lazy.nvim` specs in `vim/lua/plugins/`.
- **Performance**: Use `event` or `cmd` keys in lazy specs to defer loading.
- **Error Handling**: All require calls should be wrapped in pcall.
- **API Keys**: Never hardcode; use environment variables via `utils/apikey.lua`.
- **Security**: `exrc = false`, `secure = true` to prevent external script execution.
- **File Encoding**: UTF-8 is strictly enforced.

## Legacy Files (Deprecated)
The following files are deprecated and kept only for rollback purposes:
- `vim/init.vim.bak` - Legacy Vim script entry point
- `vim/lua/lsp.lua.bak` - Legacy LSP configuration
