#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

# Claude Code WorktreeCreate hook.
#
# Thin adapter over the `wt` command: reads the hook payload on stdin, then hands
# the worktree name and project directory to `wt new`, which creates the worktree
# (jj or git), links any .worktreeinclude entries, and prints the path. Claude
# Code reads that path on stdout. Worktrees are placed under ~/.claude/worktrees
# rather than wt's default base dir. See files/bin/wt for the real logic.

PAYLOAD=$(cat)

NAME=$(jq -r '.name' <<<"$PAYLOAD")
[ -n "$NAME" ] && [ "$NAME" != "null" ] || { echo "worktree-create: missing or null .name in payload" >&2; exit 1; }
PROJECT_DIR=$(jq -r '.cwd' <<<"$PAYLOAD")

exec bash "${HOME}/.dotfiles/files/bin/wt" new \
    --worktrees-base-dir "${HOME}/.claude/worktrees" --project "$PROJECT_DIR" -- "$NAME"
