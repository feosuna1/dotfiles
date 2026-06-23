# Agent Rules

A portable, agent-agnostic set of standing rules for AI coding agents.

- **[`RULES.md`](RULES.md)** — the entry point: a progressive-disclosure index.
  It's a table of contents whose entries link to the rule bodies and describe
  *when* to read each one.
- **`rules/`** — the rule bodies, one self-contained file per rule.

An agent reads `RULES.md`, then opens a rule file only when its situation
applies — rather than loading every rule up front.

## Installing into an agent

To make an agent use these rules, add a reference to `RULES.md` in that agent's
global-instructions file, using the **absolute path**. Don't symlink the
agent's file to `RULES.md` and don't copy `RULES.md` elsewhere: `RULES.md` links
to its rule bodies with paths relative to its own location, so the agent must
read it in place (at `~/.dotfiles/files/agents/RULES.md`) for the `rules/` links
to resolve.

**Codex** reads `~/.codex/AGENTS.md` as global instructions. Add a line there
pointing at this index:

```markdown
Follow the standing rules indexed at ~/.dotfiles/files/agents/RULES.md.
```

The same pattern works for any agent that loads a global instructions file:
reference `~/.dotfiles/files/agents/RULES.md` from it by absolute path.

**Claude Code** is wired differently and does not use `RULES.md`. It loads every
file in `rules/` eagerly through its native `rules/` mechanism —
`~/.claude/rules/dotfiles` symlinks to `~/.dotfiles/files/agents/rules`. The
rule bodies are the single source of truth shared by both paths.
