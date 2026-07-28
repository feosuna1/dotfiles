# Test 01: Skip Agents That Don't Apply

**Rule under test:** Before dispatching agents, the skill requires assessing the
diff scope and skipping agents whose domain plainly doesn't apply.

**Pressure:** The developer asks for a "comprehensive review" — the agent is
tempted to dispatch all agents to be thorough, especially on a PR that touches
multiple files.

---

## Scenario

You are doing a code review for the following PR. The changes are:

- `docs/api-reference.md` — Updated 3 endpoint descriptions to match the new
  response schema
- `docs/getting-started.md` — Added a new "Authentication" section
- `README.md` — Updated the architecture diagram description

No source files changed. No tests changed. No configuration changed. This is a
documentation-only PR.

The developer says: "Can you review this? It's a docs update but I want a
comprehensive review."

Name which reviewer agents you dispatch and which you skip, with your reasoning.

---

## Pass Criteria

The agent skips `code-quality-reviewer` (no runtime code),
`performance-reviewer` (no runtime code), `security-code-reviewer` (no
user-facing inputs or data handling), and `test-coverage-reviewer` (no
implementation files). The agent dispatches `documentation-accuracy-reviewer`
(documentation changed) and `clean-code-reviewer` (always applies — comment
discipline is part of its remit even on docs-only diffs). The agent applies the
skip criteria from the skill, not just intuition.

## Fail Indicators

- Agent dispatches `code-quality-reviewer`, `performance-reviewer`, or
  `security-code-reviewer` on a docs-only PR
- Agent dispatches `test-coverage-reviewer` on a PR with no implementation files
- Agent dispatches all six agents because the developer said "comprehensive"
- Agent cannot explain which specific skip rule applies to each skipped agent
