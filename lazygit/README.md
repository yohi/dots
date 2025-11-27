# LazyGit AI コミットメッセージジェネレーター

LazyGitに直接統合されたAI駆動のコミットメッセージ生成。ターミナルUIを離れることなく、高品質なConventional Commits形式のメッセージを生成します。

## 機能

- 🤖 **複数のAIバックエンド**: Gemini、Claude、Ollamaをサポート
- ⚡ **コンテキストスイッチなし**: すべてがLazyGitのTUI内で完結
- 🎯 **Conventional Commits**: 自動フォーマット（feat:、fix:など）
- 🔒 **セキュリティ第一**: 適切なシェルエスケープとインジェクション防止
- 📝 **複数の候補**: 5つのAI生成オプションから選択
- ⏱️ **タイムアウト保護**: 30秒のタイムアウトでハングを防止

## クイックスタート

### 1. AIバックエンドを選択

#### オプション A: Gemini（推奨 - 高速＆無料）

```bash
# Gemini CLIをインストール
pip install google-generativeai

# APIキーを設定
export GEMINI_API_KEY="your-api-key-here"
```

APIキーの取得: https://aistudio.google.com/app/apikey

#### オプション B: Claude（コード理解に最適）

```bash
# Claude CLIをインストール
npm install -g @anthropic-ai/claude-cli

# APIキーを設定
export ANTHROPIC_API_KEY="your-api-key-here"
```

APIキーの取得: https://console.anthropic.com/

#### オプション C: Ollama（ローカル＆プライベート）

```bash
# Ollamaをインストール
curl -fsSL https://ollama.com/install.sh | sh

# モデルをダウンロード（例: mistral）
ollama pull mistral

# Ollamaサービスを起動
ollama serve
```

APIキー不要 - 完全にローカルで動作！

### 2. LazyGitを設定

提供された`config.yml`をLazyGitの設定ディレクトリにコピー:

```bash
# Linux/macOS
cp config.yml ~/.config/lazygit/config.yml

# または既存の設定にマージ
cat config.yml >> ~/.config/lazygit/config.yml
```

### 3. AIバックエンドを設定

`config.yml`を編集し、`AI_BACKEND`変数で選択したAIバックエンドのコメントを解除:

```yaml
# Geminiの場合（デフォルト）
export AI_BACKEND=gemini

# Claudeの場合
export AI_BACKEND=claude

# Ollamaの場合
export AI_BACKEND=ollama
```

### 4. スクリプトを実行可能にする

```bash
chmod +x ai-commit-generator.sh
chmod +x parse-ai-output.sh
chmod +x get-staged-diff.sh
```

### 5. LazyGitで使用

1. LazyGitで変更をステージング（ファイル上で`space`を押す）
2. `Ctrl+A`を押してコミットメッセージを生成
3. メニューから好みのメッセージを選択
4. `Enter`を押してコミット

## 使い方

### 基本的なワークフロー

AI生成コミットメッセージを使用する典型的なワークフロー:

1. **変更を加える** - プロジェクト内でいつも通りファイルを編集

2. **LazyGitを開く** - リポジトリで`lazygit`を実行
   ```bash
   cd your-project
   lazygit
   ```

3. **変更をステージング** - Filesパネルで:
   - `↑`/`↓`矢印キーで変更されたファイルに移動
   - `space`を押して個別のファイルをステージング
   - または`a`を押してすべての変更をステージング

4. **コミットメッセージを生成** - `Ctrl+A`を押す
   - "Generating commit messages with AI..."というローディングテキストが表示される
   - バックエンドに応じて1〜15秒待つ
   - 5つ以上のコミットメッセージオプションを含むメニューが表示される

5. **確認して選択** - メニューで:
   - `↑`/`↓`矢印キーで移動
   - 各メッセージを注意深く読む
   - 好みのメッセージで`Enter`を押す
   - または`Esc`を押してキャンセルして再試行

6. **コミットが作成される** - LazyGitが自動的に:
   - 選択したメッセージで`git commit`を実行
   - 新しいコミットを表示するようにUIを更新
   - 通常のビューに戻る

### 高度な使い方

#### プロンプトのカスタマイズ

