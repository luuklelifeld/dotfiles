return {
    -- this is equivalent to setup({}) function
    'saghen/blink.cmp',
    -- optional: provides snippets for the snippet source
    dependencies = { 'rafamadriz/friendly-snippets' },
    version = '1.*',
    opts = {
        keymap = {
            preset = 'default'
        },
        completion = {
            documentation = { auto_show = true }
        },
        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' }
        },
        fuzzy = {
            implementation = 'prefer_rust_with_warning'
        }
    },
    opts_extend = { 'sources.default' }
}
