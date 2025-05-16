-- return {
--     'mfussenegger/nvim-lint',
--     event = "VeryLazy",
--     config = function()
--         local lint = require('lint')
--         lint.linters_by_ft = {
--             -- python = {'flake8', 'dmypy'},
--         }
--         vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--             callback = function()
--                 -- try_lint without arguments runs the linters defined in `linters_by_ft`
--                 -- for the current filetype
--                 require("lint").try_lint()
--                 -- You can call `try_lint` with a linter name or a list of names to always
--                 -- run specific linters, independent of the `linters_by_ft` configuration
--                 require("lint").try_lint("cspell")
--             end,
--         })
-- 
--         local mypy_config = require("lint").linters.mypy
--          mypy_config.append_fname = false
--          mypy_config.cmd = "dmypy"
--          mypy_config.args = {
--             'run',
--             '--',
--             -- https://github.com/mfussenegger/nvim-lint/blob/master/lua/lint/linters/mypy.lua
--             '--show-column-numbers',
--             '--show-error-end',
--             '--hide-error-context',
--             '--no-color-output',
--             '--no-error-summary',
--             '--no-pretty',
--             '--use-fine-grained-cache',
--             '.',
--          }
--     end,
-- }

-- lua/plugins/nvim-lint.lua
return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    dependencies = {
      "linux-cultist/venv-selector.nvim",
    },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        python = { "flake8", "dmypy" },
        ["*"] = { "cspell" },  -- すべてのファイルタイプでcspellを有効化
      }
      
      -- オプション設定の例（必要に応じてカスタマイズ）
      -- lint.linters.flake8.args = { "--max-line-length=100" }
      -- lint.linters.cspell.args = { "--config", "~/.cspell.json" }

      print()
      print('we are sapporo')
      print(vim.inspect(require("venv-selector").venv()))
      -- 自動実行の設定
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave", "TextChanged" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })

    end,
  },
}
