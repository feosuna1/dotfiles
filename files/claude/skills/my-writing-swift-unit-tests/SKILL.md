---
name: my-writing-swift-unit-tests
description: Use when adding or modifying Swift unit test files. DO NOT use for UI tests or snapshot tests.
---

# Writing Swift Unit Tests

## Purpose

Write production-quality Swift unit tests with clear intent, deterministic behavior, and minimal implementation coupling.

## Framework Selection

Use this decision order:

1. **Use Swift Testing (`import Testing`) for new unit tests.**
2. Use **XCTest** only when extending an existing XCTest-based unit test file.

When using XCTest by exception, document why in a short comment.

## Swift Testing Conventions (Required)

- Do **not** add redundant `@Suite` annotations.
- Use **literal test names** with backticked function names, not `@Test("...")` display names.
    - Example: `@Test func ``triggers a view update on reload``()`
- Do **not** use `XCTAssert*` APIs in Swift Testing tests.
    - Use `#expect(...)` and `#require(...)` instead.

## Test Quality Bar

- Test observable behavior, not private implementation details.
- Keep tests deterministic: no network, no clock/race dependence, no randomness without control.
- Minimize mocking; prefer lightweight fakes/stubs at boundaries.
- One behavioral assertion per test intent (multiple related expectations are fine).
- Cover happy path, edge case(s), and failure path when relevant.

## Async and Concurrency

- Prefer async tests over callback waiting patterns.
- Verify cancellation and task ordering where behavior depends on concurrency.
- Avoid time-based sleeps; use controllable clocks/schedulers/test hooks.

## Naming

- Name tests by behavior and outcome.
- Pattern: `does X when Y` or `returns A when B`.
- Keep names user-observable and domain-oriented.

## File/Structure Guidance

- Place tests next to the relevant module’s test target conventions.
- Group by feature/type under test.
- Extract shared fixtures/builders only when duplication meaningfully hurts readability.

## Implementation Checklist

Before finishing:

- [ ] Correct framework choice (Swift Testing by default)
- [ ] No redundant `@Suite`
- [ ] Literal backticked test names
- [ ] `#expect` / `#require` used in Swift Testing
- [ ] Deterministic and isolated
- [ ] Covers key behavior + edge/failure case as needed
- [ ] Readable, minimal, and maintainable
