# Testing Discipline

**Reproduce a bug with a failing test before you fix it.** When you find — or
are handed — a bug, first add a test to the relevant suite that asserts the
*correct* behavior, and run it to confirm it fails against the current code.
Only then apply the fix, and re-run to confirm it goes green along with the rest
of the suite.

**Why the order matters.** Seeing the test fail first proves it actually
exercises the bug. A test written *after* the fix can pass for the wrong reason
— asserting the new behavior without ever having driven the broken path — so it
silently guards nothing. The red-then-green sequence pins the expected behavior,
proves the repro is real, and leaves a regression guard so the bug can't quietly
return.

**How to apply.** Write the test for the expected behavior → run it and confirm
it fails → apply the fix → run the full suite and confirm it passes with no
regressions. If you can't get the test to fail first, treat that as a signal you
haven't actually reproduced the bug yet — investigate before changing any code,
rather than writing a test that rationalizes a fix you've already decided on.

**Give competing inputs distinct values, so the test can actually fail.** When a
test asserts that one source, branch, or path is the one used, the alternatives
must hold *different* values. If the "winner" and the "loser" carry the same
value, the assertion passes no matter which one the code actually reads — it
proves nothing and can't catch the bug it exists to guard against. Set the
losing input to a distinct value (e.g. the before-state `.standard`, the
after-state `.creditCard`) so the assertion only holds when the intended source
is read, and name the test for the distinction it checks. This is the same idea
as red-before-green: a test that can't fail when the behavior is wrong isn't
testing anything.

**Swift-specific testing conventions** (native types over bespoke test objects,
determinism over timing delays, not contorting the framework for testability)
live in the Testing section of the Swift conventions rule
(`swift-conventions.md`) — read that alongside this one when the tests are
Swift.
