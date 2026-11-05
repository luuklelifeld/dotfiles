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
alias p9n-symlink="rm -rf ~/dev/publitas/consumer-platforms/node_modules/@wp/p9n-viewer-canvas && ln -s ~/dev/publitas/p9n/packages/p9n-viewer-canvas ~/dev/publitas/consumer-platforms/node_modules/@wp/p9n-viewer-canvas && rm -rf ~/dev/publitas/consumer-platforms/node_modules/@wp/p9n-canvas && ln -s ~/dev/publitas/p9n/packages/p9n-canvas ~/dev/publitas/consumer-platforms/node_modules/@wp/p9n-canvas"
alias api-ssh='az webapp create-remote-connection -g WP_RG_FMP_P -n wp-wapp-api-p --port 2222 >/dev/null 2>&1 & sleep 15; ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR root@127.0.0.1 -p 2222; kill %1'
