# jj Command, Revset, and Fileset Reference

Lookup tables for command flags, revset syntax, and fileset patterns. Verify
anything not listed here with `jj help <command>` — the installed version's
help is always accurate for that version.

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

Used in `description()`, `author()`, `bookmarks()`, etc.: `exact:`, `glob:`,
`regex:`, `substring:` (default). Append `-i` for case-insensitive (e.g.,
`substring-i:`).

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
