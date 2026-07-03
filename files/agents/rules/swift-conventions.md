---
paths:
  - "**/*.swift"
---

# Swift Conventions

Standing conventions for Swift work across all iOS projects. Apply them while writing — not just at review — so code lands in the preferred shape the first time. Each is a real preference corrected before; the rationale matters more than the rule, so understand the *why* and apply it to cases these examples don't literally cover.

## Idiomatic Swift

**Prefer key path expressions over trivial closures in higher-order functions.** When a closure only reads a property or returns its argument, a key path literal is more concise and idiomatic (SE-0249) and drops the redundant `$0`.

```swift
map { $0 }            → map(\.self)
map { $0.name }       → map(\.name)
filter { $0.isReady } → filter(\.isReady)
compactMap { $0 }     → compactMap(\.self)
```

**Prefer trailing-closure syntax everywhere.** Trail a single final closure; for two or more, use multiple-trailing-closure syntax (first closure trailing and unlabeled, the rest trailing and labeled). All-trailing never trips SwiftLint's `multiple_closures_with_trailing_closure` — that rule flags only the hybrid of a parenthesized closure plus a trailing one, which all-trailing avoids.

The one exception: don't trail when the call sits inside a compound expression where the closing brace is ambiguous with the surrounding statement — most often a control-flow condition. `if collection.filter { $0.isActive }.isEmpty { … }` won't parse, because the trailing closure's braces collide with the `if` body. Parenthesize the closure argument there instead.

```swift
// Trail by default — single closure:
AverageSpentButton(amount: 120_000) { … }

// Two or more — all trailing:
UIView.animate(withDuration: 1) { … } completion: { _ in … }

// Exception — control-flow condition: parenthesize, don't trail:
if collection.filter({ $0.isActive }).isEmpty { … }   // not: if collection.filter { $0.isActive }.isEmpty {
```

**Increment change-trigger counters with the wrapping operator `&+=`.** A counter used purely to *signal* that something happened (a `.sensoryFeedback(_:trigger:)` value, a "bump this to refire" `Int`) only needs to change; its value is meaningless. `&+=` avoids a theoretical overflow trap on a monotonically increasing trigger. Regular `+=` still applies to counters whose numeric value matters.

```swift
feedbackTrigger &+= 1   // signal only
itemCount += 1          // value matters — keep +=
```

**Don't define a local `extendLifetime` helper — Swift 6 ships one.** A local wrapper around `withExtendedLifetime(_:_:)` clutters the file and implies the stdlib function doesn't exist. Call `extendLifetime(value)` directly.

**Prefer opaque parameter types over explicit generics.** When a generic parameter appears in only one position, the lightweight `some Protocol` form reads better than naming a type parameter (SE-0341). Reach for the explicit `<T>` form only when you need to refer to the type by name — across multiple parameters, in the return type, or in a `where` clause.

```swift
func test(value: some Protocol) { … }       // preferred
func test<T: Protocol>(value: T) { … }       // only when T must be named
```

**Every `nonisolated(unsafe)` needs a comment explaining why it's safe.** It bypasses Swift's concurrency checking, which can mask real data races. Future readers and reviewers need the invariant that makes it race-free so they don't break it. State the specific reason, not a generic "this is fine."

```swift
// Safe: only ever read/written on the main thread.
nonisolated(unsafe) var cachedLayout: Layout?
```

## SwiftUI

**Flag a `Spacer` inside a `VStack`/`HStack` unless the stack's `spacing` is explicitly `0`.** `spacing` is non-zero by default — leaving it unspecified gives you the platform default (8 points on iOS), not zero. The stack applies that spacing on *both* sides of the spacer, so when the spacer collapses toward its `minLength` you get `spacing + minLength + spacing` — a doubled, content-dependent gap nobody notices until long content compresses the spacer. Set `spacing: 0` explicitly and carry the intended gap on the spacer's `minLength`. This applies to the implicit default too, not just an explicitly set non-zero value.

