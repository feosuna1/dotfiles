# Codex Harness Workflow

How to operate within Codex's tool limits: context budget, tool discovery,
subagent orchestration, and model economy. The shared rules define what good
work looks like; this guide defines how Codex should run that work without
wasting context, approvals, or premium model calls.

## Context budget

**Slice large artifacts before reading them.** Use `rg`, `sed`, `head`, `tail`,
or targeted file reads to inspect the lines that matter first. Read a whole log,
generated file, or large diff only after the slice proves insufficient.

**Keep returned agent output small.** When delegating, ask for actionable
findings only, with file:line evidence and no broad summaries. The parent pays
for every returned token.

## Tool discovery

**Use `tool_search` for deferred Codex capabilities.** When a workflow mentions
a Codex tool that is not already visible, search for it first instead of
guessing its schema or falling back to shell workarounds. This applies to
multi-agent tools, thread tools, automations, workspace agents, browser control,
Sites, and app connectors.

**Prefer the smallest durable surface.** Use a prompt for one-off constraints,
`AGENTS.md` for repo conventions, a skill for reusable workflows, a custom agent
for a specialized role, and a plugin only when a bundle needs skills plus tools,
hooks, commands, or assets.

## Subagent orchestration

**Use subagents only when the user or invoked workflow asks for delegation.** A
request to run `my-code-review`, `my-code-review-fix-loop`, or another
explicitly multi-agent skill counts as that delegation request. Otherwise, offer
the review/fan-out as an option rather than silently spawning agents.

**Do the blocking step locally.** Before delegating, identify what you can do
now without waiting. Delegate independent sidecar work: domain review, one
claim validation, a disjoint code-edit slice, or a bounded exploration question.

**Keep subagent prompts narrow.** Give each agent one role, the relevant files or
diff slice, the exact output contract, and a cap such as "return only confirmed
findings." Do not hand a validator the whole review transcript; give it one
claim and the code needed to refute or confirm it.

## Model economy

**Do not let fleets inherit a premium session model by accident.** Use custom
reviewer agents for their domain expertise. For high-volume narrow validators,
per-file sweeps, and mechanical fixes, choose the cheapest capable Codex model
or reasoning effort the tool exposes. Reserve the premium session model for the
parent's synthesis and final judgment.

**Treat fixed-model custom agents as expensive finders.** If a Codex custom role
is pinned to a frontier model, use it for the first-pass domain review where the
miss cost matters. Use cheaper default, explorer, or worker agents for narrow
validation when the harness permits a model override.

## Review and fix loops

**Finders, validators, and fixers stay independent.** A reviewer that produced a
claim should not validate it, and a validator should not be the fixer. If the
harness cannot provide independent agents, validate inline one claim at a time
and state that validation was not independent.

**Stop loops before they sprawl.** Review/fix loops should run on the current
diff, apply the smallest confirmed fixes, verify, and stop after the configured
dry round or iteration cap. Report anything still subjective or low-confidence
instead of auto-fixing taste.
