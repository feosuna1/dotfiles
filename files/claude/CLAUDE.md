# CLAUDE.md

## General

1. Never do anything by yourself. Always ask me for confirmation before doing it.
2. Don't run UI or Unit tests unless I ask.
3. Don't run linters unless I ask.
4. When creating Swift Testing test cases, don't prefix the tests with `test`.

## Commit Messages

**Always ask for confirmation** before committing. Show format:

```text
Title: [50 char max, imperative, capitalized, no period]

Body: [optional, 72 char wrap]
```

**Format rules:**

- Imperative mood: "Add feature" not "Added feature"
- Test: "If applied, this commit will [subject]" must make sense
- Blank line between subject and body

**Content focus - explain WHY, not WHAT:**

- Business reason or problem solved
- Ask for clarification if unclear
- Only describe HOW if implementation is non-obvious
- Never list files, fields, or enumerate changes
- Never explain what's being replaced or temporary solution limitations
- Focus on the goal, not the journey

**Self-evaluate before proposing:**

1. Does body explain WHY (business reason)?
2. Am I describing WHAT changed (redundant with diff)?
3. Would someone understand motivation without code?
4. Am I explaining temporary/intermediate details?
5. Revise if answered "no" to #1 or "yes" to #2/#4

**Examples:**

❌ BAD (describes what):

```text
Refactor current goal to use GoalCategory model

Replace Category with GoalCategory to include progress fields
(currentAmount, remainingAmount, targetDate, progressPercentage).
Category model lacked the fields we needed.
```

✅ GOOD (explains why):

```text
Add GoalCategory for progress display

Prepare data layer for ProgressCard view that will show users
their progress toward selected goals (amount saved, amount remaining,
target dates, completion percentage).
```

## Code Quality

- Production-ready code only - no incomplete implementations
- No redundant comments or changelog-style comments
- Fix root causes properly - no backwards compatibility workarounds
- Break large tasks into subtasks with todo lists
- Stringify JSON when logging for easy copy-paste
- Be thorough, brutally honest, make no assumptions
- Before starting, confirm understanding of the task and proposed approach
- Ask clarifying questions if requirements are ambiguous
