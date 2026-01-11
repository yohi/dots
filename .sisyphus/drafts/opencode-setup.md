# Draft: OpenCode（opencode）インストール & 設定適用

## 依頼内容（原文）
- 「opencodeのインストールと設定ファイルの適用を作成してほしい」
- 追加条件: `.cursor/rules/makefile-organization.mdc` に基づく（Makefile分割/`mk/*.mk` への整理、include順序、ターゲット命名など）

## 要件（確定）
- （未確定）

## 技術的な決定（暫定）
- Makefileは `mk/` 配下に機能別 `.mk` を置き、メイン `Makefile` は include と最小限のターゲットにする（ルール準拠）。
- 既存の `mk/codex.mk` などがある場合は、そこへ統合または `mk/opencode.mk` を新設（命名規則: 小文字 + ハイフン、アンダースコア禁止）。

## 調査メモ（これから）
- リポジトリ内に既に opencode/Codex 関連の make ターゲット・設定があるかを確認する。
- 適用すべき「設定ファイル」が何を指すか（opencode の config、Cursor/VS Code設定、シェル設定、など）を特定する。

## 未決事項（質問候補）
- 「opencode」は OpenAI の Codex CLI（OpenCode）を指しますか？ それとも別プロジェクト（同名ツール）ですか？
- インストール方法の希望はありますか？（例: `brew` / `apt` / `npm` / `cargo` / 公式バイナリDL）
- 設定適用の対象OSは？（Ubuntu / macOS / WSL 等）
- 既存の dotfiles 運用（symlink、コピー、XDG準拠）に合わせますか？

## スコープ境界（暫定）
- INCLUDE: opencode の導入手順、設定ファイルの配置/リンク、Makefileターゲット追加。
- EXCLUDE: opencode 以外のツール大改修、無関係な設定整理（ユーザー指定があれば拡張）。
