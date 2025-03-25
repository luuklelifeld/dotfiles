local colorschemes = {}

table.insert(colorschemes,
    { "santos-gabriel-dario/darcula-solid.nvim", name = "darcula", dependencies = { "rktjmp/lush.nvim" } })
table.insert(colorschemes, { "rebelot/kanagawa.nvim" })
table.insert(colorschemes, { "ellisonleao/gruvbox.nvim" })
table.insert(colorschemes, { "rose-pine/neovim", name = "rose-pine" })
table.insert(colorschemes, {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
        highlight_overrides = {
            mocha = function()
                return {
                    LineNr = { fg = "#c19c91" },
                }
            end
        }
    }
})
table.insert(colorschemes, { "folke/tokyonight.nvim" })

return colorschemes
