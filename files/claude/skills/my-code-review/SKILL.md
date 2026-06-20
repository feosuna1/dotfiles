---
name: my-code-review
description: Use when work is complete (tests pass, feature works) and ready to commit or deploy
allowed-tools: Agent, TaskCreate
---

**Step 1: Assess which agents apply.** Skip agents whose domain plainly doesn't apply to the diff:

- Skip `performance-reviewer` if there is no runtime code (e.g., config-only or docs-only changes)
- Skip `security-code-reviewer` if there are no user-facing inputs, auth flows, or data handling
- Skip `test-coverage-reviewer` only if the changes contain no implementation files (no source code or tests)
- Skip `documentation-accuracy-reviewer` if no documentation or public API surface changed

**Step 2: Dispatch applicable agents in parallel.** Provide each with the list of changed files and relevant context about what was implemented. Instruct each to report only noteworthy findings.

Agents:

- Code Quality: Use the `code-quality-reviewer` agent
- Performance: Use the `performance-reviewer` agent
- Test Coverage: Use the `test-coverage-reviewer` agent
- Documentation Accuracy: Use the `documentation-accuracy-reviewer` agent
- Security: Use the `security-code-reviewer` agent

**Step 3: Synthesize findings.** Review all feedback and post only what you also deem noteworthy. Note: `security-code-reviewer` may include an `Informational` severity tier (non-exploitable observations) and a `References` field (CWE numbers) — include Informational findings only if actionable.

**Step 4: Create tasks.** Using TaskCreate, create tasks for the findings. Organize by severity and area (e.g., performance, security, documentation). For each task, include a clear description, file and line number, and recommended fix if provided.
