return {
    'APZelos/blamer.nvim',
    event = { "BufReadPost", "BufNewFile" },
    config = function ()
        vim.g.blamer_enabled = 1
        vim.g.blamer_date_format = '%Y/%m/%d %H:%M'
        vim.g.blamer_template = '<committer>, <committer-time>  * <summary>'
    end,
}
