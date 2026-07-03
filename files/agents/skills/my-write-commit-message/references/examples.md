# Worked Examples

**Example 1 — subject only (trivial change, no body needed):**

```text
Fix typo in onboarding email copy
```

**Example 2 — why + material difference:**

```text
Cache user permission lookups per request

Permission checks hit the database on every call, making hot endpoints
slow under load. Lookups are now memoized for the lifetime of a request,
so repeated checks are free and list endpoints respond noticeably
faster.
```

Note: no mention of *which* cache, file, or data structure — only why it was
needed and what's different now.

**Example 3 — backtick identifier + fixes:**

```text
Reject empty values for `apiKey` config

A blank `apiKey` silently disabled authentication instead of failing,
leaving deployments unexpectedly open. Startup now errors out when
`apiKey` is empty, so misconfiguration is caught before the service
accepts traffic.

Fixes: https://tracker.example.com/SEC-204
```

**Example 4 — trimming an over-length subject:**

Draft: "Add automatic retry logic to the payment webhook handler" (56) →
Trimmed: "Retry failed payment webhooks" (29), with the rest in the body.
