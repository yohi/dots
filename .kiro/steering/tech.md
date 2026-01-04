# Technology Stack & Decisions

## Core Stack
- **OS**: Ubuntu Linux (20.04 LTS and newer).
- **Orchestration**: GNU Make (central task runner), Bash scripts.
- **Package Management**:
  - **Homebrew (Linux)**: Primary for dev tools and CLI utilities.
  - **APT**: System-level dependencies and GUI basics.
  - **Flatpak**: GUI applications.

## Development Environment
- **Shell**: Zsh with Powerlevel10k theme and plugins.
- **Editors**:
  - **Neovim**: Lua-based configuration.
  - **VS Code**: JSON settings and extension lists.
  - **Cursor**: AI-native editor configuration.
  - **Claude Code**: Integrated via `cc-sdd` and custom make targets.

## Architecture Patterns
- **Makefile as CLI**: All operations are exposed via `make` targets (e.g., `make setup-vim`, `make install-apps`).
- **Modular Makefiles**: Task definitions are split into `mk/*.mk` by domain (system, fonts, vscode, etc.) and aggregated in the root `Makefile`.
- **Idempotency**: Scripts and make targets should be safe to re-run (checking for existence before installing).
- **Configuration Isolation**: Configs for each tool reside in their own directories (`vim/`, `zsh/`, `cursor/`) to be symlinked or copied.
