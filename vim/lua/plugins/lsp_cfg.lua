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
    -- mason (LSP server installer only)
    {
        "williamboman/mason.nvim",
        dependencies = {
            "jay-babu/mason-null-ls.nvim",
            "nvimtools/none-ls.nvim",
        },
        config = function()
            require("mason").setup()

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

            -- LSP configurations using new Neovim LSP API
            -- Global configuration for all LSP servers
            vim.lsp.config('*', {
                root_markers = { '.git' },
            })

            -- Configure LSP servers using vim.lsp.config()
            local lsp_configs = {
                basedpyright = {
                    cmd = { 'basedpyright-langserver', '--stdio' },
                    filetypes = { 'python' },
                    root_markers = { '.venv', 'pyproject.toml', 'setup.py', 'requirements.txt' },
                    settings = {
                        basedpyright = {
                            analysis = {
                                autoSearchPaths = true,
                                diagnosticMode = "openFilesOnly",
                                diagnosticSeverityOverrides = {
                                    reportGeneralTypeIssues = "none",
                                    reportMissingTypeArgument = "none",
                                    reportUnknownMemberType = "none",
                                    reportUnknownVariableType = "none",
                                    reportUnknownArgumentType = "none",
                                },
                                logLevel = 'Trace',
                                typeCheckingMode = 'off',
                                reportMissingImports = 'none',
                                reportMissingModuleSource = 'none',
                                reportUnusedImport = 'none',
                                reportUnusedVariable = 'none',
                                reportUnboundVariable = 'none',
                                reportUndefinedVariable = 'none',
                                reportOptionalSubscript = 'none',
                                reportOptionalMemberAccess = 'none',
                                useLibraryCodeForTypes = true,
                            },
                        },
                    },
                },
                bashls = {
                    cmd = { 'bash-language-server', 'start' },
                    filetypes = { 'sh', 'bash' },
                },
                lua_ls = {
                    cmd = { 'lua-language-server' },
                    filetypes = { 'lua' },
                    root_markers = { '.luarc.json', '.luarc.jsonc' },
                    settings = {
                        Lua = {
                            runtime = { version = 'LuaJIT' },
                            diagnostics = { globals = { 'vim' } },
                            workspace = {
                                library = vim.api.nvim_get_runtime_file("", true),
                                checkThirdParty = false,
                            },
                            telemetry = { enable = false },
                        },
                    },
                },
                yamlls = {
                    cmd = { 'yaml-language-server', '--stdio' },
                    filetypes = { 'yaml', 'yml' },
                },
                jsonls = {
                    cmd = { 'vscode-json-language-server', '--stdio' },
                    filetypes = { 'json', 'jsonc' },
                },
                ts_ls = {
                    cmd = { 'typescript-language-server', '--stdio' },
                    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
                    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json' },
                },
                html = {
                    cmd = { 'vscode-html-language-server', '--stdio' },
                    filetypes = { 'html' },
                },
                cssls = {
                    cmd = { 'vscode-css-language-server', '--stdio' },
                    filetypes = { 'css', 'scss', 'less' },
                },
            }

            -- Apply configurations
            for server_name, config in pairs(lsp_configs) do
                vim.lsp.config(server_name, config)
            end

            -- Enable LSP servers
            for server_name, _ in pairs(lsp_configs) do
                vim.lsp.enable(server_name)
            end
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
