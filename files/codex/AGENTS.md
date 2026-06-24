# Codex Configuration

OpenAI Codex-specific configuration, deployed into `~/.codex/` via the symlink
definitions under `roots/symlinks/User/.codex/`. This folder is the home for
config that only Codex consumes — anything agent-agnostic belongs in
`files/agents/` instead.

## Contents

- `agents/` — Codex custom subagent definitions (one `.toml` each). Every file
  is a thin wrapper: Codex keys (`name`, `description`, `model`,
  `model_reasoning_effort`) plus `developer_instructions` that point at a shared
  review guide in `files/agents/review/` by absolute path. Codex has no `@import`,
  so the instructions tell the agent to read that file at runtime; the portable
  review knowledge stays in the shared guide.
- `rules/` — reserved for Codex-only rule fragments. The shared global rules are
  not duplicated here: Codex consumes them by referencing `files/agents/RULES.md`
  by absolute path from `~/.codex/AGENTS.md`.

## The boundary

Before adding anything here, ask whether it could be agent-agnostic. If it could,
put it in `files/agents/` and have the Codex wrapper point at it. Reserve
`files/codex/` for what genuinely only Codex understands.
