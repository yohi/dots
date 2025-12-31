# Vim/Neovim Development Steering

This document guides development for the Vim/Neovim configuration within the dotfiles.

## Project Structure

The configuration follows a hybrid structure supporting both Vimscript (legacy) and Lua (modern Neovim):

- `vim/init.vim`: Entry point. Sources `rc/*.vim` and `lua/*.lua`.
- `vim/rc/`: Vimscript configurations (Basic settings, Keymaps, UI).
- `vim/lua/`: Lua configurations (Plugin manager, LSP, Modern plugins).
- `vim/lua/plugins/`: Individual plugin specifications (Lazy.nvim).

## Configuration Patterns

### 1. Hybrid Loading
The `init.vim` acts as a bridge:
```vim
runtime! rc/*.vim  " Load legacy settings
runtime! lua/*.lua " Load modern Lua config
```

### 2. Plugin Management (Lazy.nvim)
- **Manager**: `lazy.nvim` configured in `vim/lua/lazy.lua`.
- **Declaration**: Plugins are defined in `vim/lua/plugins/*.lua`.
- **Pattern**: Return a table or list of tables from each plugin file.
```lua
return {
  "username/repo",
  config = function()
    -- setup code
  end
}
```

### 3. Setting Allocation
- **General Settings**: Place in `vim/rc/basic.vim` (standard vim options).
- **Key Mappings**: Place in `vim/rc/keymap.vim` (general maps) or plugin config (plugin specific).
- **LSP/Autocompletion**: Managed via `lua/lsp.lua` and `lua/plugins/lsp_*.lua`.

### 4. Integration Patterns
- **WezTerm IME**: Specific integration handling in `vim/rc/basic.vim` for WezTerm user vars.
- **AI Tools**: Configurations for Copilot, Avante, etc., reside in `vim/lua/plugins/`.

## Best Practices

- **New Plugins**: Always use Lua and `lazy.nvim` specs in `vim/lua/plugins/`.
- **Performance**: Use `event` or `cmd` keys in lazy specs to defer loading.
- **Compatibility**: Keep `rc/` files compatible with standard Vim where possible, but prioritize Neovim for `lua/`.
- **File Encoding**: UTF-8 is strictly enforced.
