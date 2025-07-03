local lsp_servers = {
    -- "basedpyright",
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
            -- require("mason-lspconfig").setup({
            --     -- lsp_servers table Install
            --     ensure_installed = lsp_servers,
            -- })

            -- lsp_servers table setup
            for _, lsp_server in ipairs(lsp_servers) do
                lsp_config[lsp_server].setup({
                    root_dir = function(fname)
                        return lsp_config.util.find_git_ancestor(fname) or vim.fn.getcwd()
                    end,
                })
            end

            -- Python環境設定（改良版：効率的かつエラーハンドリング付き）
            local function setup_python_host()
                local python_path = nil

                -- 1. 仮想環境が有効な場合は、その環境のPythonを使用
                if vim.env.VIRTUAL_ENV then
                    local venv_python = vim.env.VIRTUAL_ENV .. "/bin/python3"
                    if vim.fn.executable(venv_python) == 1 then
                        python_path = venv_python
                    end
                end

                -- 2. 仮想環境が見つからない場合は、システムのpython3を検索
                if not python_path then
                    python_path = vim.fn.exepath("python3")
                    if python_path == "" then
                        python_path = vim.fn.exepath("python")
                    end
                end

                -- 3. エラーハンドリング
                if python_path == "" then
                    vim.notify("警告: Python3が見つかりません。LSPの動作に影響する可能性があります。", vim.log.levels.WARN)
                    return
                end

                -- 4. 効率的にホストプログラムを設定
                vim.g.python3_host_prog = python_path

                -- デバッグ情報（オプション）
                vim.notify("Python3ホストプログラムが設定されました: " .. python_path, vim.log.levels.INFO)
            end

            setup_python_host()

            lsp_config.basedpyright.setup({
                root_dir = function(fname)
                    -- return lsp_config.util.find_git_ancestor(fname) or vim.fn.getcwd()
                    return lsp_config.util.root_pattern(".venv")(fname)
                end,
                settings = {
                    basedpyright = {
                        analysis = {
                            --
                            -- inlayHints = {
                            --     functionReturnTypes = true,
                            --     variableTypes = true,
                            -- },

                            --
                            -- autoImportCompletions = true,

                            -- 事前定義された名前にもどついて検索パスを自動的に追加するか
                            autoSearchPaths = true,

                            -- [openFilesOnly, workspace]
                            diagnosticMode = "openFilesOnly",

                            -- 診断のレベルを上書きする
                            -- https://github.com/microsoft/pylance-release/blob/main/DIAGNOSTIC_SEVERITY_RULES.md
                            diagnosticSeverityOverrides = {
                                reportGeneralTypeIssues = "none",
                                reportMissingTypeArgument = "none",
                                reportUnknownMemberType = "none",
                                reportUnknownVariableType = "none",
                                reportUnknownArgumentType = "none",
                            },

                            -- インポート解決のための追加検索パス指定
                            extraPaths = {
                            },

                            -- default: Information [Error, Warning, Information, Trace]
                            -- logLevel = 'Warning',
                            logLevel = 'Trace',

                            -- カスタムタイプのstubファイルを含むディレクトリ指定 default: ./typings
                            -- stubPath = '',

                            -- 型チェックの分析レベル default: off [off, basic, strict]
                            typeCheckingMode = 'off',
                            reportMissingImports = 'none',
                            reportMissingModuleSource = 'none',
                            reportUnusedImport = 'none',
                            reportUnusedVariable = 'none',
                            reportUnboundVariable = 'none',
                            reportUndefinedVariable = 'none',
                            reportGeneralTypeIssues = 'none',
                            reportMissingTypeArgument = 'none',
                            reportOptionalSubscript = 'none',
                            reportOptionalMemberAccess = 'none',

                            --
                            -- typeshedPaths = '',

                            -- default: false
                            useLibraryCodeForTypes = true,

                            pylintPath = {
                            },
                        },
                    },
                }
            })
        end,
        cmd = "Mason",
    },

 --   -- mason-null-ls
 --   {
 --       "jay-babu/mason-null-ls.nvim",
 --       -- event = { "BufReadPre", "BufNewFile" },
 --       dependencies = {
 --           "williamboman/mason.nvim",
 --           -- "jose-elias-alvarez/null-ls.nvim",
 --           "nvimtools/none-ls.nvim",
 --       },
 --       config = function()
 --           require("mason-null-ls").setup({
 --               automatic_setup = true,
 --               -- formatters table and diagnostics table Install
 --               ensure_installed = vim.tbl_flatten({ formatters, diagnostics }),
 --               handlers = {},
 --           })
 --       end,
 --       cmd = "Mason",
 --   },

 --   -- none-ls
 --   {
 --       -- "jose-elias-alvarez/null-ls.nvim",
 --       "nvimtools/none-ls.nvim",
 --       requires = "nvim-lua/plenary.nvim",
 --       config = function()
 --           local null_ls = require("null-ls")

 --           -- formatters table
 --           local formatting_sources = {}
 --           for _, tool in ipairs(formatters) do
 --               table.insert(formatting_sources, null_ls.builtins.formatting[tool])
 --           end

 --           -- diagnostics table
 --           local diagnostics_sources = {}
 --           for _, tool in ipairs(diagnostics) do
 --               table.insert(diagnostics_sources, null_ls.builtins.diagnostics[tool])
 --           end

 --           -- none-ls setup
 --           null_ls.setup({
 --               diagnostics_format = "[#{m}] #{s} (#{c})",
 --               sources = vim.tbl_flatten({ formatting_sources, diagnostics_sources }),
 --           })
 --       end,
 --       event = { "BufReadPre", "BufNewFile" },
 --   },

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
