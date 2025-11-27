# TRACEABILITY DB

## COVERAGE ANALYSIS

Total requirements: 31
Coverage: 19.35

## TRACEABILITY

### Property 1: 複数候補生成

*任意の*有効なdiff入力に対して、AIシステムは2個以上のコミットメッセージ候補を生成すること

**Validates**
- Criteria 2.1: WHEN AIがステージングされた変更を処理する THEN LazyGitシステムは複数のコミットメッセージ候補を生成すること

**Implementation tasks**
- Task 4.1: 4.1 プロパティテスト: 複数候補生成

**Implemented PBTs**
- No implemented PBTs found

### Property 2: 正規表現解析の完全性

*任意の*改行区切りテキスト出力（各行が非空）に対して、正規表現パーサーは各行を個別のメッセージ候補として抽出すること

**Validates**
- Criteria 5.4: WHEN AIツールが出力を返す THEN LazyGitシステムは正規表現を使用して出力を解析し、個別のメッセージ候補を抽出すること

**Implementation tasks**
- Task 5.1: 5.1 プロパティテスト: 正規表現解析の完全性

**Implemented PBTs**
- No implemented PBTs found

### Property 3: シェルインジェクション防止

*任意の*コミットメッセージテキスト（特殊文字を含む）に対して、エスケープ処理後のコマンド文字列はシェルインジェクションを引き起こさないこと

**Validates**
- Criteria 4.2: WHEN メッセージをgitに渡す THEN LazyGitシステムはシェルインジェクションを防ぐために特殊文字を適切にエスケープすること
- Criteria 8.3: WHEN 生成されたメッセージに特殊文字が含まれる THEN LazyGitシステムはコマンドインジェクションを防ぐために適切にエスケープすること

**Implementation tasks**
- Task 7.1: 7.1 プロパティテスト: シェルインジェクション防止

**Implemented PBTs**
- No implemented PBTs found

### Property 4: Conventional Commits形式準拠

*任意の*diff入力に対して、生成される全てのコミットメッセージは有効なConventional Commits形式（`<type>(<scope>): <description>`または`<type>: <description>`）に従うこと

**Validates**
- Criteria 6.1: WHEN メッセージを生成する THEN AIツールはタイプ接頭辞を持つConventional Commits形式に従ったメッセージを生成すること

**Implementation tasks**
- Task 4.2: 4.2 プロパティテスト: Conventional Commits形式準拠

**Implemented PBTs**
- No implemented PBTs found

### Property 5: Markdown除去

*任意の*生成されたコミットメッセージに対して、Markdown記号（`**`, `*`, `` ` ``, `#`, `-`など）が含まれないこと

**Validates**
- Criteria 6.3: WHEN メッセージを出力する THEN AIツールはMarkdownフォーマットなしで簡潔で説明的なテキストを生成すること

**Implementation tasks**
- Task 4.3: 4.3 プロパティテスト: Markdown除去

**Implemented PBTs**
- No implemented PBTs found

## DATA

