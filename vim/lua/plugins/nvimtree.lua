return {
    "nvim-tree/nvim-tree.lua",
    event = "VimEnter",
    version = "*",
    lazy = false,
    dependencies = {"nvim-tree/nvim-web-devicons"},
    config = function()
        require("nvim-tree").setup({})
    end
}
