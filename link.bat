set path=%~dp0

mkdir %localappdata%\nvim
mklink %localappdata%\nvim\init.lua %path%nvim\init.lua
mklink /d %localappdata%\nvim\lua %path%nvim\lua

mkdir %UserProfile%\.config\wezterm
mklink %UserProfile%\.config\wezterm\wezterm.lua %path%wezterm\wezterm.lua