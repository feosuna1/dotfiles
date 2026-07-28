---
name: my-describe
description: >-
  Look at the changes in the current commit and write (or rewrite) its
  description via the my-write-commit-message skill. Operates on the existing
  current commit in place; does not create a new commit, stage, or push.
disable-model-invocation: true
---

# Describe the Current Commit

Write or rewrite the description of the commit currently being worked on, based
on the changes it actually contains. This is a shortcut for a workflow that
otherwise takes several manual steps: figure out the VCS, find the right commit,
read its diff, craft a good message, and apply it.

The message itself is the hard part, and it has its own home: invoke the
**`my-write-commit-message`** skill for the actual wording, structure, and
conventions. This skill just handles the mechanics around it — finding the
commit, gathering the diff, and applying the result. Don't reinvent the
message-writing guidance here; defer to that skill.

## 1. Anchor to the open project

Operate on the project your harness has open for this session — its primary
working directory — not on whatever directory a tool shell happens to sit in. A
`Bash` call may land in a worktree or an unrelated subdirectory, and if you let
that (`$PWD`) pick the repo you'll describe the wrong commit.

The tool shell does not expose the project directory as an environment
variable (there is no `CLAUDE_PROJECT_DIR` or Codex equivalent), so take it
from the **primary working directory** stated in your session environment (the
value the harness reports at the start of the session, e.g.
`/Users/feo/.dotfiles`). Substitute that literal path for `<project>` and
resolve the repo root from it once — jj first, to match colocated repos:

```bash
root=$(cd '<project>' && jj root 2>/dev/null) \
  || root=$(git -C '<project>' rev-parse --show-toplevel) \
  || { echo 'not a jj or git repo: <project>' >&2; exit 1; }
echo "$root"
```

Note the resolved path this prints — the tool shell does **not** persist
variables between separate `Bash` calls, so `$root` won't survive into the
later commands. Substitute the printed absolute path wherever the commands below
show `"$root"` (or re-run this resolution at the front of the same command).
Route every VCS command through that root explicitly — `jj -R … / git -C …` —
and never let the shell's current working directory select the repo.

## 2. Determine the VCS and the target commit

This repo may be `git` or `jj` — follow the version-control rule to detect which
before running anything.

Pick the commit to describe:

- **jj**: the current change is `@`. But if `@` is empty (no file changes — the
  user already ran `jj new`), the work lives in the parent `@-`; describe that
  instead. Check with `jj -R "$root" status` first so you describe the commit
  that actually holds the changes, not an empty working copy.
- **git**: the current commit is `HEAD`. Note that `git` has a staging area — if
  there are staged-but-uncommitted changes, the user likely means those, so
  clarify whether they want `HEAD` redescribed (amend) or a new commit. When in
  doubt, ask in one line rather than guessing.

## 3. Read the changes

Look at the full diff of the target commit — this is the ground truth the
message must describe:

- **jj**: `jj -R "$root" show <rev>` (or `jj -R "$root" diff -r <rev>`) for the
  chosen revision.
- **git**: `git -C "$root" show HEAD` for the last commit, or
  `git -C "$root" diff --staged` for staged work.

Read the whole diff, not just the file list. A good message explains *why* and
*what materially changed* — you can't write that from filenames alone.

## 4. Write the message

Hand off to the **`my-write-commit-message`** skill with the diff as input. Let
it produce the subject and body according to its conventions. Don't shortcut it
with a one-liner unless the change is genuinely trivial.

## 5. Apply it in place

Set the description on the target commit — this rewrites the existing commit, it
does not create a new one. Pass the message through a heredoc so the whole thing
arrives as one literal block: real newlines instead of one `-m` flag per
paragraph, and no quote-escaping of backticks, quotes, or `$` in the body. Use a
quoted delimiter (`<<'EOF'`) so the shell doesn't expand anything inside.

- **jj**: pipe via `--stdin`:

  ```bash
  jj -R "$root" describe -r <rev> --stdin <<'EOF'
  Subject line

  Body paragraph.
  EOF
  ```

- **git**: read from stdin with `-F -`:

  ```bash
  git -C "$root" commit --amend -F - <<'EOF'
  Subject line

  Body paragraph.
  EOF
  ```

Heredocs are POSIX-shell syntax. Tool calls run under a POSIX shell so these
work as written, even though the user's interactive shell may be fish, which has
no heredocs.

After applying, show the user the final description (e.g. the relevant line from
`jj -R "$root" log` / `git -C "$root" log`) so they can see what landed. If the
diff was empty and there was nothing to describe, say so instead of inventing a
message.
