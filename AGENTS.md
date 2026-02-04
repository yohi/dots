# AI Agent Guidelines for `dots` Repository

## 1. Project Overview
This repository contains dotfiles and setup scripts for building a comprehensive Ubuntu development environment. It aims to provide a fully automated setup for tools like Zsh, Neovim, VS Code, Cursor, Docker, and GNOME.

**Key Principles:**
- **Modularity**: Configuration is split into manageable chunks (Makefiles in `mk/`).
- **Idempotency**: Scripts should be safe to run multiple times (`idempotency.mk`).
- **Japanese Localization**: The environment is optimized for Japanese users (fonts, IME).

## 2. Language Policy (CRITICAL)
- **Output Language**: **ALWAYS** use **Japanese (日本語)** for all external communication, including:
  - Code comments
  - Git commit messages
  - Documentation (Markdown files)
  - Interactive responses to the user
  - `echo` messages in scripts/Makefiles
- **Thinking Process**: You may think/reason in English for precision, but the final result must be Japanese.

## 3. Build & Test Commands

### Setup & Install
There is no traditional "build" step. The primary action is "setup" or "install".
- **Full Setup**: `make setup-all` (Recommended for comprehensive testing)
- **Install Apps**: `make install-apps`
- **One-liner**: `./install.sh`

### Testing
- **Run All Tests**: `make test` (Runs unit and mock tests)
- **Run Unit Tests**: `make test-unit`
- **Run Mock Tests**: `make test-bw-mock` (Bitwarden mock tests)
- **Run Integration Tests**: `make test-bw-integration` (Requires `BW_SESSION`)
- **Verify Environment**: `./scripts/check-setup.sh` (Checks system health, packages, configs)

### Linting
- Shell scripts should be linted with `shellcheck` (if available).
- Makefiles are checked implicitly by `make`.

## 4. Code Style & Conventions

### Makefile Organization (`.cursor/rules/makefile-organization.mdc`)
- **Directory**: All partial Makefiles go in `mk/`.
- **Naming**:
  - Files: kebab-case, lowercase (e.g., `sticky-keys.mk`). No underscores (`_`).
  - Targets: `verb-noun` (e.g., `setup-vim`, `install-homebrew`).
  - Variables: `UPPER_CASE_WITH_UNDERSCORES` (e.g., `DOTFILES_DIR`).
- **Structure**:
  - **Core**: `variables.mk`, `idempotency.mk`, `help.mk`
  - **Functional**: `system.mk`, `fonts.mk`, `install.mk`, etc.
  - **Meta**: `main.mk`, `test.mk`
- **Output**: Use emojis and Japanese in `@echo`.
  - Start: `🚀 ...`
  - Success: `✅ ...`
  - Warning: `⚠️ ...`
  - Error: `❌ ...`
  - Skip: `[SKIP] ...`
- **Idempotency**: Use `check_marker` and `create_marker` macros for heavy tasks.

### Shell Scripts (`scripts/*.sh`)
- **Shebang**: `#!/bin/bash`
- **Safety**: Always use `set -euo pipefail` at the start.
- **Output**: Use colored output for logs (Info=Blue, Success=Green, Warn=Yellow, Error=Red).
- **Structure**: Define functions for logical blocks. Use `main` function at the end.

### Config Files
- **JSON**: Standard formatting (VS Code, Cursor settings).
- **Git**: Commits should follow conventional commits but in Japanese (e.g., `feat: 日本語フォントの自動インストール機能を追加`).

## 5. Directory Structure
- `mk/`: Split Makefiles.
- `scripts/`: Helper shell scripts (e.g., `check-setup.sh`).
- `vim/`, `zsh/`, `vscode/`, `cursor/`: Tool-specific configurations.
- `.kiro/`: Spec-Driven Development (SDD) files.
- `docs/`: Documentation and images.

## 6. Spec-Driven Development (SDD)
This project uses a Spec-Driven Development workflow powered by `cc-sdd` (Claude Code).
- **Specs**: Located in `.kiro/specs/`.
- **Workflow**: Requirements → Design → Tasks → Implementation.
- **Commands**: If you are acting as an agent within this workflow, respect the `.kiro/steering/` documents (`product.md`, `tech.md`, `structure.md`).

## 7. Cursor & Copilot Rules
- **Makefile Rules**: Strictly follow `.cursor/rules/makefile-organization.mdc` when editing Makefiles.
- **Copilot**: If strictly following existing patterns, check surrounding code.

## 8. Agent Behavior Checklist
- [ ] Did I verify the `Makefile` target works with `make -n <target>` (dry run) if uncertain?
- [ ] Am I using Japanese for all user-facing text?
- [ ] Did I check `mk/idempotency.mk` before adding a new heavy installation task?
- [ ] Did I run `./scripts/check-setup.sh` to verify the environment state?
