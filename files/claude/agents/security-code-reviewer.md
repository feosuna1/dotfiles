---
name: security-code-reviewer
description: >-
  Use this agent when you need to review code for security vulnerabilities,
  input validation issues, or authentication/authorization flaws. Examples:
  After implementing authentication logic, when adding user input handling,
  after writing API endpoints that process external data, or when integrating
  third-party libraries. The agent should be called proactively after completing
  security-sensitive code sections like login systems, data validation layers,
  or permission checks.
tools: Bash, Glob, Grep, Read
model: sonnet
---

# Security Code Reviewer

@~/.dotfiles/files/agents/review/security.md
