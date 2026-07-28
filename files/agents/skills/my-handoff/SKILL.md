---
name: my-handoff
description: >-
  Produce a single, self-contained prompt the user can paste into a fresh agent
  session to continue the current work without re-deriving context. Use this
  whenever the user wants to hand off, carry over, or resume work in a new
  session — phrases like "write a handoff prompt", "I'm running low on context",
  "give me something to paste into a new session", "continue this in a fresh
  session", "context is getting full", or "summarize this so a new session can
  pick up". This is for bootstrapping a *new agent session*, not for summarizing
  the conversation for the user themselves and not for commit/PR messages.
---

# Session Handoff Prompt

Produce one paste-ready prompt that bootstraps a fresh agent session so it
can continue the current work. The reader is a brand-new agent instance with
**zero memory of this conversation** — it has never seen the files you've opened,
the decisions you've made, or the things you already tried and rejected.

The job is to transfer exactly the context that the new session can't recover on
its own, and nothing more.

## The core idea: transfer what the repo can't tell them

The new session can read files, run `git`/`jj`, grep, and explore. So don't
restate what's already on disk — point to it. What the new session *cannot*
recover is everything that lived only in this conversation:

- **Why** decisions were made, and which alternatives were already ruled out.
- What was **tried and didn't work** — the dead ends, so it doesn't re-walk them.
- The **in-flight state** — what's half-done, what's uncommitted, what's stubbed.
- The **immediate next move** and how to know it worked.

A good handoff reads like a senior engineer briefing the next person on call:
oriented, specific, and honest about what's done versus what's still loose. Aim
for task-focused, not exhaustive — enough to act, not a transcript.

## Gather ground truth first

Before writing, anchor the prompt in the actual repo state so your pointers are
real, not remembered:

- Check the VCS state. This repo may be `git` or `jj` — follow the version-control
  rule (`~/.dotfiles/files/agents/rules/version-control.md`) to determine which,
  then capture the current branch/change and the
  uncommitted diff (e.g. `jj status` / `jj diff`, or `git status` / `git diff`).
  Uncommitted work is invisible to the next session unless you name it.
- Re-read the key files you'll cite and confirm the line numbers, so
  `path:line` references land where you say they do.

If something in the conversation conflicts with what's on disk now, trust disk
and say so.

## What the prompt contains

Write the prompt as a direct address **to the new session** (second person:
"You're continuing…", "Start by…"), not as a report about it. Include these,
dropping any that genuinely don't apply rather than padding them:

- **Goal** — the objective in a sentence or two. What "done" looks like.
- **Current state** — what's complete, what's in progress, and the uncommitted
  changes by file. Be honest about what's stubbed or known-broken.
- **Key files** — `path:line` pointers with a few words on why each matters.
  Pointers, not pasted contents.
- **Decisions made** — the choices already settled and the *why*, so the new
  session commits to them instead of relitigating. Note alternatives rejected.
- **Gotchas / dead ends** — what was tried that failed, surprising constraints,
  things that look wrong but are intentional.
- **Next step** — the immediate action to take, concretely.
- **How to verify** — the command or check that proves the work is correct
  (test command, build, repro steps).

## Output format

Emit the prompt as a **single fenced code block** and nothing else of substance
around it — the user copies the block verbatim into the new session, so it must
stand alone with no surrounding instructions baked in.

If the prompt's own body needs code fences (for commands or snippets), wrap the
whole thing in a fence with *more* backticks than anything inside it (e.g. four
backticks outside, three inside) so the block doesn't terminate early.

Keep the prose tight and skimmable. Use the headers below as the template:

````markdown
You're picking up work from a previous agent session. Here's the state.

## Goal
[one or two sentences]

## Current state
[what's done; what's in progress; uncommitted changes by file]

## Key files
- `path/to/file.ext:42` — [why it matters]
- `path/to/other.ext:108` — [why it matters]

## Decisions made
- [decision] — because [why]; considered [alternative], rejected because [why]

## Gotchas / dead ends
- [thing tried that failed, or constraint that isn't obvious from the code]

## Next step
[the concrete immediate action]

## How to verify
[command or check that proves it works]
````

## A note on length

Match the prompt to the work. A two-file bug fix needs a short handoff; a
multi-day feature spanning several subsystems needs more. The failure mode to
avoid is a prompt that's long but hollow — restating file contents and
narrating history instead of transferring the decisions and dead ends that
actually save the next session time. When in doubt, cut background and keep the
*why*.
