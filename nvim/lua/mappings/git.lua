local wrap = function(func, ...)
    local args = { ... }
    return function()
        func(unpack(args))
    end
end
local neogit = require('neogit')
local diffview = require('diffview')

vim.keymap.set('n', '<leader>go', wrap(neogit.open, { kind = 'floating' }))
vim.keymap.set('n', '<leader>gc', wrap(neogit.open, { 'commit', kind = 'floating' }))
vim.keymap.set('n', '<leader>dfo', diffview.open)
vim.keymap.set('n', '<leader>dfc', diffview.close)
local function parent_branch()
    if vim.fn.executable('gh') == 1 then
        local pr_base = vim.trim(vim.fn.system({ 'gh', 'pr', 'view', '--json', 'baseRefName', '--jq', '.baseRefName' }))
        if vim.v.shell_error == 0 and pr_base ~= '' then
            return 'origin/' .. pr_base
        end
    end

    local closest, fewest_commits_ahead
    for _, candidate in ipairs({ 'origin/develop', 'origin/main', 'origin/master' }) do
        local commits_ahead = tonumber(vim.fn.system({ 'git', 'rev-list', '--count', candidate .. '..HEAD' }))
        if vim.v.shell_error == 0 and commits_ahead then
            if not fewest_commits_ahead or commits_ahead < fewest_commits_ahead then
                closest, fewest_commits_ahead = candidate, commits_ahead
            end
        end
    end
    return closest
end

vim.keymap.set('n', '<leader>dfd', function()
    local parent = parent_branch()
    if not parent then
        vim.notify('Could not determine parent branch', vim.log.levels.WARN)
        return
    end
    diffview.open({ parent .. '...HEAD' })
end)
