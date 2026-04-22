#!/usr/bin/env bash
# destructive-commands.sh — warn / fail when a Copilot-produced diff or agent-proposed
# command contains irrecoverable destructive operations.
#
# Invoked by .github/workflows/copilot-hooks.yml in the pre-action-checks job.
# Reads the diff from stdin OR scans the working tree changes.
#
# Modes:
#   warn        exit 0 but print a loud warning (default for new hooks)
#   fail-closed exit 1 on any match (for tuned, trusted hooks)
#
# Configure via env: DESTRUCTIVE_MODE=warn|fail-closed (default: warn)

set -uo pipefail

MODE="${DESTRUCTIVE_MODE:-warn}"

PATTERNS=(
  'rm -rf[[:space:]]+/'
  'rm -rf[[:space:]]+\$\{?HOME'
  'rm -rf[[:space:]]+~'
  'rm -rf[[:space:]]+\*'
  'DROP TABLE'
  'DROP DATABASE'
  'DROP SCHEMA'
  'TRUNCATE TABLE'
  'DELETE FROM [a-zA-Z_]+ *$'
  'git push.*--force'
  'git push.*-f[[:space:]]'
  'git reset --hard'
  'kubectl delete namespace'
  'kubectl delete ns '
  'kubectl drain --force'
  'helm uninstall'
  'terraform destroy'
  'tofu destroy'
  'aws s3 rb.*--force'
  'aws s3 rm.*--recursive'
  'gcloud.*delete'
  'az.*delete.*--yes'
  'docker system prune -af'
)

DIFF_SRC=""
if [[ -p /dev/stdin || -s /dev/stdin ]]; then
  DIFF_SRC="$(cat)"
else
  # Working-tree scan mode
  DIFF_SRC="$(git diff --cached 2>/dev/null; git diff 2>/dev/null)"
fi

HITS=0
while IFS= read -r line; do
  for p in "${PATTERNS[@]}"; do
    if echo "$line" | grep -Eiq -- "$p"; then
      echo "DESTRUCTIVE  pattern='$p'  line='$line'"
      HITS=$((HITS + 1))
      break
    fi
  done
done <<< "$DIFF_SRC"

echo
if [[ $HITS -eq 0 ]]; then
  echo "destructive-commands.sh: no matches"
  exit 0
fi

echo "destructive-commands.sh: $HITS match(es) (mode=$MODE)"
if [[ "$MODE" == "fail-closed" ]]; then
  exit 1
else
  exit 0
fi
