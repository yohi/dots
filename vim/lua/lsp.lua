-- local bufnr = vim.api.nvim_get_current_buf()
-- print("bufnr")
-- print(bufnr)
-- local filepath = vim.api.nvim_buf_get_name(bufnr)
-- print('filepath')
-- print(filepath)
-- local venv_path = util.root_pattern('.venv')
-- print('venv_path')
-- print(venv_path)
-- local python_path = nil
-- python_path = vim.g.python3_host_prog
-- -- if (venv_path == nil) then
-- --     print('a')
-- --     python_path = vim.g.python3_host_prog
-- -- else
-- --     print('b')
-- --     python_path = util.path.join(
-- --         venv_path,
-- --         '.venv',
-- --         'bin',
-- --         'python'
-- --     )
-- -- end
-- print('python_path')
-- print(python_path)
-- print('venv_path')
-- print(venv_path(filepath))
-- 
-- local basedpyright_setting = {
--     basedpyright = {
--         analysis = {
--             --
--             -- inlayHints = {
--             --     functionReturnTypes = true,
--             --     variableTypes = true,
--             -- },
-- 
--             --
--             autoImportCompletions = true,
-- 
--             -- 事前定義された名前にもどついて検索パスを自動的に追加するか
--             autoSearchPaths = true,
-- 
--             -- [openFilesOnly, workspace]
--             diagnosticMode = "openFilesOnly",
-- 
--             -- 診断のレベルを上書きする
--             -- https://github.com/microsoft/pylance-release/blob/main/DIAGNOSTIC_SEVERITY_RULES.md
--             diagnosticSeverityOverrides = {
--                 reportGeneralTypeIssues = "none",
--                 reportMissingTypeArgument = "none",
--                 reportUnknownMemberType = "none",
--                 reportUnknownVariableType = "none",
--                 reportUnknownArgumentType = "none",
--             },
-- 
--             -- インポート解決のための追加検索パス指定
--             extraPaths = {
--             },
-- 
--             -- default: Information [Error, Warning, Information, Trace]
--             -- logLevel = 'Warning',
--             logLevel = 'Trace',
-- 
--             -- カスタムタイプのstubファイルを含むディレクトリ指定 default: ./typings
--             -- stubPath = '',
-- 
--             -- 型チェックの分析レベル default: off [off, basic, strict]
--             typeCheckingMode = 'off',
--             reportMissingImports = 'none',
--             reportMissingModuleSource = 'none',
--             reportUnusedImport = 'none',
--             reportUnusedVariable = 'none',
--             reportUnboundVariable = 'none',
--             reportUndefinedVariable = 'none',
--             reportGeneralTypeIssues = 'none',
--             reportMissingTypeArgument = 'none',
--             reportOptionalSubscript = 'none',
--             reportOptionalMemberAccess = 'none',
-- 
--             --
--             -- typeshedPaths = '',
-- 
--             -- default: false
--             useLibraryCodeForTypes = true,
-- 
--             pylintPath = {
--             },
--         },
--     },
-- }
--
-- local servers = {
--     basedpyright = basedpyright_setting,
--     -- pyright = pyright_setting,
--     pylsp = pylsp_setting,
--     -- mypy = {},
--     -- flake8 = {},
--     -- isort = {},
--     bashls = {},
--     dockerls = {},
--     dotls = {},
--     html = {},
--     jsonls = {},
--     -- sourcery = {},
--     -- sqlls = {},
--     lua_ls = {},
--     vimls = {},
--     yamlls = {},
--     -- phpcs = {},
--     intelephense = {},
--     -- sql_formatter = {},
-- }
-- 
-- mason_lspconfig.setup({
--     ensure_installed = vim.tbl_keys(servers),
--     automatic_installation = false,
-- })
--
-- mason_lspconfig.setup_handlers({
--     function(server_name)
--         local opts = {}
--         if (server_name == 'pyright') then
--             opts.root_dir = util.root_pattern('.venv')
--         end
--         if (server_name == 'pylsp') then
--             opts.root_dir = util.root_pattern('.venv')
--         end
--         if (server_name == 'basedpyright') then
--             opts.root_dir = util.root_pattern('.venv')
--         end
--         opts.on_attach = on_attach
--         opts.settings = servers[server_name]
--         opts.filetypes = (servers[server_name] or {}).filetypes
--         lspconfig[server_name].setup(opts)
--     end,
-- })
--

vim.diagnostic.config(
    {
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
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN] = "",
                [vim.diagnostic.severity.HINT] = "",
                [vim.diagnostic.severity.INFO] = "",
            },
        },
    }
)



-- 2. build-in LSP function
-- keyboard shortcut
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


vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
        border = "rounded",
    }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
})

local diagnostic_hover_augroup_name = "lspconfig-diagnostic"

vim.api.nvim_set_option('updatetime', 300)

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
        callback = function()
            vim.diagnostic.open_float()
        end,
    }
)

-- vim.api.nvim_create_autocmd(
--     {
--         'LspAttach',
--     },
--     {
--         group = diagnostic_hover_augroup_name,
--         callback = function(args)
--             local bufnr = args.buf
--             local client = vim.lsp.get_client_by_id(args.data.client_id)
--         end,
--     }
-- )

-- 3, create user command
-- vim.api.nvim_create_user_command('Formatting', vim.lsp.buf.formatting, {})
-- vim.api.nvim_create_user_command("Formatting", "lua vim.lsp.buf.format {async = true}", {})
