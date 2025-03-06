return {
    -- telescope, fzf
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        -- cmd = "Telescope",
        config = function()
            require("telescope").setup({
                defaults = {
                    -- 幅と高さを拡げる設定
                    layout_config = {
                        horizontal = {
                            -- prompt_position = "top",
                            width = { padding = 2 },
                            height = { padding = 2 },
                            preview_width = 0.5,
                        },
                    },
                    file_ignore_patterns = {
                        -- 検索から除外するものを指定
                        "^.git/",
                        "^.cache/",
                        "^Library/",
                        "Parallels",
                        "^Movies",
                        "^Music",
                    },
                    vimgrep_arguments = {
                        -- ripggrepコマンドのオプション
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                        "-uu",
                        "--hidden",
                    },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    file_browser = {
                        theme = "ivy",
                        -- disables netrw and use telescope-file-browser in its place
                        hijack_netrw = true,
                        mappings = {
                            ["i"] = {
                                -- your custom insert mode mappings
                            },
                            ["n"] = {
                                -- your custom normal mode mappings
                            },
                        },
                    },
                },
            })
            require("telescope").load_extension("fzf")

            -- ファイル検索
            vim.keymap.set('n', '<C-p>', require('telescope.builtin').find_files, {})
            -- grep検索
            vim.keymap.set('n', '<C-S-F>:', require('telescope.builtin').live_grep, {})
        end,
    },
    {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
    },
}
