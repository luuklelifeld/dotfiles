alias activate="source .venv/bin/activate"
alias cath="pygmentize -P style=catppuccin-mocha"
alias hosts-reload="dscacheutil -flushcache"
alias tmux_init="tmux rename-window code && tmux new-window -n run && tmux new-window -n cli && tmux select-window -t 1 && vim"
alias vim="nvim"

alias create-ssr-deploy="pnpm i && pnpm run deploy:consumer-platforms && rm -rf ~/ssr-deploy && mkdir ~/ssr-deploy && mv prod/node_modules ~/ssr-deploy && mv apps/consumer-platform/dist/ssr/* ~/ssr-deploy"
