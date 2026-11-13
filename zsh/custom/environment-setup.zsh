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

for fnm_dir in "$HOME/.local/share/fnm" "$HOME/.fnm"; do
    if [[ -x "$fnm_dir/fnm" ]]; then
        export PATH="$fnm_dir:$PATH"
        break
    fi
done

if command -v fnm >/dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

pyenv() {
    eval "$(command pyenv init -)"

    pyenv "$@"
}

#eval "$(jenv init -)"

if [[ "$(uname)" == "Darwin" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
