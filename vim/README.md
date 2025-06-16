# Vim/Neovim 設定

このディレクトリには、Vim/Neovim用の設定ファイルが含まれています。

## 📁 ファイル構成

```
vim/
├── init.vim              # Neovim エントリーポイント
├── rc/                   # 従来のVim設定ファイル
│   ├── vimrc            # メインのVim設定
│   └── gvimrc           # GUI Vim設定
├── lua/                  # Lua設定ファイル (Neovim)
│   ├── lazy.lua         # Lazy.nvim プラグインマネージャー設定
│   ├── lsp.lua          # LSP設定
│   └── plugins/         # 個別プラグイン設定
├── lazy-lock.json       # プラグインのバージョンロック
└── README.md            # このファイル
```

## 🚀 機能

- **プラグイン管理**: Lazy.nvim を使用
- **LSP統合**: 言語サーバープロトコル対応
- **AI支援**: Claude Code、GitHub Copilot、Avante統合
- **現代的なUI**: Tree-sitter、Telescope、Neo-tree等

## ⚙️ 主要設定

- **リーダーキー**: Space
- **インデント**: 4スペース
- **エンコーディング**: UTF-8
- **キーマッピング**: 分割ナビゲーション、バッファ管理

## 📦 セットアップ

```bash
# Makefileから自動セットアップ
make setup-vim

# または手動セットアップ
ln -nfs ~/dots/vim ~/.config/nvim
ln -nfs ~/dots/vim/rc/vimrc ~/.config/nvim/init.vim
```

## 🔧 プラグイン管理

```vim
:Lazy                 " Lazy.nvim インターフェース
:Lazy update          " プラグイン更新
:Lazy clean           " 未使用プラグイン削除
```

詳細は [CLAUDE.md](../CLAUDE.md) を参照してください。






















































