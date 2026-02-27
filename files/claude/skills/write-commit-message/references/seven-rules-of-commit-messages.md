# How to Write a Git Commit Message

**Source:** [How to Write a Git Commit Message by Chris Beams](https://cbea.ms/git-commit/)

This is a summary of the seven rules and key principles from the above article.

---

## Why Great Commit Messages Matter

**"A commit message shows whether a developer is a good collaborator."** — Peter Hutterer

A well-crafted commit message communicates context about code changes to other developers and your future self. While diffs reveal _what_ changed, only commit messages explain _why_.

**Key insight:** The command `git log` with well-written messages provides a valuable long-term history that benefits debugging, code reviews, and understanding project evolution.

## The Seven Rules of a Great Git Commit Message

### 1. Separate subject from body with a blank line

The first line is the commit title, used throughout Git tools (log, shortlog, rebase, etc.). A blank line distinguishes the summary from detailed explanation.

**When to use body:**

- Simple changes may need only a subject line
- Complex changes require both subject and detailed body

**Command line example:**

```bash
git commit -m "Fix typo in introduction" -m "Corrected spelling of 'commit' in the opening paragraph."
```

### 2. Limit the subject line to 50 characters

This constraint forces concise, focused thinking about the essential change.

**Guidelines:**

- 50 is the **ideal target**
- 72 is GitHub's truncation threshold
- Think of it as writing a headline

### 3. Capitalize the subject line

Begin all subjects with a capital letter.

- ✅ "Open the pod bay doors"
- ❌ "open the pod bay doors"

### 4. Do not end the subject line with a period

Trailing punctuation wastes limited space and is unnecessary for subject lines.

- ✅ "Fix typo in user guide"
- ❌ "Fix typo in user guide."

### 5. Use the imperative mood in the subject line

Write as if giving a command or instruction.

**Examples:**

- ✅ "Refactor subsystem X for readability"
- ✅ "Update getting started documentation"
- ✅ "Remove deprecated methods"
- ❌ "Fixed bug with Y"
- ❌ "Changing behavior of Z"
- ❌ "More fixes for broken stuff"

**Why imperative?** Git itself uses imperative mood for auto-generated messages:

- "Merge branch 'myfeature'"
- "Revert 'Add the thing'"

**The test:** Your subject should complete this sentence:

> If applied, this commit will **[your subject line here]**

**Examples:**

- If applied, this commit will **refactor subsystem X for readability** ✅
- If applied, this commit will **update getting started documentation** ✅
- If applied, this commit will **fixed bug with Y** ❌

### 6. Wrap the body at 72 characters

Git does not wrap text automatically. Manual wrapping at 72 characters:

- Leaves room for Git's indentation (typically 4 spaces)
- Keeps total width under 80 characters for terminal readability
- Maintains formatting in various Git tools

**Configure your editor** to wrap at 72 characters for commit messages.

### 7. Use the body to explain what and why vs. how

The body should focus on:

- **What** problem existed before
- **Why** this change was necessary
- **What** approach was chosen and why
- Context that reviewers need

**Don't explain how** — the code shows that. Use comments for complex implementation details.

**Example of good body:**

```text
Summarize changes in around 50 characters or less

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of the commit and the rest of the text as the body. The
blank line separating the summary from the body is critical (unless
you omit the body entirely); various tools like `log`, `shortlog`
and `rebase` can get confused if you run the two together.

Explain the problem that this commit is solving. Focus on why you
are making this change as opposed to how (the code explains that).
Are there side effects or other unintuitive consequences of this
change? Here's the place to explain them.

Further paragraphs come after blank lines.

 - Bullet points are okay, too

 - Typically a hyphen or asterisk is used for the bullet, preceded
   by a single space, with blank lines in between, but conventions
   vary here

If you use an issue tracker, put references to them at the bottom,
like this:

Resolves: #123
See also: #456, #789
```

## Practical Recommendations

### Use the Command Line, Not IDEs

The Git command line interface provides full power and precision. While IDEs have Git integrations, they often abstract away important details and limit functionality.

### Learn Git Thoroughly

Read [Pro Git](https://git-scm.com/book/en/v2) (available free online) to understand Git's design philosophy and capabilities.

### Keep Commits Atomic

Small, focused commits often need less explanation than large, sprawling ones. If you find yourself writing a lengthy commit body, consider whether the commit should be split into multiple atomic changes.

### Think of Future Maintainers

Write commit messages for the person debugging this code at 2am six months from now. That person might be you.

## Summary

**Great commit messages:**

1. Separate subject from body with a blank line
2. Limit subject to 50 characters
3. Capitalize the subject line
4. Don't end subject with a period
5. Use imperative mood in the subject
6. Wrap body at 72 characters
7. Explain what and why, not how

Following these rules creates a readable, maintainable Git history that serves as valuable documentation for your project's lifetime.
