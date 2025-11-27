# Requirements Document

## Introduction

本仕様は、LazyGit（Git用ターミナルUIツール）にAIベースのコミットメッセージ自動生成機能を統合するための要件を定義する。開発者がステージングされた変更内容から高品質なコミットメッセージを、編集作業なしに目視確認のみで採用できるワークフローを実現する。これにより、コミット作業の認知的負荷を軽減し、Atomic Commitsの促進とコミット品質の向上を目指す。

## Glossary

- **LazyGit**: Gitコマンドを操作するためのターミナルベースのユーザーインターフェース（TUI）ツール
- **Custom Commands**: LazyGitの拡張機能。config.ymlファイルでユーザー定義のコマンドとキーバインディングを設定可能
- **menuFromCommand**: LazyGitのプロンプトタイプの一つ。シェルコマンドの出力を動的に解析してメニュー項目を生成する機能
- **Staging Area**: Gitにおいて、次回のコミットに含める変更を一時的に保持する領域
- **Diff**: ファイルの変更内容を示す差分情報
- **AI CLI Tool**: コマンドラインから利用可能なAI言語モデルのインターフェース（例：gemini-cli, sgpt, ollama）
- **Conventional Commits**: コミットメッセージの標準化されたフォーマット（例：feat:, fix:, docs:）
- **Context**: LazyGitにおいて、特定の画面や操作状態を示す概念（例：files, branches, commits）

## Requirements

### Requirement 1

**User Story:** 開発者として、LazyGitから離れることなくステージングされた変更からAIでコミットメッセージを生成したい。そうすることで、ワークフローのコンテキストを維持し、認知的負荷を軽減できる。

#### Acceptance Criteria

1. WHEN 開発者がfilesコンテキストからAIコミットコマンドを起動する THEN LazyGitシステムは外部アプリケーションに切り替えることなくコマンドを実行すること
2. WHEN AIコミットコマンドが実行される THEN LazyGitシステムはフォアグラウンドに留まり、ユーザーにローディングフィードバックを表示すること
3. WHEN コマンドが完了する THEN LazyGitシステムはLazyGitターミナルインターフェース内で結果を表示すること

### Requirement 2

**User Story:** 開発者として、AIが生成した複数のコミットメッセージ候補を見たい。そうすることで、変更内容に最も適したものを選択できる。

#### Acceptance Criteria

1. WHEN AIがステージングされた変更を処理する THEN LazyGitシステムは複数のコミットメッセージ候補を生成すること
2. WHEN 候補が生成される THEN LazyGitシステムは選択可能なメニューリストとして表示すること
3. WHEN メニューを表示する THEN LazyGitシステムは各候補メッセージを視覚的なハイライトを伴う読みやすい形式で表示すること
4. WHEN ステージングされた変更が存在しない THEN LazyGitシステムはエラーメッセージを表示し、AI実行を防止すること

### Requirement 3

**User Story:** 開発者として、コミット前にAI生成メッセージを目視確認したい。そうすることで、手動編集なしに正確性を保証できる。

#### Acceptance Criteria

1. WHEN メニューが表示される THEN LazyGitシステムはキーボード操作で候補間を移動できるようにすること
2. WHEN ユーザーが候補を選択する THEN LazyGitシステムは選択されたメッセージを目視確認のためにハイライト表示すること
3. WHEN ユーザーが選択を確定する THEN LazyGitシステムは選択されたメッセージでgit commitコマンドを実行すること
4. WHEN ユーザーがメニューをキャンセルする THEN LazyGitシステムはコミット操作を中止し、前の状態に戻ること

### Requirement 4

**User Story:** 開発者として、選択したコミットメッセージを生成されたまま使用したい。そうすることで、編集なしに素早くコミットを完了できる。

#### Acceptance Criteria

1. WHEN ユーザーがメッセージ選択を確定する THEN LazyGitシステムはエディタを開かずにメッセージテキストを直接git commitに渡すこと
2. WHEN メッセージをgitに渡す THEN LazyGitシステムはシェルインジェクションを防ぐために特殊文字を適切にエスケープすること
3. WHEN コミットが完了する THEN LazyGitシステムは新しいコミットを反映するためにインターフェースを更新すること

### Requirement 5

**User Story:** 開発者として、AIにgit diffの出力を解析させ、コンテキストに適したメッセージを生成させたい。そうすることで、コミットメッセージが変更内容を正確に反映する。

#### Acceptance Criteria

1. WHEN AIコマンドが実行される THEN LazyGitシステムはgit diff --cachedを使用してステージングされた変更を取得すること
2. WHEN diffが取得される THEN LazyGitシステムはdiffの内容を標準入力経由で設定されたAI CLIツールにパイプすること
3. WHEN AIツールを呼び出す THEN LazyGitシステムは出力フォーマット要件を指定するプロンプトを含めること
4. WHEN AIツールが出力を返す THEN LazyGitシステムは正規表現を使用して出力を解析し、個別のメッセージ候補を抽出すること

### Requirement 6

**User Story:** 開発者として、コミットメッセージをConventional Commits形式に従わせたい。そうすることで、リポジトリが一貫したコミット履歴を維持できる。

#### Acceptance Criteria

1. WHEN メッセージを生成する THEN AIツールはタイプ接頭辞を持つConventional Commits形式に従ったメッセージを生成すること
2. WHEN メッセージをフォーマットする THEN AIツールは関連する場合に適切なスコープ情報を含めること
3. WHEN メッセージを出力する THEN AIツールはMarkdownフォーマットなしで簡潔で説明的なテキストを生成すること

### Requirement 7

**User Story:** 開発者として、使用するAIバックエンドを設定したい。そうすることで、速度、コスト、プライバシー要件に基づいて選択できる。

#### Acceptance Criteria

1. WHEN 設定が定義される THEN LazyGitシステムはconfig.ymlで任意のAI CLIコマンドの指定をサポートすること
2. WHEN AIコマンドが呼び出される THEN LazyGitシステムはdiffを入力として設定されたコマンドを実行すること
3. WHEN AIバックエンドが変更される THEN LazyGitシステムはコード変更なしに機能し続けること

### Requirement 8

**User Story:** 開発者として、システムにエッジケースを適切に処理させたい。そうすることで、予期しない状況がワークフローを壊さない。

#### Acceptance Criteria

1. WHEN diff出力がトークン制限を超える THEN LazyGitシステムはAIに送信する前に入力を適切なサイズに切り詰めること
2. WHEN AIツールが不正な形式の出力を返す THEN LazyGitシステムはエラーメッセージを表示し、ユーザーが再試行またはキャンセルできるようにすること
3. WHEN 生成されたメッセージに特殊文字が含まれる THEN LazyGitシステムはコマンドインジェクションを防ぐために適切にエスケープすること
4. WHEN AIツールの実行がタイムアウトする THEN LazyGitシステムはタイムアウトメッセージを表示し、ユーザーに制御を返すこと

### Requirement 9

**User Story:** 開発者として、キーボードショートカットでAIコミット機能を起動したい。そうすることで、ワークフロー中に素早くアクセスできる。

#### Acceptance Criteria

1. WHEN カスタムコマンドが設定される THEN LazyGitシステムはユーザー指定のキー組み合わせにコマンドをバインドすること
2. WHEN filesコンテキストでキー組み合わせが押される THEN LazyGitシステムはAIコミットワークフローを実行すること
3. WHEN 他のコンテキストでキー組み合わせが押される THEN LazyGitシステムは意図しない実行を防ぐためにコマンドを無視すること
