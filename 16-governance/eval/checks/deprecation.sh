#!/usr/bin/env bash
# deprecation.sh — enforce the 60-day grace period between deprecation and removal,
# and warn when scheduled removal is within 7 days.
#
# Reads `deprecated_on` and `removal_scheduled_on` from frontmatter OR manifest.
# Requires: jq; date command supporting GNU-style (`date -d`) or BSD (`date -j`).

set -uo pipefail

MANIFEST=".github/copilot-asset-manifest.json"
MIN_GRACE_DAYS=60
FAIL=0
TODAY="$(date -u +%Y-%m-%d)"

echo "deprecation.sh  (today=$TODAY, minimum grace=${MIN_GRACE_DAYS}d)"

# Prefer GNU date if available
to_epoch() {
  local d="$1"
  if date -d "$d" +%s >/dev/null 2>&1; then
    date -d "$d" +%s
  else
    date -j -f "%Y-%m-%d" "$d" +%s 2>/dev/null || echo ""
  fi
}

check_dates() {
  local label="$1" dep="$2" removal="$3"
  local dep_e rem_e today_e
  today_e="$(to_epoch "$TODAY")"
  dep_e="$(to_epoch "$dep")"
  rem_e="$(to_epoch "$removal")"
  if [[ -z "$dep_e" || -z "$rem_e" ]]; then
    echo "FAIL  $label  invalid date(s): dep=$dep removal=$removal"
    FAIL=1
    return
  fi
  local diff_days=$(( (rem_e - dep_e) / 86400 ))
  if (( diff_days < MIN_GRACE_DAYS )); then
    echo "FAIL  $label  grace period too short: ${diff_days}d (minimum ${MIN_GRACE_DAYS}d)"
    FAIL=1
  fi
  local days_until=$(( (rem_e - today_e) / 86400 ))
  if (( days_until <= 0 )); then
    echo "WARN  $label  removal date passed ${days_until}d ago — remove asset or extend deprecation"
  elif (( days_until <= 7 )); then
    echo "WARN  $label  removal in ${days_until}d — migration window closing"
  fi
}

if [[ -f "$MANIFEST" ]]; then
  while IFS=$'\t' read -r path status dep rem; do
    [[ "$status" != "deprecated" ]] && continue
    [[ -z "$dep" || "$dep" == "null" || -z "$rem" || "$rem" == "null" ]] && {
      echo "FAIL  $path  deprecated without deprecated_on/removal_scheduled_on"
      FAIL=1; continue
    }
    check_dates "$path" "$dep" "$rem"
  done < <(jq -r '.assets[] | [.path, (.status // "active"), (.deprecated_on // ""), (.removal_scheduled_on // "")] | @tsv' "$MANIFEST")
fi

if [[ $FAIL -eq 0 ]]; then
  echo "deprecation.sh: OK"
  exit 0
else
  echo "deprecation.sh: FAIL"
  exit 1
fi
