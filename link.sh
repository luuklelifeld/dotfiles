#!/bin/sh

script_dir="$(dirname $0)"

if [ $script_dir = "." ]
then
    script_dir=""
else
    script_dir="/$script_dir"
fi

path="$(pwd)$script_dir"

# Neovim
mkdir ~/.config
mkdir ~/.config/nvim
ln -s "$path/nvim/init.lua" ~/.config/nvim/init.lua
ln -s "$path/nvim/lua" ~/.config/nvim/lua

# Wezterm
mkdir ~/.config/wezterm
ln -s "$(pwd)$script_dir/wezterm/wezterm.lua" ~/.config/wezterm/wezterm.lua

# oh-my-zsh
mkdir ~/.oh-my-zsh
mkdir ~/.oh-my-zsh/custom
ln -s "$path/zsh/.zshrc" ~/.zshrc
ln -s "$path/zsh/.oh-my-zsh/custom/aliases.zsh" ~/.oh-my-zsh/custom/aliases.zsh
