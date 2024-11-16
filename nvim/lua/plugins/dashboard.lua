return {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
        local header = [[
██ ████████     ██ ███████     ██     ██ ███████ ██████  ███    ██ ███████ ███████ ██████   █████  ██    ██     ███    ███ ██    ██     ██████  ██    ██ ██████  ███████ ███████ 
██    ██        ██ ██          ██     ██ ██      ██   ██ ████   ██ ██      ██      ██   ██ ██   ██  ██  ██      ████  ████  ██  ██      ██   ██ ██    ██ ██   ██ ██      ██      
██    ██        ██ ███████     ██  █  ██ █████   ██   ██ ██ ██  ██ █████   ███████ ██   ██ ███████   ████       ██ ████ ██   ████       ██   ██ ██    ██ ██   ██ █████   ███████ 
██    ██        ██      ██     ██ ███ ██ ██      ██   ██ ██  ██ ██ ██           ██ ██   ██ ██   ██    ██        ██  ██  ██    ██        ██   ██ ██    ██ ██   ██ ██           ██ 
██    ██        ██ ███████      ███ ███  ███████ ██████  ██   ████ ███████ ███████ ██████  ██   ██    ██        ██      ██    ██        ██████   ██████  ██████  ███████ ███████ 
]]
        require("dashboard").setup({
            theme = "doom",
            config = {
                header = vim.split(string.rep("\n", 8) .. header .. "\n\n", "\n"),
                center = {
                    {
                        icon = "x", icon_hl = "Title", desc = "Find file", key = "a", keymap = "SPC f f", key_hl = "Number", key_format = " %s", action = "lua print(2)"
                    },
                }
            }
        })
    end,
    dependencies = {"nvim-tree/nvim-web-devicons"}
}
