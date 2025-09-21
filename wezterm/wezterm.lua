local wezterm = require 'wezterm'
local config = {}

local is_windows = wezterm.target_triple:find("msvc") ~= nil
local is_mac = wezterm.target_triple:find("darwin") ~= nil
local is_linux = wezterm.target_triple:find("linux") ~= nil

config.term = 'xterm-256color'
config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Catppuccin Mocha'
--config.window_decorations = 'TITLE | RESIZE'
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 160
config.initial_rows = 40
config.font_size = 14

local leader = 'CTRL'

--if is_mac then
--    leader = 'CMD'
--end

config.leader = { key = 'a', mods = leader, timeout_milliseconds = 1000 }
local act = wezterm.action

config.keys = {
    { mods = 'LEADER', key = 'f', action = act.ToggleFullScreen },
    { mods = 'LEADER', key = '+', action = act.IncreaseFontSize },
    { mods = 'LEADER', key = '-', action = act.DecreaseFontSize },
    { mods = 'LEADER', key = '=', action = act.ResetFontSize },
    { mods = 'LEADER', key = 't', action = act.ActivateKeyTable { name = 'tab', one_shot = false } },
    { mods = 'LEADER', key = 'p', action = act.ActivateKeyTable { name = 'pane', one_shot = false } },
    { mods = 'LEADER', key = 'm', action = act.ActivatePaneDirection('Left') },
    { mods = 'LEADER', key = 'n', action = act.ActivatePaneDirection('Down') },
    { mods = 'LEADER', key = 'e', action = act.ActivatePaneDirection('Up') },
    { mods = 'LEADER', key = 'i', action = act.ActivatePaneDirection('Right') }
}

config.key_tables = {
    tab = {
        { key = 'n', action = act.Multiple { act.SpawnTab 'CurrentPaneDomain', 'PopKeyTable' } },
        { key = 'x', action = act.Multiple { act.CloseCurrentTab { confirm = true }, 'PopKeyTable' } },
        { key = '1', action = act.Multiple { act.ActivateTab(0), 'PopKeyTable' } },
        { key = '2', action = act.Multiple { act.ActivateTab(1), 'PopKeyTable' } },
        { key = '3', action = act.Multiple { act.ActivateTab(2), 'PopKeyTable' } },
        { key = '4', action = act.Multiple { act.ActivateTab(3), 'PopKeyTable' } },
        { key = '5', action = act.Multiple { act.ActivateTab(4), 'PopKeyTable' } },
        { key = '6', action = act.Multiple { act.ActivateTab(5), 'PopKeyTable' } },
        { key = '7', action = act.Multiple { act.ActivateTab(6), 'PopKeyTable' } },
        { key = '8', action = act.Multiple { act.ActivateTab(7), 'PopKeyTable' } },
        { key = '9', action = act.Multiple { act.ActivateTab(8), 'PopKeyTable' } },
        { key = '0', action = act.Multiple { act.ActivateTab(9), 'PopKeyTable' } },
    },
    pane = {
        { key = 'h',          action = act.Multiple { act.SplitHorizontal { domain = 'CurrentPaneDomain' }, 'PopKeyTable' } },
        { key = 'v',          action = act.Multiple { act.SplitVertical { domain = 'CurrentPaneDomain' }, 'PopKeyTable' } },
        { key = 's',          action = act.Multiple { act.PaneSelect { alphabet = 'arstgmneio' }, 'PopKeyTable' } },
        { key = 'x',          action = act.Multiple { act.CloseCurrentPane { confirm = true }, 'PopKeyTable' } },
        { key = 'LeftArrow',  action = act.AdjustPaneSize { 'Left', 2 } },
        { key = 'RightArrow', action = act.AdjustPaneSize { 'Right', 2 } },
        { key = 'UpArrow',    action = act.AdjustPaneSize { 'Up', 1 } },
        { key = 'DownArrow',  action = act.AdjustPaneSize { 'Down', 1 } },
        { key = 'Escape',     action = 'PopKeyTable' }
    }
}

return config
