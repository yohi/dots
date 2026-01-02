return {
    'Yggdroot/indentLine',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        vim.g.indentLine_char = '│'
    end
}
