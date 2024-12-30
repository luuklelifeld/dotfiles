local wrap = function(func, ...)
  local args = {...}
  return function()
    func(unpack(args))
  end
end

local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ss', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>sb', wrap(builtin.buffers, { sort_lastused = true, ignore_current_buffer = true }), { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Telescope help tags' })
