#!/bin/sh

script_dir="$(dirname $0)"

if [ $script_dir = "." ]
then
    script_dir=""
else
    script_dir="/$script_dir"
fi

path="$(pwd)$script_dir"

# ssh
mkdir ~/.ssh
ln -s "$path/ssh/config" ~/.ssh/config

# NeoVim
mkdir ~/.config
ln -s "$path/nvim" ~/.config/nvim

# Wezterm
mkdir ~/.config/wezterm
ln -s "$path/wezterm/wezterm.lua" ~/.config/wezterm/wezterm.lua

# tmux
ln -s "$path/tmux/.tmux.conf" ~/.tmux.conf

# git
mkdir ~/.config/git
ln -s "$path/git/.gitconfig" ~/.gitconfig
ln -s "$path/git/gitconfig-personal" ~/.config/git
ln -s "$path/git/gitconfig-work" ~/.config/git

# oh-my-zsh
mkdir ~/.oh-my-zsh
mkdir ~/.oh-my-zsh/custom
ln -s "$path/zsh/.zshrc" ~/.zshrc
ln -s "$path/zsh/custom/aliases.zsh" ~/.oh-my-zsh/custom/aliases.zsh
ln -s "$path/zsh/custom/environment-setup.zsh" ~/.oh-my-zsh/custom/environment-setup.zsh

# aerospace
ln -s "$path/aerospace/.aerospace.toml" ~/.aerospace.toml

# hammerspoon
mkdir ~/.hammerspoon
ln -s "$path/hammerspoon/init.lua" ~/.hammerspoon/init.lua

# yt-dlp
ln -s "$path/yt-dlp/yt-dlp.conf" ~/yt-dlp.conf
