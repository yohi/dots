-- LSP Configuration using vim.lsp.config() (New Neovim LSP API)

-- 1. Define LSP configurations using vim.lsp.config()

-- Global configuration for all LSP servers
vim.lsp.config('*', {
  root_markers = { '.git' },
})

-- Python LSP (basedpyright)
vim.lsp.config('basedpyright', {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { '.venv', 'pyproject.toml', 'setup.py', 'requirements.txt' },
  settings = {
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
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
})

-- Python LSP (pylsp) as alternative
vim.lsp.config('pylsp', {
  cmd = { 'pylsp' },
  filetypes = { 'python' },
  root_markers = { '.venv', 'pyproject.toml', 'setup.py', 'requirements.txt' },
})

-- Bash LSP
vim.lsp.config('bashls', {
  cmd = { 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
})

-- Docker LSP
vim.lsp.config('dockerls', {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { 'Dockerfile', '.git' },
})

-- HTML LSP
vim.lsp.config('html', {
  cmd = { 'vscode-html-language-server', '--stdio' },
  filetypes = { 'html' },
  root_markers = { 'package.json', '.git' },
})

-- JSON LSP
vim.lsp.config('jsonls', {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = { 'package.json', '.git' },
})

-- Lua LSP
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- Vim LSP
vim.lsp.config('vimls', {
  cmd = { 'vim-language-server', '--stdio' },
  filetypes = { 'vim' },
  root_markers = { '.git' },
})

-- YAML LSP
vim.lsp.config('yamlls', {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yml' },
  root_markers = { '.git' },
})

-- PHP LSP (Intelephense)
vim.lsp.config('intelephense', {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git' },
})

-- 2. Enable LSP configurations
local lsp_servers = {
  'basedpyright',
  'bashls',
  'dockerls',
  'html',
  'jsonls',
  'lua_ls',
  'vimls',
  'yamlls',
  'intelephense',
}

-- Enable all configured LSP servers
for _, server in ipairs(lsp_servers) do
  vim.lsp.enable(server)
end

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
