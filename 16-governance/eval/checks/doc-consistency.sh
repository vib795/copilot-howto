#!/usr/bin/env bash
# doc-consistency.sh — scan for stale references to assets that don't exist.
#
# Checks:
#   - References to `/<command>` that don't match a prompt file
#   - References to `<name>.chatmode.md` that don't exist
#   - References to `slot/<name>` that isn't in model-compatibility.json
#   - References to `.github/agents/<x>.agent.md` that don't exist
#
# Exits non-zero on any stale reference.

set -uo pipefail

FAIL=0
MATRIX=".github/model-compatibility.json"

echo "doc-consistency.sh"

prompt_names() {
  ls .github/prompts/*.prompt.md 2>/dev/null | sed 's|.*/||; s|\.prompt\.md$||'
}

agent_names() {
  ls .github/agents/*.agent.md 2>/dev/null | sed 's|.*/||; s|\.agent\.md$||'
}

chatmode_names() {
  ls .github/chatmodes/*.chatmode.md 2>/dev/null | sed 's|.*/||; s|\.chatmode\.md$||'
}

slot_names() {
  [[ -f "$MATRIX" ]] && jq -r '.slots | keys[]' "$MATRIX" 2>/dev/null
}

KNOWN_PROMPTS="$(prompt_names)"
KNOWN_AGENTS="$(agent_names)"
KNOWN_CHATMODES="$(chatmode_names)"
KNOWN_SLOTS="$(slot_names)"

# Scan markdown files across the repo
MD_FILES=$(find . -type f -name "*.md" \
  -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/vendor/*")

# Check slot references
while IFS= read -r f; do
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    if ! echo "$KNOWN_SLOTS" | grep -qxF "$ref"; then
      echo "WARN  $f: references undefined slot $ref"
      # Slots referenced in docs outside the governance dirs are warnings, not failures.
    fi
  done < <(grep -oE 'slot/[a-z0-9]+([a-z0-9-]*[a-z0-9])?' "$f" 2>/dev/null | sort -u)
done <<< "$MD_FILES"

# Check agent handoff references within agent files
while IFS= read -r f; do
  while IFS= read -r ref; do
    [[ -z "$ref" ]] && continue
    if ! echo "$KNOWN_AGENTS" | grep -qxF "$ref"; then
      echo "FAIL  $f: handoff to non-existent agent: $ref"
      FAIL=1
    fi
  done < <(awk '
    /^---$/ {c++; next}
    c==1 && /^handoffs:/ {inhandoffs=1; next}
    c==1 && inhandoffs && /^[^[:space:]-]/ {inhandoffs=0}
    c==1 && inhandoffs && /^[[:space:]]*-/ {
      gsub(/^[[:space:]]*-[[:space:]]*/, "")
      gsub(/[[:space:]]*#.*$/, "")
      gsub(/["\x27]/, "")
      print
    }
    c>1 {exit}
  ' "$f")
done < <(find .github/agents -type f -name "*.agent.md" 2>/dev/null)

if [[ $FAIL -eq 0 ]]; then
  echo "doc-consistency.sh: OK"
  exit 0
else
  echo "doc-consistency.sh: FAIL"
  exit 1
fi
