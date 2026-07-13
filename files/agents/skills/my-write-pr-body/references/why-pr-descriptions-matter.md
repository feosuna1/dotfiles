# Why PR descriptions matter

Summary of research on the *purpose* a pull request description serves. Use this
to understand the "why" behind the spec rules.

## The core job: give the reviewer a mental model the diff can't

A diff shows *what* lines changed. It does not explain *why* the change was made
or what is materially different afterward. The description fills that gap. The
single highest-leverage thing an author can do is tell the reviewer what changed
and, more importantly, why — without that context even clean code gets
misread, and reviewers end up reverse-engineering intent from the diff, which is
slow and error-prone.

Source: James Croft, *A Guide to Making a Good Pull Request*
(<https://www.jamescroft.co.uk/a-guide-to-making-a-good-pull-request/>)

## Reviewers can already see "what" — they need "why" and "impact"

Multiple sources make the same point: the diff already communicates the
mechanics. What the reviewer needs from prose is the motivation and the impact
of the change. A description that merely restates the diff or the title adds no
value.

Sources:

- Azure Repos PR templates guide
  (<https://oneuptime.com/blog/post/2026-02-16-how-to-configure-azure-repos-pull-request-templates-for-standardized-code-review-submissions/view>)
- Hypertext Dispatches, *How to Write an Effective GitHub PR Template*
  (<https://tenthirtyam.org/dispatches/2026/04/04/how-to-write-an-effective-github-pull-request-template/>)

## A description is durable history, not just a message to today's reviewer

A PR description is read long after merge — by people debugging, onboarding, or
tracing why a decision was made. Authors should write as if anyone might read it
at any time, not only the current reviewer in the current context. This mirrors
the "permanent documentation" framing already used for commit messages.

Source: M. Kerem Keskin, *Good Manners of a Pull Request*
(<https://medium.com/deliveryherotechhub/good-manners-of-a-pull-request-some-best-practices-cb2de3c3aea1>)

## Well-structured descriptions feed downstream tooling

Beyond review, structured PR descriptions improve the quality of generated
release notes, changelogs, and activity reports. Tools that summarize git
activity produce far more useful output when the descriptions carry real context
instead of a one-line stub. This is a direct tie-in to the commit-messages
skill, whose output also feeds these artifacts.

Source: Gitmore, *Pull Request Template* (<https://gitmore.io/blog/pull-request-template>)
