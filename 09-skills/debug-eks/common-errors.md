# Common Kubernetes Pod Errors — Lookup Table

Quick lookup from exact error message → root cause → fix. Use as a reference from `SKILL.md`.

---

## Image / Registry

| Error | Cause | Fix |
|---|---|---|
| `ErrImagePull: manifest unknown` | Image tag doesn't exist in registry | Verify tag exists; check for typos in `values.yaml` |
| `ImagePullBackOff: unauthorized` | No / wrong imagePullSecret | Create secret via `kubectl create secret docker-registry`; add to pod spec |
| `toomanyrequests: Docker Hub rate limit` | Anonymous Docker Hub pull rate exceeded | Authenticate pulls (Docker Hub login) or move image to GHCR/ECR/GAR |
| `dial tcp: no such host` (on image pull) | DNS / network to registry broken | Check cluster egress, VPC DNS, security groups |
| `unsupported media type` | Image is a manifest list for a different arch | Pin image to the right platform or rebuild multi-arch |

---

## Startup

| Error | Cause | Fix |
|---|---|---|
| `CrashLoopBackOff` | App crashing repeatedly | `kubectl logs --previous` to see crash reason |
| `CreateContainerConfigError` | ConfigMap or Secret referenced doesn't exist | Check envFrom/valueFrom references match existing objects |
| `RunContainerError: permission denied` | Security context denies mount or capability | Inspect `securityContext`; consider `runAsNonRoot`, filesystem perms |
| `Back-off restarting failed container` | PID 1 exits immediately | Wrong entrypoint / command; missing binary; misconfigured readiness |
| `Init:CrashLoopBackOff` | Init container failing | `kubectl logs <pod> -c <init-container>` |

---

## Probes

| Error | Cause | Fix |
|---|---|---|
| `Readiness probe failed: HTTP probe failed with statuscode: 503` | App up but health endpoint returning unhealthy | App logic — check DB connectivity, dependencies |
| `Readiness probe failed: Get "http://...": dial tcp ...: connect: connection refused` | App not listening yet | Raise `initialDelaySeconds`; verify port matches |
| `Liveness probe failed` repeatedly | App hangs after startup | Investigate deadlock, GC pause, blocking syscall |
| `Liveness probe failed` then pod restart loop | Probe too aggressive | Raise `periodSeconds` / `failureThreshold` |

---

## Resources

| Error | Cause | Fix |
|---|---|---|
| `OOMKilled` | Memory limit exceeded | Raise limit or fix leak; check heap/GC config |
| `Evicted: The node was low on resource: memory` | Node pressure | Add resources, spread pods, or raise requests |
| `insufficient cpu` (Pending) | No node has enough CPU | Scale cluster, reduce requests, or evict low-priority pods |
| `insufficient memory` (Pending) | Same as above for memory | Same |

---

## Networking

| Error | Cause | Fix |
|---|---|---|
| `dial tcp ...: i/o timeout` (app logs) | Destination unreachable from pod | Check NetworkPolicy, security groups, service endpoints |
| `connection refused` to sibling service | Service not up, or wrong port | `kubectl get endpoints <service>` to verify backing pods |
| `TLS handshake timeout` / `x509: certificate signed by unknown authority` | Cert chain issue | Check CA bundle, service mesh mTLS config |
| `Name or service not known` (DNS) | CoreDNS issue or wrong name | `kubectl exec <pod> -- nslookup <host>`; check CoreDNS logs |

---

## Storage

| Error | Cause | Fix |
|---|---|---|
| `FailedMount: Unable to attach or mount volumes` | PVC binding failed or CSI driver sick | `kubectl describe pvc`; check CSI driver pods |
| `Unable to mount volumes: timeout expired waiting for volumes to attach or mount` | Cloud volume not attached to node | Check cloud provider limits, AZ mismatch |
| `No space left on device` (app logs) | PVC full or tmpfs exhausted | Grow PVC (if supported), add eviction for logs, clear caches |

---

## Security / RBAC

| Error | Cause | Fix |
|---|---|---|
| `forbidden: User "system:serviceaccount:..." cannot list ...` | ServiceAccount lacks RBAC | Add ClusterRole/Role binding for the SA |
| `AccessDenied` (AWS API) from pod | IRSA not configured or IAM role missing permissions | Verify ServiceAccount annotation; check the IAM role |
| `unauthorized` (Secret Manager / Vault) | Pod SA can't authenticate | Verify token projection, audience, service account |

---

## Node-level

| Condition | Cause | Fix |
|---|---|---|
| `DiskPressure` | Node disk full (images, logs, tmpfs) | Prune unused images; raise ephemeral storage; add disk |
| `MemoryPressure` | Node memory low | Evict noisy pods; add nodes; tune requests |
| `NetworkUnavailable` | CNI not ready | Check CNI daemonset pods on that node |
| `NodeNotReady` | Kubelet not reporting | SSH to node; check kubelet service status |
| `PIDPressure` | Too many processes | Check runaway pod; raise kernel.pid_max |
