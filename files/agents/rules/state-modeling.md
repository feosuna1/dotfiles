---
paths:
  - "**/*.swift"
  - "**/*.kt"
  - "**/*.ts"
  - "**/*.tsx"
---

# State Modeling & Architecture

How to shape state, models, and module boundaries. Earned across real feature
builds — each rule is a preference corrected before, so the *why* matters more
than the letter. Apply while writing, not just at review, so code lands in the
preferred shape the first time.

The rules are language-agnostic; the examples lean Swift. Where a rule names a
language primitive it gives the neutral form first — translate the example to
the language in hand.

## State

**Make impossible states unrepresentable.** Parallel booleans and independent
fields let contradictions exist — `isCommitting`, `commitFailed`, and
`isComplete` can encode "committing while complete." Collapse them into one
state value — a sum type (Swift enum, Kotlin sealed class, TypeScript
discriminated union) — where each case carries exactly the data that state
needs. Prefer `editing(EditModel)` over a `step` field plus a separate nullable
`editModel` — attaching the data to the case guarantees it is present and the
defensive nil-check disappears. Two alerts can never be active at once when
there is one alert sum type, not two nullable fields.

**One state machine per flow; layer sub-machines, don't merge them.** A
top-level machine drives the flow; a self-contained sub-flow (a row's detail
sheet, its own synchronous edits and error alerts) lives in a *smaller* machine
below it, not folded into the top-level cases. Layering keeps each machine small
and independently testable instead of a god-model whose cases multiply.

**Question every piece of separate state.** Before adding a flag or a type, ask
what it buys over what you already have. A `didRequestSnapshot` latch folds into
a `.starting` case. A parallel `Row` type that is structurally identical to
`Item.ID` gets deleted and things key off the id directly. If two types are the
same shape, or a flag duplicates what the current state already tells you,
collapse them. Don't specify the same value in two places either.

## Impossible transitions

**Crash loudly on the impossible; assert preconditions on transitions.** Once
the type system removes contradictions, trap the residue instead of handling it.
This is selective: benign races (a double-tap, a fetch already in flight) return
gracefully; genuinely-impossible transitions get a hard failure with a reason,
via the language's loud-abort primitive (Swift `fatalError`/`precondition`,
Kotlin `error()`/`require()`). A state-mutating method should assert its
expected current state before it transitions, so an unexpected caller trips in
debug rather than silently corrupting the flow. Loads and network paths fail
gracefully; internal "this can't happen" paths fail hard.

## Model / view separation

**The model owns decisions; the view only applies effects — and never reads the
model's internals.** The view should not inspect raw state to decide what to do
— codify the decision in the model and expose it by its *effect*: the view binds
to a single `isDisabled` flag rather than branching on `model.step`. Name
derived state by what it drives, not why: `isDisabled`, because the UI doesn't
care *why* it's disabled — the model does. Go further: keep the internal state
type `private`, don't let the view pattern-match it, and have tests assert the
observable projected flags, not the private state type.

**The model is free of framework, persistence, and navigation concerns.** The
model flips a flag (`isComplete`); the owning screen observes it and performs
the dismissal, presentation, haptics, and animation. A modal shouldn't dismiss
itself — that's its owner's job. Keep UI-toolkit types, storage, and navigation
out of the model so it stays pure and testable.

**Scope observation so the sub-view with its own churn owns its own model — but
don't let it reference its owner.** A frequently-changing sub-view (a detail
sheet) gets its own observable model, so mutating it doesn't invalidate the
whole parent tree. Errors belong in the mutation's own result — an `assign` that
throws or returns failure — not in a shared error field the whole tree observes.
Hand the sub-view a value snapshot plus an apply callback rather than a
reference back to the parent — a back-reference couples the child to its owner,
and under reference counting it also cycles.

## Module boundaries

**A UI module sits behind a closure seam; persistence lives outside it.** The
module takes injected data and emits a draft through an injected dependencies
value — a value type holding function references, safe to hand across
concurrency boundaries (in Swift, a `Sendable` struct of closures). Atomicity,
background-task assertions, sync suspension, and the actual write are the
*implementation of the seam*, not the module's concern, and don't belong in its
docs — a single method exposed to the module implies them.

**A module owns its own types; don't leak interface conformance onto domain
types.** Don't push UI-only protocol or interface implementations (in Swift,
`Hashable`/`Identifiable`) onto shared domain types to satisfy a view. Carry a
small `ID` type built from the already-conforming id, and compute display
strings as stored properties where the source object is in hand. That
implementation lives next to the one type that needs it, not on the domain model
everyone shares.

**Locate logic with its owner; fix by relocating, not by guarding.** When a side
effect fires from the wrong place, move it to its rightful owner rather than
adding a defensive guard where it misbehaves. Sync-pause logic belongs in the
screen that owns the flow, not the tab that opens it; a load task that can fire
during `.starting` moves to the feature-level lifecycle hook, not papered over
by disabling the button. Build a view's projection once at init, not lazily in a
getter; define per-state toolbars in the view that owns them, not conditionally
from outside.

## Restraint

**Drive every abstraction to the minimum that reads honestly.** The throughline.
Reject the first instinct to add structure; add only what the code demonstrably
needs. Cut what buys nothing: a wrapped success-or-failure return type when a
boolean suffices, a stored task handle you never reference, a UI-only field
persisted in the saved model, a catch-all path the spec never called for. The
spec is the source of truth — drop anything not in it, even mid-implementation.
When a fuller abstraction is tempting, present the tradeoff and recommend; don't
gold-plate by building it uninvited.

## Capture the design

**Capture a state machine as a durable artifact next to the code.** When a flow
has real states and transitions, write them down where they can't drift: a
diagram (Mermaid `stateDiagram-v2`) plus a From / Event / Guard / To / Effect
transition table in the module README, with a one-line doc comment on each state
case as the anti-drift guard. A transition table is a better hand-off format
than prose for a state machine — author the machine *as* a table, then normalize
it into the sum type.
