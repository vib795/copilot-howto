---
name: helm-upgrade
description: >
  Use when the user asks to deploy, upgrade, roll back, or release a service to
  Kubernetes. Also triggers for questions about Helm chart values, image tags,
  release history, rollout status, canaries, or blue/green cutovers. Relevant
  phrases include: "deploy to staging", "bump the image", "rollback", "helm
  upgrade", "release", "promote to prod", "what image is in production".
owner: "@org/platform-team"
classification: internal
---

# Helm Upgrade — Runbook

Use this runbook whenever you're changing a running service on Kubernetes via Helm. The goal is: never break prod, always be able to roll back in under 2 minutes, and always have a record of what changed.

## Prerequisites

Before starting, the user needs:

- `helm` v3.12+ (`helm version`)
- `kubectl` configured for the target cluster (`kubectl config current-context`)
- Access to the chart repo or the local path to the chart
- `KUBECONFIG` pointing at the right cluster — DO NOT run against the wrong context

Check this first:

```bash
kubectl config current-context
kubectl get ns <namespace>
helm list -n <namespace>
```

If any of these fail, stop and fix before continuing.

## Decide: regular upgrade or rollback?

| Situation | Path |
|---|---|
| Shipping a new image / config change | **Upgrade** |
| Something just deployed is broken | **Rollback** to the previous revision |
| Multiple revisions are broken | **Rollback** to a known-good revision — use `helm history` |
| Nothing deployed yet | `helm install` (not covered here — use the normal deploy) |

## Upgrade procedure

### 1. Confirm what will change

```bash
helm diff upgrade <release> <chart> \
  -f values/<env>.yaml \
  --namespace <namespace>
```

If `helm diff` is not installed, install it: `helm plugin install https://github.com/databus23/helm-diff`.

Read the diff carefully. Look for:
- Image tag change (the thing you intended)
- Unintended config changes (surprising)
- Changes to resource requests / limits
- Changes to volumes, secrets, service accounts

If anything in the diff is surprising, stop.

### 2. Dry-run

```bash
helm upgrade --install <release> <chart> \
  -f values/<env>.yaml \
  --namespace <namespace> \
  --dry-run --debug
```

Check that the rendered YAML is valid and that placeholder values are resolved.

### 3. Apply

```bash
helm upgrade --install <release> <chart> \
  -f values/<env>.yaml \
  --namespace <namespace> \
  --atomic \
  --timeout 10m
```

Flags:
- `--install` — install if the release doesn't exist yet
- `--atomic` — rollback automatically on failure (critical)
- `--timeout 10m` — don't hang forever if a pod never becomes ready

### 4. Verify rollout

```bash
kubectl rollout status deployment/<name> -n <namespace> --timeout=5m
kubectl get pods -n <namespace> -l app=<name>
```

All pods should be `Running` and `Ready`. Crashing pods at this point means roll back.

### 5. Smoke test

Hit the health endpoint or run the project's smoke-test command:

```bash
curl -sf https://<service>/health
# or
make smoke-test ENV=<env>
```

### 6. Watch for 15 minutes

- Error rate on dashboards
- Latency change
- New log patterns
- Alerts

If anything spikes, roll back immediately.

## Rollback procedure

### 1. Identify the target revision

```bash
helm history <release> -n <namespace>
```

Output shows `REVISION`, `UPDATED`, `STATUS`, `CHART`, `APP VERSION`, `DESCRIPTION`. Pick the last `deployed` revision before the broken one.

### 2. Rollback

```bash
helm rollback <release> <revision> -n <namespace>
```

Or rollback to the immediately previous revision:

```bash
helm rollback <release> 0 -n <namespace>   # 0 = previous
```

### 3. Verify

```bash
kubectl rollout status deployment/<name> -n <namespace> --timeout=5m
helm history <release> -n <namespace>     # new revision should be "deployed"
```

### 4. Communicate

Rollbacks always get communicated:

- Drop a message in the service's channel
- Update the incident ticket
- Note the rollback revision and reason in the release log

## Common errors and fixes

### "Error: UPGRADE FAILED: another operation (install/upgrade/rollback) is in progress"

A previous operation hung or was killed. Check and clear:

```bash
kubectl get secrets -n <namespace> | grep helm
kubectl describe secret sh.helm.release.v1.<release>.v<N> -n <namespace>
# If it's stuck in 'pending-upgrade' or 'pending-install':
kubectl delete secret sh.helm.release.v1.<release>.v<N> -n <namespace>
```

Then retry the upgrade.

### "Error: cannot re-use a name that is still in use"

You ran `helm install` instead of `helm upgrade --install`. Always use `--install` for idempotency.

### "Error: ImagePullBackOff"

The image tag doesn't exist in the registry, or the pull secret is missing:

```bash
kubectl describe pod <pod> -n <namespace> | grep -A 5 "Failed"
# Check the registry has the tag
# Check imagePullSecrets is referenced in the deployment
```

### "Readiness probe failed"

The pod is up but not ready. The app isn't answering health checks in time:

```bash
kubectl logs <pod> -n <namespace> --tail=100
kubectl describe pod <pod> -n <namespace> | grep -A 10 "Readiness"
```

Check:
- Port is right
- Path is right
- `initialDelaySeconds` is long enough for startup

### `OOMKilled`

Resource limits are too low or there's a leak. Inspect:

```bash
kubectl top pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace> --previous
```

Raise limits OR fix the leak. Don't just raise limits without understanding why.

## Escalation

- If the rollback fails: page the on-call platform engineer.
- If customer-facing errors spike above the SLO: declare an incident, use the `incident-triage` skill.
- If you need to change the chart itself to fix a problem: that's a PR, not an emergency fix. Apply a temporary config-only fix via `--set` if you absolutely must, and follow up with a proper chart PR within 24h.

## What you do NOT do from this skill

- Do NOT run `helm uninstall` — that deletes the release. If you need to remove a service, that's a separate change-controlled process.
- Do NOT edit live resources with `kubectl edit` — use the chart and Helm.
- Do NOT deploy to prod from a developer laptop — use the CI pipeline. This runbook assumes staging/dev; prod deploys go through the deploy workflow.
