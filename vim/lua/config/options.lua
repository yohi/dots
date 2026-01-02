local opt = vim.opt

vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0

opt.compatible = false
opt.encoding = "utf-8"
opt.fileencodings = "ucs-bom,utf-8,iso-2022-jp,euc-jp,cp932,utf-16,utf-16le"
opt.fileformat = "unix"
opt.fileformats = { "unix", "dos", "mac" }

opt.iminsert = 0
opt.imsearch = 0
if vim.fn.has("imdisable") == 1 then
  opt.imdisable = true
end

opt.swapfile = false
opt.undofile = false
opt.autoread = true
opt.hidden = true
opt.history = 1000

opt.timeout = true
opt.timeoutlen = 500
opt.shellslash = true
opt.clipboard:append("unnamedplus")

opt.backspace = { "indent", "eol", "start" }
opt.matchpairs = "(:),{:},[:],<:>"
opt.whichwrap = "b,s,h,l,<,>,[,]"

opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.smarttab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4

vim.cmd("syntax on")
opt.list = true
opt.listchars = "tab:>-,trail:_,nbsp:%,extends:<"
opt.ambiwidth = "single"
opt.number = true
opt.cmdheight = 2
opt.shortmess:append("I")
opt.showcmd = true
opt.showmode = false
opt.showmatch = true
opt.cursorline = true
opt.cursorcolumn = false
opt.ruler = true
opt.scrolloff = 5
opt.display = "lastline"
opt.wildmenu = true
opt.wildchar = 9
opt.wildmode = "longest:full,list"
opt.signcolumn = "yes:2"
if vim.fn.has("nvim") == 1 or vim.fn.has("termguicolors") == 1 then
  opt.termguicolors = true
end

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true
opt.wrapscan = false

opt.updatetime = 300
opt.exrc = false
opt.secure = true
