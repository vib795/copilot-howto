#!/usr/bin/env bash
# copilot-health.sh — produce a health report on this repo's Copilot setup.
#
# Output: JSON at .github/health-report.json  +  markdown summary at .github/HEALTH.md
#
# Checks:
#   - Asset counts by type
#   - Ownership coverage (% of assets with an owner)
#   - Classification coverage
#   - Deprecated assets and their countdown
#   - Number of eval checks + pass rate (runs them)
#   - Number of hook scripts
#   - MCP servers configured vs profile

set -uo pipefail

MANIFEST=".github/copilot-asset-manifest.json"
OUT_JSON=".github/health-report.json"
OUT_MD=".github/HEALTH.md"

if [[ ! -f "$MANIFEST" ]]; then
  echo "error: $MANIFEST not found"
  exit 1
fi

TODAY="$(date -u +%Y-%m-%d)"

count_by_type() {
  jq --arg t "$1" '[.assets[] | select(.type == $t and (.status // "active") != "removed")] | length' "$MANIFEST"
}

active_count() {
  jq '[.assets[] | select((.status // "active") == "active")] | length' "$MANIFEST"
}

deprecated_count() {
  jq '[.assets[] | select((.status // "active") == "deprecated")] | length' "$MANIFEST"
}

owned_count() {
  jq '[.assets[] | select((.status // "active") != "removed" and (.owner // "" | length) > 0)] | length' "$MANIFEST"
}

classified_count() {
  jq '[.assets[] | select((.status // "active") != "removed" and (.classification // "" | length) > 0)] | length' "$MANIFEST"
}

total_count() {
  jq '[.assets[] | select((.status // "active") != "removed")] | length' "$MANIFEST"
}

pct() {
  local num="$1" den="$2"
  if (( den == 0 )); then echo "0"; else awk -v n="$num" -v d="$den" 'BEGIN{printf "%.1f", n*100/d}'; fi
}

run_evals() {
  local passes=0 fails=0
  for c in .github/eval/checks/*.sh; do
    [[ -f "$c" ]] || continue
    if bash "$c" >/dev/null 2>&1; then
      passes=$((passes + 1))
    else
      fails=$((fails + 1))
    fi
  done
  echo "$passes $fails"
}

eval_counts="$(run_evals)"
EVAL_PASS="$(echo "$eval_counts" | awk '{print $1}')"
EVAL_FAIL="$(echo "$eval_counts" | awk '{print $2}')"
EVAL_TOTAL=$((EVAL_PASS + EVAL_FAIL))

TOTAL=$(total_count)
OWNED=$(owned_count)
CLASSIFIED=$(classified_count)
ACTIVE=$(active_count)
DEPRECATED=$(deprecated_count)

PROMPTS=$(count_by_type prompt)
CHATMODES=$(count_by_type chatmode)
AGENTS=$(count_by_type agent)
SKILLS=$(count_by_type skill)
INSTRUCTIONS=$(count_by_type instructions)
HOOKS=$(count_by_type policy-check)
EVAL_CHECKS=$(count_by_type eval-check)
WORKFLOWS=$(count_by_type workflow)

MCP_SERVERS=0
if [[ -f .vscode/mcp.json ]]; then
  MCP_SERVERS=$(jq '[.servers | to_entries[] | select(.key | test("-DISABLED$") | not)] | length' .vscode/mcp.json 2>/dev/null || echo 0)
fi

# Deprecated detail
DEP_LIST="$(jq -r '.assets[] | select((.status // "active") == "deprecated") | "\(.path)\t\(.deprecated_on // "")\t\(.removal_scheduled_on // "")"' "$MANIFEST")"

# JSON output
cat > "$OUT_JSON" <<EOF
{
  "generated": "${TODAY}",
  "summary": {
    "total_active_or_deprecated": ${TOTAL},
    "active": ${ACTIVE},
    "deprecated": ${DEPRECATED},
    "owned": ${OWNED},
    "owned_pct": "$(pct "$OWNED" "$TOTAL")",
    "classified": ${CLASSIFIED},
    "classified_pct": "$(pct "$CLASSIFIED" "$TOTAL")"
  },
  "by_type": {
    "prompts": ${PROMPTS},
    "chatmodes": ${CHATMODES},
    "agents": ${AGENTS},
    "skills": ${SKILLS},
    "instructions": ${INSTRUCTIONS}
  },
  "governance": {
    "eval_checks": ${EVAL_CHECKS},
    "eval_pass": ${EVAL_PASS},
    "eval_fail": ${EVAL_FAIL},
    "hooks": ${HOOKS},
    "workflows": ${WORKFLOWS}
  },
  "mcp": {
    "servers_configured": ${MCP_SERVERS}
  },
  "deprecated_assets": [
$(echo "$DEP_LIST" | awk -F'\t' '
  BEGIN{first=1}
  NF{
    if (!first) printf ",\n"; first=0
    printf "    {\"path\":\"%s\",\"deprecated_on\":\"%s\",\"removal_scheduled_on\":\"%s\"}", $1,$2,$3
  }
  END{print ""}')
  ]
}
EOF

# Markdown summary
cat > "$OUT_MD" <<EOF
# Copilot Setup Health Report

Generated: ${TODAY}

## Summary
- Total assets (active + deprecated): **${TOTAL}**
- Active: **${ACTIVE}** | Deprecated: **${DEPRECATED}**
- With owner: **${OWNED}** ($(pct "$OWNED" "$TOTAL")%)
- With classification: **${CLASSIFIED}** ($(pct "$CLASSIFIED" "$TOTAL")%)

## Assets by type
| Type | Count |
|---|---|
| Prompts | ${PROMPTS} |
| Chat modes | ${CHATMODES} |
| Agents | ${AGENTS} |
| Skills | ${SKILLS} |
| Instructions | ${INSTRUCTIONS} |

## Governance
| Artefact | Count | Status |
|---|---|---|
| Eval checks | ${EVAL_CHECKS} | ${EVAL_PASS}/${EVAL_TOTAL} passing |
| Policy hooks | ${HOOKS} | — |
| Workflows | ${WORKFLOWS} | — |

## MCP
- Servers configured: **${MCP_SERVERS}**

EOF

if [[ -n "$DEP_LIST" ]]; then
  echo "## Deprecated assets" >> "$OUT_MD"
  echo "" >> "$OUT_MD"
  echo "| Path | Deprecated | Removal scheduled |" >> "$OUT_MD"
  echo "|---|---|---|" >> "$OUT_MD"
  echo "$DEP_LIST" | awk -F'\t' 'NF{printf "| %s | %s | %s |\n", $1, $2, $3}' >> "$OUT_MD"
  echo "" >> "$OUT_MD"
fi

echo "wrote $OUT_JSON"
echo "wrote $OUT_MD"
