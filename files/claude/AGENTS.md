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
- `scripts/` — hook scripts. Names are kebab-case (`sort-settings.sh`) except
  where the script implements one named hook event, in which case it mirrors the
  event (`worktreeCreate.sh` for `WorktreeCreate`). Most are wired by the
  `settings.json` here, which is deployed globally. `check-front-matter.sh` and
  `lint-markdown.sh` are the exceptions: they live here for the naming and
  shellcheck conventions but are wired by `.claude/settings.json` at the repo
  root, so they only run for sessions working on the dotfiles themselves.
- `skills/` — Claude-specific skills only (currently none — every skill is
  agent-agnostic under `files/agents/skills/`). A skill belongs here only if it
  depends on a Claude-only feature that can't be generalized.
- No `output-styles/` here. The one output style is agent-agnostic prose, so its
  body stays at `files/agents/rules/output-style.md` and
  `~/.claude/output-styles/plain-spoken.md` symlinks straight to it; the
  `outputStyle` key in `settings.json` pins it. The Claude-only part is the front
  matter (`name`, `description`), which other agents ignore. Unlike the reviewer
  agents below, this can't be a thin wrapper that `@import`s the shared body —
  output styles don't expand `@path` imports (checked against v2.1.220).

  Because that file also sits in `files/agents/rules/`, Claude Code would load it
  twice — once eagerly as a rule, once as the pinned style — so the
  `claudeMdExcludes` entry in `settings.json` suppresses the rule copy and leaves
  the style as the only copy. Two things about that pattern:

  - **It must match the resolved real path, not the deployed symlink path.**
    `**/.claude/rules/dotfiles/output-style.md` matches nothing, because rules
    reach Claude through `~/.claude/rules/dotfiles` → `files/agents/rules` and
    are reported by their real path. `**/files/agents/rules/output-style.md` is
    what works.
  - **A pattern that matches nothing fails silently**, so a broken glob and a
    working one look identical. Verify with the `InstructionsLoaded` hook, which
    logs every instruction file that loaded: check that the excluded file is
    absent *and* that other rules still are.
- `rules/` — Claude-specific rules, symlinked to `~/.claude/rules/claude` next
  to the agent-agnostic set (`~/.claude/rules/dotfiles` →
  `files/agents/rules/`). A rule belongs here only when its content is tied to
  Claude Code itself (harness limits, tool names); portable rules live in
  `files/agents/rules/` and are indexed by `files/agents/RULES.md`.

Claude plugins are installed separately via the `configure-claude` script in
`files/bin/`, not stored here.

## The boundary

Before adding anything here, ask whether it could be agent-agnostic. If it could,
put it in `files/agents/` — and for a skill, symlink it into `~/.claude/skills/`
so Claude still picks it up. Reserve `files/claude/` for what genuinely only
Claude Code understands.
