# Agent-Agnostic Configuration

Portable config shared across AI coding agents (Claude Code, Codex, and others).
Anything that doesn't depend on a specific agent lives here, so there is one
source of truth; Claude-only config lives in `files/claude/` (see its `AGENTS.md`).

## Contents

- `RULES.md` — progressive-disclosure index of the global rules: a table of
  contents linking to each rule body with a "when to read it" hook.
- `rules/` — the rule bodies, one self-contained file per rule. Agents that
  eager-load this directory (Claude Code) pay for every word in every session,
  so a long rule that fires rarely keeps only a short trigger stub here.
  `output-style.md` is the one rule that is always in effect rather than read on
  demand, so each agent also loads it through its own always-on channel: Claude
  Code as an output style symlinked into `~/.claude/output-styles/`, Codex as a
  line in its global instructions. It is symlinked rather than wrapped, and
  Claude excludes the eager rule copy so it doesn't hold the text twice — see
  `files/claude/AGENTS.md` for why both of those are necessary.
- `guides/` — full bodies for the stubbed rules above, loaded on demand when
  the stub's trigger fires. `RULES.md` links straight to the guide.
- `skills/` — agent-agnostic skills (one `SKILL.md` directory each), both
  procedural workflows and references an agent loads before a kind of work. A
  skill that depends on a Claude feature lives in `files/claude/skills/` instead.
- `review/` — shared code-review guides. A reviewer subagent under
  `files/claude/agents/` (and its Codex twin under `files/codex/agents/`) wraps
  one of these so the review knowledge has a single home.

### Reviewer model tiering

The reviewer wrappers run on two tiers, and both stacks must agree; when you
change a reviewer's tier in one wrapper set, update its twin.

For Codex wrappers, `model = "gpt-5.5"` stays fixed; the tier is expressed by
`model_reasoning_effort`. Do not treat a medium-effort custom reviewer as a
cheap validator — use cheaper default/explorer/worker agents for narrow
high-volume validation when the harness permits it.

- **Strong tier** — `code-quality`, `clean-code`, `security-code`,
  `comment-discipline`: Claude `model: sonnet`, Codex
  `model_reasoning_effort = "high"`. These domains carry the highest miss cost
  and need cross-file tracing (data flow for security, edge-case logic for
  correctness, repo-wide staleness and git archaeology for comments); the
  validation pass in `my-code-review` filters false positives but can't recover
  findings a weak finder never made.
- **Cheap tier** — `documentation-accuracy`, `test-coverage`, `performance`:
  Claude `model: haiku`, Codex `model_reasoning_effort = "medium"`. These
  findings are mostly local and falsifiable, so the validation pass catches
  the noise a cheaper finder produces.

The strong tier stays at Sonnet deliberately — near-Opus coding quality at a
fraction of the cost, with the validation pass covering the false-positive side.
Revisit on Opus 5 with an effort sweep on real diffs: its review accuracy holds
at low and medium effort, so a low-effort Opus-5 finder is now a candidate to
replace the Sonnet strong tier.

The guides in `review/` tell finders to report generously — flag rather than
excuse, don't withhold a low-severity finding. That is deliberate and pairs with
the validation pass: finders maximize recall, validation filters precision.
Don't "fix" a guide by making its finder conservative; on current models a
be-conservative instruction is followed literally and simply reports less.
Changing a tier touches three places together: this mapping, the Codex effort
values, and the `sonnet`/`haiku` cases hardcoded in
`files/bin/check-agent-parity` — miss one and every install warns.

## How agents consume it

- **Claude Code** loads `rules/` eagerly via `~/.claude/rules/dotfiles` →
  `files/agents/rules`; picks up `skills/` through per-skill symlinks in
  `~/.claude/skills/`; pulls a `review/` guide into a subagent with `@import`;
  and also loads `rules/output-style.md` into the system prompt via
  `~/.claude/output-styles/plain-spoken.md`, pinned by the `outputStyle` key in
  `files/claude/settings.json`.
- **Codex and other agents** reference `RULES.md` by **absolute path** from the
  agent's global-instructions file. This repo deploys
  `files/codex/global-instructions.md` to `~/.codex/AGENTS.md`; it points at
  this rule index, `rules/output-style.md`, and the Codex harness workflow.
  Codex has no output-style mechanism, so it gets the same words with weaker
  placement: an output style is part of Claude Code's system prompt, while
  instructions Codex reads from a file arrive as conversation content. Claude
  Code documents style-adherence reminders during a conversation but not their
  cadence, and they aren't visible in transcripts — don't build on them. Use the
  absolute path; don't symlink or copy `RULES.md`, since it
  links to `rules/` relative to its own location and must be read in place.
  Skills are symlinked into `~/.agents/skills/`; a `review/` guide is read by
  absolute path from the Codex agent's `developer_instructions`.
