-- Copilot.lua is now configured directly in avante.nvim dependencies
-- to avoid loading order issues
return {
    -- "zbirenbaum/copilot.lua",
    -- cmd = "Copilot",
    -- event = "InsertEnter",
    -- config = function()
    --     require("copilot").setup({
    --         suggestion = { enabled = false },
    --         panel = { enabled = false },
    --         copilot_node_command = 'node',
    --     })
    -- end,
    'github/copilot.vim',
    cmd = 'Copilot',
    event = 'InsertEnter',
    enabled = true,
}
