# Neovim 設定

このディレクトリには、Neovim用のLuaベース設定ファイルが含まれています。

## 📁 ファイル構成

```
vim/
├── init.lua              # Neovim エントリーポイント
├── lua/
│   ├── config/           # 設定モジュール
│   │   ├── options.lua   # 基本オプション (vim.opt)
│   │   ├── keymaps.lua   # 汎用キーマップ
│   │   └── autocmds.lua  # 自動コマンド
│   ├── plugins/          # プラグイン設定 (Lazy.nvim仕様)
│   │   ├── lsp_cfg.lua   # LSP統合設定
│   │   ├── ai_*.lua      # AI関連プラグイン
│   │   └── ...           # その他プラグイン
│   ├── utils/            # ユーティリティモジュール
│   │   └── apikey.lua    # APIキー管理
│   └── lazy_bootstrap.lua # Lazy.nvim ブートストラップ
├── lazy-lock.json        # プラグインのバージョンロック (Git管理)
├── init.vim.bak          # レガシー設定バックアップ
├── tests/                # 設定テストスクリプト
└── README.md             # このファイル
```

## 🔧 設定ロード順序

1. `config/options.lua` - 基本Neovimオプション
2. `config/keymaps.lua` - 汎用キーマップ
3. `config/autocmds.lua` - 自動コマンド
4. `lazy_bootstrap.lua` - プラグインマネージャ初期化

すべてのモジュールは `pcall` でラップされ、エラー発生時も起動を継続します。

## 🚀 機能

- **100% Lua設定**: Vim scriptへの依存を完全排除
- **プラグイン管理**: Lazy.nvim による遅延ロード
- **LSP統合**: 10+ 言語サーバー対応（統一設定）
- **AI支援**: Claude Code、GitHub Copilot、Avante統合
- **WezTerm連携**: IME自動制御

## ⚙️ 主要設定

- **リーダーキー**: Space
- **インデント**: 4スペース
- **エンコーディング**: UTF-8
- **updatetime**: 300ms（CursorHold高速化）
- **セキュリティ**: `exrc=false`, `secure=true`

## 📦 セットアップ

```bash
# Makefileから自動セットアップ
make setup-vim

# または手動セットアップ
ln -nfs ~/dotfiles/vim ~/.config/nvim
```

## 🔧 プラグイン管理

```vim
:Lazy                 " Lazy.nvim インターフェース
:Lazy update          " プラグイン更新（手動のみ）
:Lazy profile         " 起動時間プロファイル
:Lazy clean           " 未使用プラグイン削除
```

**注意**: 自動更新チェックは無効化されています（`checker.enabled = false`）。
プラグインの更新は `:Lazy update` で手動実行し、動作確認後にコミットしてください。

## 🎯 主要プラグイン

### AI統合
- **Avante**: Claude/OpenAI統合（APIキーは環境変数から取得）
- **Copilot**: GitHub Copilot統合
- **CopilotChat**: AI会話機能

### 言語サーバー（統一管理: `lsp_cfg.lua`）
- **Mason**: LSPサーバー自動インストール
- **対応言語**: Python, Lua, Shell, YAML, Docker, PHP, HTML, JSON, Vim

### UI/UX
- **Telescope**: ファジーファインダー
- **Trouble**: エラー表示
- **Barbecue**: パンくずリスト
- **Bufferline**: バッファタブ表示

### Git統合
- **Gitgutter**: Git差分表示
- **Lazygit**: Git TUI統合
- **Blamer**: Git blame表示

## 🛡️ セキュリティ

- **APIキー**: 環境変数から取得（設定ファイルにハードコードしない）
- **外部スクリプト**: ローカルvimrc自動実行は無効
- **プラグインバージョン**: `lazy-lock.json` で固定・Git管理

## 🔄 トラブルシューティング

### Neovimが起動しない場合
```bash
# ヘッドレスモードでエラー確認
nvim --headless +qa

# ヘルスチェック
nvim -c ':checkhealth'
```

### レガシー設定への復帰
```bash
# バックアップから復元
mv vim/init.lua vim/init.lua.new
mv vim/init.vim.bak vim/init.vim
```

### テストの実行
```bash
# 全テスト実行
cd vim && ./tests/test_phase10_final_verification.sh
```

## 📚 関連ドキュメント

- [CLAUDE.md](../CLAUDE.md) - プロジェクト全体のAI支援ガイド
- `.kiro/specs/neovim-config-modernization/` - モダナイゼーション仕様書
