---
name: my-write-commit-message
description: >-
  Write clear, durable commit messages for any version control system (Git,
  Jujutsu/jj, etc.). Use this skill whenever the user is committing work, asks
  you to write or draft a commit message, asks for help describing a change for
  the log, or has staged changes that need a message. Trigger on phrases like
  "write a commit message", "commit this", "what should the commit say",
  "describe this change", or when finishing a unit of work that will be
  committed. Commit messages are permanent documentation that feed PR
  descriptions, release notes, and changelogs, so they deserve care even for
  small changes.
---

# Commit Messages

A commit message is permanent documentation. A good log explains *why* a change
was made and *what is materially different afterward* — without anyone needing
to read the diff. These messages also get reused to build PR descriptions,
release notes, and changelogs, so the quality compounds.

This skill is version-control agnostic. Everything here applies equally to Git,
Jujutsu (jj), and any other VCS. Do not assume Git-specific tooling or wording.

## Core principle: why and what changed, never how

The diff already records the mechanics — which lines, files, and functions
changed. The message must not repeat that. Instead it answers two questions:

1. **Why was this needed?** Lead with the problem or motivation.
2. **Why should the reader care?** Close the loop: what is concretely different
   for callers, users, or the system now that the change is applied.

If you find yourself describing *what code changed* or *how it was implemented*,
stop and rewrite to describe the outcome instead.

## Structure

A commit message has up to three parts, each separated by a **single blank line**:

```text
Subject, up to 50 chars, imperative mood

Body explaining why the change was needed and what is materially
different now.  Lines are wrapped at 72 chars by `format.py`, except
URLs and unbreakable identifiers.

Fixes: https://tracker.example.com/TASK-123
```

The body and fixes are optional. The subject is always required.

## Subject

- **Hard limit: 50 characters.** This is not a guideline. If your draft exceeds
  50, trim it: drop qualifiers, adverbs, prepositions, and descriptive phrases
  one at a time until it fits. Keep only the action + outcome; push everything
  else into the body.
- **Capitalize the first word. Never end with a period.**
- **Imperative mood.** The subject must complete the sentence *"If applied, this
  commit will…"*. So write "Fix race condition in cache", not "Fixed…" or
  "Fixes…" or "Fixing…".

### Trimming to fit 50 characters

Start from the natural phrasing, then cut toward action + outcome:

- "Add a new validation step to the signup form to prevent bad emails" (66) →
- "Add email validation to signup form" (35) ✓

Move the dropped detail ("to prevent bad emails") into the body if it matters.

## Body

The body is optional. **If the subject alone conveys the change, omit the body
entirely.** Don't pad a trivial change with prose.

When you do write one:

- **Write prose, not wrapped lines.** Don't insert your own line breaks to hit
  72 columns — `format.py` wraps each paragraph for you and keeps URLs and
  `code identifiers` whole. Just write each paragraph as continuous text and
  separate paragraphs with a blank line.
- **Lists are fine when they fit.** Bullet (`-`, `*`, `+`) and numbered (`1.` or
  `1)`) lists are wrapped with a hanging indent, so use one when the change is
  genuinely a set of points. But a list of unrelated items is often a sign the
  commit bundles concerns — prefer prose, and split the commit if so.
- **Lead with the problem or motivation**, then close the loop by stating what's
  concretely different now for callers, users, or the system. The reader should
  finish understanding both *why this was needed* and *why they should care*.
- **Be concise.** Use as few sentences as possible. Cut filler words and
  throat-clearing phrases ("This commit…", "Basically…", "In order to…").
- **Never include file names, the technical approach, or internal mechanics.**
  Those live in the diff.

## Fixes

Task/issue URLs the commit closes. Pass one `-f <url>` per URL; `format.py`
renders them as a trailing block, one `Fixes:` line each, never wrapped. You
write the URLs, not the formatting. Each URL must begin with `http://` or
`https://` and contain no whitespace.

```text
Fixes: https://tracker.example.com/TASK-123
Fixes: https://tracker.example.com/TASK-456
```

## Always-on rules

- **No implementation details.** Keep algorithms, library names, data
  structures, and code mechanics out of the subject and body. Name the outcome.
  *Only* exception: include such a detail when it is materially necessary for the
  reader to understand *why* the change was made.
- **Backtick code identifiers.** Wrap any code identifier — class name, method
  name, protocol, type constraint, config key, CLI flag — in backticks, in both
  the subject and body. E.g., "Rename `getUser` to `fetchUser`" or "Honor the
  `--no-cache` flag". Backticks must be **balanced** — every opening backtick
  needs a closing one. An unclosed span in the subject or body makes `format.py`
  reject the message.

