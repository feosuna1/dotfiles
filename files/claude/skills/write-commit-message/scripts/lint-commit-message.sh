#!/bin/bash
#
# lint-commit-message.sh — Lint commit message subject and structure.
# Reads a commit message from stdin and checks formatting rules.
#
# Usage:
#   bash lint-commit-message.sh --allow-co-authored-by <<'EOF'
#   Fix the bug
#
#   Body
#   EOF
#
# Exit codes:
#   0 — All checks passed
#   1 — One or more violations found

set -o errexit
set -o nounset
set -o pipefail

errors=()

error() {
  errors+=("$1")
}

# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

parse_args() {
  allow_co_authored_by=false
  for arg in "$@"; do
    case "$arg" in
      --allow-co-authored-by) allow_co_authored_by=true ;;
      *)
        echo "Unknown option: $arg" >&2
        exit 2
        ;;
    esac
  done
}

read_message() {
  local message
  message=$(cat)
  if [[ -z "$message" ]]; then
    echo "error: empty commit message" >&2
    exit 1
  fi

  lines=()
  while IFS= read -r line; do
    lines+=("$line")
  done <<< "$message"
}

# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

check_subject_not_empty() {
  if [[ -z "${lines[0]}" ]]; then
    error "subject: empty"
  fi
}

check_subject_length() {
  local len=${#lines[0]}
  if (( len > 50 )); then
    error "subject: ${len} chars (max 50)"
  fi
}

check_subject_capitalized() {
  local first="${lines[0]:0:1}"
  if [[ "$first" =~ [a-z] ]]; then
    error "subject: starts with lowercase '${first}'"
  fi
}

check_subject_no_period() {
  if [[ "${lines[0]}" == *. ]]; then
    error "subject: ends with a period"
  fi
}

check_blank_line_after_subject() {
  if (( ${#lines[@]} > 1 )) && [[ -n "${lines[1]}" ]]; then
    error "subject/body: missing blank line after subject"
  fi
}

check_no_escaped_backticks() {
  for (( i = 0; i < ${#lines[@]}; i++ )); do
    if [[ "${lines[$i]}" == *'\`'* ]]; then
      error "line $((i + 1)): contains escaped backtick (\\\`)"
    fi
  done
}

check_co_authored_by() {
  if [[ "$allow_co_authored_by" == true ]]; then
    return
  fi
  for (( i = 0; i < ${#lines[@]}; i++ )); do
    if [[ "${lines[$i]}" =~ ^[Cc]o-[Aa]uthored-[Bb]y: ]]; then
      error "line $((i + 1)): Co-Authored-By present without --allow-co-authored-by"
    fi
  done
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

parse_args "$@"
read_message

check_subject_not_empty
check_subject_length
check_subject_capitalized
check_subject_no_period
check_blank_line_after_subject
check_no_escaped_backticks
check_co_authored_by

if (( ${#errors[@]} > 0 )); then
  for err in "${errors[@]}"; do
    echo "error: ${err}" >&2
  done
  exit 1
fi
