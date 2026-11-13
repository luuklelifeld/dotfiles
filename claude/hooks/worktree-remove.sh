#!/bin/bash
set -euo pipefail

worktree_path=$(jq -r '.worktree_path')

if [ ! -d "$worktree_path" ]; then
  exit 0
fi

git_common_dir=$(git -C "$worktree_path" rev-parse --path-format=absolute --git-common-dir)
repo_root=$(dirname "$git_common_dir")
branch_name=$(git -C "$worktree_path" branch --show-current)

git -C "$repo_root" worktree remove --force "$worktree_path" >&2

if [[ "$branch_name" == worktree-* ]]; then
  git -C "$repo_root" branch -D "$branch_name" >&2
fi
