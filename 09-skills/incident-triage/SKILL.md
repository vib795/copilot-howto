---
name: incident-triage
description: >
  Use when an incident is in progress or was just resolved. Triggers on:
  production incident, alert firing, pager, on-call, outage, p0, p1, sev1,
  sev2, postmortem, retro, customers reporting, elevated error rate,
  "something is down", "we have an incident".
owner: "@org/sre-team"
classification: restricted
---

# Incident Triage and Response

Use this runbook during an active incident and in the hours after. The goals, in order: stop the bleeding, preserve evidence, communicate, learn.

## Phase 1: Establish reality (first 5 minutes)

### Confirm the incident is real

- What alert fired? Who reported it? When did it start?
- Is the signal trustworthy? (Flaky alerts exist. Customer reports don't.)
- Is this a single instance / region / customer, or broad?

Commands:
```bash
# Most recent alerts
kubectl get events -A --sort-by='.lastTimestamp' | tail -30

# Current error rate (PromQL example)
# curl prom -g '...' rate(http_errors_total[5m]) ...

# Known-failing services
# Check the error-rate / latency dashboards
```

### Declare severity

| Severity | Signal | Response |
|---|---|---|
| **sev0** | Complete outage of a paid product, data loss, security breach | Page exec on-call; all hands |
| **sev1** | Major feature broken for most users | Page service owner + SRE; incident channel |
| **sev2** | Minor feature broken or degraded | Service owner responds; async |
| **sev3** | Isolated user / non-critical | Normal ticket queue |

## Phase 2: Form the response (5–10 minutes)

### Open the incident

- Incident channel: `#inc-YYYYMMDD-<short-name>`
- Incident Commander (IC): one person, named out loud
- Communications Lead: one person (posts updates to stakeholders)
- Scribe: timestamps every decision and finding

The IC does NOT fix the issue. They coordinate. Rotate if the IC gets pulled in.

### Initial broadcast

Post to the incident channel and public status (if appropriate):

```
Incident opened [severity]
Summary: <one sentence of user-visible impact>
Detected: <timestamp>
IC: @<name>
Channel: #inc-...
Updates: every 15 min until resolved
```

## Phase 3: Diagnose and mitigate (while the fire burns)

### Golden question: what changed?

Most incidents are caused by a recent change. Check:

```bash
# Recent deploys for the affected service
helm history <release> -n <namespace>

# Recent merges
gh pr list --repo <org>/<repo> --state merged --limit 20

# Recent terraform applies
# (check your Atlantis / TFC / custom audit log)

# Feature flags changed in the last 24h
# (check LaunchDarkly / Unleash / your FF system)
```

If a change lines up with the incident start, roll it back. Don't diagnose a rollback you could have already done.

### Mitigate first, root-cause later

Acceptable mitigations in priority order:

1. **Roll back** the most recent change if it correlates in time
2. **Disable the feature flag** that gates the broken behaviour
3. **Fail over** to the healthy region / replica / cluster
4. **Shed load** — rate-limit abusive callers, reduce traffic
5. **Restart** the affected pods (only as a last resort — it's hiding a symptom)

Mitigation is judged by time-to-restore, not code quality. Ugly patches are fine during incidents.

### Do NOT during an active incident

- Do not run a long `terraform apply` "to fix it" — you're adding change on top of change
- Do not delete the evidence. Don't `kubectl delete pod` without first capturing logs:
  ```bash
  kubectl logs <pod> -n <ns> --previous > /tmp/inc-<pod>.log
  kubectl describe pod <pod> -n <ns> > /tmp/inc-<pod>.describe
  ```
- Do not speculate in the incident channel. Keep speculation in a DM or a thread labelled "hypothesis."
- Do not page everyone. Page who you need.

## Phase 4: Resolve and communicate

### Declare resolved

When:
- Error rate back to baseline for 10+ minutes
- Customers report working
- Alerts cleared (not just silenced)

Post:

```
Incident resolved
Duration: <start> - <end>
Root cause (preliminary): <one sentence>
Customer impact: <X users affected, Y requests failed>
Mitigation: <one sentence>
Followups: <ticket numbers>
Postmortem: <link to doc>, due <date>
```

## Phase 5: Postmortem (within 72 hours)

Use [postmortem-template.md](./postmortem-template.md). Key principles:

- **Blameless.** The incident is a failure of the system, not a person. Names appear only as "the on-call engineer" or similar.
- **Root cause analysis with at least 5 whys.** "Bug in deploy script" is not a root cause — why wasn't the bug caught? Why was the script changed? Why did we ship without a canary?
- **Action items have owners and dates.** Unassigned action items don't get done.
- **Action items include prevention AND detection.** Not just "fix the bug" — also "add the alert we needed to catch this."

Template highlights (see full file):

```
Summary
Impact
Timeline
Root cause(s)
Contributing factors
What went well
What went poorly
Action items
```

## Bundled resources

- [postmortem-template.md](./postmortem-template.md) — Postmortem template
- [runbook.sh](./runbook.sh) — Capture incident evidence (logs, pod state, recent events) in one command

## Escalation contacts

(Fill these in with your actual org's contacts.)

- **Platform on-call**: ...
- **Security incident**: ...
- **Customer communications**: ...
- **Legal / data-breach**: ... (mandatory for any suspected PII exposure)
