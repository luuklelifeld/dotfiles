#!/bin/bash
set -euo pipefail

hook_input=$(cat)
worktree_name=$(jq -r '.name' <<<"$hook_input")
session_cwd=$(jq -r '.cwd' <<<"$hook_input")

git_common_dir=$(git -C "$session_cwd" rev-parse --path-format=absolute --git-common-dir)
repo_root=$(dirname "$git_common_dir")
worktree_path="$repo_root/.worktrees/$worktree_name"
branch_name="worktree-$worktree_name"

if [ ! -d "$worktree_path" ]; then
  if git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch_name"; then
    git -C "$repo_root" worktree add "$worktree_path" "$branch_name" >&2
  else
    base_ref=$(git -C "$repo_root" symbolic-ref --quiet --short refs/remotes/origin/HEAD || echo HEAD)
    git -C "$repo_root" worktree add --no-track -b "$branch_name" "$worktree_path" "$base_ref" >&2
  fi
fi

echo "$worktree_path"
