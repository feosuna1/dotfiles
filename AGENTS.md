# Project: dotfiles

This is the user's personal `dotfiles` that configures the development environment, shell settings, git workflows, and Claude Code behavior across all of the user's machines.

## Key Patterns

**Adding a New Custom Git Command:**

1. Create executable script in `files/bin/git-<command>`
2. Script automatically available as `git <command>` (git's PATH mechanism)

**Naming Scripts:**

- Script filenames are kebab-case: `git-safe-push`, `sort-settings.sh`,
  `xc-list-runtimes`. Never camelCase.
- Scripts in `files/bin/` carry no extension — they are commands invoked by name.
  Scripts elsewhere keep their extension (`.sh`, `.fish`).

**Adding an `AGENTS.md`:**

- Whenever you create a new `AGENTS.md`, add a sibling `CLAUDE.md` next to it
  containing a single line: `@AGENTS.md`
- `AGENTS.md` is the canonical, agent-agnostic instruction file; the `CLAUDE.md`
  import lets Claude Code pick up the same content without duplicating it
- A `CLAUDE.md` must contain nothing but that `@AGENTS.md` import. If you find a
  `CLAUDE.md` with any other content, warn the user about the discrepancy rather
  than silently editing it — the extra content belongs in `AGENTS.md`

**Adding Claude Configuration:**

- Rules (global instructions): `files/agents/rules/<name>.md` — agent-agnostic; indexed by `files/agents/RULES.md`
- Skills (workflows): `files/agents/skills/<name>/SKILL.md` if agent-agnostic, else `files/claude/skills/<name>/SKILL.md` for Claude-specific ones
- Both automatically loaded via symlink to `~/.claude/` (Claude's `rules/dotfiles` symlink points at `files/agents/rules/`)

**Keeping Claude and Codex in sync:**

- The two agents carry parallel config: Claude permissions in `files/claude/settings.json` and Codex command rules in `files/codex/rules/`; subagents in `files/claude/agents/` and `files/codex/agents/`.
- When you add or change a rule for one agent — a permission/approval entry, a subagent, a behavior rule — consider whether the other needs the same change and apply it there too, unless it's genuinely agent-specific.
- `install.sh` runs `files/bin/check-permission-parity`, which warns when the Bash permission entries in `files/claude/settings.json` and the prefix rules in `files/codex/rules/default.rules` drift apart.
- `install.sh` also runs `files/bin/check-agent-parity`, which warns when a reviewer agent's Claude and Codex wrappers drift: a missing twin, differing descriptions, a model-tier mismatch against the mapping in `files/agents/AGENTS.md`, or wrappers referencing different (or missing) review guides.

**Managing Packages:**

- Edit `Brewfile` with brew/cask/vscode/cargo entries
- Run `files/bin/install-brew` to apply changes
- Format follows Homebrew Bundle syntax

## Testing Considerations

**Before Committing:**

- Verify symlink targets exist and paths are correct
- Test `install.sh` in a safe environment (VM or secondary account)
- Check that `.symlink` files contain valid paths starting with `~/`
- Validate shell syntax: `fish -n <file>` or `bash -n <file>`
- Run shellcheck on bash scripts: `shellcheck files/bin/*`

**Claude Rules/Skills:**

- Changes to `files/claude/` affect all Claude Code sessions
- Changes to `.claude/settings.json` affect only sessions opened in this repo

## Commands

**Linting:**

```bash
# Markdown linting (configured via .markdownlint-cli2.yaml)
markdownlint-cli2 "**/*.md"
```

## Architecture

**Installation System:**

- `install.sh` orchestrates the setup process
- `roots/symlinks/User/` contains symlink definitions (`.symlink` files point to targets in `files/`)
- `roots/copy/User/` contains files to be copied (not symlinked) to home directory
- Files are deployed relative to `$HOME` by preserving directory structure

**Agent Configuration:**

- Agent-agnostic config (rules, skills, review guides) lives in `files/agents/` — see `files/agents/AGENTS.md`; the rules are indexed by `files/agents/RULES.md`
- Claude Code-specific config (settings, subagents, Claude-only skills) lives in `files/claude/` — see `files/claude/AGENTS.md`

**Config for working on this repo:**

Everything under `files/` is *deployed* — symlinked into `~/.claude/` and in
effect everywhere. The `.claude/` directory at the repo root is the opposite:
project settings that apply only to sessions opened in this repo, configuring
how agents work **on** the dotfiles rather than what the dotfiles install.

- `.claude/settings.json` — committed. Holds a `PostToolUse` hook on
  `Write|Edit` that runs `files/claude/scripts/check-front-matter.sh`, rejecting
  markdown written under `~/.dotfiles` whose YAML front matter a strict parser
  can't read. Claude Code's own front matter parser is lenient, so an unquoted
  `description:` containing `": "` reads fine in a session but breaks `yq`-based
  tooling like `check-agent-parity`.
- `.claude/settings.local.json` — gitignored personal overrides.

## Important Notes

- **Never commit sensitive data** (API keys, tokens) even to personal dotfiles
- **Git config user.email** is set to GitHub noreply address for privacy