## One concern per commit

Each commit must be a single, cohesive change. If the staged work covers more
than one concern, **do not write one message that bundles them.** Instead, tell
the user the work should be split into separate commits, and briefly name the
distinct concerns you see so they can split cleanly. A message that needs "and"
to join unrelated changes is a signal the commit should be split.

## `format.py` — let the script assemble the message

Counting characters, wrapping at 72, and placing blank-line separators are
deterministic chores that models do badly by hand. Do not do any of them
yourself. `scripts/format.py` owns all of it: you supply the semantic pieces
and it produces a correctly formatted, validated message — or fails loudly if
the subject is wrong. Malformed structure is impossible to emit.

The entire **draft is fed on stdin via a quoted heredoc** — the first line is
the subject, then a blank line, then the body. The quoted `<<'EOF'` delimiter
means the shell touches nothing inside it, so apostrophes and `backtick
identifiers` survive verbatim **in the subject and the body alike**. This is the
whole reason nothing is passed as a text argument: a subject like
``Reject empty `apiKey` config`` would otherwise trigger shell command
substitution on the backticks.

- **First line of stdin** — the subject. The script rejects it (non-zero exit,
  nothing on stdout) if it exceeds 50 characters, ends with a period, starts
  with a lowercase word, or has unbalanced backticks (odd number of `).
- **The rest of stdin** (optional) — the body, blank lines between paragraphs.
  Each paragraph wraps to 72 columns; bullet/numbered lists wrap with a hanging
  indent; URLs and `backtick identifiers` are kept whole. A paragraph with an
  unbalanced (unclosed) backtick span is rejected.
- **`-f <url>`** (repeatable, optional) — one issue/task URL per flag; rendered
  as a `Fixes:` trailer block. URLs are safe as arguments; nothing else is.

Resolve the skill directory from the harness when it provides one. Fall back to
the dotfiles source path so the workflow also works from Codex or a plain shell:

```bash
skill_dir="${CODEX_SKILL_DIR:-${CLAUDE_SKILL_DIR:-$HOME/.dotfiles/files/agents/skills/my-write-commit-message}}"
"$skill_dir/scripts/format.py" -f https://tracker.example.com/SEC-204 <<'EOF'
Reject empty `apiKey` config

A blank `apiKey` silently disabled authentication instead of failing,
leaving deployments unexpectedly open.
EOF
```

A shell pipeline runs the downstream command even when the upstream one fails,
so a validation failure piped straight into a commit would blank the
description. **Gate on the exit code:** capture the output, confirm success,
then apply it.

```bash
skill_dir="${CODEX_SKILL_DIR:-${CLAUDE_SKILL_DIR:-$HOME/.dotfiles/files/agents/skills/my-write-commit-message}}"
msg=$("$skill_dir/scripts/format.py" <<'EOF'
Add rate limiting

Body paragraph one.
EOF
) && printf '%s' "$msg" | jj describe --stdin   # or: git commit -F -
```

`format.py` validates *composition* — subject limits and message shape. It
cannot judge whether the body explains *why* well or hides implementation
detail. That judgment stays with you.

## Workflow

1. Identify the single concern. If there's more than one, advise splitting
   before drafting anything.
2. Draft the subject in imperative mood, and keep it short on purpose — aim well
   under 50, trimming qualifiers and pushing detail into the body as you write.
   `format.py` is the backstop, not the strategy; don't lob a long subject and
   lean on the rejection.
3. Decide whether a body is warranted. If the subject says it all, skip it.
4. If writing a body, lead with the why, then the material difference. Backtick
   code identifiers. Separate paragraphs with blank lines and let `format.py`
   wrap them.
5. Add a `-f <url>` for each task the commit closes.
6. Run `format.py` to produce the message. If it exits non-zero, read the error,
   fix the subject or body it names, and rerun until it passes.
7. Present only the passing message. If the user asked you to apply it (not just
   draft it), gate on the exit code and pipe to the VCS as shown above.

## Examples and sources

Worked examples — subject-only, why + material difference, backtick
identifiers, subject trimming — live in
[references/examples.md](references/examples.md); read them when a draft
feels off-pattern. The rules above distill
[the seven rules of commit messages](references/seven-rules-of-commit-messages.md)
and [Tim Pope's message format](references/tim-pope-commit-message-format.md) —
consult those for the full rationale behind the subject and body conventions.
