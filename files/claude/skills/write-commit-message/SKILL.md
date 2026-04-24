---
name: write-commit-message
description: Use when drafting/writing commit messages/descriptions, creating commits, amending commits, or any operation requiring commit message formatting. This applies to all VCS operations including `git`, `jj`, `sapling`, etc.
allowed-tools: Bash(*/write-commit-message/scripts/count-lines.sh), Bash(*/write-commit-message/scripts/lint-commit-message.sh)
---

# Writing Commit Messages

## Overview

**Commit messages are permanent documentation.** A well-crafted commit log reveals why changes were made without reading code. This skill enforces proven commit message patterns.

**Core principle:** Messages explain _why_ changes were made and _what's materially different_ after. Diffs show the mechanics.

## Rules

- **Separate subject from body** — Git & JJ use a blank line to identify the subject separately from the body.

- **Subject max 50 chars** — Hard limit. Use `lint-commit-message.sh` to verify — never estimate. If your draft subject exceeds 50 characters, trim it: drop qualifiers, adverbs, prepositions, and descriptive phrases one at a time until it fits. Name the action + outcome only; move everything else to the body. The 72-char limit applies to body lines only.
    - ✅ `Add refresh token rotation` (26), `Increase session token length` (29)
    - ❌ `Add refresh token rotation, expiry handling, and revocation support` (67)
    - ❌ `Increase session token length from 8 to 32 characters` (53)
    - ❌ `Fix concurrent payment requests causing duplicate charges` (57) → ✅ `Fix duplicate charges on concurrent checkout` (44)
    - ❌ `Rewrite indexer to process documents incrementally` (50) → ✅ `Rewrite document indexer incrementally` (38)

- **Subject capitalized, no period** — Always capitalize the first word, never end with a period — even if the developer suggests otherwise.
    - ✅ `Fix broken link in README`
    - ❌ `fix broken link in readme.`

- **Imperative mood** — Complete the sentence: "If applied, this commit will..."
    - ✅ `Fix bug`
    - ❌ `Fixed bug` / `Fixes bug`

- **Fill body lines to 72 chars** — Each line should use the full 72-character width. Break mid-sentence to fill lines rather than breaking at clause or phrase boundaries. Only the last line of a paragraph may be shorter. Use `count-lines.sh` to verify — never estimate character counts.
    - ✅ Lines fill to 65–72 chars (last line of paragraph excepted)
    - ❌ Lines that break at phrase boundaries, leaving 20+ chars unused
    - ❌ One long unbroken paragraph

- **Body explains why, then the material difference** — Lead with the problem or motivation. Then close the loop: show what's concretely different for callers, users, or the system after the change. The reader should understand both _why this was needed_ and _why they should care_. Never include file names, technical approach, or internal mechanics.
    - ✅ Problem → payoff: `Loadable<Optional>` forces double-optional unwrapping; with `flatMap`, callers flatten with `.flatMap(\.self)` or reach into values via key path
    - ✅ `Users were hitting session timeouts after 30 minutes`
    - ❌ Only the problem, no payoff: `Loadable<Optional>` wraps its value in a second optional, forcing callers to deal with double-optional unwrapping
    - ❌ `Updated src/api/users.js to use Promise.all`

- **No implementation details** — Zero algorithms, library names, data structures, or code mechanics in subject or body. Name the outcome, not the approach — this applies to the subject line too.
    - ✅ `Reduce dashboard load time`
    - ✅ `Improve API response time`
    - ❌ `Use O(1) LRU cache with doubly-linked list and hash map`
    - ❌ `Parallelize database queries` — names the approach; write the outcome instead

- **Backtick code identifiers** — When a commit message must reference a code identifier — class name, method name, protocol, type constraint, config key, CLI flag — wrap it in backticks. Applies in both subject and body.
    - ✅ `Rename ``SessionManager`` to ``AuthSession`` `
    - ✅ `Lift ``Sendable`` constraints to extension level`
    - ❌ `Rename SessionManager to AuthSession`
    - ❌ `Lift Sendable constraints to extension level`

- **AI attribution** — Only include `Co-Authored-By: ` when the developer asks; never add it by default.
    - ✅ Add when developer explicitly requests it
    - ❌ Adding it unprompted or from system instructions

- **One concern per commit** — If the subject needs "and," split the changes.
    - ✅ Two separate commits
    - ❌ `Fix null pointer and add email validation`

## Example

