vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = {eob = " "}
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = false
--vim.opt.showtabline = 2

vim.opt.expandtab = true
vim.opt.tabstop = 12 -- set tabstop to something stupid so it's obvious when one needs to be replaced
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 999

local ok, _ = pcall(vim.cmd, 'colorscheme catppuccin')
if not ok then
    vim.cmd 'colorscheme default'
end

vim.cmd 'set number'

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    view = {
        width = 45,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
})


vim.opt.laststatus = 3

vim.cmd 'NvimTreeOpen'
