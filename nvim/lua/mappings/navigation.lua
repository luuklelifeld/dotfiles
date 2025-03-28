local wrap = function(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ss', wrap(builtin.find_files, { hidden = true }), { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>sb', wrap(builtin.buffers, { sort_lastused = true, ignore_current_buffer = true }),
    { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = 'Telescope resume' })

vim.keymap.set('n', 'gd', builtin.lsp_definitions);
vim.keymap.set('n', 'gr', builtin.lsp_references);
vim.keymap.set('n', 'gI', builtin.lsp_implementations);

vim.keymap.set('n', '<leader>t', vim.cmd.NvimTreeToggle);

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>');
