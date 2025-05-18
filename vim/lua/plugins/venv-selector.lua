-- return {
--   "linux-cultist/venv-selector.nvim",
--   dependencies = {
--     "neovim/nvim-lspconfig",
--     "mfussenegger/nvim-dap",
--     "mfussenegger/nvim-dap-python", --optional
--     {
--         "nvim-telescope/telescope.nvim",
--         branch = "0.1.x",
--         dependencies = { "nvim-lua/plenary.nvim" }
--     },
--   },
--   lazy = false,
--   branch = "regexp", -- This is the regexp branch, use this for the new version
--   keys = {
--     { ",v", "<cmd>VenvSelect<cr>" },
--   },
--   ---@type venv-selector.Config
--   opts = {
--     -- Your settings go here
--   },
-- }




return {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        "mfussenegger/nvim-dap-python", --optional
        {
            "nvim-telescope/telescope.nvim",
            branch = "0.1.x",
            dependencies = { "nvim-lua/plenary.nvim" }
        },
    },
    lazy = false,
    branch = "regexp", -- This is the regexp branch, use this for the new version
    keys = {
        { ",v", "<cmd>VenvSelect<cr>" },
    },
    opts = {
    },
    -- config = function()
    --     -- カスタムフックを定義
    --     local function custom_basedpyright_hook(venv_path, venv_python)
    --         local lspconfig = require("lspconfig")
    --         
    --         -- basedpyrightの設定を更新
    --         lspconfig.basedpyright.setup({
    --             -- カスタムルートディレクトリの設定
    --             root_dir = function(fname)
    --                 -- ここで希望するルートディレクトリ検出ロジックを実装
    --                 -- 例：プロジェクトのルートを特定のファイルで判断
    --                 return lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git")(fname)
    --                 -- または固定パスを返すこともできます
    --                 -- return "/path/to/your/project/root"
    --             end,
    --             
    --             -- Python環境の設定
    --             settings = {
    --                 basedpyright = {
    --                     pythonPath = venv_python,
    --                 },
    --             },
    --         })
    --     end
    --     
    --     require("venv-selector").setup({
    --         -- 他の設定
    --         changed_venv_hooks = {
    --             custom_basedpyright_hook,
    --             -- デフォルトのフックを使用したい場合は以下も追加
    --             -- require("venv-selector").hooks.basedpyright
    --         },
    --     })
    -- end,
}
