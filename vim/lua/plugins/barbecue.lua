return {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
        "SmiteshP/nvim-navic",
        "nvim-tree/nvim-web-devicons", -- optional dependency
    },
    config = function()
        require("barbecue").setup({
            create_autocmd = false, -- prevent barbecue from updating itself automatically
            separator = "  ",
            icons_enabled = true,
            icons = {
                default = "",
                symlink = "",
                git = "",
                folder = "",
                ["folder-open"] = "",
            },
        })
    end,
}
