# ギャップ分析: Neovim設定モダナイゼーション

## 1. 現状調査 (Current State Investigation)

### ディレクトリ構造
現在、Neovimの設定は `dotfiles/vim/` 配下にあり、Vim script (`rc/*.vim`) とLua (`lua/`) が混在するハイブリッド構成になっています。

- **エントリポイント**: `init.vim` (Vim script) が `rc/*.vim` と `lua/*.lua` を `runtime!` で読み込んでいます。
- **レガシー設定**: `vim/rc/` 配下に `basic.vim` (基本設定), `keymap.vim` (キーマップ), `ui.vim` 等が存在し、これらがアクティブです。
- **モダン設定**: `vim/lua/` 配下に `lazy.lua` (プラグイン管理) や `plugins/` (Lazy.nvimスペック) が存在し、モダンな構成も一部導入されています。
- **LSP設定の重複**:
  - `lua/lsp.lua`: `vim.lsp.config` を直接使用した手動設定記述。
  - `lua/plugins/lsp_cfg.lua`: `mason-lspconfig` を使用した動的設定記述。
  - **重大な発見**: `basedpyright`, `bashls`, `lua_ls` など主要なサーバの設定が**両方のファイルで定義されており、競合・二重ロードの状態**にあります。

### インテグレーション
- **プラグイン管理**: Lazy.nvim が導入済み (`lua/lazy.lua`)。
- **AIツール**: `avante.lua`, `copilot.lua` などが存在し、`os.getenv` 等で環境変数を参照している箇所も見られます（セキュリティ面は一部対応済み）。

## 2. 要件適合性分析 (Requirements Feasibility Analysis)

| 要件 | 現状とのギャップ | 判定 |
| :--- | :--- | :--- |
| **1. Lua移行と設定ロード統一** | エントリポイントが `init.vim` であり、`rc/*.vim` を依存している。Luaへの完全移行にはこれらの書き換えとファイル構造の変更が必須。 | **Missing** |
| **2. LSP設定の一元化** | `lsp.lua` と `plugins/lsp_cfg.lua` で設定が分裂・重複している。これを `mason-lspconfig` ベース（`lsp_cfg.lua`）に統合し、手動設定（`lsp.lua`）を廃止する必要がある。 | **Missing/Conflict** |
| **3. レガシーコード整理** | `rc/` 以下の全 `.vim` ファイル、`vimrc`、`gvimrc` などが削除対象。また `init.vim` も削除し `init.lua` へ移行が必要。 | **Missing** |
| **4. 最適化** | Lazy.nvim は導入済みだが、`lazy.lua` のロードタイミングや `updatetime` の設定場所（現在は廃棄予定の `lsp.lua` に記述）を適切な場所に再配置する必要がある。 | **Constraint** |
| **5. セキュリティ** | 多くのAIプラグイン設定ファイルがあるが、APIキー未設定時の警告表示などは各プラグインの実装依存。要件に合わせて明示的なチェックを追加するか検討が必要（Research Needed）。 | **Partial/Research Needed** |

## 3. 実装アプローチ案 (Implementation Approach Options)

### Option A: 既存構造の拡張とリファクタリング (推奨)
現在の `vim/lua/` 構造（Lazy.nvimベース）を活かし、レガシー部分をそこに統合するアプローチ。

- **手順**:
  1. `vim/rc/*.vim` の内容を `vim/lua/config/options.lua`, `vim/lua/config/keymaps.lua`, `vim/lua/config/autocmds.lua` 等に移植。
  2. `vim/init.vim` を削除し、`vim/init.lua` を作成して上記モジュールと `lazy` をrequireする。
  3. `vim/lua/lsp.lua` の内容（特に `updatetime` 設定などの非LSP設定があれば）を救出して、LSP設定自体は `vim/lua/plugins/lsp_cfg.lua` に統合・一本化する。
  4. 重複ファイルを削除。

- **Trade-offs**:
  - ✅ 既存のLazy.nvim設定を最大限活用できる。
  - ✅ 移行リスクが比較的低い（単純な言語変換が多い）。
  - ✅ ファイル構成が標準的なNeovim構成（lazy.nvimスターターキット等に近い形）になる。

### Option B: 新規構成による再構築
現在の設定を参考にしつつ、ゼロから `init.lua` 起点の構成を作り直す。

- **Rationale**: 現在の重複状態（LSPなど）が複雑すぎて解きほぐすのが困難な場合。
- **Trade-offs**:
  - ✅ クリーンな状態でスタートできる。
  - ❌ 既存のカスタマイズ（特に微調整されたautocmdなど）を見落とすリスクが高い。
  - ❌ 手間が大きい（XLサイズ）。

## 4. 研究・調査事項 (Out-of-Scope / Research Needed)
- **APIキー管理の統一手法**: Avante, Copilot, Gemini等複数のAIツールがあるため、共通のAPIキーチェック機構（起動時警告）を実装可能か、または各プラグインの設定で完結させるか。
- **WezTerm連携のLua化**: `rc/basic.vim` にあるWezTerm連携用autocmdのLuaへの移植確認。

## 5. 実装の複雑性とリスク (Implementation Complexity & Risk)

- **Effort**: **M (3-7 days)**
  - Vim scriptからLuaへの書き換えは単純作業だが量がある。LSP設定の統合整理に慎重さが求められる。
- **Risk**: **Low/Medium**
  - アーキテクチャ自体はLazy.nvimという標準的なものに既に乗っているため、リスクは低い。LSP設定の統合時に挙動が変わる（重複が解消されるため）可能性がある点が唯一のリスク。

## 3. 推奨事項 (Recommendations)

**Option A (リファクタリング)** を採用することを推奨します。

1. **フェーズ1: 基盤移行**
   - `init.lua` 化と `rc/*.vim` のLua移植・削除。
2. **フェーズ2: LSP統合**
   - `lsp.lua` を廃止し `plugins/lsp_cfg.lua` に集約。重複を解消。
3. **フェーズ3: セキュリティと仕上げ**
   - APIキーチェックの実装と起動高速化の確認。
