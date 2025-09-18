vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.fillchars = { eob = " " }
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wrap = false
--vim.opt.showtabline = 2

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 999

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = ""

vim.g.mapleader = " "

local ok, _ = pcall(vim.cmd, 'colorscheme catppuccin')
if not ok then
    vim.cmd 'colorscheme default'
end
vim.cmd 'set number'

vim.diagnostic.config {
    underline = true,
    virtual_text = {
        prefix = "",
        severity = nil,
        source = "if_many",
        format = nil,
    },
    signs = true,
    severity_sort = true,
    update_in_insert = false,
}

local gwidth = vim.api.nvim_list_uis()[1].width
local gheight = vim.api.nvim_list_uis()[1].height
local width = math.floor(gwidth * 0.5)
local height = math.floor(gheight * 0.7)

require("nvim-tree").setup({
    sort = {
        sorter = "case_sensitive",
    },
    update_focused_file = {
        enable = true
    },
    view = {
        float = {
            enable = true,
            open_win_config = {
                relative = "editor",
                width = width,
                height = height,
                row = (gheight - height) * 0.4,
                col = (gwidth - width) * 0.5,
            }
        }
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        custom = {
            "^.DS_STORE$",
            "^.vscode$"
        }
    },
})


vim.opt.laststatus = 3
