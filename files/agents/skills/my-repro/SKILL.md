---
name: my-repro
description: Reproduce a reported or theorized bug in the running app to confirm it's real before writing a fix. Use this whenever a bug is suspected, reported, or theorized and the next move is to debug or fix it — turn the theory into hand-run repro steps, confirm the symptom shows up, and end with a clear yes/no on whether the theory holds.
---

# Reproduce a Bug

The goal is to turn a bug theory into steps the user can run by hand in the app,
confirm the bug actually shows up, and end with a clear yes/no on whether the
theory holds — so you go into the fix knowing the trigger instead of guessing.

A reproduction is evidence. The point isn't to "make the bug happen" by any
means necessary; it's to learn whether the bug happens for the reason you think
it does. Keep that framing — it shapes how clean the repro needs to be.

## 1. Pin down the theory

A useful repro needs a hypothesis: which code path triggers the bug, what state
produces it, what symptom it causes. Look at the current conversation first —
often the theory is already there. If it isn't clear, ask the user in one short
message what they think is going on, and wait for the answer. A repro built on a
vague theory tests nothing, so don't guess your way past this.

State the theory back in one line before moving on, so the user can correct it
cheaply if you've misread it.

## 2. Write the repro steps

Produce numbered steps the user can follow in the running app without further
interpretation. Tailor them to the theory:

- **Starting state** — the data shape, account, or screen the bug needs. Be
  specific (e.g., "a project with at least one task completed before today"),
  not "some data."
- **Actions in order** — exact taps, inputs, navigation, and timing where timing
  matters.
- **What to watch for** — the precise observable symptom that proves *this*
  theory, not a vague "it breaks." Name what they'll see and where.

Prefer repros that need **no code changes**. A bug that shows up on untouched
code is stronger evidence than one that only appears with scaffolding propping
it up — fewer things you've changed means fewer alternative explanations for
what you observe.

## 3. Run it yourself when the harness can observe the app

If your environment exposes browser, simulator, device, desktop, or app-control
tools that can reach the running app, use them to execute the repro directly.
Record the exact steps, the observable result, and any screenshots/log snippets
that prove the outcome. Do not stop for the user to run steps you can observe
yourself.

If the harness cannot observe the app, continue with the hand-run workflow
below.

## 4. Optional helper code

Some states are hard to reach by hand: a race that needs precise timing, a
feature flag, seeded data, a forced error path. If the theory hinges on one of
these, offer minimal helper code. Ask first — present two options: **Add
helper** / **Skip** — because helper code is a real edit to their tree and they
may prefer to set up the state another way.

If adding:

- Keep it minimal and obviously temporary — the goal is to reach the state, not
  to be elegant.
- Mark every added line with a `// REPRO:` comment so it's trivial to find and
  strip later.
- Keep it in one place when you can.
- Do not commit it.

## 5. Hand off and wait

Only use this step when you cannot observe the app yourself. Give the user, in
one message:

- Whether helper code was added, and which files.
- The numbered repro steps.
- A note that you're waiting for them to run it.

Then stop. They have to run the app; you can't observe the symptom for them.

## 6. Ask the outcome

When they come back, ask them to pick one of three outcomes:

- **Reproduced** — the symptom showed up as the theory predicted.
- **Did not reproduce** — it didn't happen.
- **Inconclusive** — something else happened, or it's unclear.

Don't infer the outcome from a passing comment — ask, because "it crashed" and
"it crashed the way I predicted" are different results and only the second
confirms the theory.

## 7. Clean up and route

First, remove all `// REPRO:` helper code if any was added. That's the only
thing to undo — there's no fix in the tree yet.

Then route on the outcome:

- **Reproduced** → the theory holds and you know the trigger. Say so plainly and
  offer to write the fix next. Note that the same steps now double as the check
  that the fix works: once it's in, run them again and the symptom should be
  gone.
- **Did not reproduce** → either the theory is wrong or the steps missed the
  trigger. Don't quietly move on. Ask the user whether to refine the steps,
  revisit the theory, or set it aside — and say which you'd pick and why.
- **Inconclusive** → ask what they actually saw, then decide the next step with
  them. Don't force it into a yes or no.

## 8. Report

Close with one short block:

```text
**Theory:** <one line>
**Repro:** <reproduced | not reproduced | inconclusive>
**Helpers:** <removed | none>
**Next:** <write the fix | refine repro | revisit theory | set aside>
```
