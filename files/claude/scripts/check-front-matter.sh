#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

# Reject markdown whose YAML front matter a strict parser can't read.
#
# Claude Code's own front matter parser is lenient, so a description like
#   description: Reviews code. Examples: after refactoring
# reads fine in a session but is invalid YAML — a plain scalar cannot contain
# ": ". Tooling that uses a real parser (check-agent-parity, via yq) then fails
# on a file that looked correct when it was written. Catching it at write time
# turns a silent landmine into immediate feedback.
#
# Runs as a PostToolUse hook on Write|Edit. Exit 2 feeds stderr back to Claude
# so it fixes the file in the same turn.

REPO="$HOME/.dotfiles"

read -r -d '' PAYLOAD || true
FILE=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

[[ "$FILE" == *.md ]] || exit 0
[[ "$FILE" == "$REPO"/* ]] || exit 0
[[ -f "$FILE" ]] || exit 0

# Only files that actually open with a front matter fence are in scope.
[[ "$(head -n 1 "$FILE")" == "---" ]] || exit 0

if ! ERROR=$(yq --front-matter=extract --exit-status '.' "$FILE" 2>&1 > /dev/null); then
    cat >&2 <<EOF
YAML front matter in $FILE is not valid YAML:

  $ERROR

Most often this is an unquoted scalar containing ": " — a plain YAML scalar
cannot hold a colon followed by a space. Rewrite the value as a folded block
scalar, which carries ": " without any quoting:

  description: Reviews code. Examples: after refactoring    # invalid

  description: >-                                           # valid
    Reviews code. Examples: after refactoring

Folding rejoins the lines with single spaces, so the value a parser reads is
unchanged. It also lets a long description wrap within the 80-column limit
that lint-markdown.sh enforces, which a single quoted line cannot.

Fix the front matter and re-apply the edit.
EOF
    exit 2
fi