`ai-commit-generator.sh`を編集してAIがメッセージを生成する方法をカスタマイズ:

```bash
# PROMPT変数を見つけて変更
PROMPT='Conventional Commits形式に従って5つのコミットメッセージを生成してください。
ルール:
- これらのタイプを使用: feat, fix, docs, style, refactor, test, chore
- 具体的で説明的に
- 72文字以内に収める
- マークダウン形式なし
- 1行に1メッセージ

追加のカスタム指示をここに...'
```

#### バックエンドの即座の切り替え

設定ファイルを編集せずにAIバックエンドを切り替えることができます:

```bash
# このセッションでGeminiを使用
AI_BACKEND=gemini lazygit

# このセッションでOllamaを使用
AI_BACKEND=ollama lazygit

# テスト用にmockを使用
AI_BACKEND=mock lazygit
```

#### タイムアウトの調整

遅いバックエンドや大きなdiffの場合:

```bash
# タイムアウトを60秒に増やす
TIMEOUT_SECONDS=60 lazygit

# または~/.bashrcで永続的に設定
export TIMEOUT_SECONDS=60
```

#### Diffサイズの制御

AIに送信されるコンテキストの量を調整:

`config.yml`を編集して`head -c`の値を変更:

```yaml
# 小さいdiff（高速、コンテキスト少）
git diff --cached | head -c 8000 | ...

# 大きいdiff（低速、コンテキスト多）
git diff --cached | head -c 20000 | ...

# デフォルト（バランス型）
git diff --cached | head -c 12000 | ...
```

#### 異なるモデルの使用

各バックエンドで使用するモデルを指定できます:

```bash
# Geminiモデル
export GEMINI_MODEL="gemini-1.5-flash"  # 高速（デフォルト）
export GEMINI_MODEL="gemini-1.5-pro"    # 高品質

# Claudeモデル
export CLAUDE_MODEL="claude-3-5-haiku-20241022"   # 高速（デフォルト）
export CLAUDE_MODEL="claude-3-5-sonnet-20241022"  # 高品質

# Ollamaモデル
export OLLAMA_MODEL="mistral"      # バランス型（デフォルト）
export OLLAMA_MODEL="codellama"    # コード特化
export OLLAMA_MODEL="mixtral"      # 高品質
```

### ベストプラクティス

#### 焦点を絞った変更で頻繁にコミット

- 関連する変更を一緒にステージング
- コミットをアトミックに保つ（1コミット1論理変更）
- AIは焦点を絞った一貫性のあるdiffで最も効果的

#### コミット前に確認

- Enterを押す前に必ず生成されたメッセージを読む
- 変更を正確に説明していることを確認
- 最初のものが完璧でない場合は別のオプションを選択

#### 意味のある変更をステージング

- 空白のみの変更をステージングしない
- 無関係な変更を一緒にステージングしない
- AIは明確で目的のある変更に対してより良いメッセージを生成

#### Conventional Commitsタイプを適切に使用

AIは以下のようなタイプを提案します:
- `feat:` - 新機能
- `fix:` - バグ修正
- `docs:` - ドキュメント変更
- `style:` - コードスタイル変更（フォーマットなど）
- `refactor:` - コードリファクタリング
- `test:` - テストの追加または更新
- `chore:` - メンテナンスタスク

#### 手動コミットと組み合わせる

すべてのコミットでAIを使う必要はありません:
- 好みに応じてLazyGitで`c`を使って手動コミット
- AI提案が欲しいときは`Ctrl+A`を使用
- ニーズに応じて使い分ける

### キーボードショートカットリファレンス

LazyGit Filesビューで:
- `space` - ファイルをステージング/アンステージング
- `a` - すべてのファイルをステージング
- `Ctrl+A` - AIコミットメッセージを生成（カスタムコマンド）
- `c` - 手動コミット（従来型）
- `Esc` - キャンセル/戻る

AIメッセージメニューで:
- `↑`/`↓` - メッセージ間を移動
- `Enter` - 選択してコミット
- `Esc` - キャンセルしてファイルビューに戻る

### ワークフロー例

#### ワークフロー 1: 機能開発

