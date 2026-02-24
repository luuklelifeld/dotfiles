#bootstrap-dev() {
#  tmux set-hook -gu session-created
#  for s in api fmp folders-nl-web; do
#    tmux new-session -d -s $s -c ~/dev/publitas/$s
#    tmux_init $s 'npm run serve'
#  done
#  tmux set-hook -g session-created 'run-shell "tmux send-keys -t #{session_name} \"tmux_init\" C-m"'
#}

alias activate="source .venv/bin/activate"
alias cath="pygmentize -P style=catppuccin-mocha"
alias hosts-reload="dscacheutil -flushcache"
tmux_init() {
  local s=${1:-$(tmux display-message -p '#S')}
  local d=$(tmux display-message -t $s -p '#{pane_current_path}')
  tmux rename-window -t $s:1 code
  tmux new-window -t $s -n run -c "$d"
  tmux new-window -t $s -n cli -c "$d"
  tmux select-window -t $s:1
  tmux send-keys -t $s:1 'vim' Enter
  [[ -n "$2" ]] && tmux send-keys -t $s:2 "$2" Enter
}
alias vim="nvim"

alias create-ssr-deploy="pnpm i && pnpm run deploy:consumer-platforms && rm -rf ~/ssr-deploy && mkdir ~/ssr-deploy && mv prod/node_modules ~/ssr-deploy && mv apps/consumer-platform/dist/ssr/* ~/ssr-deploy"