```swift
HStack(spacing: 0) {
    Text(title)
    Spacer(minLength: 8)
    Text(value)
}
```

When you spot this combination in existing code, surface it and ask before changing layout — the right gap is a design decision.

## Concurrency

**Don't reach for cancellation the work can't honor.** Cooperative cancellation (`Task.checkCancellation`, `.task(id:)` teardown) protects nothing when the operation isn't cancellation-aware and must run to completion for correctness — e.g. a commit that would leave data inconsistent if abandoned partway. For work that must finish, a detached `Task {}` is the honest fit; don't wrap it in structured-concurrency machinery whose only feature — cancellation — is meaningless here.

## UIKit

**`UITabBarController.shouldAutomaticallyForwardAppearanceMethods` defaults to `false`, not `true`.** Container controllers (`UITabBarController`, `UINavigationController`) disable auto-forwarding because they manage tab/stack visibility themselves — only plain `UIViewController` defaults to `true`. So a `if !shouldAutomaticallyForwardAppearanceMethods { … }` block that manually forwards `viewWillAppear`/`viewDidAppear`/etc. to a non-tab child VC is **load-bearing, not dead code**. Before calling such guards dead, verify both: whether the property is overridden (`grep -n shouldAutomaticallyForwardAppearanceMethods`), and the actual default for the parent class.

## DocC Comments

DocC comments have two parts: the **abstract** (everything up to the first blank `///`) and an optional **discussion** (after it). Getting the split right changes what Xcode's Quick Help and autocomplete surface.

**Separate the abstract from the discussion with a blank `///` line.** Without it, the whole block becomes the abstract and the IDE shows a wall of text where a tight one-liner belongs. Any DocC comment with more than one sentence needs the blank `///` after the first.

**Keep the abstract short, and add a discussion only when it says something non-obvious.** The abstract is a short noun phrase or sentence — don't cram an enumeration of the type's parts into it (let per-property docs carry that) and don't restate what the type's name or location already says. Add a discussion paragraph only for the non-obvious *why*. Write flowing prose, not clipped "fragment: restated idea" constructions — short does not mean clipped.

```swift
/// The loaded starting point for a reset.
///
/// Groups and total are fetched together, so they travel as one value.
```

**Use single backticks for code references in DocC, not double.** Write `` `SomeType` ``, not `` ``SomeType`` ``.

## Testing

These extend the language-agnostic testing-discipline rule for Swift work.

**Prefer native types; a one-off type built for a single test is a smell.** Reach for the standard library before rolling your own, especially for gating concurrent work — if you think you need an actor, consider a `Mutex`; if a mutex, consider an `Atomic`. Needing a bespoke object to support one test is a signal the design or the test is off. And don't add production API that exists only for tests: a test-only projection of a model belongs in a `private extension` in the test file via `@testable import`, not in shipping code.

**Prefer determinism over fragile timing.** A test that leans on a `sleep` delay to let state settle is fragile — one main-actor hop is often not enough and the delay is a magic number. Rewrite it to observe the actual signal (`withObservationTracking` + a timeout, an awaited async method) so it passes for the right reason. Make flow methods `async` rather than fire-and-forget `Task {}` so tests can await them deterministically.

**Don't contort the framework to unit-test it, and don't chase unreachable branches.** If a view is genuinely hard to unit-test (most SwiftUI rendering is), don't extract logic solely to make it testable — that trades a real design for test convenience. And don't write subprocess exit-tests to "cover" a `fatalError` guard; verifying that a fatal path is fatal is low-value coverage.

## Build & Test Tooling

**Prefer Xcode MCP tools over the `xcodebuild` CLI** for building and running tests (`BuildProject`, `RunAllTests`, `RunSomeTests`, etc.). They integrate with the user's workflow better. Fall back to `xcodebuild` only when the Xcode MCP server is unavailable.
