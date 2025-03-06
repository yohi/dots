return {
    "karb94/neoscroll.nvim",
    config = function()
        require("neoscroll").setup({
            easing_function = "sine",
        })
        vim.keymap.set("n", "gg", function()
            require("neoscroll").scroll(
                -2 * vim.api.nvim_buf_line_count(0),
                { move_cursor = true, duration = 100, easing = "sine" }
            )
        end, { silent = true, noremap = true })

        vim.keymap.set("n", "G", function()
            require("neoscroll").scroll(
                2 * vim.api.nvim_buf_line_count(0),
                { move_cursor = true, duration = 100, easing = "sine" }
            )
        end, { silent = true, noremap = true })
    end,
    event = "WinScrolled",
}
