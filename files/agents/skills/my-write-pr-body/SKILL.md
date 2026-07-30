---
name: my-write-pr-body
description: >-
  Compose the title and description prose for a pull/merge request — host- and
  VCS-agnostic. Use this skill whenever the user is opening or updating a PR/MR,
  asks you to write or draft a PR description or title, asks "what should the PR
  say", or has a branch of commits ready for review. Other skills that open PRs
  should call this skill to generate the description content, then place it into
  whatever template the repo uses.
---

# Writing a PR description

A pull request description gives the reviewer the mental model the diff can't.
The diff shows *what* changed; the description explains *why* the change was
made and *what is materially different* afterward — for users, callers, or the
system. It is also durable documentation: it is read long after merge by people
debugging, onboarding, or tracing a decision, and it feeds PR review, release
notes, and changelogs.

This skill composes the **content** — a title and a description body in prose.
It is deliberately ignorant of templates and of how PRs get opened. Those are
the repo's concern: a project may carry its own PR template and its own
PR-opening workflow, and the skill that opens the PR is responsible for placing
this content into the right sections. Keep your output clean and
template-agnostic so any caller can slot it in.

## What you produce

Two things, nothing more:

1. A **title** — one line.
2. A **description body** — a short summary paragraph, optionally followed by a
   deeper "why" paragraph with links.

Emit them as raw text: the **title on the first line**, a blank line, then the
body as plain prose. Nothing wraps it — no `Title:`/`Body:` labels, no code
fences, no markdown headings (no `## Summary`, no `## Description`). Labels and
fences are scaffolding the caller didn't ask for, and headings are a property of
the destination template, which you don't own — imposing your own would collide
with the section names the caller places this under. A bare title plus prose is
equally pasteable when a human invokes the skill directly and trivially
placeable when another skill does. (The fenced blocks in the examples below are
only there to delimit each example for reading; your real output carries no
fences.)

## A PR is not a commit, and not a commit list

A PR aggregates commits. The description **synthesizes** them into one story; it
never pastes or enumerates the commit log. The author has the whole change fresh
in mind and is best placed to group the work by the concepts or problems it
solves, sparing the reviewer from reconstructing that structure from a list of
commits.

To synthesize well you need to see the actual change, not guess from the branch
name. Read the diff and the commit log for the PR's range using whatever
commands the repo's VCS provides (Git, jj, or another). Then describe the change
at the right altitude: the net outcome, not a file-by-file or commit-by-commit
walk.

**The single-commit exception.** When the PR contains exactly one commit, there
is no log to synthesize — the commit *is* the story. A well-written commit
message (subject as the title, body as the summary, its `Fixes:` trailer carried
through) is already a fine PR description, so reuse it rather than paraphrasing
it into something new. Still apply the title and body rules below — lengthen the
title toward the ~70-char target if the 50-char subject left detail behind, and
lift any code identifiers into backticks — but don't manufacture differences for
their own sake.

## Title

One line that names the **net outcome** of the whole PR, not its mechanics.

- **Imperative mood, no trailing period.** It completes the sentence *"If
  applied, this PR will…"* — so "Add email validation to signup", not "Added…"
  or "Adds…". This is the same spirit as a commit subject.
- **Soft target ~70 characters.** Hosts don't enforce the 50-char limit a commit
  subject lives under, so you have a little more room — but shorter is still
  better. Name the outcome; push detail into the body.
- **Name the outcome, not the symbol that changed.** "Cap oversized avatars on
  upload" reads better than "Cap avatars in `resizeAvatar`" — which file or
  function carries the change is a mechanic the reviewer finds in the diff.
  Backtick an identifier in the title only when it *is* the subject of the
  change (e.g. "Deprecate `LegacyClient`"), not to point at where you edited.
- **Backtick any code identifier** — class, method, type, config key, CLI flag.

## Body

Up to three parts, in order:

1. **Summary — 1–3 sentences.** State what is materially different now that the
   change is applied. Lead with the motivation *only when it isn't obvious* — a
   real problem (duplicated logic, a silent failure) earns the opening sentence.
   When the why is self-evident from the title or the domain (back-deploying a
   newer-OS API, a rename), lead with the change itself and let the motivation
   trail in a clause, or drop it; don't manufacture a problem sentence just to
   have one. This is the first thing a reviewer reads and often the only thing a
   future reader reads. Don't restate the title — earn the space with the
   *impact*, and with the *why* only when it adds information the title can't
   carry.
