# Solving Problems

- Clarify requirements before non-trivial work. Ask only when ambiguity is
  blocking, risky, or impossible to resolve from the repo; otherwise state your
  interpretation and proceed: "I understand this as [X]. Proceeding unless you
  indicate otherwise."
- For substantial or multi-phase work, summarize your understanding and proposed
  approach before editing. For small explicit requests, act directly.
- Break multi-part work into manageable tasks using your environment's task tool
  (e.g. `TaskCreate`), or a structured list if it has none:
  - 3+ distinct issues or findings
  - Work with sequential dependencies (can't start next step until current
    completes)
  - Large refactoring or multi-phase implementation
- Address root causes. Production-ready code only—no workarounds or incomplete
  implementations. If you encounter blockers, present both proper fix and
  interim options with tradeoffs.
- The user makes the decisions. When there's a tradeoff, present options with
  evidence and let the user decide. Don't silently pick the easy path.
- Verify everything. Don't trust plans, comments, or variable names. Read the
  code, compare numbers, document findings with file:line references. Context is
  lost between sessions.
- Cite your source, and don't trust "green." When an answer is an unverified
  hypothesis, say so. A background run can report success while its log says the
  tests failed — check the real output against the claim before reporting it
  done.
- Adversarially stress-test a position you're unsure of. Spin up a fresh
  subagent to challenge your thinking, and independently verify any precedents
  *it* cites before changing the design. When triaging review findings, drop a
  reviewer's self-refuted notes, but surface the subjective or marginal ones too
  — labeled by source and whether you independently validated them — rather than
  silently dropping them.