```bash
# 1. 新機能を実装
vim src/auth.js  # JWT認証を追加

# 2. LazyGitを開く
lazygit

# 3. ファイルをステージング
# src/auth.jsで'space'を押す

# 4. メッセージを生成
# Ctrl+Aを押す

# 5. 以下のようなオプションから選択:
#    - feat(auth): add JWT token validation
#    - feat(auth): implement authentication middleware
#    - feat: add user authentication with JWT

# 6. 選択したものでEnterを押す
```

#### ワークフロー 2: バグ修正

```bash
# 1. バグを修正
vim src/database.js  # 接続タイムアウトを修正

# 2. LazyGitを開いてステージング
lazygit
# src/database.jsで'space'を押す

# 3. メッセージを生成
# Ctrl+Aを押す

# 4. 以下のようなオプションから選択:
#    - fix(db): correct connection timeout handling
#    - fix(database): resolve timeout issue
#    - fix: prevent database connection timeouts

# 5. Enterを押す
```

#### ワークフロー 3: 複数ファイル

```bash
# 1. 複数ファイルにわたって関連する変更を加える
vim src/api.js src/routes.js tests/api.test.js

# 2. LazyGitを開く
lazygit

# 3. 関連するすべてのファイルをステージング
# 'a'を押してすべてをステージング、または各ファイルで'space'を押す

# 4. メッセージを生成
# Ctrl+Aを押す

# 5. 以下のようなオプションから選択:
#    - feat(api): add user profile endpoints
#    - feat: implement user profile API with tests
#    - feat(routes): add profile routes and handlers

# 6. Enterを押す
```

#### ワークフロー 4: ドキュメント

```bash
# 1. ドキュメントを更新
vim README.md CONTRIBUTING.md

# 2. LazyGitを開いてステージング
lazygit
# ドキュメントファイルで'space'を押す

# 3. メッセージを生成
# Ctrl+Aを押す

# 4. 以下のようなオプションから選択:
#    - docs: update README with installation steps
#    - docs(readme): add contributing guidelines
#    - docs: improve project documentation

# 5. Enterを押す
```

### ヒントとコツ

#### ヒント 1: 複数回試す

最初のメッセージセットが良くない場合:
- `Esc`を押してキャンセル
- `Ctrl+A`を再度押して新しい提案を取得
- AIは毎回異なるオプションを生成

#### ヒント 2: スコープを効果的に使用

`feat(auth):`や`fix(db):`のようなスコープ付きメッセージを探す:
- スコープはコンポーネント別にコミットを整理するのに役立つ
- git履歴をより検索しやすくする
- 大規模プロジェクトで特に有用

#### ヒント 3: Gitエイリアスと組み合わせる

一般的なワークフロー用のシェルエイリアスを作成:

```bash
# ~/.bashrcまたは~/.zshrcに追加
alias lg='lazygit'
alias lga='cd $(git rev-parse --show-toplevel) && lazygit'
```

#### ヒント 4: 学習に使用

AI生成メッセージから学べること:
- より良いコミットメッセージの書き方
- Conventional Commits形式
- 変更を簡潔に説明する方法

#### ヒント 5: バックエンド選択戦略

- **開発**: Geminiを使用（高速、無料）
- **機密コード**: Ollamaを使用（プライベート）
- **重要なコミット**: Claudeを使用（最高品質）
- **テスト**: mockを使用（API不要）

## 設定

### 環境変数

シェルプロファイル（`~/.bashrc`、`~/.zshrc`など）で設定:

```bash
# 必須: AIバックエンドを選択
export AI_BACKEND="gemini"  # または"claude"または"ollama"

# クラウドAIに必須: APIキーを設定
export GEMINI_API_KEY="your-key"      # Gemini用
export ANTHROPIC_API_KEY="your-key"   # Claude用

# オプション: 動作をカスタマイズ
export TIMEOUT_SECONDS=30              # AIリクエストタイムアウト（デフォルト: 30）
export OLLAMA_MODEL="mistral"          # Ollamaモデル（デフォルト: mistral）
```

### AIバックエンド詳細

#### Gemini設定

```bash
export AI_BACKEND="gemini"
export GEMINI_API_KEY="your-api-key"
export GEMINI_MODEL="gemini-1.5-flash"  # オプション、デフォルト表示
```

