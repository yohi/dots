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
                        system = "see [Prompt] section for the default value",
                        few_shots = "see [Prompt] section for the default value",
                        chat_input = "See [Prompt Section for default value]",
                        stream = true,
                        api_key = 'AIzaSyAbpdEzp2aKKd3_KdtPd4bEJSCOaFUj3Lg',
                        end_point = 'https://generativelanguage.googleapis.com/v1beta/models',
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
