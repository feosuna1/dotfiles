# Writing and scoping best practices

Summary of research on *how to write* the description and *how to scope* the PR
itself. Use this to justify the always-on rules in the spec.

## One concern per PR (single responsibility)

A PR should address a single, cohesive change. Don't fold in unrelated typo
fixes or a small bug fix riding along with a feature. Keeping one concern per PR
makes the intent describable in a sentence, prevents one change from blocking an
unrelated one, and keeps the history clean. This is the same single-responsibility
rule the commit-messages skill applies at the commit level.

Sources:
- M. Kerem Keskin
  (https://medium.com/deliveryherotechhub/good-manners-of-a-pull-request-some-best-practices-cb2de3c3aea1)
- Hugo Dias, *Pull Requests Best Practices*
  (https://hugodias.substack.com/p/pull-requests-best-practices)

## Smaller PRs review better

Smaller diffs yield better defect detection and don't block dependent work. One
widely cited Cisco study found that reviewing roughly 200–400 lines over 60–90
minutes yields a high defect-discovery rate, which several authors translate into
a soft target of a few hundred lines changed per PR. The number is a guideline,
not a hard rule — it varies by language and framework — but the underlying point
is to bias toward small, and to let the template nudge authors to split when a
change grows large.

Source: Hugo Dias (https://hugodias.substack.com/p/pull-requests-best-practices)

Note for the spec: PR *size* is a property of the change, not the description.
The skill can surface a gentle "consider splitting" nudge but shouldn't try to
enforce a line count.

## Describe at the right altitude — guide, don't dump

The best descriptions guide the reviewer through the change, grouping files into
the concepts or problems they solve, rather than listing every file or pasting
the commit log. The author is best placed to do this grouping because the work is
fresh in their mind, and it saves the reviewer from reconstructing structure
themselves. For a PR that aggregates many commits, synthesize the overall story
rather than concatenating commit messages.

Source: Atlassian, *The Unwritten Pull Request Guide*
(https://www.atlassian.com/blog/git/written-unwritten-guide-pull-requests)

## Plain prose beats ceremony

The summary doesn't need to be technical or elaborate — a clear, plain-language
synopsis of the net effect of the change is usually enough. Lead with the effect
and motivation; save deeper technical notes for later sections only if they help
the reviewer.

Source: HackerOne, *Writing A Great Pull Request Description*
(https://www.hackerone.com/blog/writing-great-pull-request-description)

## Keep instructions out of the rendered output

When templates embed guidance, they use HTML comments (`<!-- ... -->`) so the
rendered PR reads as clean content rather than a half-filled form. The skill's
output should be finished prose, not a template with leftover prompts.

Source: Azure Repos guide
(https://oneuptime.com/blog/post/2026-02-16-how-to-configure-azure-repos-pull-request-templates-for-standardized-code-review-submissions/view)
