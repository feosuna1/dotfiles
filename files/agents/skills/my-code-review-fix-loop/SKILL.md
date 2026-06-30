---
name: my-code-review-fix-loop
description: Drive a converging review-fix loop on a finished change — repeatedly run the adversarial code review, apply fixes for confirmed high-signal findings, and re-review the result until the change goes quiet. Use when you want to grind a diff down to no remaining issues without hand-driving each round. Mutates the working copy; never commits.
---

This skill automates the loop you would otherwise run by hand: review, fix the confirmed findings, review again, and repeat until nothing new surfaces. It uses [`my-code-review`](../my-code-review/SKILL.md) as the find-and-validate engine and adds the fix-and-repeat control loop on top.

It **mutates code in the working copy.** It never commits, pushes, or files tasks. When it finishes you inspect the accumulated changes yourself (`jj diff` / `git diff`) and keep, amend, or discard them.

**Preconditions.** Run only on a change whose work is complete (tests pass, feature works) — the same bar as `my-code-review`. The loop's own edits must be separable from your work, so start from a committed or otherwise inspectable state. If the working copy already has uncommitted changes you want to keep distinct from the loop's fixes, commit them first.

## The loop

Each iteration:

1. **Review.** Run `my-code-review --no-tasks` on the current working diff **in a fresh agent every iteration** — a new subagent that carries no memory of prior rounds. It selects reviewers, runs them, and validates every falsifiable finding with independent refuters, then returns the **CONFIRMED** findings as a structured list — no tasks filed.

   The fresh agent is load-bearing, not an optimization. A review that remembers the previous round's findings anchors to what it already flagged and goes blind to what the last round's fixes changed — it re-confirms its old list instead of attacking the current diff cold. Pass only the current diff and the implementation context into each new agent; never carry forward the prior round's findings, reasoning, or conversation.

2. **Decide.** Split the confirmed findings into two sets:
   - **Auto-fix:** correctness, robustness, and security findings, and any falsifiable bug regardless of source reviewer. These get fixed this round.
   - **Report-only:** style, naming, "consider extracting", and other non-falsifiable or low-severity findings. These are *never* auto-fixed — auto-fixing taste findings spawns more taste findings and the loop never converges. They accumulate in the final report instead.

3. **Stop check.** If the auto-fix set is empty, this is a **dry round**. Stop after **1 dry round**, or after **5 iterations**, whichever comes first. Otherwise continue.

4. **Fix.** Apply a fix for each auto-fix finding. The agent applying fixes must not be one that produced or validated the finding — keep the fixer independent, same reason the validator is independent. For a bug, follow the testing-discipline rule where practical: add or adjust a test that fails against the current code first, then apply the fix so the test goes green. Make the smallest edit that resolves the finding; don't refactor beyond it.

5. **Verify.** Run the project's tests/build. If a fix broke something, fix or revert *that* change before looping — don't carry a regression into the next round. A fix that can't be made to pass is reverted and recorded as report-only with a note.

6. **Repeat.** Go to step 1. The next review runs on the now-modified diff, so it covers the code the fixer just wrote — a bad fix gets caught next round.

## Stop conditions

The loop ends on the first of:

- **One dry round** — a full review produced no auto-fixable confirmed findings.
- **Five iterations** — a hard cap so a thrashing or slowly-diverging loop can't run unbounded.
- **Unrecoverable verification failure** — tests can't be brought green and the offending fix has been reverted.

If you hit the iteration cap with auto-fixable findings still outstanding, say so explicitly — that means the change didn't converge, not that it's clean.

## Final report

When the loop stops, report:

- **Stopped because:** dry round / iteration cap / verification failure.
- **Iterations run** and a one-line summary of each round's fixes.
- **Fixes applied** — claim, file:line, and what changed, for every finding fixed.
- **Reverted** — any fix backed out, with why.
- **Report-only findings still open** — the non-auto-fixed set, so you can decide whether to address them by hand or file them with a plain `my-code-review` run.

End by reminding the user the changes are uncommitted in the working copy for them to review.
