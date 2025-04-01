local wrap = function(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end
local neogit = require('neogit')

vim.keymap.set('n', '<leader>go', wrap(neogit.open, { kind = 'floating' }))
vim.keymap.set('n', '<leader>gc', wrap(neogit.open, { 'commit', kind = 'floating' }))
