return {
    "akinsho/bufferline.nvim",
    version = "*",
    config = function()
        local status_ok, bufferline = pcall(require, "bufferline")
        if not status_ok then
            vim.notify("bufferline not ok")
        end bufferline.setup({
            highlights = require("catppuccin.groups.integrations.bufferline").get(),
            options = {
                mode = "buffers",
                style_preset = bufferline.style_preset.default,
                themable = true,
                numbers = "buffer_id",
                indicator = {
                    --icon = '|', -- this should be omitted if indicator style is not 'icon'
                    style = 'none',
                },
                --buffer_close_icon = '󰅖',
                --modified_icon = '●',
                --close_icon = '',
                --left_trunc_marker = '',
                --right_trunc_marker = '',
                max_name_length = 18,
                max_prefix_length = 15,
                truncate_names = true,
                tab_size = 18,
                diagnostics = "nvim_lsp",
                diagnostics_update_in_insert = false,
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        text_align = "left",
                        separator = true
                    }
                },
                color_icons = true,
                show_buffer_icons = true, -- filetype icons for buffers
                show_buffer_close_icons = false,
                show_close_icon = false,
                show_tab_indicators = true,
                show_duplicate_prefix = false, -- whether to show duplicate buffer prefix
                persist_buffer_sort = false, -- whether or not custom sorted buffers should persist
                move_wraps_at_ends = false, -- whether or not the move command "wraps" at the first or last position
                -- can also be a table containing 2 custom separators
                -- [focused and unfocused]. eg: { '|', '|' }
                separator_style = "slant",
                enforce_regular_tabs = false,
                always_show_bufferline = true,
                sort_by = "insert_after_current"
            }
        })
    end
}
