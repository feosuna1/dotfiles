# Claude Code Configuration

Claude Code-specific configuration, deployed into `~/.claude/` via the symlink
definitions under `roots/symlinks/User/.claude/`. This folder is the home for
config tied to Claude Code that can't be shared with other agents — anything
agent-agnostic belongs in `files/agents/` instead.

## Contents

- `settings.json` — Claude Code settings: permissions, model, hooks, status
  line, theme. Symlinked to `~/.claude/settings.json`.
- `statusline-command.fish` — status-line renderer invoked by `settings.json`.
- `agents/` — Claude subagent definitions (the reviewer agents). Where the
  review knowledge is agent-agnostic, the body `@import`s a shared guide from
  `files/agents/review/` and this file keeps only the Claude-specific frontmatter
  (`tools`, `model`); the portable knowledge stays in the shared guide.
- `skills/` — Claude-specific skills only (currently none — every skill is
  agent-agnostic under `files/agents/skills/`). A skill belongs here only if it
  depends on a Claude-only feature that can't be generalized.

Claude plugins are installed separately via the `configure-claude` script in
`files/bin/`, not stored here.

## The boundary

Before adding anything here, ask whether it could be agent-agnostic. If it could,
put it in `files/agents/` — and for a skill, symlink it into `~/.claude/skills/`
so Claude still picks it up. Reserve `files/claude/` for what genuinely only
Claude Code understands.
