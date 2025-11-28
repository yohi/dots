# 技術スタック

## 主要技術

- **Shell**: Bashスクリプト（主要実装言語）
- **Git**: バージョン管理統合
- **LazyGit**: Git操作用ターミナルUI（カスタムコマンド）
- **AIバックエンド**: 
  - Google Gemini（`google-generativeai`経由のPython SDK）
  - Anthropic Claude（公式CLI）
  - Ollama（ローカルLLMサーバー）
  - Mockバックエンド（テスト用）

## アーキテクチャ

**パイプラインベース設計**: パイプで接続されたシェルスクリプト
```
git diff → ai-commit-generator.sh → parse-ai-output.sh → LazyGitメニュー → git commit
```

**主要コンポーネント**:
- `ai-commit-generator.sh`: タイムアウト処理を備えたAIバックエンドインターフェース
- `parse-ai-output.sh`: 正規表現ベースの出力パーサー
- `get-staged-diff.sh`: Git diff抽出
- `mock-ai-tool.sh`: テスト用バックエンド
- `config.yml`: LazyGitカスタムコマンド設定

## 設定

- **LazyGit設定**: `~/.config/lazygit/config.yml`
- **環境変数**: APIキー、バックエンド選択、タイムアウト
- **スクリプトパス**: LazyGit設定では絶対パスを使用する必要がある

## 共通コマンド

### テスト
```bash
# 完全なテストスイートを実行（23テスト）
./tests/lazygit-ai-commit/test-complete-workflow.sh

# エラーシナリオテストを実行
./tests/lazygit-ai-commit/test-all-error-scenarios.sh

# 特定のコンポーネントをテスト
./tests/lazygit-ai-commit/test-regex-parser.sh
./tests/lazygit-ai-commit/test-error-handling.sh
./tests/lazygit-ai-commit/test-timeout-handling.sh
```

### セットアップ
```bash
# スクリプトを実行可能にする
chmod +x scripts/lazygit-ai-commit/*.sh

# AIバックエンドをテスト
echo "test change" | AI_BACKEND=mock scripts/lazygit-ai-commit/ai-commit-generator.sh

# パーサーをテスト
echo -e "feat: test\nfix: another" | scripts/lazygit-ai-commit/parse-ai-output.sh
```

### 開発
```bash
# 完全なパイプラインをテスト
git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh | scripts/lazygit-ai-commit/parse-ai-output.sh

# デバッグモード
bash -x scripts/lazygit-ai-commit/ai-commit-generator.sh < test-diff.txt

# 異なるバックエンドでテスト
AI_BACKEND=gemini scripts/lazygit-ai-commit/ai-commit-generator.sh
AI_BACKEND=ollama scripts/lazygit-ai-commit/ai-commit-generator.sh
```

## 依存関係

- Bash（`set -e`、`set -o pipefail`を使用）
- Git
- LazyGit（最新バージョン推奨）
- `timeout`コマンド（タイムアウト処理用）
- Python 3（Geminiバックエンド用）
- Node.js（Claudeバックエンド用、オプション）
- Ollama（ローカルLLMバックエンド用、オプション）

## エラー処理

- **パイプライン失敗**: `set -o pipefail`がパイプチェーンの失敗をキャッチ
- **タイムアウト**: 30秒のデフォルトタイムアウト（`TIMEOUT_SECONDS`で設定可能）
- **空入力検出**: 処理前にステージングされた変更が存在することを検証
- **APIキー検証**: API呼び出し前に環境変数をチェック
- **終了コード**: 説明的なエラーメッセージを伴う適切な終了コード
