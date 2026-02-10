# Requirements: git-pr-flow-enhancement

以下の要件を定義してください：
1. OpenCodeの `/git-pr-flow` コマンドが引数（追加のコンテキスト）を受け取れるようにする。
2. LLMがコンテキストを解釈し、適切なフローを選択する（例：「コミット不要」ならPR作成のみ、「master以外」ならターゲットブランチ変更など）。
3. 主なユースケース：
   - PR作成のみ（commit, pushはスキップ）
   - ターゲットブランチの指定
   - 途中からの再開
4. 実装場所：`opencode/AGENTS.md` (または適切な場所) に `<skill>` 定義を追加・更新する。
5. 既存の `git-pr-flow` がない場合は新規作成する。
