#!/bin/bash
#
# count-lines.sh — Print character count for each line of input.
#
# Usage:
#   bash count-lines.sh <<'EOF'
#.  First line
#   Second line
#.  EOF
#
# Output:
#    1: 11  First line.
#    2: 12  Second line.

set -o errexit
set -o nounset
set -o pipefail

input=$(cat)
n=0

while IFS= read -r line; do
  n=$((n + 1))
  printf "%2d: %2d  %s\n" "$n" "${#line}" "$line"
done <<< "$input"
