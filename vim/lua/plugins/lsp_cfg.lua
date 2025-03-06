local lsp_servers = {
    "basedpyright",
    -- "ruff",
    "bashls",
    "lua_ls",
    "yamlls",
    "jsonls",
    -- "taplo",
    -- "rust_analyzer",
    "ts_ls",
    "html",
    "cssls",
}

local formatters = {
    "djlint",
    "stylua",
    -- "shfmt",
    -- "prettier",
}
local diagnostics = {
    "yamllint",
    -- "selene",
}

local opts = {
    noremap = true,
    silent = true,
}

local on_attach = function(_, bufnr)
    -- カーソル下の変数情報表示
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    -- 改行やインデントのフォーマティング
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    --定義ジャンプ
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<F12>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    -- カーソル下の変数参照元一覧表示
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    -- 変数名リネーム
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    -- 
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
end

local function on_cursor_hold()
    vim.diagnostic.open_float()
end

local diagnostic_hover_augroup_name = "lspconfig-diagnostic"

vim.api.nvim_set_option('updatetime', 500)

vim.api.nvim_create_augroup(
    diagnostic_hover_augroup_name,
    {
        clear = true,
    }
)

vim.api.nvim_create_autocmd(
    {
        "CursorHold",
    },
    {
        group = diagnostic_hover_augroup_name,
        callback = on_cursor_hold,
    }
)

vim.api.nvim_create_autocmd(
    {
        "WinScrolled", -- or WinResized on NVIM-v0.9 and higher
        "BufWinEnter",
        "CursorHold",
        "InsertLeave",
        -- include this if you have set `show_modified` to `true`
        "BufModifiedSet",
    },
    {
        group = vim.api.nvim_create_augroup("barbecue.updater", {}),
        callback = function()
            require("barbecue.ui").update()
        end,
    }
)

vim.api.nvim_create_autocmd(
    {
    'LspAttach',
    },
    {
        group = diagnostic_hover_augroup_name,
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
        end,
    }
)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})


return {
    -- mason / mason-lspconfig / lspconfig
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "jay-babu/mason-null-ls.nvim",
            -- "jose-elias-alvarez/null-ls.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            local lsp_config = require("lspconfig")

            require("mason").setup()
            require("mason-lspconfig").setup({
                -- lsp_servers table Install
                ensure_installed = lsp_servers,
            })

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
    },

    -- mason-null-ls
    {
        "jay-babu/mason-null-ls.nvim",
        -- event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            -- "jose-elias-alvarez/null-ls.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            require("mason-null-ls").setup({
                automatic_setup = true,
                -- formatters table and diagnostics table Install
                ensure_installed = vim.tbl_flatten({ formatters, diagnostics }),
                handlers = {},
            })
        end,
        cmd = "Mason",
    },

    -- none-ls
    {
        -- "jose-elias-alvarez/null-ls.nvim",
        "nvimtools/none-ls.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            local null_ls = require("null-ls")

            -- formatters table
            local formatting_sources = {}
            for _, tool in ipairs(formatters) do
                table.insert(formatting_sources, null_ls.builtins.formatting[tool])
            end

            -- diagnostics table
            local diagnostics_sources = {}
            for _, tool in ipairs(diagnostics) do
                table.insert(diagnostics_sources, null_ls.builtins.diagnostics[tool])
            end

            -- none-ls setup
            null_ls.setup({
                diagnostics_format = "[#{m}] #{s} (#{c})",
                sources = vim.tbl_flatten({ formatting_sources, diagnostics_sources }),
            })
        end,
        event = { "BufReadPre", "BufNewFile" },
    },

    -- lspsaga
    {
        "nvimdev/lspsaga.nvim",
        config = function()
            require("lspsaga").setup({
                symbol_in_winbar = {
                    separator = "  ",
                },
            })
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        event = { "BufRead", "BufNewFile" },
    },

    -- mason-nvim-dap
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            ensure_installed = {
                "python",
            },
            handlers = {},
        },
    },
}


