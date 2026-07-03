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
- `guides/` — full bodies for the stubbed rules above, loaded on demand when
  the stub's trigger fires. `RULES.md` links straight to the guide.
- `skills/` — agent-agnostic workflow skills (one `SKILL.md` directory each). A
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

- **Strong tier** — `code-quality`, `clean-code`, `security-code`: Claude
  `model: sonnet`, Codex `model_reasoning_effort = "high"`. These domains carry
  the highest miss cost and need cross-file tracing (data flow for security,
  edge-case logic for correctness); the validation pass in `my-code-review`
  filters false positives but can't recover findings a weak finder never made.
- **Cheap tier** — `documentation-accuracy`, `test-coverage`, `performance`:
  Claude `model: haiku`, Codex `model_reasoning_effort = "medium"`. These
  findings are mostly local and falsifiable, so the validation pass catches
  the noise a cheaper finder produces.

The strong tier stays at Sonnet deliberately — near-Opus coding quality at a
fraction of the cost, with the validation pass covering the false-positive
side; an Opus-class finder only pays off on very large, cross-cutting diffs.
Changing a tier touches three places together: this mapping, the Codex effort
values, and the `sonnet`/`haiku` cases hardcoded in
`files/bin/check-agent-parity` — miss one and every install warns.

## How agents consume it

- **Claude Code** loads `rules/` eagerly via `~/.claude/rules/dotfiles` →
  `files/agents/rules`; picks up `skills/` through per-skill symlinks in
  `~/.claude/skills/`; and pulls a `review/` guide into a subagent with `@import`.
- **Codex and other agents** reference `RULES.md` by **absolute path** from the
  agent's global-instructions file. This repo deploys
  `files/codex/global-instructions.md` to `~/.codex/AGENTS.md`; it points at
  this rule index and the Codex harness workflow. Use the absolute path; don't
  symlink or copy `RULES.md`, since it links to `rules/` relative to its own
  location and must be read in place. Skills are symlinked into
  `~/.agents/skills/`; a `review/` guide is read by absolute path from the
  Codex agent's
  `developer_instructions`.
