# Project Initialization Profile for cc-sdd

## 1. Project Overview (for /kiro:spec-init)

Run the following command to initialize the project:
Makefileの構造的リファクタリングを行い、Bitwarden CLI連携によるセキュアな自動化フローとDevcontainer内での完全なテスト環境を構築する。

## 2. Requirements Draft (for requirements.md)

以下の要件定義は **EARS (Easy Approach to Requirements Syntax)** に基づいています。

### Functional Requirements

* **The System shall** unify command terminology (e.g., distinguishing strictly between `setup`, `install`, and `deploy`) across all Makefiles.
* **The System shall** use **Bitwarden CLI** to securely retrieve authentication tokens for tasks requiring external authorization (e.g., AWS, GitHub).
* **The System shall** reorganize the existing `mk/` directory structure into logical layers (e.g., System, Apps, Tools) to improve maintainability.
* **The System shall** utilize Python scripts for complex logic handling (e.g., JSON parsing of Bitwarden output), encapsulated within Make targets.

### Technical Constraints

* The system **must** be built using **GNU Make** (refactored) and **Shell/Python Hybrid Scripting**.
* All execution **must** occur within the **Devcontainer** environment.
* Host-side execution is strictly **prohibited**.
* Security credentials **must not** be hardcoded and **must** be injected via Bitwarden CLI integration at runtime.

## 3. Environment Setup (Devcontainer)

Create `.devcontainer/devcontainer.json` with the following configuration:

```json
{
  "name": "Makefile Refactoring Env",
  "image": "[mcr.microsoft.com/devcontainers/base:ubuntu-24.04](https://mcr.microsoft.com/devcontainers/base:ubuntu-24.04)",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {},
    "ghcr.io/devcontainers/features/github-cli:1": {},
    "ghcr.io/meaningful-ooo/devcontainer-features/bitwarden-cli:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-vscode.makefile-tools",
        "timonwong.shellcheck",
        "foxundermoon.shell-format",
        "ms-python.python"
      ]
    }
  },
  "remoteUser": "vscode"
}

```

## 4. Testing Strategy

* Tests will be executed using **Custom Shell Scripts (Execution Verification)**.
* The testing suite **shall** perform "Dry-Run" validation (`make -n`) and actual "File Generation" verification within the container.
* Command: `docker exec -it [container] ./tests/run_integration_tests.sh` (or via VS Code task).
