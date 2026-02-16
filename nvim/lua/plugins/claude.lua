return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        event = "VeryLazy",
        config = true,
        keys = {
            { "<leader>a",  nil,                              desc = "AI/Claude Code" },
            { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
            { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
            { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
            { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>",        mode = "v",                  desc = "Send to Claude" },
            {
                "<leader>as",
                "<cmd>ClaudeCodeTreeAdd<cr>",
                desc = "Add file",
                ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
            },
            {
                "<leader>aa",
                function()
                    vim.cmd("ClaudeCodeDiffAccept")
                    vim.cmd("tabclose")
                    vim.cmd("ClaudeCode")
                end,
                desc = "Accept diff",
            },
            {
                "<leader>ad",
                function()
                    vim.cmd("ClaudeCodeDiffDeny")
                    vim.cmd("tabclose")
                    vim.cmd("ClaudeCode")
                end,
                desc = "Deny diff",
            },
        },
        opts = {
            terminal = {
                ---@module "snacks"
                ---@type snacks.win.Config|{}
                snacks_win_opts = {
                    position = "float",
                    width = 0.7,
                    height = 0.7
                },
            },
            diff_opts = {
                open_in_new_tab = true,
                hide_terminal_in_new_tab = true,
            },
        }
    }
}
