local lsp_servers = {
    "basedpyright",
    "bashls",
    "lua_ls",
    "yamlls",
    "jsonls",
    "ts_ls",
    "html",
    "cssls",
    "vimls",
    "dockerls",
    "intelephense",
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
    -- mason (LSP server installer)
    {
        "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "jay-babu/mason-null-ls.nvim",
            "nvimtools/none-ls.nvim",
        },
        priority = 100, -- 他のプラグインより先に読み込む
        config = function()
            require("mason").setup({
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })

            -- mason-lspconfig: LSPサーバーの自動インストールと管理
            require("mason-lspconfig").setup({
                -- lsp_serversテーブルで定義されたサーバーを自動インストール
                ensure_installed = lsp_servers,
                -- サーバーが利用可能になったら自動的にセットアップ
                automatic_installation = true,
            })
        end,
    },

    -- LSP Configuration (バッファ読み込み時に実行)
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = {
            "williamboman/mason.nvim",
        },
        event = { "BufReadPre", "BufNewFile" }, -- バッファ読み込み時にLSP設定を実行
        config = function()
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

            -- バージョンガード: Neovim 0.11以降の新しいLSP APIを使用
            local has_new_lsp_api = vim.fn.has('nvim-0.11') == 1

            -- Masonのレジストリから実行可能ファイル名を取得するヘルパー関数
            local function get_mason_cmd(server_name)
                local registry = require("mason-registry")
                if registry.is_installed(server_name) then
                    local pkg = registry.get_package(server_name)
                    -- MasonでインストールされたパッケージのbinディレクトリはすでにPATHに含まれている
                    return nil  -- デフォルトのコマンドを使用
                end
                return nil
            end

            -- Configure LSP servers using vim.lsp.config()
            -- Masonでインストールされたバイナリは自動的にPATHに追加される
            local lsp_configs = {
                basedpyright = {
                    -- Masonのパッケージ名: basedpyright
                    -- インストールされる実行可能ファイル: basedpyright-langserver
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
                    -- Masonのパッケージ名: bash-language-server
                    -- インストールされる実行可能ファイル: bash-language-server
                    cmd = { 'bash-language-server', 'start' },
                    filetypes = { 'sh', 'bash' },
                },
                lua_ls = {
                    -- Masonのパッケージ名: lua-language-server
                    -- インストールされる実行可能ファイル: lua-language-server
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
                    -- Masonのパッケージ名: yaml-language-server
                    -- インストールされる実行可能ファイル: yaml-language-server
                    cmd = { 'yaml-language-server', '--stdio' },
                    filetypes = { 'yaml', 'yml' },
                },
                jsonls = {
                    -- Masonのパッケージ名: json-lsp
                    -- インストールされる実行可能ファイル: vscode-json-language-server
                    cmd = { 'vscode-json-language-server', '--stdio' },
                    filetypes = { 'json', 'jsonc' },
                },
                ts_ls = {
                    -- Masonのパッケージ名: typescript-language-server
                    -- インストールされる実行可能ファイル: typescript-language-server
                    cmd = { 'typescript-language-server', '--stdio' },
                    filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
                    root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json' },
                },
                html = {
                    -- Masonのパッケージ名: html-lsp
                    -- インストールされる実行可能ファイル: vscode-html-language-server
                    cmd = { 'vscode-html-language-server', '--stdio' },
                    filetypes = { 'html' },
                },
                cssls = {
                    -- Masonのパッケージ名: css-lsp
                    -- インストールされる実行可能ファイル: vscode-css-language-server
                    cmd = { 'vscode-css-language-server', '--stdio' },
                    filetypes = { 'css', 'scss', 'less' },
                },
                vimls = {
                    -- Masonのパッケージ名: vim-language-server
                    -- インストールされる実行可能ファイル: vim-language-server
                    cmd = { 'vim-language-server', '--stdio' },
                    filetypes = { 'vim' },
                },
                dockerls = {
                    -- Masonのパッケージ名: dockerfile-language-server
                    -- インストールされる実行可能ファイル: docker-langserver
                    cmd = { 'docker-langserver', '--stdio' },
                    filetypes = { 'dockerfile' },
                    root_markers = { 'Dockerfile' },
                },
                intelephense = {
                    -- Masonのパッケージ名: intelephense
                    -- インストールされる実行可能ファイル: intelephense
                    cmd = { 'intelephense', '--stdio' },
                    filetypes = { 'php' },
                    root_markers = { 'composer.json' },
                },
            }

            -- Apply configurations
            if has_new_lsp_api then
                -- Neovim 0.11以降: 新しいLSP APIを使用
                -- Global configuration for all LSP servers
                vim.lsp.config('*', {
                    root_markers = { '.git' },
                })

                for server_name, config in pairs(lsp_configs) do
                    vim.lsp.config(server_name, config)
                end

                -- Enable LSP servers
                for server_name, _ in pairs(lsp_configs) do
                    vim.lsp.enable(server_name)
                end
            else
                -- Neovim 0.10以前: 従来のlspconfig APIを使用
                -- 従来のlspconfigプラグインが必要な場合はここに実装を追加
                vim.notify(
                    "Neovim 0.10以前が検出されました。LSP設定には lspconfig プラグインが必要です。",
                    vim.log.levels.WARN
                )
            end

            -- LSP Diagnostic Configuration (migrated from lsp.lua)
            vim.diagnostic.config({
                virtual_text = false,
                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    source = "always",
                    header = "",
                    prefix = "",
                    border = "rounded",
                },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.HINT] = "",
                        [vim.diagnostic.severity.INFO] = "",
                    },
                },
            })

            -- LSP Handlers Configuration (migrated from lsp.lua)
            vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
                vim.lsp.handlers.hover, {
                    border = "rounded",
                }
            )

            vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
                vim.lsp.handlers.signature_help, {
                    border = "rounded",
                }
            )

            -- LSP Keymaps (migrated from lsp.lua)
            vim.keymap.set('n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>')
            vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
            vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>')
            vim.keymap.set('n', '<F12>', '<cmd>lua vim.lsp.buf.definition()<CR>')
            vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>')
            vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
            vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>')
            vim.keymap.set('n', 'gn', '<cmd>lua vim.lsp.buf.rename()<CR>')
            vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
            vim.keymap.set('n', 'ge', '<cmd>lua vim.diagnostic.open_float()<CR>')
            vim.keymap.set('n', 'g]', '<cmd>lua vim.diagnostic.goto_next()<CR>')
            vim.keymap.set('n', 'g[', '<cmd>lua vim.diagnostic.goto_prev()<CR>')

            -- LSP Diagnostic Hover Autocmd (migrated from lsp.lua)
            local diagnostic_hover_augroup = vim.api.nvim_create_augroup(
                "lspconfig-diagnostic",
                { clear = true }
            )

            vim.api.nvim_create_autocmd(
                { "CursorHold" },
                {
                    group = diagnostic_hover_augroup,
                    callback = function()
                        vim.diagnostic.open_float()
                    end,
                }
            )
        end,
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
