#!/usr/bin/env bash
# broad-permissions.sh — warn / fail on IAM or RBAC changes that grant broad power.
#
# Looks for common "I gave up and added *" patterns in diffs:
#   - AWS IAM: Action: "*", Resource: "*", AdministratorAccess
#   - K8s RBAC: cluster-admin, verbs: ["*"], resources: ["*"]
#   - GCP: roles/owner, roles/editor (in prod projects)
#   - Azure: role "Owner", "Contributor" on subscriptions
#
# Env: PERMISSIONS_MODE=warn|fail-closed (default: warn)

set -uo pipefail

MODE="${PERMISSIONS_MODE:-warn}"

DIFF_SRC=""
if [[ -p /dev/stdin || -s /dev/stdin ]]; then
  DIFF_SRC="$(cat)"
else
  DIFF_SRC="$(git diff --cached 2>/dev/null; git diff 2>/dev/null)"
fi

HITS=0

AWS_PATTERNS=(
  '"Action":[[:space:]]*"\*"'
  '"Resource":[[:space:]]*"\*"'
  'arn:aws:iam::aws:policy/AdministratorAccess'
  '"Effect":[[:space:]]*"Allow".*"NotAction"'
)

K8S_PATTERNS=(
  'kind:[[:space:]]*ClusterRoleBinding'
  'name:[[:space:]]*cluster-admin'
  'verbs:[[:space:]]*\["\*"\]'
  'resources:[[:space:]]*\["\*"\]'
  'apiGroups:[[:space:]]*\["\*"\]'
)

GCP_PATTERNS=(
  'roles/owner'
  'roles/editor'
)

AZURE_PATTERNS=(
  '"roleDefinitionName":[[:space:]]*"Owner"'
  '"roleDefinitionName":[[:space:]]*"Contributor"'
)

check_patterns() {
  local label="$1"; shift
  local pats=("$@")
  while IFS= read -r line; do
    for p in "${pats[@]}"; do
      if echo "$line" | grep -Eq -- "$p"; then
        echo "BROAD-PERMS  [$label]  pattern='$p'  line='$line'"
        HITS=$((HITS + 1))
        break
      fi
    done
  done <<< "$DIFF_SRC"
}

check_patterns AWS "${AWS_PATTERNS[@]}"
check_patterns K8S "${K8S_PATTERNS[@]}"
check_patterns GCP "${GCP_PATTERNS[@]}"
check_patterns AZURE "${AZURE_PATTERNS[@]}"

echo
if [[ $HITS -eq 0 ]]; then
  echo "broad-permissions.sh: no matches"
  exit 0
fi

echo "broad-permissions.sh: $HITS match(es) (mode=$MODE)"
if [[ "$MODE" == "fail-closed" ]]; then
  exit 1
else
  exit 0
fi
