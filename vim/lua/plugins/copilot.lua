-- Unified to use zbirenbaum/copilot.lua across all plugins
return {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    enabled = true,
    config = function()
        require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
            copilot_node_command = 'node',
        })
    end,
}
