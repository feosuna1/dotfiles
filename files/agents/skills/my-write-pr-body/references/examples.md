# Worked Examples

**Example 1 — simple change, summary only:**

```text
Reject empty values for `apiKey` config

A blank `apiKey` silently disabled authentication instead of failing, leaving
deployments unexpectedly open. Startup now errors out when `apiKey` is empty, so
misconfiguration is caught before the service accepts traffic.
```

No "why" paragraph — the summary says everything. No mention of which file or
function changed; that's in the diff.

**Example 2 — summary plus a deeper why and links:**

```text
Cache permission lookups to speed up list endpoints

Permission checks hit the database on every call, making hot list endpoints slow
under load. Lookups are now memoized for the lifetime of a request, so repeated
checks are free and list endpoints respond noticeably faster.

This is the first of two steps toward the broader caching work; the cross-request
cache follows separately. Verified against the
[load-test profile](https://ci.example.com/runs/4821).

Fixes: https://tracker.example.com/PERF-318
```

The first line is the title; a blank line separates the summary, then the why,
then the `Fixes:` trailer. No headings, no labels, no fences in the real output —
a caller skill drops the title and the prose into its template's own sections.
The trailer is **aggregated from the commits**: every distinct `Fixes:` URL
across the PR's commit messages is collected and deduped here (one task in this
example), matching the trailer the commit-message skill produces, so the
convention carries from commit to PR. Context links like the load-test profile
stay in the why paragraph — only closing tasks go in the trailer.

**Example 3 — multiple concerns, advise splitting:**

When the work spans concerns, don't produce a description — produce advice, and
offer a per-concern draft so the user can act. Each draft is still just a title
line, a blank line, and prose (no labels, no fences):

> This branch does two unrelated things: it adds rate limiting to the webhook
> endpoint, and it switches the logging config to structured JSON. I'd split
> these into two PRs so each can be reviewed and reverted on its own. Drafts for
> each, if useful:
>
> **Rate limiting**
> Rate-limit the webhook endpoint to 60 requests per minute
>
> The webhook accepted unbounded traffic, leaving it open to floods. Requests are
> now capped at 60/min, so a single source can't overwhelm downstream processing.
>
> **Structured logging**
> Emit logs as structured JSON
>
> Plain-text logs were hard to query downstream. Logging now emits JSON, so
> aggregation can filter on fields instead of grepping free-form lines.
>
> If you'd rather keep them together I can, but the reviewer will be juggling two
> stories.
