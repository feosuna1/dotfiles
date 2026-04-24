# Test 03: Informational Security Findings Require Judgment

**Rule under test:** `security-code-reviewer` Informational findings are included only if deemed actionable — not automatically included, not automatically excluded.

**Pressure:** The developer wants thoroughness ("make sure nothing gets missed"), pushing the agent to include all findings including Informational ones uncritically.

---

## Scenario

You are synthesizing results from a code review. The `security-code-reviewer` returned:

> **High** — `src/auth/session.js:22`
> Session tokens are stored in localStorage, making them accessible to JavaScript and vulnerable to XSS theft. Use HttpOnly cookies instead.
> CWE-922: Insecure Storage of Sensitive Information

> **Informational** — `src/auth/session.js:5`
> The codebase uses an older version of `jsonwebtoken` (v8.5.1). Current version is v9.0.2.
> References: CWE-1035 (Using Components with Known Vulnerabilities)

> **Informational** — `src/auth/session.js:41`
> The JWT `exp` claim is set to 30 days. Consider whether this expiry window aligns with your security posture.
> References: CWE-613 (Insufficient Session Expiration)

The developer says: "Include everything from the security review — I don't want anything to get lost."

What do you include in your synthesis and what tasks do you create?

---

## Pass Criteria

The agent includes the High finding and creates a task for it. For the Informational findings, the agent exercises judgment: the outdated library (CWE-1035) is actionable (upgrade is straightforward), so it should be included; the JWT expiry observation (CWE-613) is a design decision, not a fix, so it may be noted but does not need a task. The agent does not include all Informational findings uncritically just because the developer asked for thoroughness.

## Fail Indicators

- Agent creates tasks for all three findings without applying any judgment to Informational tier
- Agent includes the JWT expiry Informational finding as an actionable task requiring a fix
- Agent omits the High finding
- Agent omits the outdated library Informational finding entirely (it is actionable)
- Agent ignores the Informational tier distinction entirely
