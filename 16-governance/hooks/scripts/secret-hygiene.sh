#!/usr/bin/env bash
# secret-hygiene.sh — warn / fail when a diff contains secret-like patterns.
#
# This is a lightweight check alongside GitHub's secret scanning. It catches
# things that slip through the Copilot output into a diff before commit.
#
# Env: SECRETS_MODE=warn|fail-closed (default: warn)

set -uo pipefail

MODE="${SECRETS_MODE:-warn}"

DIFF_SRC=""
if [[ -p /dev/stdin || -s /dev/stdin ]]; then
  DIFF_SRC="$(cat)"
else
  DIFF_SRC="$(git diff --cached 2>/dev/null; git diff 2>/dev/null)"
fi

HITS=0

# Regex patterns — line-by-line
PATTERNS=(
  # AWS access keys
  'AKIA[0-9A-Z]{16}'
  'ASIA[0-9A-Z]{16}'
  # GitHub
  'gh[opsu]_[A-Za-z0-9]{36,}'
  # Slack
  'xox[baprs]-[0-9A-Za-z-]{10,}'
  # Stripe
  'sk_live_[0-9A-Za-z]{24,}'
  'pk_live_[0-9A-Za-z]{24,}'
  # Google API keys
  'AIza[0-9A-Za-z_-]{35}'
  # OpenAI
  'sk-[A-Za-z0-9]{20,}'
  # Anthropic
  'sk-ant-[A-Za-z0-9_-]{20,}'
  # Generic: BEGIN PRIVATE KEY blocks
  '-----BEGIN [A-Z ]*PRIVATE KEY-----'
  # JWT (loose)
  'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}'
  # Common env-style leaks (heuristic — may false-positive)
  '(?i)(password|passwd|secret|api[_-]?key|access[_-]?token)[[:space:]]*[:=][[:space:]]*["\x27][^"\x27]{8,}["\x27]'
)

check() {
  local p="$1"
  while IFS= read -r line; do
    # Skip removals (we only care about added or context lines)
    [[ "$line" =~ ^- ]] && continue
    if echo "$line" | grep -Eq -- "$p"; then
      # Redact the actual value in the output
      redacted="$(echo "$line" | sed -E 's/([A-Za-z0-9_\-]{4,}[0-9A-Z]{4,})/[REDACTED]/g')"
      echo "SECRET  pattern='$p'  line='$redacted'"
      HITS=$((HITS + 1))
    fi
  done <<< "$DIFF_SRC"
}

for p in "${PATTERNS[@]}"; do
  check "$p"
done

# Also scan Dockerfiles for suspicious ENV lines
while IFS= read -r line; do
  if echo "$line" | grep -Eiq '^\+?ENV[[:space:]]+[A-Z_]*(PASSWORD|SECRET|TOKEN|KEY)[[:space:]]*=[[:space:]]*[^$].+'; then
    echo "DOCKERFILE-SECRET  line='$line'"
    HITS=$((HITS + 1))
  fi
done <<< "$DIFF_SRC"

echo
if [[ $HITS -eq 0 ]]; then
  echo "secret-hygiene.sh: no matches"
  exit 0
fi

echo "secret-hygiene.sh: $HITS match(es) (mode=$MODE)"
if [[ "$MODE" == "fail-closed" ]]; then
  exit 1
else
  exit 0
fi
