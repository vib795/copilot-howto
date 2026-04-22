---
name: debug-eks
description: >
  Use when a pod is crashing, not starting, or behaving weirdly on Kubernetes
  (EKS, GKE, AKS, or vanilla). Triggers on: CrashLoopBackOff, OOMKilled,
  ImagePullBackOff, ErrImagePull, Pending, ContainerCreating, readiness probe
  failing, liveness probe failing, pod stuck terminating, node not ready,
  kubectl describe events, "why is my pod crashing", "pod won't start".
owner: "@org/platform-team"
classification: internal
---

# Debug EKS / Kubernetes Pod Issues

Systematic diagnosis of pod and node problems. Start at the top, stop when you find the cause. Don't skip steps — the ordering is what makes this fast.

## Step 1: What state is the pod in?

```bash
kubectl get pods -n <namespace> -l app=<app-name>
```

Status tells you where to go:

| Status | Meaning | Next |
|---|---|---|
| `Running` + `0/1 Ready` | App is up but failing readiness | Step 4 |
| `CrashLoopBackOff` | App keeps starting and dying | Step 3 |
| `Pending` | Scheduler can't place the pod | Step 5 |
| `ContainerCreating` | Stuck fetching image or mounting | Step 6 |
| `ImagePullBackOff` / `ErrImagePull` | Can't pull image | Step 6 |
| `OOMKilled` (in Last State) | Killed for memory | Step 7 |
| `Terminating` (stuck) | Pod can't shut down | Step 8 |

## Step 2: Read the events first

Events are usually the answer. Always run this before logs:

```bash
kubectl describe pod <pod> -n <namespace> | grep -A 20 "Events:"
```

If there's a clear event ("Failed to pull image X: manifest unknown"), you're done — fix the image.

## Step 3: CrashLoopBackOff — read the crash logs

```bash
# Current container logs (if running)
kubectl logs <pod> -n <namespace> --tail=200

# Previous crashed container logs (more useful for crashloop)
kubectl logs <pod> -n <namespace> --previous --tail=200

# If the pod has multiple containers
kubectl logs <pod> -n <namespace> -c <container> --previous --tail=200
```

Classify:
- Stack trace / unhandled exception → app bug
- "connection refused" / "no such host" → dependency not reachable
- "permission denied" → RBAC, file mounts, or security context
- Empty output → app died before logging — check the command/args and entrypoint

## Step 4: Readiness/liveness probe failing (Running, not Ready)

```bash
kubectl describe pod <pod> -n <namespace> | grep -A 10 "Readiness\|Liveness"
```

Look at the probe configuration vs app behaviour:
- Is the port right?
- Is the path right?
- Does the app respond to HTTP on that path during startup? (test with `kubectl exec` and `curl localhost:<port>/<path>`)
- Is `initialDelaySeconds` long enough for cold start?

```bash
# Test the probe manually from inside the pod
kubectl exec <pod> -n <namespace> -c <container> -- curl -sf http://localhost:<port>/<path>
```

## Step 5: Pending — scheduler can't place the pod

```bash
kubectl describe pod <pod> -n <namespace> | grep -A 10 "Events:"
```

Common causes:
- **`insufficient cpu/memory`** — cluster doesn't have room. Check node capacity:
  ```bash
  kubectl top nodes
  kubectl describe nodes | grep -A 5 "Allocated resources"
  ```
  Options: scale cluster, reduce resource requests, evict non-essential workloads.

- **`no nodes match node selector / affinity / taint`** — pod has `nodeSelector`, affinity, or toleration that matches no node. Check:
  ```bash
  kubectl get nodes --show-labels
  kubectl get pod <pod> -n <namespace> -o yaml | grep -A 5 "nodeSelector\|tolerations"
  ```

- **`pod has unbound PVC`** — waiting on a PersistentVolumeClaim:
  ```bash
  kubectl get pvc -n <namespace>
  kubectl describe pvc <pvc-name> -n <namespace>
  ```

## Step 6: Image pull issues

```bash
kubectl describe pod <pod> -n <namespace> | grep -A 3 "Failed to pull"
```

- **`manifest unknown`** — tag doesn't exist. Confirm in the registry. Did someone typo the tag in values.yaml?
- **`unauthorized`** — missing or wrong imagePullSecret. Verify:
  ```bash
  kubectl get pod <pod> -n <namespace> -o yaml | grep imagePullSecrets
  kubectl get secret <secret-name> -n <namespace> -o yaml
  ```
- **`toomanyrequests`** (Docker Hub) — rate limit. Authenticate the pull or switch registry.
- **`no such host`** — cluster can't reach the registry. Network / DNS issue, not an auth issue.

## Step 7: OOMKilled

Check previous container status:

```bash
kubectl get pod <pod> -n <namespace> -o jsonpath='{.status.containerStatuses[].lastState}'
```

If `OOMKilled`:

```bash
# Current usage pattern
kubectl top pod <pod> -n <namespace>

# Limits
kubectl get pod <pod> -n <namespace> -o yaml | grep -A 3 "resources:"
```

Options:
1. **Raise limits** — if usage is genuinely higher than expected for a valid reason. Update chart values and redeploy.
2. **Fix the leak** — if usage grows over time. Enable heap dumps, use `jcmd` / `py-spy` / `pprof` depending on language.
3. **Tune the runtime** — for the JVM, `-XX:MaxRAMPercentage` matters. For Node.js, `--max-old-space-size`.

Don't just raise limits without understanding which. A leaky service with higher limits just OOMs later.

## Step 8: Pod stuck in Terminating

```bash
kubectl get pod <pod> -n <namespace> -o yaml | grep -A 5 "finalizers\|deletionTimestamp"
```

Causes:
- **Stuck finalizers** — another controller owns cleanup. Investigate who. Removing finalizers is the last resort:
  ```bash
  kubectl patch pod <pod> -n <namespace> -p '{"metadata":{"finalizers":null}}'
  ```
- **`preStop` hook timing out** — app doesn't shut down cleanly. Logs / exec to confirm.
- **Node is NotReady** — pod can't actually be deleted. Check the node:
  ```bash
  kubectl get nodes
  kubectl describe node <node-name>
  ```

## Step 9: Node-level problems

If multiple pods on the same node are sick:

```bash
kubectl get nodes
kubectl describe node <node> | grep -A 20 "Conditions:"
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20
```

Common node issues:
- `DiskPressure` — evicting pods
- `MemoryPressure` — will evict pods
- `NetworkUnavailable` — no pod can reach the network
- `NotReady` — kubelet is down; SSH to the node if possible

## Reference files in this skill folder

- [common-errors.md](./common-errors.md) — Extended table of error messages → causes → fixes

## Escalation

- **Multiple services affected on the same cluster** — treat as a cluster incident; use `incident-triage` skill.
- **Node hardware symptoms (disk, NIC)** — involve the infra team, not the app team.
- **Node permissions / IAM (EKS)** — involve the cloud team; IRSA and IAM roles are often the cause of mysterious auth failures.