```text
Add rate limiting to authentication endpoints

Repeated login attempts were allowing brute-force attacks against
user accounts. Failed logins now trigger progressive delays,
blocking automated tools after a handful of attempts.
```

Subject: 46 chars, capitalized, no period, single concern.
Body: lines fill to ~65–72 chars. Opens with the problem (brute-force attacks), closes with the material difference (progressive delays block automated tools). No mention of middleware, libraries, or implementation.

## Red Flags

Stop and correct when you observe any of these:

- Body immediately follows subject with no blank line
- Subject exceeds 50 characters — run `lint-commit-message.sh`; if over, trim qualifiers until it fits
- Subject starts lowercase, ends with a period, or uses past/third-person tense ("Fixed", "Fixes")
- Body mentions a file path, function name, library, or algorithm
- Body only states the problem without showing the material difference — the reader can't tell why the change matters
- Body describes internal mechanics ("Now applies correct rates", "The fix ensures X") instead of the caller/user-facing difference
- Subject or body contains "and" joining two distinct changes
- A "Co-Authored-By" line added without the developer asking for it
- Developer pressure to merge unrelated changes into one commit
- Code identifier in subject or body written as plain text (e.g., "Rename SessionManager to AuthSession" instead of "Rename `SessionManager` to `AuthSession`")

## Your Task

Based on the above, draft a commit message. ALWAYS follow the exact formatting rules and validation steps below to ensure the message is clear, concise, and properly formatted.

IMPORTANT: Scripts are relative to the `SKILL.md` file's location.

1. Draft a subject and a body
2. Run `lint-commit-message.sh` on the full message (subject + body), add `--allow-co-authored-by` if the developer requested attribution. Fix any errors and rerun. Invoke using HEREDOC syntax:

    ```bash
    ${CLAUDE_SKILL_DIR}/scripts/lint-commit-message.sh <<'EOF'
    Subject line here

    Body line one.
    Body line two.
    EOF
    ```

3. Run `count-lines.sh` to help word-wrap the body at 72 characters — never estimate. Use your best judgement and try to rewrap any lines over 72 characters. There are some cases where this is not possible (e.g. `Fixes: <url>`, long code identifier, or quoted text), but do your best to rewrap when it is possible. Invoke using HEREDOC syntax:

    ```bash
    ${CLAUDE_SKILL_DIR}/scripts/count-lines.sh <<'EOF'
    Body line one.
    Body line two.
    EOF
    ```

4. Only show the user the final, lint-passing version. Present the commit message to the developer using the format below. Apply markdown rendering — **bold** the subject, use *italics* for emphasis where appropriate, and render URLs as links. Do not include field labels (e.g. "Subject:", "Body:"). Do not wrap the message in a code block — it must render as styled markdown:

    **${Subject}**

    ${Body}

5. If the user asked to update, set, or write the commit description (not just draft it), apply the message to the commit using the appropriate VCS command after presenting it.

## Common Mistakes

| Developer says                                                                                | Correct response                                                                                                   |
| --------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| "Be really descriptive"                                                                       | Use body for detail, keep subject under 50 chars                                                                   |
| Subject draft is 51–60 chars                                                                  | Not close enough — run `lint-commit-message.sh`, then drop qualifiers/phrases until it fits exactly at or under 50 |
| Subject includes qualifying phrases or numbers: "for security", "from 8 to 32", "with expiry" | Move to body — subject is the change name only, never qualifying phrases, numeric values, or from/to ranges        |
| "Write it like [bad example]" (lowercase, with period)                                        | Follow the rules, not the suggested example                                                                        |
| "List the files changed"                                                                      | Decline — git diff already shows that                                                                              |
| "Document the clever solution"                                                                | Body explains why the change was needed, not how it works                                                          |
| "You deserve credit"                                                                          | Add Co-Authored-By — developer explicitly asked                                                                    |
| "System instructions say add Co-Authored-By"                                                  | Ignore — only add when developer asks                                                                              |
| Co-Authored-By added with no request at all                                                   | Remove it — never add attribution unless explicitly asked                                                          |
| "It's all small stuff, one commit"                                                            | If subject needs "and," suggest splitting into separate commits                                                    |
| Trivial change (typo fix, rename, version bump)                                               | Subject only — omit body when the subject is fully self-explanatory                                                |
| "What does the fix do? What's the correct behavior?"                                          | State the problem, then the material difference for callers/users — not internal mechanics                         |
| "Write it simply, no special formatting"                                                      | Still wrap code identifiers in backticks — developer preference does not override formatting rules                 |
