# プロジェクト構造

## ディレクトリレイアウト

```text
.
├── archive/                          # 過去のドキュメントと実装ノート
│   ├── AI-CLI-INTERFACE.md
│   ├── COMMIT-EXECUTION-IMPLEMENTATION.md
│   ├── MENU-FROM-COMMAND-IMPLEMENTATION.md
│   ├── REGEX-PARSER-IMPLEMENTATION.md
│   └── TASK-*-*.md                   # タスク完了サマリー
│
├── config.example.yml                # LazyGit設定テンプレート
├── config.yml                        # アクティブなLazyGit設定
│
├── docs/lazygit-ai-commit/           # ユーザー向けドキュメント
│   ├── README.md                     # メインドキュメント（日本語）
│   ├── QUICKSTART.md                 # 5分セットアップガイド
│   ├── INSTALLATION.md               # 詳細なインストール手順
│   ├── AI-BACKEND-GUIDE.md           # AIバックエンド設定
│   ├── BACKEND-COMPARISON.md         # バックエンド機能比較
│   ├── TESTING-GUIDE.md              # テスト手順
│   ├── DOCUMENTATION-IMPROVEMENTS.md # ドキュメントロードマップ
│   └── PROPERTY-COVERAGE-STATUS.md   # テストカバレッジ状況
│
├── scripts/lazygit-ai-commit/        # コア実装スクリプト
│   ├── ai-commit-generator.sh        # AIバックエンドインターフェース（メインスクリプト）
│   ├── parse-ai-output.sh            # 正規表現による出力パーサー
│   ├── get-staged-diff.sh            # Git diff抽出
│   └── mock-ai-tool.sh               # テスト用バックエンド
│
└── tests/lazygit-ai-commit/          # テストスイート
    ├── test-complete-workflow.sh     # エンドツーエンド統合テスト（23テスト）
    ├── test-all-error-scenarios.sh   # エラー処理テスト
    ├── test-ai-backend-integration.sh
    ├── test-commit-escape.sh
    ├── test-error-handling.sh
    ├── test-lazygit-commit-integration.sh
    ├── test-menu-integration.sh
    ├── test-regex-parser.sh
    ├── test-timeout-handling.sh
    └── verify-task-10.sh
```

## 主要ファイル

### 設定
- **config.example.yml**: すべてのオプションを説明する詳細なコメント付きテンプレート
- **config.yml**: アクティブな設定（ユーザー変更を加えたexampleのコピー）

### コアスクリプト
- **ai-commit-generator.sh**: 
  - AIバックエンド選択を処理（gemini/claude/ollama/mock）
  - APIキーと環境変数を管理
  - タイムアウト保護を実装
  - Conventional Commits用のプロンプトをフォーマット
  
- **parse-ai-output.sh**:
  - AI出力を行ごとに解析
  - 番号付きリストの接頭辞を削除
  - 空行をフィルタリング
  - 出力にメッセージが含まれることを検証

### ドキュメント
- **README.md**: 日本語の包括的ガイド（メインドキュメント）
- **QUICKSTART.md**: 異なるバックエンド用の高速セットアップパス
- **INSTALLATION.md**: ステップバイステップのインストール手順
- **AI-BACKEND-GUIDE.md**: 詳細なバックエンド設定
- **TESTING-GUIDE.md**: テストの実行と解釈方法

### テスト
- **test-complete-workflow.sh**: 主要な統合テストスイート
- **test-all-error-scenarios.sh**: エラーパス検証
- 個別機能用のコンポーネント固有テスト

## 命名規則

- **スクリプト**: ハイフン付き小文字（例: `ai-commit-generator.sh`）
- **ドキュメント**: ハイフン付き大文字（例: `QUICKSTART.md`）
- **テスト**: `test-`接頭辞（例: `test-regex-parser.sh`）
- **アーカイブ**: 大文字の説明的な名前（例: `TASK-10-COMPLETION.md`）

## ファイル構成の原則

1. **関心の分離**: スクリプト、ドキュメント、テストを別々のディレクトリに配置
2. **名前空間接頭辞**: すべてのファイルを`lazygit-ai-commit/`サブディレクトリ配下に配置
3. **自己完結型スクリプト**: 各スクリプトは適切なエラー処理により独立して実行可能
4. **包括的なドキュメント**: 異なるユーザーニーズ（クイックスタート vs 詳細）に対応する複数のドキュメント
5. **テストカバレッジ**: テストは実装スクリプトの構造を反映

## パス規則

- **絶対パス必須**: LazyGit設定ではスクリプトへの絶対パスを使用する必要がある
- **スクリプトディレクトリ検出**: スクリプトは相対インポートに`$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)`を使用
- **設定場所**: `~/.config/lazygit/config.yml`（標準LazyGit場所）
- **環境変数**: 永続化のために`~/.bashrc`または`~/.zshrc`に設定
