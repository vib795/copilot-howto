# Postmortem: <incident title>

- **Incident**: <inc-YYYYMMDD-short-name>
- **Severity**: sev0 / sev1 / sev2 / sev3
- **Duration**: <start> — <end> (<total minutes>)
- **Detected by**: alert / customer / manual check
- **IC**: role (anonymised — not an individual's name)
- **Author**: <this doc's author>
- **Date**: YYYY-MM-DD
- **Status**: Draft / Under review / Published

---

## Summary

One paragraph. What happened, how it was user-visible, how long it lasted, how it was resolved. Written for a reader who wasn't there.

---

## Impact

- Users affected: <number and/or percentage>
- Requests failed: <number>
- Revenue impact (if known): <range>
- SLO budget consumed: <percentage of the quarterly budget>
- Data loss: <yes / no — if yes, scope>
- Security implications: <yes / no — if yes, brief>

---

## Timeline

All times in UTC. Every line is a fact with a timestamp.

| Time | Event |
|---|---|
| HH:MM | <what happened> |
| HH:MM | <what happened> |
| ... | ... |
| HH:MM | Resolved |

Include:
- The triggering change, if there was one
- When the alert fired
- When humans responded
- Mitigations tried, successes and failures
- When the fix was applied
- When normal operation was confirmed

---

## Root cause

The sequence of causes that led to the incident, stated plainly. Use "5 whys" or similar.

> We shipped a bad query. Why? It wasn't in the test suite. Why? The test fixture was pre-populated, so the query returned results. Why didn't the staging canary catch it? Staging traffic is 1% of prod and the query only degraded above a certain row count. Why wasn't there an alert on the slow-query signal? ...

The root cause is the deepest one that is actually actionable.

---

## Contributing factors

Not the root cause, but things that made the incident worse or the recovery slower.

- <factor>
- <factor>

---

## What went well

- <thing>
- <thing>

Be specific. "The team responded quickly" is vague; "the on-call paged within 2 minutes and the IC was joined within 4" is useful.

---

## What went poorly

- <thing>
- <thing>

Things to look for:
- Missing alerts
- Misleading dashboards
- Runbooks that didn't apply or were wrong
- Tools that didn't work (kubectl RBAC, logging gaps, flaky CI)
- Communication failures
- Cognitive overload / too many people in the channel

---

## Action items

Each action item has an owner (team, not individual), a ticket, and a target date. Unassigned items don't ship.

| # | Action | Owner | Ticket | Target |
|---|---|---|---|---|
| 1 | Add alert on query p99 > X | @team | TCK-123 | YYYY-MM-DD |
| 2 | Add slow-query test case to CI | @team | TCK-124 | YYYY-MM-DD |
| 3 | Canary staging with replayed prod traffic | @team | TCK-125 | YYYY-MM-DD |
| 4 | Update runbook with this failure mode | @team | TCK-126 | YYYY-MM-DD |

Mix prevention, detection, and response:

- **Prevention** — stop this from happening again
- **Detection** — catch it faster if it does
- **Response** — respond better if it does

---

## Lessons

Short paragraphs, 3–5 maximum. The durable takeaways. Don't repeat the timeline here — extract the generalisable insight.

---

## References

- Incident channel: #inc-YYYYMMDD-...
- Dashboards at the time: links
- Related tickets: links
- Previous related incidents: links

---

## Reviewer signoff

- [ ] Engineering manager
- [ ] Service owner
- [ ] SRE lead
- [ ] (if security-relevant) Security team
