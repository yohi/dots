# Project Structure

## Directory Organization

### Root Level
- `Makefile`: The main entry point for all setup commands.
- `install.sh`: The bootstrapping script for curl-pipe-bash installation.
- `.kiro/`: AI Project Memory (Steering, Specs).

### Configuration Modules
- `mk/`: Contains modular Makefile includes (`system.mk`, `fonts.mk`, `vscode.mk`, etc.).
- `scripts/`: Helper shell scripts for complex logic (e.g., `check-setup.sh`, `memory-optimization.sh`).

### Application Configurations
Each directory contains dotfiles/configs for a specific tool:
- `vim/`: Neovim configuration (`init.lua`).
- `zsh/`: Zsh runcoms and scripts.
- `vscode/`, `cursor/`: Editor settings and extension lists.
- `gnome-*/`: GNOME desktop environment settings (shortcuts, extensions).
- `wezterm/`: Terminal emulator config.

### Documentation
- `README.md`: User-facing documentation.
- `docs/`: Detailed guides (memory optimization, performance reports).

## Conventions
- **Make Targets**: Use hyphen-case (e.g., `setup-vim`, `install-homebrew`).
- **Scripts**: Executable shell scripts should be in `scripts/` or specific app folders if local.
- **Steering**: Update `.kiro/steering/` when adding new top-level components or changing architectural patterns.
