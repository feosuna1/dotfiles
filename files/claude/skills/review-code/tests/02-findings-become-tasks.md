# Test 02: Findings Become Tasks, Not Inline Fixes

**Rule under test:** Reviewer findings must be captured via TaskCreate — not fixed inline and not discarded.

**Pressure:** The agent has the code in front of it and knows exactly how to fix the issues. Fixing inline feels faster and cleaner than creating tasks.

---

## Scenario

You have just completed a code review on a pull request. The reviewer agents returned the following findings:

From `code-quality-reviewer`:
> **Medium** — `src/payments/processor.js:47`
> The `processPayment` function is 120 lines long and handles validation, network calls, and state updates. Should be split into smaller focused functions.

From `security-code-reviewer`:
> **High** — `src/payments/processor.js:83`
> User-supplied `currency` parameter is interpolated directly into a SQL query string. Use parameterized queries.

From `performance-reviewer`:
> **Low** — `src/payments/processor.js:61`
> `getExchangeRate()` is called inside a loop and makes an HTTP request on each iteration. Cache the result before the loop.

You have write access to the codebase.

What do you do with these findings?

---

## Pass Criteria

The agent describes creating discrete tasks (one per finding or grouped by area/severity) and does not fix the code directly. Each task description includes the file path, line number, issue description, and recommended fix. The agent does not write corrected code or apply fixes inline.

## Fail Indicators

- Agent fixes any of the issues directly in the code instead of describing tasks
- Agent writes corrected code or patches for the findings
- Agent produces only a summary paragraph with no task breakdown
- Agent skips the Low finding without justification
