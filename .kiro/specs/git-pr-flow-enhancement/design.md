# Design: git-pr-flow-enhancement

設計方針：
1. `opencode/AGENTS.md` に `<skill>` 定義を追加・更新する。
2. スキル名は `git-pr-flow` とし、引数 `user_message` を受け取る。
3. スキル内のプロンプトで `{{user_message}}` を参照し、以下のフロー制御を行うロジックを含める：
   - コンテキスト解析（例：「コミット不要」→ git commit/push スキップ）
   - ターゲットブランチ指定（例：「develop」→ base branch: develop）
   - 途中再開（例：「ブランチ作成済み」→ git checkout/push のみ）
4. 具体的なプロンプトの例を含める。
