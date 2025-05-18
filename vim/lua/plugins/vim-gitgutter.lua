return {
    "airblade/vim-gitgutter",
    config = function ()
        vim.g.gitgutter_map_keys = 0
        vim.g.gitgutter_sign_priority = 1
        vim.g.gitgutter_sign_added              = '▌'
        vim.g.gitgutter_sign_modified           = '▌'
        vim.g.gitgutter_sign_removed            = '▌'
        vim.g.gitgutter_sign_removed_first_line = '▌'
        vim.g.gitgutter_sign_modified_removed   = '▌'
        vim.cmd('highlight GitGutterAdd ctermfg=green')
        vim.cmd('highlight GitGutterChange ctermfg=yellow')
        vim.cmd('highlight GitGutterDelete ctermfg=red')
        vim.cmd('highlight GitGutterChangeDelete ctermfg=yellow')
    end,
}
