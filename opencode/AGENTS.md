# Global Agent Configuration

This configuration applies to ALL projects and overrides default agent behaviors.

## 🗣️ Core Language & Interaction
* **Language**: You MUST think, communicate, and output in **Japanese** (日本語), unless the user explicitly requests English.
* **Code Comments**: Write all inline code comments and documentation in **Japanese**.
* **Tone**: Technical, concise, and professional. Avoid excessive politeness; focus on engineering value.

## 🎨 Universal Coding Standards
* **Style Guide**: Strictly follow the [Google Style Guide](https://google.github.io/styleguide/) for the target language.
* **Linting**: If the project has a linter config (eslint, flake8, etc.), fixing linter errors takes precedence over general style guides.
* **Naming**: Use English for variable/function names. Use Japanese for descriptions/comments.

## 🗺️ Progressive Disclosure
For detailed operational standards, refer to the following global documents:

- **Git & PRs**: `~/.config/opencode/docs/global/GIT_STANDARDS.md` (Commit formats, PR templates)
- **Documentation**: `~/.config/opencode/docs/global/DOCS_STYLE.md` (README, Specs writing style)

> **Note**: If the current repository has its own `AGENTS.md`, rules defined there take precedence over these global settings.