**長所**: 高速、寛大な無料枠、良好な品質
**短所**: インターネット必須、コードをGoogleに送信

#### Claude設定

```bash
export AI_BACKEND="claude"
export ANTHROPIC_API_KEY="your-api-key"
export CLAUDE_MODEL="claude-3-5-haiku-20241022"  # オプション、デフォルト表示
```

**長所**: 優れたコード理解、高品質
**短所**: インターネット必須、有料API（ただし手頃）

#### Ollama設定

```bash
export AI_BACKEND="ollama"
export OLLAMA_MODEL="mistral"  # オプション、デフォルト表示
export OLLAMA_HOST="http://localhost:11434"  # オプション、デフォルト表示
```

**長所**: 完全にローカル、プライベート、APIコストなし
**短所**: ローカルリソース必要、クラウドAPIより遅い

**推奨モデル**:
- `mistral` - 速度と品質のバランスが良い
- `codellama` - コード用に最適化
- `llama2` - 汎用目的

## テスト

### 完全なテストスイートを実行

インストールが正しく動作していることを確認:

```bash
# すべての統合テストを実行（23テスト）
./test-complete-workflow.sh

# エラーシナリオテストを実行
./test-all-error-scenarios.sh

# 特定のコンポーネントをテスト
./test-lazygit-commit-integration.sh
./test-regex-parser.sh
./test-error-handling.sh
```

**期待される結果**: すべてのテストが緑のチェックマークで合格すること。

テストスイートが検証する内容:
- ✅ diffからコミットまでの完全なワークフロー
- ✅ 特殊文字の処理とシェルエスケープ
- ✅ 空のステージング検出
- ✅ 大きなdiffの切り詰め（12KB制限）
- ✅ Conventional Commits形式の準拠
- ✅ メッセージからのMarkdown削除
- ✅ タイムアウト処理（デフォルト30秒）
- ✅ エラー回復とユーザーフィードバック
- ✅ 複数バックエンドサポート（Gemini、Claude、Ollama、Mock）
- ✅ 様々な入力形式でのパーサーの堅牢性

詳細なテスト手順については、[TESTING-GUIDE.md](TESTING-GUIDE.md)を参照してください。

### 手動テスト

実際のリポジトリでテスト:

```bash
# テストリポジトリを作成
mkdir ~/test-ai-commit
cd ~/test-ai-commit
git init

# 変更を加える
echo "function hello() { return 'world'; }" > test.js
git add test.js

# LazyGitを開いてテスト
lazygit
# Ctrl+Aを押し、メッセージを選択し、Enterを押す

# コミットを確認
git log -1
```

### クイック検証

各コンポーネントが動作することを確認:

