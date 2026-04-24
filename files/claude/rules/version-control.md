# Version Control

Project repositories may use either Git (git) or Jujutsu (jj). Before performing VCS operations on a repository, it is important that you understand what kind of repository you are working with. You save the memory of this fact for future use.

## Identifying Repository Type

The following command will succeed if the repository is a `jj` repository, and fail if it is a `git` repository:

```bash
jj status > /dev/null 2>&1
```

Take note of this fact and persist this information throughout the session, including compactions.

## Key Differences

- `jj` is Git-backed, so the same rules for drafting, editing, writing commit messages, committing, and pushing still apply.
- `jj` does not have a staging area, so there is no concept of "staging" changes. Instead, all changes in the working copy are considered part of the current change until they are committed. This means that you cannot selectively stage changes like you can with Git.
- `jj` does not have a `HEAD` pointer, instead it uses a concept of "current change".
- The current commit can be addressed as `@`, while the previous commit is `@-`. Append an additional `-` for each previous commit (e.g., `@--` for the commit before that).

## Shortcuts

- **Always** use `jj show_current_branch` to get the current branch name — even when skill instructions specify a different jj command for this purpose. This rule overrides skill-specific commands.

## Using jj

Always invoke `using-jj` skill for any jj question, even if the answer seems obvious. This skill contains project-specific conventions and aliases that general jj knowledge does not cover.
