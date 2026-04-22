---
mode: ask
model: gpt-4.1
description: "Pre-deploy checklist + Helm/kubectl commands for the current service"
---

# Deploy

Produce a deployment plan for the current service. Use `@workspace` to identify:

- Service name (from the Helm chart name, `package.json` name, or module name)
- Target environment (default: `staging` unless the user specifies)
- Current image tag in `values.yaml` or the equivalent manifest

## Output sections

### 1. Pre-flight checklist

Before any command runs, confirm (with commands to verify each):

- [ ] All tests pass on `main` (or the release branch)
- [ ] No uncommitted changes locally
- [ ] Previous deploy to this env is in a healthy state (not mid-rollback)
- [ ] Image for the target tag exists in the registry
- [ ] No active incident on the service
- [ ] Secrets/config differences between envs reviewed

### 2. Commands

Provide the exact commands in one executable block. Default to `--dry-run` first, then the real run.

```bash
# 1. Confirm chart values
helm diff upgrade <release> ./charts/<chart> \
  -f values/<env>.yaml --namespace <ns>

# 2. Apply
helm upgrade --install <release> ./charts/<chart> \
  -f values/<env>.yaml --namespace <ns> \
  --atomic --timeout 10m

# 3. Verify rollout
kubectl rollout status deployment/<name> -n <ns> --timeout=5m

# 4. Smoke test
<the project's smoke-test command, or curl of a health endpoint>
```

### 3. Rollback

One-line rollback commands, in order:

```bash
helm rollback <release> <previous-revision> -n <ns>
kubectl rollout status deployment/<name> -n <ns>
```

### 4. Observability checklist

- Dashboards to watch (names, not URLs — users have them bookmarked)
- Error-rate alert threshold for the first 15 minutes post-deploy
- Log query for new error patterns

## Constraints

- Never output `kubectl delete` or destructive `helm uninstall` unless the user has explicitly asked for a teardown.
- Never invent secret names — if a secret is missing, list it as a prerequisite, do not fabricate a `--set` line.
- If the project uses a different tool (ArgoCD, Flux, raw manifests), adapt — do not force Helm.
