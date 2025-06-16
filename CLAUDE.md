# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration (dotfiles) repository using Lazy.nvim as the plugin manager. The configuration focuses on development productivity with AI assistance, LSP integration, and modern Neovim features.

## Key Architecture

- **Plugin Management**: Uses Lazy.nvim with plugin specifications in `vim/lua/plugins/`
- **Configuration Structure**: 
  - `vim/init.vim` - Entry point that loads all rc/ and lua/ files
  - `vim/rc/` - Traditional Vim configuration files (basic.vim, keymap.vim, etc.)
  - `vim/lua/` - Lua-based configuration (lazy.lua, lsp.lua)
  - `vim/lua/plugins/` - Individual plugin configurations

## AI Integration

The configuration includes multiple AI assistants:
- **Avante** (`avante.lua`) - Configured with Copilot provider using Claude Sonnet 4 model
- **Claude Code** (`claude-code.lua`) - Direct Claude Code integration 
- **GitHub Copilot** - Multiple Copilot-related plugins for code completion

## LSP Configuration

LSP setup is primarily in `vim/lua/lsp.lua` with:
- Diagnostic configuration with floating windows and custom signs
- Key mappings for LSP functions (hover, references, definition, etc.)
- Auto-hover diagnostics on cursor hold
- Commented-out server configurations (Python, Bash, Docker, etc.) for reference

## Important Configuration Details

- Uses space as leader key (`vim.g.mapleader = " "`)
- 4-space indentation by default (expandtab, shiftwidth=4, tabstop=4)
- No swap files, undo files, or backup files
- Clipboard integration enabled
- Auto-indent and smart-indent enabled
- Custom key mappings in `vim/rc/keymap.vim` including split navigation and buffer management

## Plugin Management Commands

Since this uses Lazy.nvim:
- `:Lazy` - Open Lazy.nvim interface
- `:Lazy update` - Update all plugins
- `:Lazy clean` - Remove unused plugins
- `:Lazy check` - Check for plugin updates

## Development Notes

- The configuration disables Python2, Ruby, and Perl providers for performance
- Custom auto-commands prevent auto-commenting and set proper text width
- Buffer management with F5-F8 function keys
- Leader-based window splitting commands