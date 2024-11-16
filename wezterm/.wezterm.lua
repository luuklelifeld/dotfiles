local wezterm = require 'wezterm'
local config = {}

local is_mac = function()
    return wezterm.target_triple:find("darwin") ~= nil
end

config.font = wezterm.font 'JetBrains Mono'
config.color_scheme = 'Catppuccin Mocha'

config.window_decorations = 'TITLE | RESIZE'
config.hide_tab_bar_if_only_one_tab = true

local leader = 'CTRL'

if is_mac then
    leader = 'CMD'
end

config.leader = {key = 'a', mods = leader, timeout_milliseconds = 1000}
config.keys = {
  {
    mods   = "LEADER",
    key    = "v",
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
  },
  {
    mods   = "LEADER",
    key    = "h",
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
  },
  {
    mods = "LEADER",
    key = "x",
    action = wezterm.action.CloseCurrentPane { confirm = true }
  }
}

return config
