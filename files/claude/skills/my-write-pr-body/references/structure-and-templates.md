# Structure and template sections

Summary of research on *what sections* a PR description should contain. Use this
to justify the section list in the spec.

## The recurring core: Summary + Testing

Across templates from GitHub, Azure DevOps, and independent guides, two sections
appear almost universally:

- **Summary** — what changed and why, in prose. Widely described as the most
  important section and the first thing reviewers read. It should make the diff
  legible, not restate the title.
- **Testing** — what the author ran and how a reviewer can verify the change.
  Treated as near-mandatory; its absence is a common cause of review back-and-forth.

Sources:
- Hypertext Dispatches
  (https://tenthirtyam.org/dispatches/2026/04/04/how-to-write-an-effective-github-pull-request-template/)
- Willow Voice, *Write Good PR Descriptions*
  (https://willowvoice.com/blog/how-to-write-good-pull-request-description)
- CodeAnt, *Azure DevOps PR Template Examples*
  (https://www.codeant.ai/blogs/azure-devops-pull-request-template-examples)

## Context / links section, placed early

A short block of links — the tracking task (Jira/Asana/etc.), design docs, RFCs,
related PRs, and a deploy/preview link — gives reviewers a path to go as deep as
they need without asking the author. One guide recommends putting these links at
the very top because they get referenced repeatedly during review. Importantly,
link the tracking task rather than restating its contents, and keep
tutorial/reference links out of this section (those belong with implementation
notes if anywhere).

Sources:
- Ashlee M. Boyer, *An Undefeated Pull Request Template*
  (https://ashleemboyer.com/blog/pull-request-template/)
- James Croft (https://www.jamescroft.co.uk/a-guide-to-making-a-good-pull-request/)

## Optional sections, included only when they carry weight

Depending on the change type, useful additional sections include:

- **Reviewer guidance** — where to start, how files group into concepts, what to
  focus on. Especially valuable for larger PRs; can be nearly as helpful as
  splitting the PR.
- **Risk / rollback** — for risky, infrastructure, or migration changes.
- **Config / migration callouts** — deploy-time steps, migration ordering, and
  new secret *names* (never the secret values).
- **Screenshots / visuals** — for UI changes.

Sources:
- Atlassian, *The Unwritten Pull Request Guide*
  (https://www.atlassian.com/blog/git/written-unwritten-guide-pull-requests)
- minware, *10 PR Template Sections*
  (https://www.minware.com/blog/effective-pr-template)
- freeCodeCamp, *How to Write a Good PR Description*
  (https://www.freecodecamp.org/news/how-to-write-a-pull-request-description/)

## Keep it lean and omit empty sections

A consistent warning: templates should not become forms full of empty headers.
Keep prompts short, keep the rendered result scannable (a reviewer should find
answers in under a minute), and drop sections that don't apply rather than
leaving placeholders. Start with a minimal structure and only add sections when a
real, repeating need justifies them.

Sources:
- minware (https://www.minware.com/blog/effective-pr-template)
- Azure Repos guide
  (https://oneuptime.com/blog/post/2026-02-16-how-to-configure-azure-repos-pull-request-templates-for-standardized-code-review-submissions/view)
