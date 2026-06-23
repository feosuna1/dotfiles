---
name: my-code-review
description: Run a multi-agent code review on finished work — dispatch domain reviewers, independently validate their findings, and file only confirmed, high-signal issues as tasks. Use when a change is complete (tests pass, feature works) and ready to commit or deploy.
---

Review the diff in stages: pick the reviewers, run them, validate what they surface, then file only what's confirmed.

**Step 1 — Select reviewers.** Run the reviewers whose domain the diff touches; skip the rest:

- `code-quality-reviewer` — correctness, robustness, and language idioms. Skip only if the diff has no runtime code (config- or docs-only).
- `clean-code-reviewer` — naming, function size, duplication, comment discipline, and craftsmanship. Always applies — even docs-only diffs, since limiting and justifying comments is part of its remit.
- `performance-reviewer` — skip if there's no runtime code (config- or docs-only).
- `security-code-reviewer` — skip if there are no inputs, auth flows, or data handling.
- `test-coverage-reviewer` — skip only if the diff has no implementation files (no source or tests).
- `documentation-accuracy-reviewer` — skip if no docs or public API surface changed.

**Step 2 — Run them in parallel.** Give each reviewer the changed files and context on what was implemented, and have it report only noteworthy findings.

**Step 3 — Collect candidates.** Gather all findings and merge duplicates — agents often flag the same issue. For each, record the claim, location (file:line), severity, and source agent. Post nothing yet. (`security-code-reviewer` may add an `Informational` tier and CWE `References`.) Then classify each:

- **Falsifiable** — a concrete claim you could prove wrong by reading or running the code: a bug, a performance characteristic, a doc-vs-code mismatch, a missing error path, an uncovered branch.
- **Non-falsifiable** — a subjective judgment with nothing to test: naming taste, "consider extracting", "might be nice".

**Step 4 — Validate every falsifiable finding.** Reviewers emit false positives, and forwarding them unfiltered spends the developer's attention on non-issues — so each falsifiable candidate must clear an independent check before it can become a task.

Dispatch one fresh validator per finding, in parallel, none of which produced the finding. Give each only its single claim and location — not the other findings, so it stays unbiased — and have it:

- Read (and trace or run) the actual code rather than trust the finding's wording.
- Try to refute the claim; default to *not confirmed* when the evidence is ambiguous, unreproducible, or already handled elsewhere.
- Return **CONFIRMED** (with file:line evidence, and for a bug how it manifests), **REFUTED**, or **UNCERTAIN**.

Validate with the matching-domain reviewer where its expertise helps (a fresh `security-code-reviewer` for a security claim, `performance-reviewer` for a performance claim); otherwise a general-purpose agent. Keep only CONFIRMED findings.

Non-falsifiable candidates have nothing to verify — hold them to a high bar yourself, keeping only the few that are concretely actionable and dropping the rest. Keep an Informational security note only if it's actionable.

**Step 5 — File confirmed findings.** With TaskCreate, create one task per surviving finding, grouped by severity and area. Include the claim, file:line, the validator's confirming evidence, and a recommended fix where available. If nothing survived, say so — an empty list is the right outcome when there are no high-signal issues.
