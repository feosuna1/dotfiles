# Codex Configuration

OpenAI Codex-specific configuration, deployed into `~/.codex/` via the symlink
definitions under `roots/symlinks/User/.codex/`. This folder is the home for
config that only Codex consumes — anything agent-agnostic belongs in
`files/agents/` instead.

## Contents

- `global-instructions.md` — deployed to `~/.codex/AGENTS.md`; points Codex at
  the shared rule index and the Codex-specific harness workflow trigger.
- `harness-workflow.md` — Codex-specific operating guidance for tool discovery,
  subagent orchestration, model economy, and large-context work. It is loaded on
  demand from `global-instructions.md`, not duplicated into the shared rules.
- `agents/` — Codex custom subagent definitions (one `.toml` each). Every file
  is a thin wrapper: Codex keys (`name`, `description`, `model`,
  `model_reasoning_effort`) plus `developer_instructions` that point at a shared
  review guide in `files/agents/review/` by absolute path. Codex has no `@import`,
  so the instructions tell the agent to read that file at runtime; the portable
  review knowledge stays in the shared guide.
- `rules/` — Codex command-permission rules (`default.rules`, Starlark
  `prefix_rule` allow/prompt/forbidden), deployed to `~/.codex/rules/`. The shared
  global *instruction* rules aren't duplicated here: Codex consumes those by
  referencing `files/agents/RULES.md` by absolute path from `~/.codex/AGENTS.md`.

Filesystem path protections (`[permissions]` deny globs) are *not* kept here.
They live in the machine-local `~/.codex/config.toml`, which Codex writes its own
state into and which changes too often to track — set them there directly.

## The boundary

Before adding anything here, ask whether it could be agent-agnostic. If it could,
put it in `files/agents/` and have the Codex wrapper point at it. Reserve
`files/codex/` for what genuinely only Codex understands.
