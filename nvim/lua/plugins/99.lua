return {
    "ThePrimeagen/99",
    dependencies = { 'saghen/blink.compat', version = '2.*' },
    config = function()
        local _99 = require("99")
        local cwd = vim.uv.cwd()
        local basename = vim.fs.basename(cwd)
        _99.setup({
            logger = {
                level = _99.DEBUG,
                path = "/tmp/" .. basename .. ".99.debug",
                print_on_error = true,
            },
            --provider = _99.ClaudeCodeProvider,
            model = 'anthropic/claude-opus-4-6',

            completion = {
                custom_rules = {
                    "scratch/custom_rules/",
                },

                source = "blink",
            },

            md_files = {
                "CLAUDE.md",
                "AGENT.md",
            },
        })

        vim.keymap.set("v", "<leader>av", function()
            _99.visual({})
        end)
        vim.keymap.set("v", "<leader>ax", function()
            _99.stop_all_requests()
        end)
        vim.keymap.set("n", "<leader>as", function()
            _99.search({})
        end)
    end,
}
