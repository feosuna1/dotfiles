#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

# Sort a Claude Code settings.json in place.
#
# Object keys are sorted alphabetically and string arrays (the permission lists)
# are sorted, so entries appended by permission prompts land in a stable order and
# stop producing noisy diffs. Arrays holding anything other than strings — the
# `hooks` entries, for example — keep their order, since order is meaningful there.
#
# Runs as a Stop hook, which fires in every session on every project, so it must be
# cheap and quiet: the file is rewritten only when sorting actually changes it, and
# a malformed settings.json is left alone rather than failing the turn.

FILE="${1:-${HOME}/.dotfiles/files/claude/settings.json}"

SORTED=$(jq -S 'walk(if type == "array" and all(.[]; type == "string") then sort else . end)' "$FILE") || {
    echo "sort-settings: skipping ${FILE}: not valid JSON" >&2
    exit 0
}

[ "$SORTED" != "$(cat "$FILE")" ] || exit 0

# Truncate and rewrite rather than replacing the file, so the ~/.claude symlink
# pointing here survives.
printf '%s\n' "$SORTED" >"$FILE"
