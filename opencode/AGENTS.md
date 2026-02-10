# AI Agent Guidelines for `dots` Repository

## 1. Project Overview
This repository contains dotfiles and setup scripts for building a comprehensive Ubuntu development environment (Zsh, Neovim, VS Code, etc.).
**Key Principles:** Modularity, Idempotency, and Japanese Localization.

## 2. Language Policy (CRITICAL)
- **Output Language**: **ALWAYS** use **Japanese (日本語)** for all external communication (Commits, Docs, Comments, Chat).
- **EXCEPTION**: `AGENTS.md` and `docs/rules/*.md` must be written in English for LLM precision.
- **Thinking**: You may think in English, but output must be Japanese.

## 3. Operations & Commands
- **Install**: `./install.sh` or `make setup-all`
- **Test**: `make test` (Unit + Mock), `./scripts/check-setup.sh` (Health Check)
- **Lint**:
  - Shell: `shellcheck`
  - Markdown: `markdownlint-cli2` (See `docs/rules/MARKDOWN.md`)

## 4. Documentation & Rules Map
The agent **MUST** read the specific rule file before editing corresponding file types.

| Context | Rule File |
| :--- | :--- |
| **Markdown / Docs** | [`docs/rules/MARKDOWN.md`](docs/rules/MARKDOWN.md) |
| **Shell Scripts** | [`docs/rules/SHELL.md`](docs/rules/SHELL.md) |
| **Makefiles** | [`.cursor/rules/makefile-organization.mdc`](.cursor/rules/makefile-organization.mdc) |
| **SDD Workflow** | `.kiro/steering/*.md` |

## 5. Agent Behavior Checklist
- [ ] Validated with `markdownlint-cli2` when editing docs?
- [ ] Used Japanese for user-facing text?
- [ ] Verified `Makefile` target with `make -n`?
- [ ] Checked `check_marker` for heavy tasks?
