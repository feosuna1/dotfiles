# Version Control

Project repositories may use either Git (git) or Jujutsu (jj). Before performing VCS operations on a repository, it is important that you understand what kind of repository you are working with. You save the memory of this fact for future use.

## Identifying Repository Type

The following command will succeed if the repository is a `jj` repository, and fail if it is a `git` repository:

```bash
jj status > /dev/null 2>&1
```

Take note of this fact and persist this information throughout the session, including after context is compacted or summarized.

## Using jj

Always invoke the `my-using-jj` skill before any jj operation and for any jj question, even if the answer seems obvious. It carries the jj mental model, commands, and the user's conventions and aliases that general jj knowledge does not cover — don't operate from memory of Git habits.

## Committing hygiene

- **One concern per commit; every commit compiles and is reviewable on its own.** Split mechanical moves (a compilation fix, a rename, a file move) from behavior changes. Verify an earlier commit by checking it out and running its tests. A building-block commit ships next to its first consumer — a model with no consumer reads as a floating abstraction.
- **Track follow-ups as tasks, never as `// TODO` comments.** Code TODOs are unwanted (automation may block them). Capture the follow-up as a task instead.
- **Stage changes as a reviewable diff, don't amend a target commit directly.** In jj, put the changes in an empty child commit the user can review and squash themselves. Empty or undescribed commits are fine — don't feel compelled to describe every one. Don't create branches unprompted.
- **Split large PRs by reviewer domain.** When a change spans domains (logic vs. UI), look for clean seams to break it into smaller PRs so each reviewer sees only their domain.
