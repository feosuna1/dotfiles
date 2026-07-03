# Version Control

Project repositories may use either Git (git) or Jujutsu (jj). Before performing VCS operations on a repository, it is important that you understand what kind of repository you are working with. You save the memory of this fact for future use.

## Identifying Repository Type

The following command will succeed if the repository is a `jj` repository, and fail if it is a `git` repository:

```bash
jj status > /dev/null 2>&1
```

Take note of this fact and persist this information throughout the session, including compactions.

## Using jj

Always invoke the `my-using-jj` skill before any jj operation and for any jj question, even if the answer seems obvious. It carries the jj mental model, commands, and the user's conventions and aliases that general jj knowledge does not cover — don't operate from memory of Git habits.
