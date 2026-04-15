---
name: using-jj
description: Use when performing version control operations in a Jujutsu (jj) repository, or when answering questions about jj usage. Covers the jj mental model, commands, revsets, filesets, and workflows needed to operate effectively in jj repos.
---

# Using Jujutsu (jj)

## Mental Model

jj is **not Git with different commands.** These paradigm shifts matter:

1. **The working copy is a commit.** `@` is a real commit that updates automatically as you edit files. There is no staging area — all working copy changes are part of `@` immediately.
2. **Change IDs are stable, commit IDs are not.** A change ID (short letter string like `kpqxywon`) persists across rewrites. The commit ID (SHA hash) changes every time the commit is rewritten. Use change IDs to refer to logical changes.
3. **Descendants auto-rebase.** Rewriting any commit automatically rebases all its descendants. No manual rebase cascade needed.
4. **Conflicts are data, not errors.** Operations never fail due to conflicts — the conflict is stored in the commit. Resolve later. Conflict information propagates correctly through rebases.
5. **No current branch.** Bookmarks (jj's branches) don't advance automatically with new commits. You move them explicitly.
6. **Everything is undoable.** Every operation is recorded. `jj undo` reverses the last operation. `jj op restore` jumps to any prior state.

## Commands

### Creating and Editing Changes

| Command            | Purpose                                   | Key Flags                                                            |
| ------------------ | ----------------------------------------- | -------------------------------------------------------------------- |
| `jj new [PARENTS]` | Create new empty change                   | `-m MESSAGE`, `--no-edit`, `-A/--insert-after`, `-B/--insert-before` |
| `jj commit`        | Describe `@` and create new change on top | `-m MESSAGE`, `-i/--interactive` (alias: `ci`)                       |
| `jj describe`      | Update commit description                 | `-r REVSET`, `-m MESSAGE`, `--reset-author` (alias: `desc`)          |
| `jj edit REVSET`   | Set revision as working copy              |                                                                      |
| `jj next [N]`      | Move working copy to child                | `--edit`, `--conflict`                                               |
| `jj prev [N]`      | Move working copy to parent               | `--edit`, `--conflict`                                               |

**`-m` is repeatable.** Each `-m MESSAGE` becomes one paragraph; jj joins them with blank lines. Applies to every command accepting `-m MESSAGE` (`new`, `commit`, `describe`, `squash`, `split`).

### Rewriting History

| Command                  | Purpose                                     | Key Flags                                                                   |
| ------------------------ | ------------------------------------------- | --------------------------------------------------------------------------- |
| `jj squash`              | Move changes from `@` into parent           | `--from`, `--into`, `-m MESSAGE`, `-i/--interactive`                        |
| `jj split [PATHS]`       | Split revision into two                     | `-r REVSET`, `-m MESSAGE`, `-p/--parallel`                                  |
| `jj rebase`              | Move revisions to new parent(s)             | `-s` (source+descendants), `-r` (just revision), `-b` (branch), `-o/--onto` |
| `jj absorb [PATHS]`      | Auto-distribute changes to ancestor commits | `--from`, `-t/--into REVSETS`                                               |
| `jj duplicate`           | Copy changes to new commits                 | `-o/--onto`, `-A/--insert-after`, `-B/--insert-before`                      |
| `jj parallelize REVSETS` | Make revisions siblings                     |                                                                             |
| `jj abandon`             | Discard revision(s)                         | `-r REVSETS`                                                                |

### Inspecting State

| Command             | Purpose                        | Key Flags                                                             |
| ------------------- | ------------------------------ | --------------------------------------------------------------------- |
| `jj status`         | Working copy status            | (alias: `st`)                                                         |
| `jj log --no-graph` | Revision history with graph    | `-r REVSETS`, `-T TEMPLATE`, `-p/--patch`, `-n/--limit`, `--no-graph` |
| `jj diff`           | Compare file contents          | `-r REVSET`, `--from`/`--to`, `--git`                                 |
| `jj show REVSET`    | Commit description and diff    | `-T TEMPLATE`                                                         |
| `jj evolog`         | How a change evolved over time | `-r REVSET`                                                           |

### Bookmarks (Branches)

| Command                             | Purpose               |
| ----------------------------------- | --------------------- |
| `jj bookmark create NAME -r REVSET` | Create bookmark       |
| `jj bookmark move NAME -r REVSET`   | Move bookmark         |
| `jj bookmark set NAME -r REVSET`    | Create or move        |
| `jj bookmark delete NAME`           | Delete bookmark       |
| `jj bookmark list`                  | List bookmarks        |
| `jj bookmark track NAME@REMOTE`     | Track remote bookmark |

### Git Integration

| Command            | Purpose           | Key Flags                              |
| ------------------ | ----------------- | -------------------------------------- |
| `jj git fetch`     | Fetch from remote | `--remote`, `-b/--branch`              |
| `jj git push`      | Push to remote    | `--bookmark NAME`, `--all`, `--remote` |
| `jj git clone URL` | Clone repository  |                                        |

### Conflict Resolution

| Command                          | Purpose                                    |
| -------------------------------- | ------------------------------------------ |
| `jj resolve`                     | Open merge tool for conflicted files       |
| `jj resolve --list`              | List conflicted files                      |
| `jj restore --from REVSET PATHS` | Restore file content from another revision |

### Recovery

| Command               | Purpose                       |
| --------------------- | ----------------------------- |
| `jj undo`             | Undo last operation           |
| `jj op log`           | View operation history        |
| `jj op restore OP_ID` | Restore to specific operation |

## Revsets

Revsets select commits. Almost every command accepts `-r REVSET`.

### Symbols

- `@` — working copy commit
- `@-` — parent of `@`, `@--` — grandparent, etc.
- `root()` — virtual root commit
- `trunk()` — default branch (auto-detected)

### Operators (by binding strength)

| Operator      | Meaning                                       |
| ------------- | --------------------------------------------- |
| `x-` / `x+`   | Parents / children of x                       |
| `::x` / `x::` | Ancestors / descendants of x (inclusive)      |
| `x::y`        | DAG range from x to y                         |
| `x..y`        | Commits reachable from y but not x (like Git) |
| `~x`          | Complement (everything except x)              |
| `x & y`       | Intersection                                  |
| `x ~ y`       | Difference (in x but not y)                   |
| `x \| y`      | Union                                         |

### Key Functions

| Function                             | Selects                                    |
| ------------------------------------ | ------------------------------------------ |
| `bookmarks([pattern])`               | Local bookmarks                            |
| `remote_bookmarks([name], [remote])` | Remote bookmarks                           |
| `tags([pattern])`                    | Tags                                       |
| `heads(x)`                           | Commits in x with no descendants in x      |
| `roots(x)`                           | Commits in x with no ancestors in x        |
| `description(pattern)`               | Commits matching description               |
| `author(pattern)` / `mine()`         | By author / authored by you                |
| `empty()`                            | Commits with no file changes               |
| `merges()`                           | Merge commits                              |
| `conflicts()`                        | Commits with unresolved conflicts          |
| `mutable()` / `immutable()`          | Mutable / immutable commits                |
| `present(x)`                         | x if it exists, else empty (avoids errors) |
| `files(fileset)`                     | Commits touching matching files            |
| `diff_lines(pattern)`                | Commits with matching diff content         |

### String Patterns

Used in `description()`, `author()`, `bookmarks()`, etc.: `exact:`, `glob:`, `regex:`, `substring:` (default). Append `-i` for case-insensitive (e.g., `substring-i:`).

### Common Revset Recipes

```bash
# All mutable ancestors of working copy
jj log --no-graph -r '::@ & mutable()'

# Commits on current stack
jj log --no-graph -r 'trunk()..@'

# Find commits touching a file
jj log --no-graph -r 'files("src/main.rs")'

# All conflicted commits
jj log --no-graph -r 'conflicts()'
```

## Filesets

Filesets select files in commands like `diff`, `split`, `squash`, `restore`.

| Pattern            | Meaning                   |
| ------------------ | ------------------------- |
| `"path"`           | cwd-relative path prefix  |
| `file:"path"`      | Exact file                |
| `glob:"*.rs"`      | Glob pattern              |
| `root:"path"`      | Workspace-relative prefix |
| `~x`               | Everything except x       |
| `x & y` / `x \| y` | Intersection / union      |

```bash
jj diff 'glob:"**/*.rs"'          # Only Rust files
jj split '~"Cargo.lock"'          # Everything except Cargo.lock
```

## Workflows

### Start a New Feature

```bash
jj new trunk() -m "Add feature X"
# ... make changes (auto-tracked) ...
jj describe -m "Revised description"   # Update message
jj new -m "Next change"                # Start next change in stack
```

### Amend an Earlier Commit

```bash
# Option 1: Edit directly
jj edit CHANGE_ID
# ... make changes ...
jj new   # Return to creating new work

# Option 2: Absorb from working copy
# Make fixes in working copy, then:
jj absorb   # Auto-distributes hunks to matching ancestors
```

### Push a Bookmark

```bash
jj bookmark create feature-x -r @-
jj git push --bookmark feature-x
```

### Recover from Mistakes

```bash
jj undo                    # Undo last operation
jj op log                  # Find the right operation
jj op restore OP_ID        # Jump to that state
```

## Rules

- **Verify unfamiliar flags with `jj help <command>`.** This skill covers core usage; for uncommon flags or subcommands, check help. The installed version's help is always accurate for that version.
- **Never fabricate flags.** If you're unsure a flag exists, run `jj help <command>` first.
- **Use change IDs, not commit IDs**, when referring to commits across operations — they survive rewrites.
- **Read error messages.** jj errors often suggest the correct syntax or alternative command.
- **Don't fear conflicts.** Operations succeed with conflicts stored in commits. Resolve them as a separate step.

## Red Flags

Stop and verify when:

- You're constructing a complex revset from memory — check `jj help -k revsets`
- You're unsure if a command rewrites history or is read-only — check `jj help <command>`
- An error suggests different syntax than what you tried
- You need template customization — check `jj help -k templates`
