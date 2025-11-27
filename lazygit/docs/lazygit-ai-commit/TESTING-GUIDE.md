# テストガイド

このドキュメントでは、LazyGit AIコミットメッセージジェネレーターが正しく動作していることを確認するためのテスト方法を説明します。

## クイックテスト

完全なテストスイートを実行してすべてが動作することを確認:

```bash
./test-complete-workflow.sh
```

これにより、システムのすべての側面をカバーする23の統合テストが実行されます。

## テストスイート概要

### 完全なワークフローテスト（`test-complete-workflow.sh`）

システム全体をエンドツーエンドで検証する包括的な統合テスト。

**テスト内容**:
1. 完全なハッピーパスワークフロー（diff → AI → コミット）
2. 特殊文字の処理とエスケープ
3. 空のステージングエリア検出
4. 大きなdiffの切り詰め（12KB制限）
5. Conventional Commits形式の準拠
6. メッセージからのMarkdown削除
7. タイムアウト処理
8. エラー回復
9. 複数バックエンドサポート
10. UI更新の検証
11. キャンセルシナリオ
12. パーサーの堅牢性

**期待される結果**: すべての23テストが合格すること

**実行方法**:
```bash
./test-complete-workflow.sh
```

### エラーシナリオテスト（`test-all-error-scenarios.sh`）

システムが適切に失敗することを確認するためのすべてのエラー処理パスをテスト。

**テスト内容**:
- 空のdiff入力処理
- AIツールの空出力検出
- AIツール失敗処理
- タイムアウト検出
- パーサーの空入力処理
- パーサーの空白のみ入力処理
- パイプライン失敗の伝播
- 有効な入力が有効な出力を生成
- エラーメッセージに提案が含まれる
- タイムアウトの設定可能性

**実行方法**:
```bash
./test-all-error-scenarios.sh
```

### コンポーネントテスト

特定の機能のための個別コンポーネントテスト:

#### コミット統合テスト（`test-lazygit-commit-integration.sh`）

menuFromCommandからコミット実行までの完全なパイプラインをテスト。

**実行方法**:
```bash
./test-lazygit-commit-integration.sh
```

#### 正規表現パーサーテスト（`test-regex-parser.sh`）

AI出力を個別のコミットメッセージに解析することをテスト。

**実行方法**:
```bash
./test-regex-parser.sh
```

#### エラー処理テスト（`test-error-handling.sh`）

エラー検出と報告をテスト。

**実行方法**:
```bash
./test-error-handling.sh
```

#### タイムアウト処理テスト（`test-timeout-handling.sh`）

タイムアウト機能をテスト。

**実行方法**:
```bash
./test-timeout-handling.sh
```

#### AIバックエンド統合テスト（`test-ai-backend-integration.sh`）

異なるAIバックエンドとの統合をテスト。

**実行方法**:
```bash
./test-ai-backend-integration.sh
```

## 手動テスト

### Mockバックエンドでテスト

mockバックエンドはAPIキー不要でテストに最適:

```bash
# バックエンドをmockに設定
export AI_BACKEND=mock

# テストリポジトリを作成
mkdir ~/test-ai-commit
cd ~/test-ai-commit
git init

# 変更を加える
echo "function hello() { return 'world'; }" > test.js
git add test.js

# パイプラインを手動でテスト
git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh | scripts/lazygit-ai-commit/parse-ai-output.sh

# またはLazyGitでテスト
lazygit
# Ctrl+Aを押してAI生成メッセージを確認
```

### 実際のAIバックエンドでテスト

APIキーが設定されたら:

```bash
# Geminiの場合
export AI_BACKEND=gemini
export GEMINI_API_KEY="your-key"

# Claudeの場合
export AI_BACKEND=claude
export ANTHROPIC_API_KEY="your-key"

# Ollamaの場合（実行中であることを確認）
export AI_BACKEND=ollama
ollama serve  # 別のターミナルで

# パイプラインをテスト
cd your-project
git add some-file.js
git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh | scripts/lazygit-ai-commit/parse-ai-output.sh
```

### LazyGitでテスト

最終的なテストはLazyGitで使用すること:

```bash
# 1. 実際のプロジェクトで変更を加える
cd your-project
vim some-file.js

# 2. LazyGitを開く
lazygit

# 3. ファイルをステージング（spaceを押す）

# 4. Ctrl+Aを押してメッセージを生成

# 5. 確認:
#    - ローディングメッセージが表示される
#    - メニューに5つ以上のメッセージが表示される
#    - メッセージがConventional Commits形式に従っている
#    - markdown形式がない
#    - メッセージが変更に関連している

# 6. メッセージを選択してEnterを押す

# 7. コミットが作成されたことを確認:
git log -1
```

## テストチェックリスト

完全なインストールを確認するためにこのチェックリストを使用:

### インストールテスト

- [ ] スクリプトが実行可能（`ls -l *.sh`で`-rwxr-xr-x`と表示）
- [ ] AIバックエンドがインストールされアクセス可能
- [ ] APIキーが設定されている（クラウドバックエンドの場合）
- [ ] 環境変数が設定されている
- [ ] LazyGit config.ymlに正しい絶対パスがある
- [ ] LazyGit config.ymlの構文が有効

### 機能テスト

- [ ] mockバックエンドが動作: `echo "test" | AI_BACKEND=mock scripts/lazygit-ai-commit/ai-commit-generator.sh`
- [ ] パーサーが動作: `echo "feat: test" | scripts/lazygit-ai-commit/parse-ai-output.sh`
- [ ] 完全なパイプラインが動作: `git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh | scripts/lazygit-ai-commit/parse-ai-output.sh`
- [ ] LazyGitがfilesビューでCtrl+Aオプションを表示
- [ ] Ctrl+Aを押すとローディングメッセージが表示される
- [ ] 複数のメッセージを含むメニューが表示される
- [ ] メッセージがConventional Commits形式に従っている
- [ ] メッセージを選択するとコミットが作成される
- [ ] コミットメッセージが正しく保持される
- [ ] 特殊文字が処理される（引用符、バッククォートでテスト）

