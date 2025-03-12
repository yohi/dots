return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
        local cmp = require("cmp")
        local lspkind = require("lspkind")
        vim.opt.completeopt = { "menu", "menuone", "noselect" }

        local has_words_before = function()
          if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
        end

        cmp.setup({
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol",
                    maxwidth = 50,
                    symbole_map = {
                        -- Copilot = "" ,
                    },
                    ellipsis_char = "...",
                    before = function(entry, vim_item)
                        return vim_item
                    end,
                }),
            },
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                -- ["<Tab>"] = vim.schedule_wrap(function(fallback)
                --     if cmp.visible() and has_words_before() then
                --         cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
                --     else
                --         fallback()
                --     end
                -- end),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                -- { name = "copilot" },
                { name = "nvim_lua" },
                { name = "luasnip" }, -- For luasnip users.
                -- { name = "orgmode" },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })
    end


}

