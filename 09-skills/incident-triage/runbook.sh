#!/usr/bin/env bash
# Capture evidence for an active incident before anything gets restarted or cleaned up.
# Usage: ./runbook.sh <namespace> [app-label]
# Writes everything to /tmp/inc-$(date)/ so nothing is lost when pods churn.

set -euo pipefail

NS="${1:?usage: $0 <namespace> [app-label]}"
APP="${2:-}"
TS="$(date -u +%Y%m%dT%H%M%SZ)"
OUT="/tmp/inc-${TS}"
mkdir -p "$OUT"

echo "Capturing incident evidence to $OUT"

# Cluster context
kubectl config current-context > "$OUT/context.txt"
kubectl version --short > "$OUT/kubectl-version.txt" 2>&1 || true
kubectl cluster-info > "$OUT/cluster-info.txt" 2>&1 || true

# Recent events (whole cluster, last)
kubectl get events -A --sort-by='.lastTimestamp' | tail -200 > "$OUT/events-cluster.txt"
kubectl get events -n "$NS" --sort-by='.lastTimestamp' > "$OUT/events-ns.txt"

# Nodes
kubectl get nodes -o wide > "$OUT/nodes.txt"
kubectl describe nodes > "$OUT/nodes-describe.txt"

# Namespace-level state
kubectl get all -n "$NS" -o wide > "$OUT/ns-all.txt"
kubectl get pvc,secret,configmap,ingress -n "$NS" > "$OUT/ns-resources.txt"

# Pod-level (filter by app if given, else all in namespace)
if [[ -n "$APP" ]]; then
  PODS=$(kubectl get pods -n "$NS" -l "app=$APP" -o name)
else
  PODS=$(kubectl get pods -n "$NS" -o name)
fi

for pod in $PODS; do
  name="${pod##pod/}"
  echo "  -> $name"
  kubectl describe "$pod" -n "$NS" > "$OUT/${name}.describe.txt" 2>&1 || true
  kubectl logs "$pod" -n "$NS" --tail=500 > "$OUT/${name}.logs.txt" 2>&1 || true
  kubectl logs "$pod" -n "$NS" --previous --tail=500 > "$OUT/${name}.logs-previous.txt" 2>&1 || true
  kubectl get "$pod" -n "$NS" -o yaml > "$OUT/${name}.yaml" 2>&1 || true
done

# Recent Helm history for common releases
kubectl get secret -n "$NS" -l owner=helm -o custom-columns=NAME:.metadata.name --no-headers \
  | awk -F'.' '{print $4}' | sort -u > "$OUT/helm-releases.txt" || true

echo
echo "Done. Evidence in: $OUT"
echo "Upload to the incident channel before restarting anything."
