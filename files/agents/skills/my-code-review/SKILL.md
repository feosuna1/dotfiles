---
name: my-code-review
description: Run a multi-agent code review on finished work — dispatch domain reviewers, independently validate their findings, and file only confirmed, high-signal issues as tasks. Accepts `--no-tasks` to return the confirmed findings instead of filing them, for a caller (e.g. an automated fix loop) that acts on them programmatically. Use when a change is complete (tests pass, feature works) and ready to commit or deploy.
---

# Multi-Agent Code Review

Review the diff in stages: pick the reviewers, run them, validate what they
surface, then file only what's confirmed.

This skill accepts an optional `--no-tasks` flag. Without it (the default), Step
5 files confirmed findings as tasks. With it, Step 5 skips task-filing and
instead returns the confirmed findings as a structured list for the caller to
consume — used when another skill (e.g. an automated fix loop) acts on the
findings rather than a human reading tasks.

## Harness notes

Invoking this skill is an explicit request for the multi-agent review workflow
it defines. In Codex, use `tool_search` if the multi-agent tools or custom
reviewer roles are not already visible. Use the custom reviewer roles for the
first-pass domain finders; validator model choice is covered in Step 4.

If the harness forbids subagents unless the user explicitly requested
delegation, and this skill was triggered only implicitly, offer to run the
multi-agent review rather than spawning agents silently.

**Step 1 — Select reviewers.** Run the reviewers whose domain the diff touches;
skip the rest:

- `code-quality-reviewer` — correctness, robustness, and language idioms. Skip
  only if the diff has no runtime code (config- or docs-only).
- `clean-code-reviewer` — naming, function size, duplication, comment
  discipline, and craftsmanship. Always applies — even docs-only diffs, since
  limiting and justifying comments is part of its remit.
- `performance-reviewer` — skip if there's no runtime code (config- or
  docs-only).
- `security-code-reviewer` — skip if there are no inputs, auth flows, or data
  handling.
- `test-coverage-reviewer` — skip only if the diff has no implementation files
  (no source or tests).
- `documentation-accuracy-reviewer` — skip if no docs or public API surface
  changed.

**Step 2 — Run them in parallel.** Give each reviewer the changed files and
context on what was implemented, and have it report only noteworthy findings.

**Step 3 — Collect candidates.** Gather all findings and merge duplicates —
agents often flag the same issue. For each, record the claim, location
(file:line), evidence, severity, confidence, and source agent. Post nothing yet.
(`security-code-reviewer` may add an `Informational` tier and CWE `References`.)
Then classify each:

- **Falsifiable** — a concrete claim you could prove wrong by reading or running
  the code: a bug, a performance characteristic, a doc-vs-code mismatch, a
  missing error path, an uncovered branch.
- **Non-falsifiable** — a subjective judgment with nothing to test: naming
  taste, "consider extracting", "might be nice".

**Step 4 — Validate every falsifiable finding.** Reviewers emit false positives,
and forwarding them unfiltered spends the developer's attention on non-issues —
so each falsifiable candidate must clear an independent check before it can
become a task.

Dispatch one fresh validator per finding, in parallel, none of which produced
the finding. If your environment can't fan out that widely (few parallel
subagents, or a fleet this size risks timing out), batch the dispatch into
smaller sequential waves — but still spawn a fresh validator instance for every
claim; never reuse one validator across findings, since a context polluted by a
previous validation biases the next. If your harness has no subagent primitive
at all, get the same isolation by launching each validator as a separate
one-shot agent run from the shell (e.g. `codex exec` with the matching reviewer
agent), one claim per run. Validating inline in your own context is the last
resort — if forced to it, take the claims one at a time and say in the output
that validation was not independent. Give each only its single claim and
location — not the other findings, so it stays unbiased — and have it:

- Read (and trace or run) the actual code rather than trust the finding's
  wording.
- Try to refute the claim; default to *not confirmed* when the evidence is
  ambiguous, unreproducible, or already handled elsewhere.
- Return **CONFIRMED** (with file:line evidence, and for a bug how it
  manifests), **REFUTED**, or **UNCERTAIN**.

Validate with the matching-domain reviewer where its expertise helps (a fresh
`security-code-reviewer` for a security claim, `performance-reviewer` for a
performance claim); otherwise a fresh general-purpose agent with no special
role. Keep only CONFIRMED findings.

Run validators on your harness's cheapest capable model tier (e.g. `model:
haiku` on the Agent tool, or a cheap Codex default/explorer/worker when custom
reviewer roles are fixed to a frontier model): each validator gets one narrow,
falsifiable claim with a specific location — exactly the local, high-volume work
the cheap tier is built for, and this is the widest fleet the skill dispatches.
Escalate a single validator to a stronger tier only when its claim genuinely
spans files or requires deep tracing. Cheap-tier models also carry a smaller
context window, so give each validator only the claim and the relevant slice of
code, never the whole diff.

Non-falsifiable candidates have nothing to verify — hold them to a high bar
yourself, keeping only the few that are concretely actionable and dropping the
rest. Keep an Informational security note only if it's actionable.

**Step 5 — Output confirmed findings.** How you emit the surviving findings
depends on the flag:

- **Default (no flag):** record one task per surviving finding, grouped by
  severity and area — using your environment's task tool (e.g. `TaskCreate`) if
  it has one, otherwise as a structured list.
- **With `--no-tasks`:** skip task creation entirely. Return the surviving
  findings as a structured list for the caller to consume — do not file any
  tasks.

Either way, include the claim, file:line, the validator's confirming evidence,
and a recommended fix where available. If nothing survived, say so — an empty
list is the right outcome when there are no high-signal issues.
