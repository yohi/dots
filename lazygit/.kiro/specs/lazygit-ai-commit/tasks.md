# Implementation Plan

- [x] 1. LazyGit設定ファイルの作成とAI統合の基本構造実装
  - config.ymlにcustomCommandsセクションを作成
  - キーバインディング（`<c-a>`）とコンテキスト（`files`）を設定
  - menuFromCommandプロンプトの基本構造を定義
  - _Requirements: 1.1, 9.1, 9.2, 9.3_

- [x] 2. Diff取得とエラーハンドリングの実装
  - `git diff --cached`コマンドでステージング差分を取得するスクリプトを作成
  - 空のステージングエリアを検出するチェック機能を実装
  - エラーメッセージ表示機能を実装
  - _Requirements: 5.1, 2.4_

- [ ]* 2.1 Diff取得のユニットテストを作成
  - 空のステージングエリアでエラーを返すテスト
  - 有効な変更がある場合にdiffを出力するテスト
  - _Requirements: 5.1, 2.4_

- [x] 3. サイズ制限機能の実装
  - Diff出力を12KBに制限する処理を実装
  - `head -c 12000`を使用した切り詰め機能を追加
  - _Requirements: 8.1_

- [ ]* 3.1 サイズ制限のユニットテストを作成
  - 12KB以下の入力がそのまま通過するテスト
  - 12KB超の入力が正しく切り詰められるテスト
  - _Requirements: 8.1_

- [x] 4. AI CLIインターフェースの実装
  - モックAIツールスクリプトを作成（テスト用）
  - プロンプト構造を定義（Conventional Commits形式、Markdown除去指示）
  - stdin/stdoutパイプライン処理を実装
  - _Requirements: 5.2, 5.3, 6.1, 6.3_

- [ ]* 4.1 プロパティテスト: 複数候補生成
  - **Property 1: 複数候補生成**
  - **Validates: Requirements 2.1**
  - 任意の有効なdiff入力に対して2個以上の候補が生成されることを検証
  - _Requirements: 2.1_

- [ ]* 4.2 プロパティテスト: Conventional Commits形式準拠
  - **Property 4: Conventional Commits形式準拠**
  - **Validates: Requirements 6.1**
  - 任意のdiff入力に対して生成メッセージが形式に従うことを検証
  - _Requirements: 6.1_

- [ ]* 4.3 プロパティテスト: Markdown除去
  - **Property 5: Markdown除去**
  - **Validates: Requirements 6.3**
  - 任意のdiff入力に対して生成メッセージにMarkdown記号が含まれないことを検証
  - _Requirements: 6.3_

- [x] 5. 正規表現パーサーの実装
  - AI出力を解析する正規表現（`^(?P<msg>.+)$`）を実装
  - 空行をスキップする処理を追加
  - 番号付きリスト対応の正規表現を実装
  - _Requirements: 5.4_

- [ ]* 5.1 プロパティテスト: 正規表現解析の完全性
  - **Property 2: 正規表現解析の完全性**
  - **Validates: Requirements 5.4**
  - 任意の改行区切りテキストが全て抽出されることを検証
  - _Requirements: 5.4_

- [ ]* 5.2 正規表現解析のユニットテストを作成
  - 標準的な改行区切り入力の分割テスト
  - 番号付きリストの処理テスト
  - 空行スキップのテスト
  - _Requirements: 5.4_

- [x] 6. menuFromCommandの完全な設定
  - commandフィールドにパイプライン全体を統合
  - filterフィールドに正規表現を設定
  - valueFormatとlabelFormatを設定（色付き表示）
  - loadingTextを設定してユーザーフィードバックを追加
  - _Requirements: 2.2, 2.3, 3.1, 3.2, 1.2_

- [x] 7. コミット実行とエスケープ処理の実装
  - `git commit -m {{.Form.SelectedMsg | quote}}`コマンドを実装
  - `| quote`フィルタによるシェルエスケープを適用
  - コミット後のUI更新を確認
  - _Requirements: 4.1, 4.2, 4.3_

- [ ]* 7.1 プロパティテスト: シェルインジェクション防止
  - **Property 3: シェルインジェクション防止**
  - **Validates: Requirements 4.2, 8.3**
  - 任意の特殊文字を含むメッセージが安全にエスケープされることを検証
  - _Requirements: 4.2, 8.3_

- [ ]* 7.2 エスケープ処理のユニットテストを作成
  - シングルクォートを含むメッセージのテスト
  - ダブルクォートを含むメッセージのテスト
  - バックティックを含むメッセージのテスト
  - セミコロンを含むメッセージのテスト
  - _Requirements: 4.2, 8.3_

- [x] 8. エラーハンドリングの強化
  - AI実行エラー時の処理を実装（`set -o pipefail`）
  - タイムアウト処理を実装（`timeout 30s`）
  - 不正な形式の出力に対するエラーメッセージを実装
  - _Requirements: 8.2, 8.4_

- [x] 9. 実際のAI CLIツールとの統合
  - Gemini CLI、Claude CLI、またはOllamaのいずれかを選択
  - 選択したAIツールのインストール手順をドキュメント化
  - プロンプトを実際のAIツールに合わせて調整
  - 環境変数でAPIキーを管理する設定を追加
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 10. 統合テストとドキュメント作成
  - テスト用Gitリポジトリで完全なワークフローを検証
  - README.mdに使用方法とトラブルシューティングを記載
  - 設定例（複数のAIバックエンド）をドキュメント化
  - _Requirements: 3.3, 3.4_

- [x] 11. チェックポイント - 全テストの実行確認
  - 全てのテストが通過することを確認
  - ユーザーに質問があれば確認
