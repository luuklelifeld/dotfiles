return {
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
--return {
--    "hrsh7th/nvim-cmp",
--    dependencies = {
--        "hrsh7th/cmp-nvim-lsp",
--        "hrsh7th/cmp-buffer",
--        "hrsh7th/cmp-path",
--        "hrsh7th/cmp-cmdline",
--        "saadparwaiz1/cmp_luasnip"
--    },
--    config = function()
--        local cmp = require("cmp")
--        cmp.setup({
--            snippet = {
--                expand = function(args)
--                    require("luasnip").lsp_expands(args.body)
--                end
--            },
--            window = {
----               completion = cmp.config.window.bordered(),
--               documentation = cmp.config.window.bordered()
--            },
--            mapping = {}, -- move this to mappings module
--            sources = cmp.config.sources({
--                {name = "nvim_lsp"},
--                {name = "luasnip"},
--                {name = "buffer"}
--            })
--        })
--
--        cmp.setup.cmdline("/", {
--            mapping = cmp.mapping.preset.cmdline(),
--            sources = {
--                {name = "buffer"}
--            }
--        })
--
--        cmp.setup.cmdline(":", {
--            mapping = cmp.mapping.preset.cmdline(),
--            sources = {
--                {name = "path"},
--                {name = "cmdline"}
--            }
--        })
--    end
--}