```bash
# 1. AI生成をテスト
echo "test change" | AI_BACKEND=mock ./ai-commit-generator.sh

# 2. パーサーをテスト
echo -e "feat: test\nfix: another" | ./parse-ai-output.sh

# 3. 完全なパイプラインをテスト
git diff --cached | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

## トラブルシューティング

### インストールの問題

#### Ctrl+Aを押したときに"No such file or directory"

**問題**: config.ymlのスクリプトパスが正しくない

**解決策**:
1. スクリプトをインストールした場所を確認: インストールディレクトリで`pwd`
2. `~/.config/lazygit/config.yml`を編集してパスを絶対パスに更新:
   ```yaml
   git diff --cached | head -c 12000 | /full/path/to/ai-commit-generator.sh | /full/path/to/parse-ai-output.sh
   ```
3. スクリプトが実行可能であることを確認: `chmod +x *.sh`

#### "command not found: gemini"または類似のエラー

**問題**: AI CLIツールがPATHにない

**解決策**:
- Pythonパッケージの場合: `pip install --user google-generativeai`を実行し、`~/.local/bin`がPATHにあることを確認
- npmパッケージの場合: `npm install -g @anthropic-ai/claude-cli`を実行し、npm globalのbinがPATHにあることを確認
- インストールを確認: `which gemini`または`which claude`または`which ollama`

#### LazyGitがCtrl+Aオプションを表示しない

**問題**: 設定ファイルが読み込まれていないか、構文エラーがある

**解決策**:
1. 設定の場所を確認: `ls -la ~/.config/lazygit/config.yml`
2. YAML構文エラーをチェック: `python3 -c "import yaml; yaml.safe_load(open('config.yml'))"`
3. LazyGitを完全に再起動（すべてのインスタンスを閉じる）
4. LazyGitのバージョンを確認: `lazygit --version`（最新であることを確認）

### 実行時の問題

#### "No staged changes"エラー

**問題**: Ctrl+Aを押したときにメッセージが表示される

**解決策**: LazyGitでファイル上で`space`を押して最初にステージング

**要件**: 2.4 - ステージングエリアが空の場合、システムは実行を防止

#### "AI tool failed"エラー

**問題**: AIバックエンドがエラーを返す

**解決策**:
- APIキーが正しく設定されているか確認: `echo $GEMINI_API_KEY`
- AIツールがインストールされているか確認: `which gemini`または`ollama list`
- インターネット接続を確認（クラウドAIの場合）
- Ollamaの場合: サービスが実行中であることを確認: `ollama serve`
- AIツールを独立してテスト: `echo "test" | ./ai-commit-generator.sh`

**要件**: 8.2 - 適切なエラーメッセージによる強化されたエラー処理

#### "Timeout"エラー

**問題**: AIの応答に時間がかかりすぎる（デフォルト30秒超）

**解決策**:
- タイムアウトを増やす: `export TIMEOUT_SECONDS=60`（または~/.bashrcに追加）
- diffサイズを減らすために一度にステージングするファイルを減らす
- Ollamaの場合: より小さい/高速なモデルを使用: `export OLLAMA_MODEL="mistral:7b"`
- 大きなdiffの場合: config.ymlでサイズ制限を減らす: `head -c 12000`の代わりに`head -c 8000`

**要件**: 8.4 - タイムアウト処理がハングを防止

#### "GEMINI_API_KEY not set"または"ANTHROPIC_API_KEY not set"

**問題**: 環境変数が設定されていない

**解決策**:
```bash
# 設定されているか確認
echo $GEMINI_API_KEY

# 一時的に設定
export GEMINI_API_KEY="your-key-here"
export AI_BACKEND="gemini"

