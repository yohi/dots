return {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
        "SmiteshP/nvim-navic",
        "MunifTanjim/nui.nvim",
        "numToStr/Comment.nvim",
        "nvim-telescope/telescope.nvim"
    },
    config = function()
        require("nvim-navbuddy").setup({
            lsp = {
                auto_attach = true,
            }
        })
    end,
}
