#!/bin/bash
set -euo pipefail

previous_head="$1"
null_ref_pattern='^0+$'

if [[ ! "$previous_head" =~ $null_ref_pattern ]]; then
  exit 0
fi

git_dir=$(git rev-parse --absolute-git-dir)
git_common_dir=$(git rev-parse --path-format=absolute --git-common-dir)

if [ "$git_dir" = "$git_common_dir" ]; then
  exit 0
fi

main_root=$(dirname "$git_common_dir")
worktree_root=$(git rev-parse --show-toplevel)

find "$main_root" \
  \( -name .git -o -name .worktrees -o -path "$main_root/.claude/worktrees" \) -prune \
  -o -name node_modules -type d -prune -print |
  while IFS= read -r main_node_modules; do
    relative_path="${main_node_modules#"$main_root"/}"
    worktree_node_modules="$worktree_root/$relative_path"

    if [ -d "$(dirname "$worktree_node_modules")" ] && [ ! -e "$worktree_node_modules" ] && [ ! -L "$worktree_node_modules" ]; then
      ln -s "$main_node_modules" "$worktree_node_modules"
      echo "Linked $relative_path -> $main_node_modules" >&2
    fi
  done
