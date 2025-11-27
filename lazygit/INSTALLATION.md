# インストールガイド

このガイドでは、好みのAIバックエンドを使用してLazyGit AIコミットメッセージジェネレーターをセットアップする手順を説明します。

## 前提条件

- LazyGitがインストールされ動作していること
- Git
- Bashシェル
- インターネット接続（クラウドAIバックエンドの場合）

## ステップバイステップのインストール

### ステップ 1: AIバックエンドを選択

3つのAIバックエンドから1つを選択する必要があります。それぞれ異なるトレードオフがあります:

| バックエンド | 長所 | 短所 | 最適な用途 |
|---------|------|------|----------|
| **Gemini** | 高速、寛大な無料枠、良好な品質 | インターネット必須、コードをGoogleに送信 | ほとんどのユーザー、クイックセットアップ |
| **Claude** | 優れたコード理解 | 有料API、インターネット必須 | プロフェッショナル用途、最高品質 |
| **Ollama** | 完全にローカル、プライベート、無料 | 遅い、ローカルリソース必要 | プライバシー重視のプロジェクト |

### ステップ 2: 選択したバックエンドをインストール

#### オプション A: Gemini（推奨）

1. Google Generative AI Pythonパッケージをインストール:
   ```bash
   pip install google-generativeai
   ```

2. APIキーを取得:
   - https://aistudio.google.com/app/apikey にアクセス
   - "Create API Key"をクリック
   - キーをコピー

3. 環境変数を設定:
   ```bash
   # ~/.bashrcまたは~/.zshrcに追加
   export GEMINI_API_KEY="your-api-key-here"
   export AI_BACKEND="gemini"
   ```

4. シェルをリロード:
   ```bash
   source ~/.bashrc  # またはsource ~/.zshrc
   ```

#### オプション B: Claude

1. Claude CLIをインストール:
   ```bash
   npm install -g @anthropic-ai/claude-cli
   ```

2. APIキーを取得:
   - https://console.anthropic.com/ にアクセス
   - アカウントを作成してクレジットを追加
   - APIキーを生成

3. 環境変数を設定:
   ```bash
   # ~/.bashrcまたは~/.zshrcに追加
   export ANTHROPIC_API_KEY="your-api-key-here"
   export AI_BACKEND="claude"
   ```

4. シェルをリロード:
   ```bash
   source ~/.bashrc  # またはsource ~/.zshrc
   ```

#### オプション C: Ollama（ローカル）

1. Ollamaをインストール:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

2. モデルをダウンロード（1つ選択）:
   ```bash
   # Mistral（推奨 - バランスが良い）
   ollama pull mistral
   
   # またはCodeLlama（コード用に最適化）
   ollama pull codellama
   
   # またはLlama2（汎用目的）
   ollama pull llama2
   ```

3. Ollamaサービスを起動:
   ```bash
   ollama serve
   ```
   
   注意: システムサービスとして自動起動するように設定することをお勧めします。

4. 環境変数を設定:
   ```bash
   # ~/.bashrcまたは~/.zshrcに追加
   export AI_BACKEND="ollama"
   export OLLAMA_MODEL="mistral"  # または選択したモデル
   ```

5. シェルをリロード:
   ```bash
   source ~/.bashrc  # またはsource ~/.zshrc
   ```

### ステップ 3: スクリプトをインストール

1. このリポジトリをシステム上の場所にクローンまたはダウンロード:
   ```bash
   cd ~/projects  # または好みの場所
   git clone <repository-url> lazygit-ai-commit
   cd lazygit-ai-commit
   ```

2. スクリプトを実行可能にする:
   ```bash
   chmod +x ai-commit-generator.sh
   chmod +x parse-ai-output.sh
   chmod +x get-staged-diff.sh
   chmod +x mock-ai-tool.sh
   ```

### ステップ 4: LazyGitを設定

1. LazyGit設定ディレクトリを見つける:
   ```bash
   # Linux/macOS
   mkdir -p ~/.config/lazygit
   
   # 設定ファイルは以下にあるはず:
   # ~/.config/lazygit/config.yml
   ```

2. `config.yml`のスクリプトパスを更新:
   
   `config.yml`を開き、スクリプトをインストールした場所を指すようにパスを更新:
   
   ```yaml
   command: |
     # ... 既存の設定 ...
     git diff --cached | head -c 12000 | /full/path/to/ai-commit-generator.sh | /full/path/to/parse-ai-output.sh
   ```
   
   `/full/path/to/`をリポジトリをクローンした実際のパスに置き換えます。

