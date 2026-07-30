---
name: my-human-voice
description: >-
  Write prose in the user's own voice — email, Slack messages, commit messages,
  PR descriptions and comments, review feedback, or anything else sent to other
  people under their name. Use this skill whenever you are drafting text the
  user will send as themselves, including when another skill asks you to
  produce that prose. Defines the voice, plain-language rules, what to cut,
  structure, formatting, and register by context. Not for in-session replies.
---

# Human Voice

This is prose sent under the user's name. For how you talk to the user
in-session, see `output-style` — a different voice than this one.

## Voice

Engineer who's direct but humble. Own opinions, state them cleanly, don't pad.
Keep subjects and articles — "I think we should X" not "thinking we should X";
"The logic looks solid" not "Logic looks solid". Say "I think" / "I believe"
only when genuinely uncertain.

When a recommendation is landed, commit to it: "X is the right choice," not "X
is a good fit" / "could work" / "might help" / "I'd lean X." Weasel verbs are
worse than no recommendation.

## Plain language

Write it the way you'd say it across a table. Everyday words, short sentences,
a real person doing a real thing in each one.

**Short sentences.** Average 15–20 words in anything written out — docs, email,
technical Slack. One main idea per sentence, plus at most one related point.
Don't make every sentence the same length — mix a short one in with a longer
one. When a sentence runs long because the point is complicated, break it up.
Casual Slack runs shorter than this; see Register.

**Active verbs, ~80–90% of the time.** "We will consider this shortly," not
"this matter will be considered by us." "The migration broke the build," not
"the build was broken by the migration." Passive earns its place in three
cases: softening something hostile, when you genuinely don't know who did it,
or when it plainly sounds better. Never to dodge blame — own the mistake (see
the bad-news rule under Structure).

**Say "you" and "we."** Address the person, not their role: "You need to send
us the token," not "applicants must send the token." Your team is "we." Mixing
"we" and "I" in the same message is fine.

**Give instructions as instructions.** "Restart the worker," not "the worker
should be restarted" or "I'd be grateful if you would restart the worker."
Commands are the shortest, clearest form. "Please" softens one when you want
it softer — but drop it when the thing isn't optional, since it invites a no.

**No nominalizations.** Use the verb, not the noun made from it: "We discussed
the rollout," not "we had a discussion about the rollout"; "A team implemented
it," not "the implementation was done by a team." Watch for *-tion*, *-ment*,
*-ance*, *-al*: completion, arrangement, provision, failure, removal.

**Ignore the fake grammar rules.** Start a sentence with "And," "But," or
"Because" when it reads better. Split infinitives. End on a preposition. Repeat
a word rather than reaching for a worse synonym. Avoid "So," as an opener — it
is the one that stays out.

## Cut

Filler qualifiers: just, really, somewhat, kind of, sort of, a bit, a little.
Drop "concrete" and "clear" when they add nothing.

Fancy words, use plain ones: "give a strong reason" over "articulate a concrete
reason"; "answer" over "solution"; never "articulate," "utilize," or "leverage."

Long word (plain word) — reach for the one in parentheses:

- additional (extra), advise (tell), commence (start), comply with (follow)
- consequently (so), ensure (make sure), in excess of (more than)
- in the event of (if), prior to (before), purchase (buy), regarding (about)
- terminate (end)

Well-defined jargon is fine. A term with a settled meaning in the field —
idempotent, backpressure, p99, cache invalidation — is shorthand the reader
already holds, and spelling it out wastes their time. Use it with people who
share it; spell it out the first time when you're not sure they do.

Invented jargon and metaphors are not. A phrase you coined on the spot carries
no shared meaning, so the reader has to reverse-engineer it — "spending floor,"
"the paved road," "let's socialize this." Say the plain thing instead: "the
amount already spent," "the supported setup," "let's get feedback on this."
The test is whether the term means the same to the reader as it does to you.

Banned phrases: "circling back," "just checking in," "hope this finds you well,"
"wanted to reach out"; "So," at the start of a sentence; performative warmth.

## Structure

Open with the point. No prose-y setup ("Looking back at…"), no passive or
abstract openers ("One thing nagging me…"). Name the thing and state it: "I have
a concern about the pattern."

Technical feedback runs: brief acknowledgment → concerns one per paragraph with
the "why" → a question only if genuinely unsure. When you ask and then
recommend, break them into separate paragraphs.

End on your point. Don't trail it with softening, self-undermining, or
evaluative codas — if the facts carry it, don't stack judgment on top. Let
questions stand alone.

For trade-offs, use decision-tree framing: "It depends. If X, I'd do A. If Y,
I'd do B. If Z, skip it."

On bad news and incidents, use active subjects: "We can't meet the date and I
need to move it" — not "the date is slipping"; "I deployed a change that
caused…" — not "a change was deployed." Personal stakes are fair ("I'd be
embarrassed to ship this"). Invite disagreement warmly: "Let me know if you
disagree, happy to chat."

## Formatting

Backticks for code (`List<X>`, `gpg`). Em dashes for asides. Parentheticals with
"e.g.," not "like" or "such as." Greetings: "Hi" or "Hiya," never "Hey." No
multiple exclamation points; no emoji beyond `:D`.

For inline lists, separate items with commas and an Oxford "and" before the last
— "A, B, and C." When items contain their own commas, separate with semicolons
instead, with "; and" before the last.

Break a set of points out into a bulleted list when the sentence would strain to
hold them. Use bullets, not numbers or letters, unless the order or a later
reference to "step 3" actually matters — a number is one more thing to read.
Every bullet has to follow grammatically from the line introducing it; read the
intro straight into each point and check that it still parses. Points that are
full sentences take a capital and a period. Points that continue the intro line
stay lowercase, end with a semicolon, and put "; and" (or "; or") on the
second-to-last one.

## Register

Shifts by context:

- Technical docs and postmortems: headers, structured paragraphs, numbered
  lists, backticks, active subjects.
- Technical Slack: investigative prose with backticks, light hedging only when
  genuinely uncertain.
- Casual Slack/DMs: short bursts, one thought per line, lowercase fine, dry
  satire, `:D` is the only emoji.
- Personal: can be edgier, satirical, crude.

## Examples

Good (code review): "The logic looks solid. I have a concern about the pattern
you chose for `X`, but I can't give you a strong reason why. Can you share your
rationale?"

Bad: "Logic looks great! Just wondering, and I could be wrong, but I was
thinking maybe there might be a small issue with the pattern. Just flagging!"

Good (trade-off): "It depends. If the latency is from DB reads on stable data,
caching is the right choice. If it's a downstream call, caching insulates you
from their outages. If the endpoint is fast enough already, skip it."

Bad: "Caching could potentially be a good fit here, though it might depend on
various factors."

Good (bad news): "Hi [Name] — we can't meet the ship date and I need to move it
to [new date]. I ran into two problems: [A], and [B]. I considered [alternative]
but it's a bad user experience and I'd be embarrassed for customers to use it.
Let me know if you disagree, I'm happy to chat."

Bad: "Just a quick update — the timeline is slipping a bit. We might need to
push the date. Let me know your thoughts!"

Good (casual): "hey, saw the thing. wild that it still works."

Bad: "Hi! Just saw the update, that's really exciting! 🎉"
