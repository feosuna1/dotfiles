# Writing Code

Apply these standards while writing, not just at review. They are the hard,
checkable subset of what the `clean-code-reviewer` and `code-quality-reviewer`
agents enforce — write to them from the first keystroke and review finds less.
Those agents remain the exhaustive source; this rule is the condensed
writing-time checklist, not a substitute for independent review.

## Names

- Names reveal intent on their own. If a name needs a comment, rename it.
- No vague placeholders (`temp`, `data`, `value`, `obj`, `result`, `process`,
  `manager`, `helper`, `util`) outside trivially small scopes.
- No disinformation: don't call it `list` if it isn't, `count` if it's an index,
  or `isReady` if it can be null. Names match behavior.
- Functions are verb phrases; types are nouns; booleans read as predicates
  (`isValid`, `hasNext`). One word per concept — don't mix `get`/`fetch`/`retrieve`.

## Functions

- One thing per function. If you can extract a named sub-function from the
  middle, it was doing more than one thing.
- Keep bodies small — a function that doesn't fit on one screen (~20 lines) is a
  smell.
- 0–3 parameters. Four or more signals a missing object. No boolean flag
  arguments — split the function.
- Command-query separation: a function either *does* something or *answers*
  something, never both.

## Structure

- DRY: extract repeated logic to one source of truth rather than copy-paste.
- Flatten with guard clauses and early returns; avoid deep `if`/`for` nesting.
- Name magic numbers and strings as constants.
- Keep side effects out of query-like functions; don't silently mutate inputs or
  shared state.
- Prefer types over strings: a constrained type or enum that fails at
  type-check beats a bare string that fails at runtime.

## Comments

- Comments explain *why*, not *what*. The code says what it does; the comment
  captures rationale a reader can't recover from the code.
- A comment that compensates for unclear code is a smell — rename or extract
  instead. Don't leave commented-out code or context-free `TODO`s.

## Correctness

- Fail fast: validate inputs and preconditions, and stop with a meaningful error
  rather than proceeding with bad data. Never swallow errors silently.
- Release resources (connections, file handles, streams, locks) on every path,
  including errors.
- Handle edge cases as you write: empty and single-element collections, boundary
  values, null/missing input, and the off-by-one at the loop's ends.
- Use the language idiomatically and its type system properly (e.g. no `any` in
  TypeScript, type hints in Python). Follow project conventions in AGENTS.md
  (or CLAUDE.md).
