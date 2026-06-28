#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

# Claude Code WorktreeRemove hook.
#
# Thin adapter over the `wt` command: reads the hook payload on stdin and hands
# the worktree path to `wt rm --dir`, which forgets the workspace (jj) or removes
# the worktree (git) and deletes the directory. This hook has no decision control
# and produces no output Claude Code acts on; its only job is cleanup. See
# files/bin/wt for the real logic.

PAYLOAD=$(cat)

WORKTREE_PATH=$(jq -r '.worktree_path' <<<"$PAYLOAD")
[ -n "$WORKTREE_PATH" ] && [ "$WORKTREE_PATH" != "null" ] || { echo "worktreeRemove: missing or null .worktree_path in payload" >&2; exit 1; }

exec bash "${HOME}/.dotfiles/files/bin/wt" rm --dir "$WORKTREE_PATH"
