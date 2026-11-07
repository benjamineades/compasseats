#!/usr/bin/env bash
# Put the publish-preview branch in a folder next to the main checkout, as a
# git worktree, so a workflow can write to it and push it.
#
#   scripts/publish/checkout-preview.sh <folder> create    (build: make the branch if it is not there yet)
#   scripts/publish/checkout-preview.sh <folder> require   (promote, rollback: the branch must exist)
#
# The branch holds no site code. A new branch starts empty (an orphan branch,
# with no history shared with main), so nothing from the site can leak onto it.
set -euo pipefail

dir="${1:?usage: checkout-preview.sh <folder> create|require}"
mode="${2:?usage: checkout-preview.sh <folder> create|require}"
branch="publish-preview"

if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  git fetch --no-tags --depth=1 origin "+refs/heads/$branch:refs/remotes/origin/$branch"
  git worktree add -B "$branch" "$dir" "origin/$branch"
  echo "Checked out $branch at $(git -C "$dir" rev-parse --short HEAD) into $dir."
elif [ "$mode" = "create" ]; then
  git worktree add --detach "$dir" HEAD
  git -C "$dir" checkout --orphan "$branch"
  git -C "$dir" rm -rfq --cached . >/dev/null
  git -C "$dir" clean -fdqx
  # remove the tracked files the detached checkout put on disk
  find "$dir" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
  echo "Created a new, empty $branch branch in $dir."
else
  echo "The $branch branch does not exist yet. Run Publish — build first." >&2
  exit 1
fi
