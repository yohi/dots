# 調査・設計意思決定ログ: neovim-config-modernization

---
**目的**: 技術設計に必要な調査結果、アーキテクチャ検討、および設計判断の根拠を記録する。
---

## サマリ
- **機能**: `neovim-config-modernization`
- **調査スコープ**: Extension（既存システムのリファクタリング）
- **主要な発見**:
  1. **LSP設定の重複**: `lua/lsp.lua` と `lua/plugins/lsp_cfg.lua` の両方で `vim.lsp.enable()` が呼ばれ、`basedpyright`, `bashls`, `lua_ls` 等のサーバ設定が二重定義されている
  2. **レガシーVim scriptの残存**: `vim/rc/*.vim` に5件のTODOマーカーと未整理なコメントアウトコードが存在
  3. **自動更新チェックの有効化**: `lazy.lua` で `checker = { enabled = true }` が設定されており、要件 4.3 に違反
  4. **updatetime設定の配置**: 削除予定の `lsp.lua` 内に `updatetime=300` が設定されており、移行時に移設が必要

## 調査ログ

### Vim script設定の内容分析
- **背景**: Lua移行対象のVim scriptファイルを特定するため
- **調査ソース**: `vim/rc/basic.vim`, `vim/rc/keymap.vim`, `vim/rc/ui.vim`, `vim/rc/search.vim`
- **発見**:
  - `basic.vim` (153行): エンコーディング、インデント、autocmd（WezTerm連携含む）、プロバイダ無効化
  - `keymap.vim` (72行): ノーマル/挿入/コマンドモードのキーマップ
  - `ui.vim` (64行): 表示設定（行番号、カーソル行、サインカラム、termguicolors）
  - `search.vim` (19行): 検索オプション
- **影響**: これら4ファイル合計約308行をLuaに移植し、元ファイルは削除する

### LSP設定の競合調査
- **背景**: LSP設定の一元化戦略を決定するため
- **調査ソース**: `vim/lua/lsp.lua`, `vim/lua/plugins/lsp_cfg.lua`
- **発見**:
  - **lsp.lua**:
    - `vim.lsp.config()` で直接9個のLSPサーバを定義
    - `vim.lsp.enable()` でサーバを有効化
    - 診断設定 (`vim.diagnostic.config`)、キーマップ、ハンドラ設定を含む
    - `updatetime=300` の設定がここにある
  - **lsp_cfg.lua**:
    - Mason連携 (`mason-lspconfig`) でサーバを自動インストール・有効化
    - `vim.lsp.config()` でサーバ設定を定義し `vim.lsp.enable()` で有効化
    - バージョンガード (`nvim-0.11` チェック) あり
    - Python環境検出ロジック含む
- **影響**: `lsp_cfg.lua` をベースとし、`lsp.lua` の診断設定・キーマップ・updatetimeを適切な場所に再配置して統合

### プラグイン自動更新チェック
- **背景**: 要件 4.3「起動時に自動のプラグイン更新チェックを実行しない」への準拠確認
- **調査ソース**: `vim/lua/lazy.lua`
- **発見**: `checker = { enabled = true }` が設定されている
- **影響**: `checker = { enabled = false }` に変更する必要がある

### AIプラグインのAPIキー管理
- **背景**: 要件 5 のセキュリティ要件への準拠状況を確認
- **調査ソース**: `vim/lua/plugins/avante.lua`, `vim/lua/plugins/copilot.lua`, `vim/lua/plugins/minuet-ai.lua`
- **発見**:
  - `avante.lua`: `os.getenv("AWS_PROFILE")` を使用（環境変数参照）
  - `copilot.lua`: GitHub OAuth認証ベースのため直接的なAPIキー管理なし
  - `minuet-ai.lua`: `vim.env.GEMINI_API_KEY or ""` で環境変数参照、未設定時は空文字（警告なし）
- **影響**: APIキー未設定時に明示的な警告を出すラッパーユーティリティの導入を検討

## アーキテクチャパターン評価

| オプション | 説明 | 強み | リスク / 制限 | 備考 |
|-----------|------|------|---------------|------|
| A: 段階的リファクタリング | 既存Lazy.nvim構造を維持しつつ、段階的にVim script→Lua移行 | 既存設定を活かせる、リスク低 | 移行中の一時的な混在状態 | **採用** |
| B: フルリビルド | ゼロから init.lua を作り直す | クリーンスタート | カスタマイズ見落ちリスク、工数大 | 不採用 |

## 設計決定

### 決定: エントリポイントを `init.lua` に移行
- **背景**: 要件 1「Lua移行と設定ロードの統一」を満たすため
- **代替案**:
  1. `init.vim` から Lua を source し続ける（現状維持）
  2. `init.lua` を新規作成し Vim script 不要にする
- **選択したアプローチ**: オプション 2。`init.lua` を作成し、Lua モジュールを `require` でロードする
- **根拠**: 要件 1.2「Vim scriptを起動時に読み込まない」を満たすには `init.vim` 自体を削除する必要がある
- **トレードオフ**: 移行完了までの一時的な設定非互換リスクがあるが、テスト可能
- **フォローアップ**: 移行後に旧 `init.vim`, `rc/` ディレクトリを削除

### 決定: LSP設定を `plugins/lsp_cfg.lua` に一元化
- **背景**: 要件 2「LSP設定の一元化」を満たすため
- **代替案**:
  1. `lsp.lua` を残し、`lsp_cfg.lua` を削除
  2. `lsp_cfg.lua` をベースに統合（Mason連携を維持）
- **選択したアプローチ**: オプション 2
- **根拠**: Mason連携によるLSPサーバ自動インストールは運用上有益。手動設定（`lsp.lua`）はMason設定と重複しているため廃止する
- **トレードオフ**: `lsp.lua` 内の診断設定やキーマップは別モジュール（または `lsp_cfg.lua` 内）に移設する必要あり
- **フォローアップ**: 統合後 `lsp.lua` を削除

### 決定: Lua設定ディレクトリ構造の標準化
- **背景**: Vim script設定を移植する受け皿を準備するため
- **選択したアプローチ**: `vim/lua/config/` ディレクトリを新設し、以下のモジュールを配置：
  - `config/options.lua`: 基本オプション（現 `basic.vim`, `ui.vim`, `search.vim` 相当）
  - `config/keymaps.lua`: キーマップ（現 `keymap.vim` 相当）
  - `config/autocmds.lua`: 自動コマンド（WezTerm連携など）
- **根拠**: LazyVim等のコミュニティスターターキット構成に倣うことで保守性向上
- **トレードオフ**: ファイル数増加だが責務分離は明確

## リスクと軽減策
- **リスク1**: 移行中に一部設定が読み込まれずNeovimが不安定になる可能性
  - **軽減策**: 変更をモジュール単位で行い、各段階でNeovim起動テストを実施
- **リスク2**: LSP統合後に特定言語のサポートが抜け落ちる可能性
  - **軽減策**: 統合前に両ファイルのサーバリストを突合し、全サーバをカバー
- **リスク3**: WezTerm連携 autocmd の Lua 移植漏れ
  - **軽減策**: `basic.vim` の WezTerm 用 augroup を完全移植対象として明示的に管理

## 参照
- [Lazy.nvim Configuration](https://lazy.folke.io/configuration) — checker オプションの設定
- [Neovim 0.11 LSP API](https://neovim.io/doc/user/lsp.html) — `vim.lsp.config`, `vim.lsp.enable` の公式ドキュメント
- [LazyVim Starter](https://www.lazyvim.org/) — Lua設定構造のベストプラクティス参考
