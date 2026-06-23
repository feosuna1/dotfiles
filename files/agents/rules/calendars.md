# Calendars and Dates

Date and time work is easy to get subtly wrong — stale context dates, mental arithmetic, and assumed timezones all produce confident, wrong answers. Verify, compute, and confirm the zone before acting.

**Verify the current date from the system before anything date-sensitive.** Run `date +%Y-%m-%d` (or `date` for the time) rather than trusting a date from earlier in the conversation, a prior note, or the `currentDate` system-reminder — those go stale. Acting on the wrong day means querying the wrong calendar or editing the wrong daily note. Check first, then proceed.

**Compute calendar math; don't do it in your head.** Any date arithmetic — day of week, week number, offsets, durations, ranges, "N days/business days from X" — goes through a script run in place (e.g. `python3 -c "..."`) so the answer is computed and verifiable, not guessed. Mental date math is a frequent source of off-by-one and wrong-weekday errors.

**Confirm the timezone before calendar operations.** Before reading or writing calendar events (e.g. checking Google Calendar) or scheduling anything, check the current timezone from the system (`date +%Z` and `date +%z`) rather than assuming a fixed one — the user travels, so a hardcoded zone misplaces every event. Interpret and display event times in the user's current local timezone, and state the zone explicitly when it could be ambiguous.
