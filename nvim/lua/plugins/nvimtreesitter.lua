return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed =  {"c", "cpp", "diff", "html", "javascript", "json", "lua", "markdown", "python", "typescript", "query", "vim", "vimdoc", "xml", "yaml"},
            sync_install = false,
            auto_install = true,
            ignore_install = { },
            highlight = {
                enable = true,
                disable = { },
                additional_vim_regex_highlighting = false
            }
        })
    end
}
