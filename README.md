### Vim configs

Create symlinks from these files to your vim or neovim config file location, depending on your OS.

- .vimrc for editor config
- init.lua for editor lua customization
- init.vim simply loads the .vimrc and init.lua into neovim

This way this repo is compatible with both vim and neovim on any OS yaaay.

For vim you only need to symlink the .vimrc, for neovim you need to symlink all 3 files.

## Examples

Symlinking neovim and vim commands on Windows: 

- first cd to this project's folder
- neovim: `mklink %localappdata%\nvim\.vimrc %CD%\.vimrc && mklink %localappdata%\nvim\init.vim %CD%\init.vim && mklink %localappdata%\nvim\init.lua %CD%\init.lua`
- vim: `mklink %userprofile%\.vimrc %CD%\.vimrc`