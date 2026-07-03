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
- The one exception is a script whose whole job is to implement a named external
  event, where mirroring that name is clearer than describing the job: the
  `worktreeCreate.sh` / `worktreeRemove.sh` hooks in `files/claude/scripts/` match
  the Claude Code `WorktreeCreate` / `WorktreeRemove` hook events. Don't reach for
  this unless the name really is dictated from outside.

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

**Modifying Shell Config:**

- Fish: `files/config/fish/conf.d/` for modules, `roots/copy/User/.config/fish/config.fish` for main config
- Zsh: `files/config/zsh/` for shared scripts, `roots/copy/User/.zsh*` for init files
- Changes require shell restart or re-sourcing

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
- Test new rules/skills in isolated project before global deployment
- Verify YAML frontmatter in instruction files are valid
- Skills must follow the expected format (see existing examples)

## Critical Files

- `files/config/git/config` - Git preferences, aliases, and tool configuration
- `Brewfile` - Package manifest for reproducible environment setup
- `install.sh` - Entry point for all installation logic

## Commands

**Installation:**

```bash
# Full setup: symlinks, copies, brew, system config
./install.sh
```

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

**Configuration Structure:**

```text
.dotfiles/
├── files/
│   ├── agents/           Agent-agnostic config (RULES.md index; rules/, skills/, review/)
│   │   ├── rules/        Global instructions and coding standards
│   │   ├── skills/       Agent-agnostic workflow skills
│   │   └── review/       Shared code-review guides
│   ├── bin/              Custom commands (git-*, configure-*, utilities)
│   ├── claude/           Claude Code configuration (deployed to ~/.claude/)
│   │   ├── agents/       Claude subagent definitions (reviewer agents)
│   │   └── skills/       Claude-specific workflow skills
│   ├── codex/            Codex configuration (deployed to ~/.codex/)
│   │   ├── agents/       Codex subagent definitions
│   │   └── rules/        Codex command/approval rules
│   └── config/           Shell and tool configurations
│       ├── fish/         Fish shell theme and environment
│       ├── git/          Git config, ignore patterns, hooks
│       └── zsh/          Zsh interactive and login scripts
└── roots/
    ├── symlinks/         Symlink definitions for user files
    │   └── User/         Files to be symlinked to home directory
    └── copy/             Files to be copied to home directory
        └── User/         Files to be copied to home directory
```

**Symlink Mechanism:**

- Files in `roots/symlinks/User/` mirror target home directory structure
- `.symlink` extension = file contains path to actual target

**Agent Configuration:**

- Agent-agnostic config (rules, skills, review guides) lives in `files/agents/` — see `files/agents/AGENTS.md`; the rules are indexed by `files/agents/RULES.md`
- Claude Code-specific config (settings, subagents, Claude-only skills) lives in `files/claude/` — see `files/claude/AGENTS.md`

## Important Notes

- **Never commit sensitive data** (API keys, tokens) even to personal dotfiles
- **Git config user.email** is set to GitHub noreply address for privacy
