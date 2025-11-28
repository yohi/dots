# クイックスタートガイド

5分以内でLazyGitでAI駆動のコミットメッセージを取得！

## パスを選択

### パス 1: クイックテスト（セットアップ不要）

まずmockバックエンドで試してみる:

```bash
# 1. リポジトリをクローン
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit

# 2. スクリプトを実行可能にする
chmod +x *.sh

# 3. 動作することをテスト
export AI_BACKEND=mock
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh

# 4. config.ymlを完全なパスで更新
# config.ymlを編集してscripts/lazygit-ai-commit/ai-commit-generator.shを完全なパスに置き換える
# 例: /home/username/lazygit-ai-commit/ai-commit-generator.sh

# 5. LazyGit設定にコピー
cp config.yml ~/.config/lazygit/config.yml

# 6. LazyGitで試す
cd /tmp
git init test-repo
cd test-repo
echo "test" > test.txt
git add test.txt
lazygit
# Ctrl+Aを押してAI生成メッセージを確認！
```

### パス 2: Geminiセットアップ（推奨）

Google Geminiで実際のAI駆動メッセージを取得:

```bash
# 1. Geminiをインストール
pip install google-generativeai

# 2. APIキーを取得
# アクセス: https://aistudio.google.com/app/apikey
# "Create API Key"をクリックしてコピー

# 3. 環境変数を設定
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.bashrc
echo 'export AI_BACKEND="gemini"' >> ~/.bashrc
source ~/.bashrc

# 4. クローンしてセットアップ
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit
chmod +x *.sh

# 5. テスト
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh

# 6. config.ymlのパスを更新してLazyGitにコピー
# config.ymlを編集: scripts/lazygit-ai-commit/ai-commit-generator.shを完全なパスに置き換える
cp config.yml ~/.config/lazygit/config.yml

# 7. LazyGitで使用
lazygit
# filesビューでCtrl+Aを押す！
```

### パス 3: Ollamaセットアップ（プライバシー重視）

AIを完全にローカルで実行:

```bash
# 1. Ollamaをインストール
curl -fsSL https://ollama.com/install.sh | sh

# 2. モデルをダウンロード
ollama pull mistral

# 3. Ollamaを起動（別のターミナルで）
ollama serve

# 4. 環境変数を設定
echo 'export AI_BACKEND="ollama"' >> ~/.bashrc
source ~/.bashrc

# 5. クローンしてセットアップ
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit
chmod +x *.sh

# 6. テスト
echo "test change" | scripts/lazygit-ai-commit/ai-commit-generator.sh

# 7. config.ymlのパスを更新してLazyGitにコピー
# config.ymlを編集: scripts/lazygit-ai-commit/ai-commit-generator.shを完全なパスに置き換える
cp config.yml ~/.config/lazygit/config.yml

# 8. LazyGitで使用
lazygit
# filesビューでCtrl+Aを押す！
```

## 使い方

セットアップ後:

1. **変更をステージング** - LazyGitでファイル上で`space`を押す
2. **`Ctrl+A`を押す** - コミットメッセージを生成
3. **移動** - 矢印キーで
4. **`Enter`を押す** - 選択したメッセージでコミット
5. **`Esc`を押す** - キャンセル

## トラブルシューティング

### "No such file or directory"

**問題**: config.ymlのスクリプトパスが間違っている

**修正**: `~/.config/lazygit/config.yml`を編集して完全な絶対パスを使用:
```yaml
git diff --cached | head -c 12000 | /home/username/lazygit-ai-commit/ai-commit-generator.sh | /home/username/lazygit-ai-commit/parse-ai-output.sh
```

### "GEMINI_API_KEY not set"

**問題**: 環境変数が設定されていない

**修正**:
```bash
export GEMINI_API_KEY="your-key"
export AI_BACKEND="gemini"
# 永続化するために~/.bashrcに追加
```

### "AI tool failed"

**問題**: バックエンドがインストールされていないか実行されていない

**修正**:
- Gemini: `pip install google-generativeai`
- Claude: `npm install -g @anthropic-ai/claude-cli`
- Ollama: `ollama serve`が実行中であることを確認

### "No staged changes"

**問題**: コミット用にステージングされたファイルがない

**修正**: LazyGitでファイル上で`space`を押して最初にステージング

## 次のステップ

- 完全なドキュメントは[README.md](README.md)を読む
- 詳細なセットアップは[INSTALLATION.md](INSTALLATION.md)を参照
- バックエンド比較は[AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md)を確認
- `ai-commit-generator.sh`でプロンプトをカスタマイズ

## ヘルプを得る

問題を診断するためにテストスイートを実行:
```bash
./test-ai-backend-integration.sh
```

これにより、何が動作していて何を修正する必要があるかが正確にわかります！