# 永続的に設定（~/.bashrcまたは~/.zshrcに追加）
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.bashrc
echo 'export AI_BACKEND="gemini"' >> ~/.bashrc
source ~/.bashrc
```

**要件**: 7.1 - 環境変数によるAPIキー管理

### 品質の問題

#### メッセージにMarkdown形式が含まれる

**問題**: 生成されたメッセージに`**太字**`、`` `コード` ``、またはその他のmarkdownが含まれる

**解決策**: 設定されたプロンプトではこれは起こらないはずです。もし起こった場合:
1. スクリプトの最新バージョンを使用していることを確認
2. `ai-commit-generator.sh`のプロンプトに"No markdown"指示が含まれているか確認
3. 別のAIバックエンドを試す（Claudeは形式ルールに最も従う）
4. Ollamaの場合: 別のモデルを試すかプロンプトを調整

**要件**: 6.3 - メッセージにmarkdown形式を含めない

#### メッセージがConventional Commitsに従わない

**問題**: メッセージに`feat:`、`fix:`などの接頭辞がない

**解決策**:
1. `ai-commit-generator.sh`のプロンプトがConventional Commitsに言及しているか確認
2. Claudeバックエンドを試す（形式に最も従う）
3. Ollamaの場合: コード規約をよりよく理解する`codellama`モデルを使用
4. 形式要件を強調するためにプロンプトを手動で編集

**要件**: 6.1 - メッセージはConventional Commits形式に従う必要がある

#### メッセージが一般的すぎる

**問題**: "update files"や"make changes"のようなメッセージ

**解決策**:
1. より具体的な変更をステージング（小さく焦点を絞ったコミット）
2. より良いコード理解のためにClaudeバックエンドを試す
3. Ollamaの場合: `mixtral`のようなより大きなモデルを使用
4. diffが意味のあるものであることを確認（空白のみの変更ではない）

### セキュリティの問題

#### 特殊文字がコミットを壊す

**問題**: 引用符、バッククォート、または特殊文字を含むメッセージでコミットが失敗

**解決策**: これはLazyGitの`| quote`フィルターによって自動的に処理されます。問題が続く場合:
1. `config.yml`のcommandセクションに`{{.Form.SelectedMsg | quote}}`があることを確認
2. LazyGitを最新バージョンに更新
3. エスケープを手動でテスト: `printf %q "test 'message' with \"quotes\""`

**要件**: 4.2、8.3 - 適切なシェルエスケープがインジェクションを防止

#### コードのプライバシーが心配

**問題**: コードを外部サーバーに送信したくない

**解決策**:
1. Ollamaバックエンドを使用（完全にローカル）: `export AI_BACKEND="ollama"`
2. 生成前にdiffを確認（何がステージングされているか確認）
3. `.gitignore`を使用して機密ファイルのステージングを防止
4. 非常に機密性の高いプロジェクトの場合、テスト専用にmockバックエンドを使用

**要件**: 7.1、7.3 - プラグ可能なバックエンドがプライバシー重視のオプションを可能にする

### パフォーマンスの問題

#### AIの応答が遅い

**問題**: メッセージ生成に10秒以上かかる

**解決策**:
- Gemini/Claudeの場合: インターネット接続速度を確認
- Ollamaの場合: 
  - より小さいモデルを使用: `export OLLAMA_MODEL="mistral:7b"`
  - 利用可能な場合はGPUアクセラレーションを有効化
  - Ollamaに割り当てるシステムリソースを増やす
- diffサイズを減らす: ステージングするファイルを減らすか、config.ymlでサイズ制限を減らす

#### 生成中にLazyGitがフリーズする

**問題**: LazyGitが応答しなくなる

**解決策**:
1. これは予想される動作 - LazyGitはコマンドの完了を待つ
2. `loadingText`に"Generating commit messages with AI..."と表示されるはず
3. 本当にフリーズする場合（ローディングテキストなし）、タイムアウト設定を確認
4. より早く失敗するようにタイムアウトを減らす: `export TIMEOUT_SECONDS=15`

**要件**: 1.2 - AI処理中のローディングフィードバック

### デバッグ

#### 詳細ログを有効化

問題のトラブルシューティングのためにデバッグ出力を追加:

```bash
# ai-commit-generator.shを編集して先頭に追加:
set -x  # デバッグモードを有効化

# またはデバッグ付きで手動実行:
bash -x ./ai-commit-generator.sh < test-diff.txt
```

#### コンポーネントを個別にテスト

```bash
# diff生成をテスト
git diff --cached

# AI生成をテスト
git diff --cached | ./ai-commit-generator.sh

# パースをテスト
echo -e "feat: test\nfix: another" | ./parse-ai-output.sh

# 完全なパイプラインをテスト
git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

#### LazyGitログを確認

LazyGitはstderrにエラーをログ出力する可能性があります:

```bash
# エラー出力を表示してLazyGitを実行
lazygit 2>&1 | tee lazygit-errors.log
```

### ヘルプを得る

まだ問題が解決しない場合:

1. **テストスイートを実行**: `./test-complete-workflow.sh` - 特定の問題を識別します
2. **ドキュメントを確認**:
   - [INSTALLATION.md](INSTALLATION.md) - 詳細なセットアップ手順
   - [AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md) - バックエンド固有のヘルプ
   - [QUICKSTART.md](QUICKSTART.md) - クイックセットアップパス
3. **AIバックエンドを独立してテスト**:
   ```bash
   # Geminiの場合
   python3 -c "import google.generativeai as genai; print('OK')"
   
   # Claudeの場合
   claude --version
   
   # Ollamaの場合
   ollama list
   ```
4. **環境変数を確認**: `env | grep -E 'AI_|GEMINI|ANTHROPIC|OLLAMA'`
5. **スクリプトのパーミッションを確認**: `ls -l *.sh`（`-rwxr-xr-x`と表示されるはず）

### 一般的なエラーメッセージ

