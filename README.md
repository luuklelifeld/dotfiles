### Vim configs

## Usage

Create symlinks from these files to your vim or neovim config file location, depending on your OS.

Example for Windows: cd to the current directory, then run `mklink %localappdata%\nvim\init.lua %CD%\init.lua && mklink /d %localappdata%\nvim\lua %CD%\lua`
Example for Ubuntu: cd to the current directory, then run `ln -s $(pwd)/init.lua ~/.config/nvim/init.lua && ln -s $(pwd)/lua ~/.config/nvim/lua` 

## Font

I use Hack Nerd Font Mono @16pt. It adds an insane amount of icons which can be used by other plugins and it's a very clean font overall. You can download it from `nerdfonts.com`.
