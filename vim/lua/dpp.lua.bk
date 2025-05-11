local cache_dir = vim.fn.expand('~/.cache/')
local dpp_base = cache_dir .. 'dpp/'
local repo_dir = dpp_base .. 'repos/'

local dpp_repo = 'github.com/Shougo/dpp.vim'
local denops_repo = 'github.com/vim-denops/denops.vim'

if vim.fn.isdirectory(cache_dir) == 0 then
    vim.fn.mkdir(cache_dir)
end

local function init_plugin(plugin, prepend)
    local dir = repo_dir .. plugin
    if vim.fn.isdirectory(dir) == 0 then
        vim.fn.execute('!git clone https://' .. plugin .. ' ' .. dir)
    end
    if prepend then
        vim.opt.runtimepath:prepend(dir)
    else
        vim.opt.runtimepath:append(dir)
    end
end

-- if vim.opt.runtimepath:find(repo_dir .. dpp_repo) == nil then
--     -- dpp.vimのインストール
--     init_plugin(dpp_repo)
-- end

-- dpp.vimのインストール
init_plugin(dpp_repo, true)

local dpp = require('dpp')

local plugins = {
    -- 'github.com/vim-denops/denops.vim',
    'github.com/Shougo/dpp-ext-installer',
    'github.com/Shougo/dpp-ext-toml',
    'github.com/Shougo/dpp-ext-lazy',
    'github.com/Shougo/dpp-protocol-git',
    'github.com/Shougo/dpp-ext-installer',
}

for _, plugin in next, plugins do
    init_plugin(plugin, false)
end


if dpp.load_state(dpp_base) then
    -- local plugins = {
    --     'github.com/vim-denops/denops.vim',
    --     'github.com/Shougo/dpp-ext-installer',
    --     'github.com/Shougo/dpp-ext-toml',
    --     'github.com/Shougo/dpp-ext-lazy',
    --     'github.com/Shougo/dpp-protocol-git',
    --     'github.com/Shougo/dpp-ext-installer',
    -- }
    -- for i, plugin in next, plugins do
    --     init_plugin(plugin)
    -- end
    init_plugin(denops_repo, true)

    vim.api.nvim_create_autocmd('User', {
        pattern = 'DenopsReady',
        callback = function()
            vim.notify('dpp load_state() is failed')
            dpp.make_state(dpp_base, '~/dotfiles/vim/dpp/dpp.ts')
        end,
    })
end

vim.api.nvim_create_autocmd('User', {
    pattern = 'Dpp:makeStatePost',
    callback = function()
        vim.notify('dpp make_state() is done')
    end,
})


-- dpp_alias
vim.api.nvim_create_user_command("DppInstall", "call dpp#async_ext_action('installer', 'install')", { nargs = 0 })
vim.api.nvim_create_user_command("DppUpdate", "call dpp#async_ext_action('installer', 'update')", { nargs = 0 })
vim.api.nvim_create_user_command("DppMakestate", function(val)
    dpp.make_state(dpp_base, '~/dotfiles/vim/dpp/dpp.ts')
end, { nargs = 0 })

vim.cmd('filetype indent plugin on')
vim.cmd('syntax on')


-- TODO
vim.cmd('colorscheme codedark')
vim.cmd('highlight LspDiagnosticsSignError ctermbg=None cterm=underline ctermfg=Red')
vim.cmd('highlight LspDiagnosticsSignWarn  ctermbg=None cterm=underline ctermfg=Yellow')
vim.cmd('highlight LspDiagnosticsSignHint  ctermbg=None cterm=underline ctermfg=LightBlue')
vim.cmd('highlight LspDiagnosticsSignInfo  ctermbg=None cterm=underline ctermfg=White')
vim.cmd('highlight CocInlayHint ctermbg=18 ctermfg=112 guibg=#cceeee guifg=#004400 cterm=italic gui=italic')

