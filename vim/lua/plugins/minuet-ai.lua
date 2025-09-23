return {
    {
        'milanglacier/minuet-ai.nvim',
        config = function()
            require('minuet').setup {
                -- Your configuration options here
                provider = 'gemini',
                provider_options = {
                    gemini = {
                        model = 'gemini-2.0-flash',
                        -- system = 'your system prompt',
                        -- few_shots = 'your few-shot examples',
                        -- chat_input = 'your chat input template',
                        stream = true,
                        api_key = vim.env.GEMINI_API_KEY or "",
                        endpoint = vim.env.GEMINI_API_ENDPOINT or 'https://generativelanguage.googleapis.com/v1/models',
                        optional = {},
                    },
                }
            }
        end,
    },
    { 'nvim-lua/plenary.nvim' },
    -- optional, if you are using virtual-text frontend, nvim-cmp is not
    -- required.
    { 'hrsh7th/nvim-cmp' },
    -- optional, if you are using virtual-text frontend, blink is not required.
    { 'Saghen/blink.cmp' },
}
