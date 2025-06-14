return {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    enabled = vim.g.largeEnable,
    config = true,
    -- config = function()
    --     require('nvim-treesitter.config').setup({
    --         -- シンタックスハイライト

    --         -- A list of parser names, or "all"
    --         ensure_installed = {
    --             "c",
    --             "lua",
    --             "rust",
    --             "typescript",
    --             "vim",
    --             "json",
    --             "javascript",
    --             "python",
    --             "jsonc",
    --             "toml",
    --             "yaml",
    --             "php_only",
    --         },

    --         -- Install parsers synchronously (only applied to `ensure_installed`)
    --         sync_install = false,

    --         -- List of parsers to ignore installing (for "all")
    --         -- ignore_install = { "javascript" },

    --         highlight = {
    --             -- `false` will disable the whole extension
    --             enable = true,

    --             -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    --             -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    --             -- the name of the parser)
    --             -- list of language that will be disabled
    --             disable = { "c", "rust" },

    --             -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    --             -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    --             -- Using this option may slow down your editor, and you may see some duplicate highlights.
    --             -- Instead of true it can also be a list of languages
    --             additional_vim_regex_highlighting = false,
    --         },

    --         -- カッコハイライト
    --         rainbow = {
    --             enable = true,
    --             -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
    --             extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
    --             max_file_lines = nil, -- Do not enable for files with more than n lines, int
    --             -- colors = {}, -- table of hex strings
    --             -- termcolors = {} -- table of colour name strings
    --         },

    --         -- インデント
    --         indent = {
    --             enable = true,
    --         },

    --         -- タグ自動クローズ
    --         utotag = {
    --             enable = true,
    --         },
    --     })
    -- end,
}
