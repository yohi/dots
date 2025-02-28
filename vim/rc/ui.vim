" =====================================================================================
" ui.vim
" =====================================================================================

" シンタックスハイライト有効
set syntax=on

" 不可視文字の可視化
set list
set listchars=tab:>-,trail:_,nbsp:%,extends:<

" 全角文字を半角倍幅で表示する -> しない
set ambiwidth=single

" 行番号表示
set number

" コマンドライン表示行数
set cmdheight=2

" 起動時の広告非表示
set shortmess+=I

" コマンドを表示
set showcmd

" モードを非表示
set noshowmode

" 対応括弧を表示
set showmatch

" カーソル行強調表示
set cursorline

" カーソル列強調非表示
set nocursorcolumn

" カーソル位置表示を行う
set ruler

" 上下5行の視野を確保
set scrolloff=5

" 表示を省略しない
set display=lastline

" コマンドライン補完有効
set wildmenu

" コマンドライン補完起動キー
set wildchar=<tab>

" 補完の挙動
set wildmode=longest:full,list

" サインカラムは2カラムで常に表示
set signcolumn=yes:2

" 24-bitカラーを有効
if has('nvim') || has('termguicolors')
    set termguicolors
endif
