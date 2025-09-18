local wrap = function(func, ...)
    local args = { ... }
    return function()
        func(table.unpack(args))
    end
end

local fzf = require('fzf-lua')

vim.keymap.set('n', '<leader>sf', fzf.files, { desc = 'Find Files' })
vim.keymap.set('n', '<leader>sg', fzf.live_grep, { desc = 'Live Grep' })
vim.keymap.set('n', '<leader>sb', fzf.buffers, { desc = 'Find Buffers' })
vim.keymap.set('n', '<leader>sh', fzf.help_tags, { desc = 'Help Tags' })
vim.keymap.set('n', 'gd', fzf.lsp_definitions);
vim.keymap.set('n', 'gr', fzf.lsp_references);
vim.keymap.set('n', 'gI', fzf.lsp_implementations);

vim.keymap.set('n', '<leader>t', vim.cmd.NvimTreeToggle);

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>'); -- Change esc behaviour in terminal mode to match the rest of nvim
