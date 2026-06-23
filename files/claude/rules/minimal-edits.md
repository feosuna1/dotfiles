# Minimal Edits

When asked to change specific things, change only those things. Don't rewrite or restructure surrounding logic, swap in a different approach, rename, reformat, or add patterns and abstractions that weren't requested. The working code you weren't asked to touch is working — leave it alone.

**Why this matters.** Edits that reach beyond the request overwrite decisions the user already made, bury the change they actually wanted in unrelated diff noise, and risk breaking code that was fine. A reviewer (and the user) should be able to look at the diff and see exactly the requested change, nothing more. "While I was in there I also…" is how a one-line fix becomes a regression.

**When a proper fix genuinely needs broader changes**, surface that as a tradeoff and let the user decide before you make it — don't silently take the larger path. State what the minimal change would be, what the fuller change would be, and why you'd lean one way. This is the same principle your code reviews follow: *flag* the improvement, don't *impose* it. Spotting a better structure nearby is worth mentioning; rewriting it uninvited is not.

**How to apply.** Read the code, identify the smallest edit that satisfies each requested change, and make only those edits. If a requested fix appears to require restructuring, stop and raise it rather than expanding scope on your own. Match the surrounding style rather than imposing your own.