3. 設定をコピーまたはマージ:
   ```bash
   # 既存の設定がない場合:
   cp config.yml ~/.config/lazygit/config.yml
   
   # 既存の設定がある場合、customCommandsセクションをマージ:
   # 両方のファイルを開き、AIコミットコマンドを既存の設定にコピー
   ```

### ステップ 5: インストールをテスト

1. テストリポジトリを作成:
   ```bash
   mkdir ~/test-ai-commit
   cd ~/test-ai-commit
   git init
   echo "test" > test.txt
   git add test.txt
   ```

2. LazyGitを開く:
   ```bash
   lazygit
   ```

3. `Ctrl+A`を押してAIコミットジェネレーターをトリガー

4. 以下が表示されるはず:
   - "Generating commit messages with AI..."ローディングメッセージ
   - 5つのコミットメッセージオプションを含むメニュー
   - Conventional Commits形式のメッセージ

5. メッセージを選択してEnterを押してコミット

### ステップ 6: すべてが動作することを確認

テストスイートを実行して、すべてが正しく設定されていることを確認:

```bash
# mockバックエンドでテスト（APIキー不要）
export AI_BACKEND=mock
./test-all-error-scenarios.sh

# 選択したバックエンドでテスト
export AI_BACKEND=gemini  # またはclaudeまたはollama
echo "test change" | ./ai-commit-generator.sh
```

コミットメッセージが生成されれば、すべて設定完了です！

## インストールのトラブルシューティング

### "command not found: gemini"または類似のエラー

**問題**: AI CLIツールがPATHにない

**解決策**:
- Pythonパッケージの場合: pipインストール場所がPATHにあることを確認
- npmパッケージの場合: npm globalのbinがPATHにあることを確認
- 確認: `which gemini`または`which claude`または`which ollama`

### "GEMINI_API_KEY not set"エラー

**問題**: 環境変数が設定されていない

**解決策**:
1. 設定されているか確認: `echo $GEMINI_API_KEY`
2. 空の場合、シェルプロファイルに追加:
   ```bash
   echo 'export GEMINI_API_KEY="your-key"' >> ~/.bashrc
   source ~/.bashrc
   ```

### Ctrl+Aを押したときに"No such file or directory"

**問題**: config.ymlのスクリプトパスが正しくない

**解決策**:
1. スクリプトをインストールした場所を確認: `pwd`
2. config.ymlを完全な絶対パスで更新
3. スクリプトが実行可能であることを確認: `ls -l *.sh`

### Ollama "connection refused"エラー

**問題**: Ollamaサービスが実行されていない

**解決策**:
```bash
# 別のターミナルでOllamaを起動
ollama serve

# またはシステムサービスとして設定（Linux）
sudo systemctl enable ollama
sudo systemctl start ollama
```

### LazyGitがCtrl+Aオプションを表示しない

**問題**: 設定ファイルが読み込まれていないか構文エラー

**解決策**:
1. 設定の場所を確認: `ls -la ~/.config/lazygit/config.yml`
2. YAML構文を検証: `python3 -c "import yaml; yaml.safe_load(open('config.yml'))"`
3. LazyGitを完全に再起動

## 次のステップ

- 使用方法については[README.md](README.md)を読む
- `ai-commit-generator.sh`でプロンプトをカスタマイズ
- 微調整のための追加の環境変数を設定
- バックエンドの素早い切り替えのためのシェルエイリアスの設定を検討

## ヘルプを得る

問題が発生した場合:

1. README.mdの[トラブルシューティング](README.md#troubleshooting)セクションを確認
2. AIバックエンドが独立して動作することを確認:
   ```bash
   # Geminiの場合
   python3 -c "import google.generativeai as genai; print('OK')"
   
   # Claudeの場合
   claude --version
   
   # Ollamaの場合
   ollama list
   ```
3. スクリプトを個別にテスト:
   ```bash
   echo "test diff" | ./ai-commit-generator.sh
   ```
4. LazyGitログでエラーを確認

## アンインストール

AIコミットジェネレーターを削除するには:

1. `~/.config/lazygit/config.yml`からカスタムコマンドを削除
2. クローンしたリポジトリを削除
3. シェルプロファイルから環境変数を削除
4. （オプション）AI CLIツールをアンインストール:
   ```bash
   pip uninstall google-generativeai
   npm uninstall -g @anthropic-ai/claude-cli
   # Ollamaの場合、アンインストール手順に従う
   ```
