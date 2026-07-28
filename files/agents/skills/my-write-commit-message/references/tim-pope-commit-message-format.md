# A Note About Git Commit Messages

**Source:** [A Note About Git Commit Messages by Tim
Pope](https://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)

This is a summary of the commit message formatting guidelines from the above
article.

---

## The Template

Tim Pope provides a widely-adopted commit message template:

```text
Capitalized, short (50 chars or less) summary

More detailed explanatory text, if necessary. Wrap it to about 72
characters or so. In some contexts, the first line is treated as the
subject of an email and the rest of the text as the body. The blank
line separating the summary from the body is critical (unless you omit
the body entirely); tools like rebase can get confused if you run the
two together.

Write your commit message in the imperative: "Fix bug" and not "Fixed bug"
or "Fixes bug." This convention matches up with commit messages generated
by commands like git merge and git revert.

Further paragraphs come after blank lines.

- Bullet points are okay, too

- Typically a hyphen or asterisk is used for the bullet, preceded by a
  single space, with blank lines in between, but conventions vary here

- Use a hanging indent
```

## Formatting Rules

### Subject Line

**Length:** Target ~50 characters maximum

**Capitalization:** Start with a capital letter

**Mood:** Use imperative ("Fix bug" not "Fixed bug" or "Fixes bug")

**Rationale for imperative:** This convention matches commit messages generated
by Git commands like `git merge` and `git revert`, which use imperative mood:

- "Merge branch 'feature'"
- "Revert 'Add the thing'"

**Critical:** Always follow the subject with a blank line (unless there's no
body)

### Body Text

**Wrapping:** Wrap at ~72 columns

**Paragraphs:** Separate with blank lines

**Bullets:** Acceptable using hyphens or asterisks

- Preceded by a single space
- Use blank lines between items
- Use hanging indent for multi-line items

## Why These Rules Matter

### The Subject/Body Distinction

The subject line appears throughout Git's ecosystem:

- `git log --pretty=oneline` - shows only subject lines
- `git rebase --interactive` - displays subjects for picking commits
- Merge summaries - uses subject as the merge description
- `git format-patch` - subject becomes email subject line
- Changelogs - typically generated from subject lines
- GitHub interface - shows subject in commit lists and PR descriptions

**Impact:** This distinction makes "Git history so much more pleasant to work
with than Subversion."

### The 72-Column Rule

**Technical reason:** `git log` doesn't automatically wrap commit messages.

**Terminal context:** On standard 80-column terminals, 72-column text leaves
room for:

- Left indentation (4 spaces for `git log`)
- Right margin for readability
- Email reply indicators (`>` characters) when commits become patches

**Email workflow:** When using `git format-patch` to convert commits into
emails, proper wrapping maintains readability through multiple reply levels:

```text
> > > Original text at 72 columns
> > > still fits within terminal width
> > > with multiple reply indicators
```

Without proper wrapping, text flows off-screen and becomes unreadable in email
threads.

## Practical Application

### Setting Up the Template

Save the template to a file and configure Git to use it:

```bash
git config --global commit.template ~/.gitmessage.txt
```

Now `git commit` opens your editor with the template pre-populated.

### Editor Configuration

Configure your editor to wrap at 72 columns for commit messages:

**Vim:** Add to `.vimrc`:

```vim
autocmd Filetype gitcommit setlocal spell textwidth=72
```

**Emacs:** Git commit mode typically handles this automatically

**VS Code:** Set `git.inputValidationLength` and enable `editor.wordWrap`

## Why This Format Became Standard

Tim Pope's template became influential because it:

1. **Codifies existing Git conventions** (imperative mood matches Git's own
   messages)
2. **Explains the rationale** (not just rules, but why they matter)
3. **Provides practical constraints** (50/72 limits with technical
   justification)
4. **Acknowledges workflow reality** (terminal width, email patches, tooling
   integration)

The format works because it aligns with how Git actually uses commit messages
across its command set and integrates with common developer workflows (email,
terminal, code review).

## Key Takeaways

1. **50-character subject** - forces concise thinking, works in all Git tools
2. **Blank line separation** - critical for tools like `git rebase` and `git
   format-patch`
3. **72-column body** - readable in terminals, emails, and with reply indicators
4. **Imperative mood** - consistency with Git's own generated messages
5. **Subject line is the API** - used everywhere in Git's ecosystem
6. **Body explains context** - what and why, using paragraphs and bullets as
   needed

This format has become the de facto standard for Git commit messages across the
open-source community.
