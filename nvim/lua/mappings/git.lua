local wrap = function(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end
local neogit = require('neogit')

vim.keymap.set('n', '<leader>go', neogit.open)
vim.keymap.set('n', '<leader>gc', wrap(neogit.open, { 'commit' }))
