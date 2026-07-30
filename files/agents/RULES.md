# Rules Index

Standing rules for any AI coding agent working in the user's environment. This
file is a table of contents — not the rules themselves. Each entry links to a
self-contained rule file under `rules/`, with a hook describing *when* to read
it. Open a rule file when its situation applies (progressive disclosure); you
don't need to load every rule up front.

## How you work

- [Solving problems](rules/solving-problems.md) — read before starting any
  non-trivial task: clarify requirements first, address root causes, surface
  tradeoffs for the user to decide, verify everything against the code.
- [Rules of engagement](rules/rules-of-engagement.md) — read when managing task
  lists, delegating to subagents, or about to commit/push: task lists are
  interactive, don't commit unless asked, no timeline estimates.
- [Minimal edits](rules/minimal-edits.md) — read before editing existing code:
  change only what was asked, don't restructure or reformat working code you
  weren't told to touch.
- [Testing discipline](rules/testing-discipline.md) — read before fixing a bug:
  write a failing test that reproduces it first, then fix (red-then-green); give
  competing inputs distinct values.

## How you communicate

- [Output style](rules/output-style.md) — how to talk to the user in-session:
  lead with conclusions, no pleasantries, plain words, challenge reasoning as a
  peer.
- [Human voice](guides/human-voice.md) — read when writing prose *as the user*:
  email, Slack, commit messages, feedback to others. Direct, humble, no filler.
  (The body lives in `guides/` so eager-loading agents pick up only the stub at
  `rules/human-voice.md`.)

## How you write code

- [Writing code](rules/writing-code.md) — read while writing any code: the
  checkable subset of clean-code standards — names, function size, structure,
  comments, correctness.
- [State modeling & architecture](rules/state-modeling.md) — *(path-scoped to
  Swift, Kotlin, and TypeScript sources)* read when shaping state, models, or
  module boundaries: make impossible states unrepresentable, keep the model free
  of framework/navigation concerns, drive abstractions to the honest minimum.
- [Swift conventions](rules/swift-conventions.md) — *(path-scoped to
  `**/*.swift`)* read when writing or reviewing Swift, SwiftUI, or UIKit:
  idiomatic preferences corrected before, plus Swift-specific testing
  conventions.

## Tools and version control

- [Version control](rules/version-control.md) — read before any VCS operation:
  detect Git vs Jujutsu (jj) first, then follow the matching workflow.
- [Xcode build & test tooling](rules/xcode-build-tools.md) — *(path-scoped to
  Swift sources and Xcode project/config files)* read before building or running
  tests in an Apple project: prefer the Xcode MCP tools over `xcodebuild`.

## Time

- [Calendars and dates](guides/calendars.md) — read before any date/time or
  calendar work: verify the current date from the system, compute date math in a
  script, confirm the timezone. (The body lives in `guides/` so eager-loading
  agents pick up only the stub at `rules/calendars.md`.)