### ACCEPTANCE CRITERIA (31 total)
- 1.1: WHEN 開発者がfilesコンテキストからAIコミットコマンドを起動する THEN LazyGitシステムは外部アプリケーションに切り替えることなくコマンドを実行すること (not covered)
- 1.2: WHEN AIコミットコマンドが実行される THEN LazyGitシステムはフォアグラウンドに留まり、ユーザーにローディングフィードバックを表示すること (not covered)
- 1.3: WHEN コマンドが完了する THEN LazyGitシステムはLazyGitターミナルインターフェース内で結果を表示すること (not covered)
- 2.1: WHEN AIがステージングされた変更を処理する THEN LazyGitシステムは複数のコミットメッセージ候補を生成すること (covered)
- 2.2: WHEN 候補が生成される THEN LazyGitシステムは選択可能なメニューリストとして表示すること (not covered)
- 2.3: WHEN メニューを表示する THEN LazyGitシステムは各候補メッセージを視覚的なハイライトを伴う読みやすい形式で表示すること (not covered)
- 2.4: WHEN ステージングされた変更が存在しない THEN LazyGitシステムはエラーメッセージを表示し、AI実行を防止すること (not covered)
- 3.1: WHEN メニューが表示される THEN LazyGitシステムはキーボード操作で候補間を移動できるようにすること (not covered)
- 3.2: WHEN ユーザーが候補を選択する THEN LazyGitシステムは選択されたメッセージを目視確認のためにハイライト表示すること (not covered)
- 3.3: WHEN ユーザーが選択を確定する THEN LazyGitシステムは選択されたメッセージでgit commitコマンドを実行すること (not covered)
- 3.4: WHEN ユーザーがメニューをキャンセルする THEN LazyGitシステムはコミット操作を中止し、前の状態に戻ること (not covered)
- 4.1: WHEN ユーザーがメッセージ選択を確定する THEN LazyGitシステムはエディタを開かずにメッセージテキストを直接git commitに渡すこと (not covered)
- 4.2: WHEN メッセージをgitに渡す THEN LazyGitシステムはシェルインジェクションを防ぐために特殊文字を適切にエスケープすること (covered)
- 4.3: WHEN コミットが完了する THEN LazyGitシステムは新しいコミットを反映するためにインターフェースを更新すること (not covered)
- 5.1: WHEN AIコマンドが実行される THEN LazyGitシステムはgit diff --cachedを使用してステージングされた変更を取得すること (not covered)
- 5.2: WHEN diffが取得される THEN LazyGitシステムはdiffの内容を標準入力経由で設定されたAI CLIツールにパイプすること (not covered)
- 5.3: WHEN AIツールを呼び出す THEN LazyGitシステムは出力フォーマット要件を指定するプロンプトを含めること (not covered)
- 5.4: WHEN AIツールが出力を返す THEN LazyGitシステムは正規表現を使用して出力を解析し、個別のメッセージ候補を抽出すること (covered)
- 6.1: WHEN メッセージを生成する THEN AIツールはタイプ接頭辞を持つConventional Commits形式に従ったメッセージを生成すること (covered)
- 6.2: WHEN メッセージをフォーマットする THEN AIツールは関連する場合に適切なスコープ情報を含めること (not covered)
- 6.3: WHEN メッセージを出力する THEN AIツールはMarkdownフォーマットなしで簡潔で説明的なテキストを生成すること (covered)
- 7.1: WHEN 設定が定義される THEN LazyGitシステムはconfig.ymlで任意のAI CLIコマンドの指定をサポートすること (not covered)
- 7.2: WHEN AIコマンドが呼び出される THEN LazyGitシステムはdiffを入力として設定されたコマンドを実行すること (not covered)
- 7.3: WHEN AIバックエンドが変更される THEN LazyGitシステムはコード変更なしに機能し続けること (not covered)
- 8.1: WHEN diff出力がトークン制限を超える THEN LazyGitシステムはAIに送信する前に入力を適切なサイズに切り詰めること (not covered)
- 8.2: WHEN AIツールが不正な形式の出力を返す THEN LazyGitシステムはエラーメッセージを表示し、ユーザーが再試行またはキャンセルできるようにすること (not covered)
- 8.3: WHEN 生成されたメッセージに特殊文字が含まれる THEN LazyGitシステムはコマンドインジェクションを防ぐために適切にエスケープすること (covered)
- 8.4: WHEN AIツールの実行がタイムアウトする THEN LazyGitシステムはタイムアウトメッセージを表示し、ユーザーに制御を返すこと (not covered)
- 9.1: WHEN カスタムコマンドが設定される THEN LazyGitシステムはユーザー指定のキー組み合わせにコマンドをバインドすること (not covered)
- 9.2: WHEN filesコンテキストでキー組み合わせが押される THEN LazyGitシステムはAIコミットワークフローを実行すること (not covered)
- 9.3: WHEN 他のコンテキストでキー組み合わせが押される THEN LazyGitシステムは意図しない実行を防ぐためにコマンドを無視すること (not covered)

### IMPORTANT ACCEPTANCE CRITERIA (0 total)

### CORRECTNESS PROPERTIES (5 total)
- Property 1: 複数候補生成
- Property 2: 正規表現解析の完全性
- Property 3: シェルインジェクション防止
- Property 4: Conventional Commits形式準拠
- Property 5: Markdown除去

### IMPLEMENTATION TASKS (20 total)
1. LazyGit設定ファイルの作成とAI統合の基本構造実装
2. Diff取得とエラーハンドリングの実装
2.1 Diff取得のユニットテストを作成
3. サイズ制限機能の実装
3.1 サイズ制限のユニットテストを作成
4. AI CLIインターフェースの実装
4.1 プロパティテスト: 複数候補生成
4.2 プロパティテスト: Conventional Commits形式準拠
4.3 プロパティテスト: Markdown除去
5. 正規表現パーサーの実装
5.1 プロパティテスト: 正規表現解析の完全性
5.2 正規表現解析のユニットテストを作成
6. menuFromCommandの完全な設定
7. コミット実行とエスケープ処理の実装
7.1 プロパティテスト: シェルインジェクション防止
7.2 エスケープ処理のユニットテストを作成
8. エラーハンドリングの強化
9. 実際のAI CLIツールとの統合
10. 統合テストとドキュメント作成
11. チェックポイント - 全テストの実行確認

### IMPLEMENTED PBTS (0 total)