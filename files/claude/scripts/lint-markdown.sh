#!/bin/bash
set -o errexit # Exit if any individual command fails and isn't handled
set -o nounset # Exit if unset variables are used

# Auto-fix markdown lint violations, and report the ones --fix can't resolve.
#
# markdownlint-cli2 repairs the mechanical rules itself (blank lines, trailing
# spaces, list marker spacing, missing final newline). What it cannot repair is
# mostly MD013 line-length, which this repo sets to 80 — that needs prose
# rewrapped, so it comes back as a blocking error for Claude to fix.
#
# markdownlint strips YAML front matter before linting, so MD013 never sees it.
# Skill and agent `description` values are the one front matter field long enough
# to need wrapping, so this script checks them itself — otherwise the 80-column
# limit stops at the front matter fence.
#
# Runs as a PostToolUse hook on Write|Edit. Exit 2 feeds stderr back to Claude;
# exit 1 surfaces a missing prerequisite to the user without blocking the turn.
# Claude Code already reports on its own when a hook rewrites a file, so this
# script does not duplicate that notice.

REPO="$HOME/.dotfiles"

read -r -d '' PAYLOAD || true
FILE=$(printf '%s' "$PAYLOAD" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')

[[ "$FILE" == *.md ]] || exit 0
[[ "$FILE" == "$REPO"/* ]] || exit 0
[[ -f "$FILE" ]] || exit 0

if ! command -v markdownlint-cli2 > /dev/null 2>&1; then
    echo "lint-markdown: markdownlint-cli2 is not installed; $FILE was not linted." >&2
    exit 1
fi

# markdownlint-cli2 discovers .markdownlint-cli2.yaml from the working directory,
# not from the file being linted. Run from the repo root or the repo's config —
# including its CLAUDE.md ignores — is silently skipped.
cd "$REPO"

# Report every over-long line of the front matter `description`, if any. Bash's
# ${#line} counts characters rather than bytes, matching how MD013 measures a
# line — an em dash must not read as three columns.
long_description_lines() {
    local line key="" number=0

    while IFS= read -r line; do
        number=$((number + 1))
        if ((number == 1)); then
            continue # the opening fence
        fi
        if [[ "$line" == "---" ]]; then
            break # the closing fence; the body is markdownlint's job
        fi
        # A top-level key resets the scope; continuation lines are indented, so
        # they leave `key` pointing at the field they belong to.
        if [[ "$line" =~ ^[A-Za-z0-9_-]+: ]]; then
            key="${line%%:*}"
        fi
        if [[ "$key" == "description" ]] && ((${#line} > 80)); then
            printf '%s:%d: description line is %d columns\n' "$1" "$number" "${#line}"
        fi
    done < "$1"
}

STATUS=0
OUTPUT=$(markdownlint-cli2 --fix "$FILE" 2>&1) || STATUS=$?

LONG_DESCRIPTION=""
if [[ "$(head -n 1 "$FILE")" == "---" ]]; then
    LONG_DESCRIPTION=$(long_description_lines "$FILE")
fi

if ((STATUS != 0)); then
    {
        echo "markdownlint fixed what it could in $FILE, but these need your judgment:"
        echo
        printf '%s\n' "$OUTPUT" | grep -E '\.md:[0-9]+' || printf '%s\n' "$OUTPUT"
        echo
        echo "MD013/line-length is the usual one. This repo wraps markdown at 80"
        echo "columns; rewrap the offending prose rather than disabling the rule."
    } >&2
fi

if [[ -n "$LONG_DESCRIPTION" ]]; then
    cat >&2 <<EOF
The YAML front matter description in $FILE runs past 80 columns:

$LONG_DESCRIPTION

Wrap it as a folded block scalar. Folding rejoins the lines with single
spaces, so the value the parser sees is unchanged, and \`>-\` needs no
quoting even when the text contains ": ":

  description: >-
    Reviews code for clean-code principles. Examples: after refactoring,
    before committing.

Rewrap the description rather than leaving it on one line.
EOF
fi

if ((STATUS != 0)) || [[ -n "$LONG_DESCRIPTION" ]]; then
    exit 2
fi
