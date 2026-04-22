#!/usr/bin/env bash
# model-refs.sh — validate that every `model:` reference in prompts / chatmodes / agents
# resolves to either a registered model or a registered slot in model-compatibility.json.
#
# Requires: jq, yq
# Exit non-zero if any reference is unresolved.

set -uo pipefail

MATRIX=".github/model-compatibility.json"
FAIL=0

if [[ ! -f "$MATRIX" ]]; then
  echo "FAIL  $MATRIX not found"
  exit 1
fi

REGISTERED_MODELS="$(jq -r '.models | keys[]' "$MATRIX")"
REGISTERED_SLOTS="$(jq -r '.slots | keys[]' "$MATRIX")"

is_registered() {
  local ref="$1"
  if [[ "$ref" == slot/* ]]; then
    echo "$REGISTERED_SLOTS" | grep -qxF "$ref"
  else
    echo "$REGISTERED_MODELS" | grep -qxF "$ref"
  fi
}

extract_model() {
  # Extract the value of `model:` from YAML frontmatter (first occurrence).
  awk '/^---$/{c++; next} c==1 {print} c>1{exit}' "$1" \
    | grep -E '^model:' | head -1 | sed -E 's/^model:\s*//; s/#.*$//; s/[[:space:]]*$//' \
    | tr -d '"'
}

check_file() {
  local f="$1"
  local m; m="$(extract_model "$f")"
  [[ -z "$m" ]] && return 0
  if ! is_registered "$m"; then
    echo "FAIL  $f  unregistered model: $m"
    FAIL=1
  fi
}

echo "model-refs.sh"

for d in .github/prompts .github/chatmodes .github/agents; do
  [[ -d "$d" ]] || continue
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find "$d" -type f \( -name "*.prompt.md" -o -name "*.chatmode.md" -o -name "*.agent.md" \) -print0)
done

if [[ $FAIL -eq 0 ]]; then
  echo "model-refs.sh: OK"
  exit 0
else
  echo "model-refs.sh: FAIL  — all model: references must resolve in $MATRIX"
  exit 1
fi