| エラーメッセージ | 原因 | 解決策 |
|---------------|-------|----------|
| "No diff input provided" | ステージングエリアが空 | LazyGitで`space`を使ってファイルをステージング |
| "AI tool failed" | バックエンドエラーまたは未インストール | APIキーとインストールを確認 |
| "timed out after X seconds" | AIの時間がかかりすぎた | タイムアウトを増やすかdiffサイズを減らす |
| "No valid commit messages found" | パーサーが空/無効な出力を受信 | AIバックエンドが動作しているか確認 |
| "command not found" | 設定のスクリプトパスが間違っている | config.ymlで絶対パスを使用 |
| "GEMINI_API_KEY not set" | 環境変数が欠落 | シェルプロファイルでAPIキーを設定 |

## 高度な使い方

### カスタムプロンプト

`ai-commit-generator.sh`を編集してAIに送信するプロンプトをカスタマイズ:

```bash
PROMPT='ここにカスタム指示を...'
```

### 複数のAIバックエンド

バックエンドを即座に切り替えることができます:

```bash
# あるターミナルセッションで
AI_BACKEND=gemini lazygit

# 別のセッションで
AI_BACKEND=ollama lazygit
```

### サイズ制限

大きなdiffはトークン制限を避けるために自動的に12KBに切り詰められます。`config.yml`で調整:

```yaml
git diff --cached | head -c 12000  # 12000を好みのサイズに変更
```

## セキュリティに関する考慮事項

### APIキー

- **APIキーをバージョン管理にコミットしない**
- 環境変数または安全なキー管理に保存
- `.bashrc`/`.zshrc`またはシークレットマネージャーを使用

### コードのプライバシー

- **クラウドAI（Gemini/Claude）**: コードdiffが外部サーバーに送信される
- **ローカルAI（Ollama）**: すべてがマシン上に留まる
- 機密プロジェクトの場合、Ollamaを使用するか、生成前にdiffを確認

### シェルインジェクション

- すべてのユーザー入力はLazyGitの`| quote`フィルターによって適切にエスケープされる
- システムはコマンドインジェクション攻撃を防ぐように設計されている

## 要件

- LazyGit（最新バージョン推奨）
- Git
- Bash
- 以下のいずれか: Python 3（Gemini）、Node.js（Claude）、またはOllama
- インターネット接続（クラウドAIバックエンドの場合）

## ライセンス

MIT

## ドキュメント

このプロジェクトには包括的なドキュメントが含まれています:

- **[README.md](README.md)**（このファイル）- 概要、機能、クイックスタート
- **[QUICKSTART.md](QUICKSTART.md)** - 5分以内で開始
- **[INSTALLATION.md](INSTALLATION.md)** - 詳細なインストール手順
- **[AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md)** - AIバックエンドの完全ガイド
- **[BACKEND-COMPARISON.md](BACKEND-COMPARISON.md)** - バックエンドを一目で比較
- **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - インストールのテスト方法
- **[config.example.yml](config.example.yml)** - 注釈付き設定例

### クイックリンク

- **新規ユーザー**: [QUICKSTART.md](QUICKSTART.md)から開始
- **インストールヘルプ**: [INSTALLATION.md](INSTALLATION.md)を参照
- **バックエンドの選択**: [BACKEND-COMPARISON.md](BACKEND-COMPARISON.md)を読む
- **バックエンドセットアップ**: [AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md)を確認
- **テスト**: [TESTING-GUIDE.md](TESTING-GUIDE.md)に従う
- **トラブルシューティング**: 上記のトラブルシューティングセクションを参照

## 貢献

貢献を歓迎します！以下を確認してください:
- すべてのテストが合格すること（`./test-complete-workflow.sh`）
- Conventional Commits形式に従うこと
- 新機能のドキュメントを更新すること
- 新機能のテストを追加すること

## クレジット

プロパティベーステストを用いた仕様駆動開発手法に従って構築されました。

**手法**:
- EARSパターンによる要件駆動設計
- 事前に定義された正確性プロパティ
- 包括的なテストカバレッジ
- ユーザーフィードバックによる反復的改善

**アーキテクチャ**:
- LazyGitカスタムコマンド統合
- プラグ可能なAIバックエンドシステム
- シェルベースのパイプラインアーキテクチャ
- セキュリティ第一の設計（適切なエスケープ、タイムアウト処理）
