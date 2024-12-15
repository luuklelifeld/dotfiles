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
ln -s "$path/wezterm/wezterm.lua" ~/.config/wezterm/wezterm.lua

# Git
mkdir ~/.config/git
rm ~/.gitconfig
ln -s "$path/git/.gitconfig" ~/.gitconfig
ln -s "$path/git/gitconfig-personal" ~/.config/git
ln -s "$path/git/gitconfig-work" ~/.config/git

# oh-my-zsh
mkdir ~/.oh-my-zsh
mkdir ~/.oh-my-zsh/custom
ln -s "$path/zsh/.zshrc" ~/.zshrc
ln -s "$path/zsh/custom/aliases.zsh" ~/.oh-my-zsh/custom/aliases.zsh
ln -s "$path/zsh/custom/environment-setup.zsh" ~/.oh-my-zsh/custom/environment-setup.zsh
