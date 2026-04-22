# Writing Skill Descriptions That Actually Trigger

The `description:` field is the only text Copilot reads when scanning skills for relevance. If the description is vague, the skill never loads. If it's too narrow, the skill misses obvious cases. This page is a recipe for descriptions that work.

---

## The principle

Write the description like a search engine query someone *would actually type*, not like a catalogue entry.

Bad (catalogue):
```yaml
description: "Helm deployment automation skill"
```

Good (query-language):
```yaml
description: >
  Use when the user asks to deploy, upgrade, roll back, or release a service to
  Kubernetes. Also triggers for questions about Helm chart values, image tags,
  release history, rollout status, canaries, or blue/green cutovers. Relevant
  phrases include: "deploy to staging", "bump the image", "rollback", "helm
  upgrade", "release", "promote to prod", "what image is in production".
```

Copilot matches natural-language intent against this string. The more the description resembles what your teammates actually say, the more reliably it triggers.

---

## The recipe

### 1. Start with "Use when..."

Signals to Copilot that this is a triggering condition, not a title.

```yaml
description: >
  Use when the user asks to ...
```

### 2. Enumerate verbs

List the verbs that describe the action: deploy, rollback, upgrade, audit, diagnose, investigate, plan, apply, review, fix, refactor.

### 3. List entities

What object is the action acting on? "service", "database", "cluster", "release", "image", "PR", "issue", "alert".

### 4. Include symptoms and error phrases

For debugging skills, include the literal error messages or symptoms users report:

```yaml
description: >
  Triggers on: CrashLoopBackOff, OOMKilled, ImagePullBackOff, readiness probe
  failing, "why is my pod crashing", "pod won't start".
```

### 5. Use the team's actual vocabulary

Not the canonical terms — the words your team actually uses. Include:

- Internal jargon ("ops queue", "the pipeline", "freshness")
- Informal phrasings ("push to prod", "ship it", "hotfix")
- System names your users say ("bump in release-tool", "deploy via Artifactory")

### 6. Keep it scoped

Don't try to be "the deploy skill for everything." One skill per verb-object pair. If helm and kubectl raw are both valid deploy paths in your org, that's probably two skills.

---

## Anti-patterns

### The single-word description

```yaml
description: "Deployment"
```

Too vague. Matches everything and nothing.

### The documentation description

```yaml
description: >
  This skill provides a comprehensive runbook for performing Helm-based
  deployments, including best practices for rollouts, observability
  considerations, and rollback procedures.
```

Reads like a blog post intro. No trigger phrases. Fails to match "how do I deploy?"

### The over-specific description

```yaml
description: >
  Use when deploying exactly version 2.3.4 of the payments service to the
  eu-west-1 production cluster with Helm chart revision 12.
```

Won't trigger on anything except that exact case. Keep descriptions about the *kind* of task, not the specific instance.

### The hyphenated keyword list

```yaml
description: "deploy upgrade rollback helm kubernetes"
```

Unnatural. Copilot matches against natural-language intent; a keyword salad doesn't resemble how users phrase requests.

---

## Testing a description

Two ways:

### Manual — ask Copilot

In chat, ask what skills are available for a phrase:

```
What skills apply to "I need to roll back the payment service to v2.2"?
```

If your `helm-upgrade` skill isn't listed, the description isn't matching.

### Automated — the discover script

From [Module 16 — Governance](../16-governance/README.md):

```bash
bash copilot-discover.sh "rollback payment service"
# Expected: shows helm-upgrade skill as a match
```

The discover script maps canonical task phrases to the skills that should handle them. If a reasonable phrase doesn't produce a match, fix the description.

---

## Multiple overlapping skills

If two skills both claim "deploy," Copilot may:

1. Load both (expensive, wastes budget)
2. Load the wrong one
3. Load neither

Fix:
- Make the descriptions mutually exclusive — one on "deploy", one on "rollback".
- Or merge into a single skill with one runbook covering both.

---

## Real-world examples from this module

| Skill | Triggering phrases |
|---|---|
| [helm-upgrade](./helm-upgrade/SKILL.md) | "deploy", "upgrade", "rollback", "bump the image", "promote to prod" |
| [debug-eks](./debug-eks/SKILL.md) | "pod crashing", "OOMKilled", "why is my pod in CrashLoopBackOff", "ImagePullBackOff" |
| [terraform-plan](./terraform-plan/SKILL.md) | "tofu plan", "terraform apply", "change the infrastructure", "state lock" |
| [incident-triage](./incident-triage/SKILL.md) | "production incident", "alert firing", "something is down", "postmortem" |

---

## Rule of thumb

After writing a description, ask: *"If I ran a keyword search for this description on my team's Slack, would it match the messages where people ask about this thing?"* If yes, ship. If no, rewrite.
