# CLAUDE.md

## General

1. Never do anything by yourself. Always ask me for confirmation before doing it.
2. Don't run UI or Unit tests unless I ask.
3. Don't run linters unless I ask.
4. When creating Swift Testing test cases, don't prefix the tests with `test`.

## Code Quality

### Core Principles

- Production-ready code only - no incomplete implementations
- Fix root causes properly - no backwards compatibility workarounds
- Break large tasks into subtasks with todo lists
- Be thorough, brutally honest, make no assumptions
- Before starting, confirm understanding of the task and proposed approach
- Ask clarifying questions if requirements are ambiguous

### Security

- Never log sensitive data (passwords, tokens, API keys, PII)
- No hardcoded secrets or credentials
- Always validate and sanitize user input
- Use parameterized queries - never string concatenation for SQL
- Sanitize output to prevent XSS
- Ensure authentication/authorization checks are present
- Prevent path traversal vulnerabilities

### Performance

- Watch for N+1 query problems
- Consider database indexes for lookup queries
- Avoid memory leaks - clean up resources properly
- Keep hot paths non-blocking
- Use efficient algorithms - avoid O(n²) when O(n) exists
- Don't repeat expensive operations unnecessarily

### Clean Code

- **Names:** Clear over clever. No abbreviations unless universally known. Names should reveal intent.
- **Functions:** Small and focused. One responsibility. No hidden side effects.
- **DRY:** No code duplication. Extract shared logic.
- **Dead Code:** Delete it. No commented-out blocks. No unused code.
- **Error Handling:** Explicit errors with helpful messages. No swallowed exceptions.
- **Comments:** Only when logic isn't self-evident. No redundant or changelog-style comments.

### Logging

- Stringify JSON when logging for easy copy-paste
- Never log sensitive data
