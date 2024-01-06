return {
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed =  {"c", "cpp", "javascript", "lua", "python", "typescript", "vim", "vimdoc", "query"},
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
