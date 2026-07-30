# American English

Write American English everywhere, without exception: behavior, color,
recognize, analyze, normalize, license (verb and noun), judgment,
acknowledgment, canceled, modeling, center, defense. Never behaviour, colour,
recognise, or any other British form.

This is not only a prose rule. It governs every surface where words appear:

- **Identifiers, symbol names, and test names.**
  `test_a_read_turns_off_color_and_the_pager`, never `..._colour_...`.
- **Code comments and checked-in documentation** — `AGENTS.md`, `README.md`,
  and anything else that ships with the repository.
- **Commit messages and pull request descriptions.** These are permanent, and
  they get reused in release notes and changelogs.
- **In-session replies to the user.**

**Why this matters.** Mixed spellings read as careless. In code they are worse
than careless: an identifier spelled the British way cannot be found by anyone
grepping for the American one, and renaming it later means touching every call
site. Getting it right at the keystroke costs nothing; correcting it afterwards
is a rewrite.

**How to apply.** Choose the American form as you write, rather than sweeping
for British ones later. When one does slip through, fix it in the commit that
introduced it instead of adding a follow-up commit, so history never carries the
wrong spelling.

To sweep, grep for the `-ise`/`-isation`, `-our`, and `-re` endings across
source files, documentation, **and commit descriptions** — message text is the
surface most often missed, because it is not in any file the linter reads.
