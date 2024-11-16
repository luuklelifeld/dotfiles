local wezterm = require 'wezterm'
local config = {}

local is_windows = function()
    return wezterm.target_triple:find("windows") ~= nil
end

if is_windows then
    config.wsl_domains = {
        {
            name = 'WSL:Ubuntu',
            distribution = 'Ubuntu',
			default_cwd = '~'
        }
    }

    config.default_domain = 'WSL:Ubuntu'
end

config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Catppuccin Mocha'
config.window_decorations = 'TITLE | RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.initial_cols = 160
config.initial_rows = 40

local leader = 'CTRL'

if not is_windows then
    leader = 'CMD'
end

config.leader = {key = 'a', mods = leader, timeout_milliseconds = 1000}
act = wezterm.action

config.keys = {
  { mods = 'LEADER', key = 'r', action = act.ReloadConfiguration },
  { mods = 'LEADER', key = 'f', action = act.ToggleFullScreen },
  { mods = 'LEADER', key = 't', action = act.SpawnTab 'CurrentPaneDomain' },
  { mods = 'LEADER', key = 'X', action = act.CloseCurrentTab { confirm = true } },
  { mods = "LEADER", key = "v", action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { mods = "LEADER", key = "h", action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { mods = "LEADER", key = "x", action = act.CloseCurrentPane { confirm = true } },
  { mods = 'LEADER', key = 's', action = act.PaneSelect { alphabet = 'arstgmneio' } }
}

return config
