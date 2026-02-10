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

## 6. Available Skills
<available_skills>
  <skill>
    <name>git-pr-flow</name>
    <description>Handles pull request creation flow including committing, pushing, and PR creation using GitHub CLI.</description>
    When this skill is invoked with `{{user_message}}`, follow these steps:
    1. **Analyze Context**:
       - Extract any specific instructions from `{{user_message}}`.
       - Check if the user wants to skip committing (e.g., "skip commit", "already committed").
       - Check if the user wants to skip pushing (e.g., "skip push", "already pushed").
       - Identify the target (base) branch if specified (e.g., "to develop", "base master"). Default to the repository's default branch if not specified.
       - Check if this is a "resume" operation to continue a previous failed or interrupted PR flow.
    2. **Standards Compliance**:
       - Strictly follow the standards defined in `opencode/docs/global/GIT_STANDARDS.md`.
       - Use Japanese (日本語) for commit messages and PR titles/descriptions.
       - Use Conventional Commits format for the PR title.
    3. **Execution Flow**:
       - **Commit**: Unless skipped, stage changes and create atomic commits following the Conventional Commits standard.
       - **Push**: Unless skipped, push the current branch to the remote (`origin`). Use `-u` if it's a new branch.
       - **PR Creation**: Use `gh pr create` to create the pull request.
         - Use a descriptive title based on the commits.
         - Generate a summary for the PR body (What and Why) as per `GIT_STANDARDS.md`.
         - Specify the `--base` branch if a target branch was identified.
    4. **Verification**:
       - Confirm the PR URL and provide it to the user.
       - Ensure all steps are logged and marked as completed in the todo list.
  </skill>
</available_skills>