2. **Why — only when the summary can't carry it.** A further paragraph of deeper
   motivation, plus reference links: design docs or RFCs, related PRs, and a
   deploy/preview link if one exists. **Link, don't restate** — point rather
   than paraphrase. Omit this entirely when the summary already says everything;
   most PRs need only the summary.
3. **`Fixes:` trailer — the tasks this PR closes.** A PR closes whatever its
   commits close, so collect the `Fixes:` lines from every commit message in the
   PR's range, dedupe them, and emit them as a trailer block at the very bottom
   — one `Fixes: <url>` per line, after a blank line, matching the trailer the
   commit-message skill produces. If the user names a tracking task that the
   commits didn't reference, add it here too. Skip this block when no commit
   carries a `Fixes:` and the user supplies none.

The closing task(s) belong in the `Fixes:` trailer, not the why paragraph — keep
the why for context links (docs, related PRs, previews) so the two don't
duplicate.

## One concern per PR

A PR should address a single, cohesive change — describable in one sentence. If
the work spans unrelated concerns (a feature *and* an incidental refactor *and*
a typo fix), **don't paper over it with a description that joins them with
"and".** Tell the user the work should be split into separate PRs and name the
distinct concerns you see, so they can split cleanly. A description that needs
"and" to join unrelated changes is the signal.

## Size nudge (soft, advisory)

PR size is a property of the change, not the description, so there's no
line-count rule to enforce. But smaller PRs review better and catch more
defects, so when a change is clearly large or sprawls across concerns, surface a
gentle "consider splitting this PR" nudge — and, if you can see the seams, name
where it would split. Advisory only; the user decides.

## Always-on rules

- **No implementation mechanics in the summary or why.** Name outcomes, not the
  algorithm, library, or file-by-file approach. Include a mechanic *only* when
  it is materially necessary to understand the change.
- **Backtick code identifiers** — class, method, protocol, type, config key, CLI
  flag — in the title and body alike.
- **Link, don't restate** the tracking task and other references.
- **Keep it scannable.** Short, plain prose; cut filler and throat-clearing
  ("This PR…", "Basically…"). A reviewer should find answers in under a minute.
  An essay no one will read is as useless as no description at all.

## Anti-patterns to reject

- Restating the title in the summary.
- Pasting or enumerating the commit list instead of synthesizing it.
- An implementation play-by-play instead of the outcome.
- **Scope and sequencing notes** — "infrastructure only," "no callers yet," "the
  migration lands in [N]." A PR's place in a stack is carried by the stack map
  and the diff; don't narrate it in prose.
- **Exhaustive enumeration** — listing every call site or file of one kind
  instead of naming the category ("every alert call site"). Name a specific
  instance only when it carries risk the reviewer must know.
- **Narrating incidental changes** — a type constraint, an import, a mechanical
  rename that only removes boilerplate. Describe the core change and let the
  rest live in the diff; mention a secondary change only when it has a
  consequence a reviewer would act on (e.g. a shrunk public API surface).
- Imposing your own section headings — leave structure to the destination
  template.
- An essay no reviewer will read.

## Workflow

1. **See the change.** Read the diff and commit log for the PR's range using the
   repo's VCS commands. Synthesize the story; don't lean on the branch name. If
   there's exactly one commit, reuse its message (see the single-commit
   exception) rather than rewriting it.
2. **Check scope.** If it's more than one concern, advise splitting and name the
   concerns before drafting. If it's large but cohesive, note the soft size
   nudge.
3. **Collect the `Fixes:` trailers** from every commit message in the range,
   dedupe them, and add any closing task the user named that the commits missed.
4. **Draft the title.** Imperative, ~70 chars, net outcome, backtick
   identifiers.
5. **Draft the summary** (1–3 sentences: lead with the change, or with the
   problem when it's substantive — see Body), then a **why** paragraph only if
   the summary can't carry the motivation and context links, then the `Fixes:`
   trailer block at the bottom if step 3 found any.
6. **Present the title and body** as raw text — title on the first line, blank
   line, then the body prose, then the trailer. No `Title:`/`Body:` labels, no
   code fences, no headings; ready for a human to paste or a caller skill to
   place into its template.

## Examples and sources

Worked examples — summary-only, summary plus why and links, and the
advise-splitting response — live in
[references/examples.md](references/examples.md); read them when a draft feels
off-pattern. The remaining references are sourced background, not extra rules —
the operational guidance above already distills them. Read
[why PR descriptions matter](references/why-pr-descriptions-matter.md),
[writing best practices](references/writing-best-practices.md), or
[structure and templates](references/structure-and-templates.md) only when you
need the cited rationale behind a rule (e.g. to justify splitting a PR to a
skeptical author); [sources.md](references/sources.md) lists what they distill.
