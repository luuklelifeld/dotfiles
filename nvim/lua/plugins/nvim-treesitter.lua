return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main",
    config = function()
        local treesitter = require 'nvim-treesitter'
        local parsers = { "c", "cpp", "css", "diff", "html", "javascript", "json", "lua", "markdown", "python",
            "typescript",
            "query", "vim", "vimdoc", "xml", "yaml" }

        for _, parser in ipairs(parsers) do
            treesitter.install(parser)
        end

        local patterns = { "vue" }
        for _, parser in ipairs(parsers) do
            local parser_patterns = vim.treesitter.language.get_filetypes(parser)
            for _, pp in pairs(parser_patterns) do
                table.insert(patterns, pp)
            end
        end

        vim.api.nvim_create_autocmd('FileType', {
            pattern = patterns,
            callback = function()
                vim.treesitter.start()
            end,
        })

        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
    end
}
