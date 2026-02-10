---
description: PR作成時にGitHub ActionsでCI/CDを実行するワークフローを作成（ubuntu-slim使用）
agent: sisyphus
model: google/antigravity-gemini-3-flash
---

PR作成時にGitHub Actionsでテスト（CI/CD）を回す処理を作成してください。
具体的には、以下の要件を満たす `.github/workflows/ci.yml` ファイルを生成してください。

## 要件
1. **トリガー**: Pull Request 作成時 (`on: pull_request`)
2. **ジョブ内容**: 
   - コードのチェックアウト
   - リポジトリ内のスクリプトやコードに対する Lint チェック（例: ShellCheck 等、プロジェクトに適したもの）
3. **ランナー環境**: `ubuntu-slim` を使用すること。
   - **理由**: コスト効率のため。
   - **注意**: よく `ubuntu-latest` と間違えられるので、必ず `ubuntu-slim` を指定してください。
   - 参照: https://github.blog/changelog/2025-10-28-1-vcpu-linux-runner-now-available-in-github-actions-in-public-preview/

## 出力
作成したYAMLファイルの内容を提示し、ファイルを `.github/workflows/ci.yml` に保存してください。
保存後、ユーザーに確認を求めてください。
