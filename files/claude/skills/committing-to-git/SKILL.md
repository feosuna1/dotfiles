---
name: committing-to-git
description: Use when drafting commit messages or creating commits. Triggers include preparing to commit changes, writing commit messages, or any git commit operation requiring message formatting.
---

# Git Commit Messages

## Overview

**Commit messages are for future developers (including your future self).** They explain WHY changes were made, not WHAT changed (git diff shows that). Follow these rules to create scannable, useful commit history.

## The Seven Rules

1. Separate subject from body with blank line
2. Limit subject to 50 characters (hard limit)
3. Capitalize subject, no period
4. Use imperative mood ("Add" not "Added")
5. Wrap body at 72 characters
6. Body explains what and why, not how

## Critical: NO Claude Attribution

**NEVER add Co-Authored-By: Claude lines to commit messages.**

This is the user's work. Claude is a tool, not a co-author.

## The Imperative Test

Subject completes: **"If applied, this commit will [your subject line]"**

✅ "...will **Add caching**" ❌ "...will **Added/Adds caching**"

## WHY Over WHAT

Code shows WHAT. Commit explains WHY.

**Complete example format:**

```text
Fix race condition in payment processing

Prevents duplicate charges when concurrent payment requests occur.
Race condition was causing duplicate transactions, resulting in
customer complaints and approximately $50k/month in refunds and
support costs.
```

Note: Subject line, blank line, then body explaining business impact (not "Added transaction lock to processPayment function").

## One Commit = One Purpose

**Subject needs "and"? Need multiple commits.** Each commit = one reason to exist. File location irrelevant.

## Body Content

**DO:** Why necessary, problem solved, business/user impact
**DON'T:** Files/functions changed, implementation steps, technical "how" (middleware, locks, pooling)

**Body = business context only. Zero implementation details.**

## Common Mistakes

### Common Rationalizations

| Excuse                              | Reality                                            |
| ----------------------------------- | -------------------------------------------------- |
| "Need to be complete/thorough"      | Subject is summary. Details in body.               |
| "Past tense feels natural"          | Git uses imperative. Be consistent.                |
| "These are trivial"                 | Future you needs specificity.                      |
| "Some implementation context helps" | Body is ONLY business WHY. Diff shows how.         |
| "Proud of elegant solution"         | Body is ONLY business WHY. Zero technical details. |
| "Claude helped, give credit"        | User's work. Tools don't get credit.               |
| "All small, one commit fine"        | Different purposes = separate commits.             |
| "They're in same file"              | Purpose determines commits, not location.          |

### Examples

❌ `Add Redis caching layer to improve API performance` (55 chars) → ✅ `Add Redis caching for API performance` (40 chars)
❌ `Fixed/Fixes race condition` → ✅ `Fix race condition`
❌ `Minor fixes and improvements` → ✅ `Allow plus signs in email validation`
❌ Body: "Added transaction lock in processPayment function" → ✅ "Prevents duplicate charges costing $50k/month"
❌ "Improve validation and fix UI" → ✅ Separate commits per purpose

## Red Flags - Stop and Revise

Subject: >50 chars, past tense, generic, ends with period, contains "and"
Body: lists files/functions, implementation details, technical "how"
Other: Co-Authored-By line, bundling unrelated changes, missing body for non-trivial changes

## The Bottom Line

50 char subject (imperative, capitalized, no period) + body explains WHY (business impact, not implementation). NO Claude attribution. Ask: "Will this help me understand WHY in 6 months?"
