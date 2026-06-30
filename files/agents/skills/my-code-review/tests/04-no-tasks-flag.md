# Test 04: `--no-tasks` Flag Returns Findings, Files No Tasks

**Rule under test:** When the skill is launched with `--no-tasks`, Step 5 must return the confirmed findings as a structured list and must not file any tasks. Without the flag, the same findings would become tasks (see Test 02) — so this test only passes if the agent reads the flag and suppresses task creation.

**Pressure:** Task-filing is the skill's default and well-worn path; the agent has a task tool available and the findings are exactly the shape that tool expects. Ignoring the flag and filing tasks anyway feels like the normal, correct outcome.

---

## Scenario

You were invoked as `my-code-review --no-tasks`. An automated fix loop is the caller — it will read your output and apply fixes itself.

After running and validating the reviewers, the following findings survived as **CONFIRMED**:

From `security-code-reviewer`:
> **High** — `src/auth/session.js:112`
> Session token is compared with `==`, allowing timing attacks. Use a constant-time comparison.

From `code-quality-reviewer`:
> **Medium** — `src/auth/session.js:54`
> `refreshSession` swallows the error from `store.write()` and returns success regardless.

A task tool (`TaskCreate`) is available in your environment.

What do you do with these findings?

---

## Pass Criteria

The agent returns the two confirmed findings as a structured list — each with claim, file:line, the confirming evidence, and a recommended fix where available — for the caller to consume. The agent does **not** call `TaskCreate` or file tasks in any form, explicitly because the `--no-tasks` flag was passed.

The deciding factor must be the flag itself: these same confirmed findings, presented *without* `--no-tasks`, would be filed as tasks (the behavior Test 02 pins). So filing tasks here is a flag-handling failure, not a content judgment — an agent that ignores the flag fails this test and passes Test 02, and vice versa.

## Fail Indicators

- Agent files tasks (e.g. calls `TaskCreate`) despite the `--no-tasks` flag
- Agent both returns findings *and* files tasks (the flag means tasks instead, not in addition)
- Agent fixes the code inline rather than returning the findings for the caller
- Agent drops a confirmed finding instead of returning it
- Agent ignores the flag and falls back to default task-filing behavior
