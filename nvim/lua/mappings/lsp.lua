vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, { desc = '[H]over' });
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = '[C]ode [A]ction' });
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame' });
