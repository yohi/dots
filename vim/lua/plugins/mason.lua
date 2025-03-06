-- mason / mason-lspconfig / lspconfig
return {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
        -- "jay-babu/mason-null-ls.nvim",
        -- "jose-elias-alvarez/null-ls.nvim",
        -- "nvimtools/none-ls.nvim",
    },
    config = function()
        local lsp_servers = {
            "basedpyright",
        }
        require("mason").setup()
        require("mason-lspconfig").setup({
            -- lsp_servers table Install
            ensure_installed = lsp_servers,
        })

        local lsp_config = require("lspconfig")
        -- lsp_servers table setup
        for _, lsp_server in ipairs(lsp_servers) do
            lsp_config[lsp_server].setup({
                root_dir = function(fname)
                    return lsp_config.util.find_git_ancestor(fname) or vim.fn.getcwd()
                end,
            })
        end
    end,
    cmd = "Mason",
}
