# write-commit-message

A Claude Code skill for writing well-formatted VCS commit messages.

## Intent

The skill applies to all VCS operations (`git`, `jj`, `sapling`, etc.) and covers the rules most likely to be violated in practice: subject length, imperative mood, blank-line separation, body wrapping, no implementation details, and no unprompted AI attribution.

## Rules derived from established standards

The rules in `SKILL.md` are distilled from two widely-adopted sources (summarized in `references/`):

- Chris Beams' *How to Write a Git Commit Message* — the seven rules
- Tim Pope's commit message template — formatting rationale and the 50/72 character constraints

The `references/` files are **not loaded as skill context**. They exist so the rationale behind each rule is preserved and traceable if the skill needs to be updated in the future.

## Mechanical validation via shell scripts

Claude cannot reliably count characters. The skill addresses this by requiring two scripts to run after every draft:

- **`count-lines.sh`** — prints the character count for each line of stdin, used to verify body wrapping at 72 characters
- **`lint-commit-message.sh`** — checks subject length (≤ 50), capitalization, trailing period, blank-line separation, escaped backticks, and `Co-Authored-By` presence

The `allowed-tools` frontmatter in `SKILL.md` restricts Claude to only these scripts during the skill, so no other shell commands can be run. Claude is instructed never to estimate character counts — always run the scripts and fix any errors before presenting the final message.
