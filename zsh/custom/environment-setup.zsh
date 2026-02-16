if [[ "$(uname)" == "Linux" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

source <(fzf --zsh)

export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

eval "$(fnm env --use-on-cd --shell zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

pyenv() {
    eval "$(command pyenv init -)"

    pyenv "$@"
}

#eval "$(jenv init -)"

export PNPM_HOME="/Users/luuklelifeld/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