### エラー処理テスト

- [ ] 空のステージングエリアでエラーが表示される
- [ ] AI失敗でエラーメッセージが表示される
- [ ] タイムアウトでエラーメッセージが表示される（該当する場合）
- [ ] 無効な出力が適切に処理される
- [ ] Escを押すとコミットせずにキャンセルされる

### 品質テスト

- [ ] メッセージが変更に関連している
- [ ] メッセージがConventional Commits形式に従っている
- [ ] メッセージにmarkdown形式がない
- [ ] メッセージが簡潔（72文字以内）
- [ ] 複数の候補が提供される

## テスト失敗のトラブルシューティング

### "AI tool failed with exit code 127"

**原因**: スクリプトが見つからないか実行可能でない

**修正**:
```bash
chmod +x *.sh
ls -l mock-ai-tool.sh  # -rwxr-xr-xと表示されるはず
```

### "No such file or directory"

**原因**: テストディレクトリから相対パスが機能しない

**修正**: スクリプトは現在絶対パスを使用しています。正しいディレクトリから実行していることを確認してください。

### "Timeout not detected"

**原因**: システムで`timeout`コマンドが利用できない

**修正**: これは許容範囲 - テストは注記付きで合格します。タイムアウト機能には`timeout`コマンドが必要です（通常Linuxで利用可能）。

### "Some messages don't follow format"

**原因**: mockAIツールが適切な形式を生成していない

**修正**: `mock-ai-tool.sh`が正しいバージョンで実行可能であることを確認してください。

### テストは合格するがLazyGitが動作しない

**原因**: LazyGit config.ymlのパスが正しくない

**修正**:
1. `~/.config/lazygit/config.yml`を編集
2. `scripts/lazygit-ai-commit/ai-commit-generator.sh`を完全な絶対パスに置き換える
3. `scripts/lazygit-ai-commit/parse-ai-output.sh`を完全な絶対パスに置き換える
4. LazyGitを再起動

## 継続的インテグレーション

CI/CDでテストを実行するには:

```bash
#!/bin/bash
# CIテストスクリプト

set -e

# mockバックエンドを使用（APIキー不要）
export AI_BACKEND=mock

# すべてのテストを実行
./test-complete-workflow.sh
./test-all-error-scenarios.sh

echo "All tests passed!"
```

## パフォーマンステスト

異なるdiffサイズでテスト:

```bash
# 小さいdiff（< 1KB）
echo "small change" > test.txt
git add test.txt
time git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh

# 中程度のdiff（5-10KB）
cat large-file.js > test.js
git add test.js
time git diff --cached | scripts/lazygit-ai-commit/ai-commit-generator.sh

# 大きいdiff（> 12KB、切り詰められる）
dd if=/dev/zero of=large.bin bs=1024 count=20
git add large.bin
time git diff --cached | head -c 12000 | scripts/lazygit-ai-commit/ai-commit-generator.sh
```

## バックエンド固有のテスト

### Geminiをテスト

```bash
export AI_BACKEND=gemini
export GEMINI_API_KEY="your-key"

# API接続をテスト
python3 -c "
import google.generativeai as genai
import os
genai.configure(api_key=os.environ['GEMINI_API_KEY'])
print('Gemini API key is valid')
"

# メッセージ生成をテスト
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh
```

### Claudeをテスト

```bash
export AI_BACKEND=claude
export ANTHROPIC_API_KEY="your-key"

# CLIインストールをテスト
claude --version

# メッセージ生成をテスト
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh
```

### Ollamaをテスト

```bash
export AI_BACKEND=ollama

# Ollamaが実行中であることをテスト
curl http://localhost:11434/api/tags

# モデルが利用可能であることをテスト
ollama list | grep mistral

# メッセージ生成をテスト
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh
```

## テストカバレッジ

テストスイートがカバーする内容:

- ✅ 要件 1.1、1.2 - LazyGit統合
- ✅ 要件 2.1、2.2、2.3、2.4 - 複数候補とメニュー
- ✅ 要件 3.1、3.2、3.3、3.4 - ユーザー選択と確認
- ✅ 要件 4.1、4.2、4.3 - コミット実行とエスケープ
- ✅ 要件 5.1、5.2、5.3、5.4 - diff処理と解析
- ✅ 要件 6.1、6.3 - Conventional Commits形式
- ✅ 要件 7.1、7.2、7.3 - 設定可能なAIバックエンド
- ✅ 要件 8.1、8.2、8.3、8.4 - エラー処理とエッジケース
- ✅ 要件 9.1、9.2、9.3 - キーボードショートカット

## 問題の報告

テストが失敗した場合、この情報を収集:

```bash
# システム情報
uname -a
bash --version
git --version
lazygit --version

# 環境
env | grep -E 'AI_|GEMINI|ANTHROPIC|OLLAMA'

# テスト出力
./test-complete-workflow.sh > test-output.log 2>&1

# スクリプトのパーミッション
ls -la *.sh

# LazyGit設定
cat ~/.config/lazygit/config.yml
```

問題を報告する際にこの情報を含めてください。

## 成功基準

成功したテスト実行では以下が表示されるはず:

```
==========================================
Test Summary
==========================================

Total Tests: 23
Passed: 23
Failed: 0

✓ All integration tests passed!

The LazyGit AI Commit system is working correctly.
You can now use it with confidence in your workflow.
```

これが表示されれば、インストールは完了し正しく動作しています！
