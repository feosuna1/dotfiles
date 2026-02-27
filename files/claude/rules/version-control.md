# Version Control

Project repositories may use either Git (git) or Jujutsu (jj). Before performing operations on a repository, it is important that you understand what kind of repository you are working with. You should memorize this fact for the duration of the session and future sessions.

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

## Common Commands

- Almost all `jj` commands take a `-r/--revisions` flag to specify the revsets to operate on, and default to `@` if not provided.
  - Use `-r ::@` for operations that need to act on the ancestors from the current change (e.g., `jj log`, `jj diff`)
  - Use `-r @::` for operations that need to act on the descendants from the current change (e.g., `jj diff`)
  - Change trees can diverge and have multiple parents, so be mindful of the revision range you specify.
- `jj log --no-graph -T 'builtin_draft_commit_description_with_diff'` as an equal to `git log`
- `jj log --no-graph -T 'builtin_log_oneline'` as an equal to `git log --oneline`
- `jj log --no-graph -T 'description'` to verify a commit message
- `jj diff --git` as an equal to `git diff`
- `jj describe` to amend the current commit message
- `jj new` to start a new change
- `jj squash` to combine changes
- `jj split -m ${COMMIT_MESSAGE} ${FILES}` to split a change into multiple changes, replace:
  - `${COMMIT_MESSAGE}` with the desired message for the new change (empty string is a valid message, if you don't have a reasonable message). If `-m` is not provided, the new change will open in the editor for the user to write the commit message.
  - `${FILES}` with the list of files to split into the new change.
