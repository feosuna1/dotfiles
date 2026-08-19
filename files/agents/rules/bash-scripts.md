# Bash Scripts

How to write shell scripts the user will keep. These are settled points from
code review, not preferences to reopen — the first two came back four separate
times before they were written down.

## Always quote expansions

Quote every expansion, in every position, including the ones where the shell
cannot word-split:

```bash
local var="$(command)"     # not: local var=$(command)
local var="$other"         # not: local var=$other
foo "$var"                 # not: foo $var
[[ "$#" -gt 0 ]]           # not: [[ $# -gt 0 ]]
```

**Why this matters.** A variable assignment does not word-split, so
`local var=$(…)` is genuinely safe — and that is the trap. The rules for where
splitting applies are subtle, an unquoted expansion in argument position
(`foo $var`) behaves differently from the same text in an assignment, and the
resulting bugs are confusing to read. Quoting everywhere removes the need to
work out which context you are in, and a reader never has to check whether an
unquoted expansion was deliberate.

**How to apply.** Write the quotes as you type the expansion. When reviewing a
script, treat a bare `$var` or `$(…)` as a finding even where it is provably
harmless: the point is that the file is consistent, so the eye can stop
checking. `shellcheck` catches the dangerous cases but not the safe-but-
inconsistent ones.

## Accept both `--opt arg` and `--opt=arg`

Match the joined form first, split it on the first `=`, push the pair back onto
the positional arguments, and keep looping:

```bash
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -*=*)
      param="${1%%=*}"
      value="${1##*=}"
      shift
      set -- "$param" "$value" "$@"
      ;;
    -b | --base)
      [[ -n "${2:-}" ]] || exit_usage
      base="$2"
      shift 2
      ;;
    …
  esac
done
```

`set --` replaces the positional arguments in the current shell, so shifting the
joined argument off and then setting the split pair in front of `"$@"` is an
unshift. Every option case below it handles one spelling and supports both.

**Why this matters.** Callers expect both spellings from anything that looks
like a CLI, and writing each option twice to get them is duplication that drifts.
One case at the top covers every option in the script, including options added
later.

**How to apply.** Use `-*=*` rather than the broader `*=*`, so a positional
argument that happens to contain `=` is passed through instead of split. Put the
case first, before any option it feeds.

## `readonly` goes on its own line under `errexit`

```bash
sha="$(resolve_commit "$rev")"
readonly sha
```

Not `readonly sha="$(resolve_commit "$rev")"`.

**Why this matters.** The combined form returns the status of the `readonly`
builtin, which is zero, and not the status of the command substitution. A
failure that `set -o errexit` exists to catch is swallowed, and the script
continues with an empty value. The same applies to `local` and `declare`.

**How to apply.** Assign on one line, mark on the next. The combined form is
fine only when the value is a literal or composes variables already set, since
there is no command status to lose.

## Sources

The first two rules are review feedback from Itai Ferber, 2026-08-06, on a
script the user wrote:
https://ynab.slack.com/archives/D047KRY2VRN/p1786025023804199
