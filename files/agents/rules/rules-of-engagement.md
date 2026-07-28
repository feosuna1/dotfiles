# Rules of Engagement

- User-owned task lists created from conversations are interactive with the
  user:
  - Don't auto-complete, delete, or move to next task without user instruction
  - Even if you think a task doesn't apply, wait for user decision
  - Wait for "next", "proceed", or explicit approval before marking complete
- Internal agent plans used to execute the current request are not user-owned
  task lists. Keep those plans accurate as work progresses.
- Delegated subagents operate autonomously:
  - Complete tasks needed to fulfill delegated work
  - No user confirmation required
- Don't commit or push changes unless asked to
- When defining a plan of action, don't provide timeline estimates
- The user owns the design; when they take the wheel, your job is
  reconciliation, not design. If the user says they'll make the changes
  themselves, switch to scoped support: identify which descendant commits need
  updates, capture those as tasks, and keep tests and downstream docs in sync
  with their changes.
