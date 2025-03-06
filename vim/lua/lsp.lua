-- lua_add {{{
print 'read lsp.lua !!'

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- require("ddc_source_lsp_setup").setup()


local neodev = require('neodev')
local util = require('lspconfig/util')
local lspconfig = require('lspconfig')
local mason = require('mason')
local mason_lspconfig = require('mason-lspconfig')
local nvim_navic = require('nvim-navic')
local barbecue = require('barbecue')

neodev.setup({})
-- require("ddc_source_lsp_setup").setup({})

nvim_navic.setup({
    icons = {
        File = ' ',
        Module = ' ',
        Namespace = ' ',
        Package = ' ',
        Class = ' ',
        Method = ' ',
        Property = ' ',
        Field = ' ',
        Constructor = ' ',
        Enum = ' ',
        Interface = ' ',
        Function = ' ',
        Variable = ' ',
        Constant = ' ',
        String = ' ',
        Number = ' ',
        Boolean = ' ',
        Array = ' ',
        Object = ' ',
        Key = ' ',
        Null = ' ',
        EnumMember = ' ',
        Struct = ' ',
        Event = ' ',
        Operator = ' ',
        TypeParameter = ' ',
    },
    lsp = {
        auto_attach = true,
        -- preference = {
        --     -- 'pyright',
        --     'basedpyright',
        -- },
    },
    highlight = false,
    separator = " > ",
    depth_limit = 9,
    depth_limit_indicator = "..",
    safe_output = true,
    click = false
})
vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

-- triggers CursorHold event faster
vim.opt.updatetime = 200

barbecue.setup({
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

-- 1. LSP Sever management
mason.setup({
    PATH = 'prepend',
    log_level = vim.log.levels.WARN,
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        }
    }
})

local config = {
    virtual_text = false,
    update_in_insert = false,
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
    -- inlay_hints = {
    --     enabled = false,
    -- },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.HINT] = "",
            [vim.diagnostic.severity.INFO] = "",
        },
    },
}

vim.diagnostic.config(config)

local bufnr = vim.api.nvim_get_current_buf()
print("bufnr")
print(bufnr)
local filepath = vim.api.nvim_buf_get_name(bufnr)
print('filepath')
print(filepath)
local venv_path = util.root_pattern('.venv')
print('venv_path')
print(venv_path)
local python_path = nil
python_path = vim.g.python3_host_prog
-- if (venv_path == nil) then
--     print('a')
--     python_path = vim.g.python3_host_prog
-- else
--     print('b')
--     python_path = util.path.join(
--         venv_path,
--         '.venv',
--         'bin',
--         'python'
--     )
-- end
print('python_path')
print(python_path)
print('venv_path')
print(venv_path(filepath))

local basedpyright_setting = {
    basedpyright = {
        analysis = {
            --
            -- inlayHints = {
            --     functionReturnTypes = true,
            --     variableTypes = true,
            -- },

            --
            autoImportCompletions = true,

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

local pyright_setting = {
    -- root_dir = venv_path,
    -- -- https://github.com/microsoft/pyright/blob/main/docs/settings.md
    -- log_level = vim.log.levels.Trace,
    -- settings = {
    pyright = {
        disableLanguageService = false,
        disableOrganizeImports = false,
        disableTaggedHints = false,
        openFilesOnly = false,
    },
    python = {
        pythonPath = python_path,
        venvPath = venv_path(filepath),
        venv = '.venv',
        analysis = {
            --
            -- inlayHints = {
            --     functionReturnTypes = true,
            --     variableTypes = true,
            -- },

            --
            autoImportCompletions = true,

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
        good_names_rgxs = {'[a-z]{1,3}'},
    },
}

local pylsp_setting = {
    -- cmd = {
    --     python_path,
    --     '-m',
    --     'pylsp',
    -- },
    -- root_dir = venv_path,
    -- log_level = vim.log.levels.DEBUG,
    -- settings = {
    pylsp = {
       configurationSources = {
           'flake8'
       },
       plugins = {
            flake8 = {
                enabled = true,
                -- executable = python_path,
           --      overrides = {
           --          '--python-executable', python_path, true,
           --      },
            },
            pyls_isort = {
                enabled = true,
            },
            pylsp_mypy = {
                enabled = false,
                live_mode = false,
                dmypy = true,
                report_progress = true,
                skip_token_initialization = true,
                strict = false,
                overrides = {
                    '--cache-fine-grained',
                    '--cache-dir', '/dev/null',
                    '--python-executable', python_path, true,
                    '--ignore-missing-imports',
                },
                config_sub_paths = {
                  -- '/home/y_ohi/docker/scs2/django/project/',
                }
            },
            pycodestyle = {
                enabled = false,
                maxLineLength = 120,
            },
            pyflakes = {
                enabled = false,
            },
            autopep8 = {
                enabled = false,
            },
            yapf = {
                enabled = false,
            },
            pylsp_black = {
                enabled = false,
            },
            memestra = {
                enabled = false,
            },
            mccabe = {
                enabled = false
            },
            pylint = {
                enabled = false
            },
       },
    },

}

local servers = {
    basedpyright = basedpyright_setting,
    -- pyright = pyright_setting,
    pylsp = pylsp_setting,
    -- mypy = {},
    -- flake8 = {},
    -- isort = {},
    bashls = {},
    dockerls = {},
    dotls = {},
    html = {},
    jsonls = {},
    -- sourcery = {},
    -- sqlls = {},
    lua_ls = {},
    vimls = {},
    yamlls = {},
    -- phpcs = {},
    intelephense = {},
    -- sql_formatter = {},
}

mason_lspconfig.setup({
    ensure_installed = vim.tbl_keys(servers),
    automatic_installation = false,
})

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

mason_lspconfig.setup_handlers({
    function(server_name)
        local opts = {}
        if (server_name == 'pyright') then
            opts.root_dir = util.root_pattern('.venv')
        end
        if (server_name == 'pylsp') then
            opts.root_dir = util.root_pattern('.venv')
        end
        if (server_name == 'basedpyright') then
            opts.root_dir = util.root_pattern('.venv')
        end
        opts.on_attach = on_attach
        opts.settings = servers[server_name]
        opts.filetypes = (servers[server_name] or {}).filetypes
        lspconfig[server_name].setup(opts)
    end,
})

local function on_cursor_hold()
    -- if vim.lsp.buf.server_ready() then
        vim.diagnostic.open_float()
    -- end
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

vim.api.nvim_create_autocmd({
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
})

vim.api.nvim_create_autocmd(
    {
    'LspAttach',
    },
    {
        group = diagnostic_hover_augroup_name,
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            -- if client.supports_method("textDocument/inlayHint") then
            --     vim.lsp.inlay_hint(bufnr, true)
            -- end
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

local function lsp_highlight_document(client)
    -- illuminate.on_attach(client)
end


-- 2. build-in LSP function
-- keyboard shortcut


-- 3, create user command
-- vim.api.nvim_create_user_command('Formatting', vim.lsp.buf.formatting, {})
vim.api.nvim_create_user_command("Formatting", "lua vim.lsp.buf.format {async = true}", {})


local handle_lsp = function(opts)
    return opts
end

--   }}}

