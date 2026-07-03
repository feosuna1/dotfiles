# Harness Workflow

How to operate within the tool's limits — context budget and subagent
orchestration. The code and design rules govern *what* to build; these govern
*how to run the session* so long, ambitious work doesn't collapse on
infrastructure limits. Earned from sessions that stalled on token ceilings and
watchdog timeouts, not from anything wrong with the code.

## Context budget

**Slice large artifacts before reading them.** Never paste or Read a whole CI
log, build output, or large file into context to diagnose one failure. Grep the
signal-bearing lines first — `grep -iE 'error|fail|linker|undefined' build.log |
tail -50` — diagnose from that slice, and widen only when the slice is
genuinely insufficient. Reading the whole thing to "be safe" is how a session
hits "Prompt is too long" and dies mid-task with the failure still unresolved.

**Report findings incrementally and chunk big analyses.** For a large diagnosis
or audit, summarize as you go rather than accumulating the full raw input in
context. When an analysis is large enough that it would fill the window on its
own, start it in a fresh session instead of appending it to a long one — a
mid-task context collapse loses more than the restart costs.

## Subagent orchestration

**Scope each subagent tight and cap its output.** When fanning out parallel
agents (per-commit reviews, multi-file sweeps), give each a narrow task and tell
it to return only actionable findings, kept short. A broad, open-ended agent
prompt produces verbose output that eats the parent's context on return and
risks the agent running long enough to trip the watchdog.

**Prefer many small agents over few long ones, and run fewer at once.** Large
parallel fleets stall at the 600s watchdog and force a slow inline fallback that
defeats the point of fanning out. If a fleet is at risk of the watchdog, split
the work into smaller units rather than raising ambition per agent. Several
tightly-scoped agents that each finish quickly beat one long-running agent that
times out.

## Model economy

**Match each subagent's model tier to its task; don't let fleets inherit a
premium session model.** A subagent spawned without an explicit `model` inherits
the session's — so a fleet dispatched from an Opus- or Fable-class session pays
the premium rate per agent for work a cheaper tier does as well. Narrow,
falsifiable, single-claim work (validators, per-file sweeps, mechanical fixes)
goes to the cheap tier (`haiku`); scoped code-writing and per-round
orchestration to the mid tier (`sonnet`); reserve the session's premium model
for the judgment the fleet reports back to.

**The cheap tier carries a smaller context window** (Haiku: 200k vs 1M
elsewhere), so cheap-tier agents must get sliced inputs — one claim, one file,
one commit's diff — never the whole log or diff. This is the same slicing the
context-budget section demands, with a second reason it can't be relaxed.

**Pick the session model by the work's horizon, not by habit.** Drive
orchestration-heavy skills (code review, fix loops) from a mid-tier session —
the driver is procedural and its subagents carry their own tiers. Step up to a
premium session for design, long-horizon agentic work, and cross-cutting
reasoning where the extra capability changes the outcome.

## Review and fix loops

**Finders, validators, and fixers stay independent.** A reviewer that produced a
claim should not validate it, and a validator should not be the fixer. If
independent agents aren't available, validate inline one claim at a time and
state that validation was not independent.

**Stop loops before they sprawl.** Review/fix loops run on the current diff,
apply the smallest confirmed fixes, verify, and stop at the configured dry round
or iteration cap. Report anything still subjective or low-confidence instead of
auto-fixing taste.
