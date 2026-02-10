# GitHub Actions CI 設定 (テスト用)

このドキュメントでは、PR作成時に自動でテスト（Lintチェック）を実行するための GitHub Actions の設定について説明します。

## 概要
リポジトリの品質維持のため、`master` ブランチへの Pull Request が作成された際に、自動的にスクリプトのチェック（ShellCheck）を実行します。

## 設定詳細
- **トリガー**: `master` ブランチをターゲットとする Pull Request の作成・更新時。
- **実行内容**: `ShellCheck` による `switch-opencode-pattern.sh` の構文・静的解析チェック。
- **実行環境**: `ubuntu-slim` (1 vCPU)
  - **理由**: 軽量な静的解析タスクに最適であり、コスト効率を最大化するため。

## ワークフローファイル
設定は `.github/workflows/ci.yml` に記述されています。

```yaml
name: CI

on:
  pull_request:
    branches: [ master ]

jobs:
  lint:
    runs-on: ubuntu-slim
    steps:
      - uses: actions/checkout@v4
      - name: Install ShellCheck
        run: sudo apt-get update && sudo apt-get install -y shellcheck
      - name: Run ShellCheck
        run: shellcheck switch-opencode-pattern.sh
```
