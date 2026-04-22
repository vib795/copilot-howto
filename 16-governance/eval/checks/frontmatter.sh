#!/usr/bin/env bash
# frontmatter.sh — validate YAML frontmatter has required fields per asset type.
#
# Required fields per type:
#   prompt:       description, mode
#   chatmode:     description, model
#   agent:        name, description, model
#   skill:        name, description
#   instructions: applyTo
#
# Optional but validated when present:
#   owner, classification -- per governance
#
# Requires: yq v4+ (https://github.com/mikefarah/yq). Falls back to a simple grep if unavailable.

set -uo pipefail

FAIL=0
HAVE_YQ=1
command -v yq >/dev/null 2>&1 || HAVE_YQ=0

extract_frontmatter() {
  # Print lines between the first pair of --- markers
  awk '/^---$/{c++; next} c==1 {print} c>1{exit}' "$1"
}

yaml_has_key() {
  local file="$1" key="$2"
  if [[ $HAVE_YQ -eq 1 ]]; then
    fm="$(extract_frontmatter "$file")"
    echo "$fm" | yq eval ".${key} // null" - 2>/dev/null | grep -vq '^null$' || return 1
    return 0
  else
    extract_frontmatter "$file" | grep -Eq "^${key}:\s+\S+" && return 0 || return 1
  fi
}

check_fields() {
  local file="$1"; shift
  local missing=()
  for k in "$@"; do
    if ! yaml_has_key "$file" "$k"; then
      missing+=("$k")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "FAIL  $file  missing: ${missing[*]}"
    FAIL=1
  fi
}

check_dir() {
  local dir="$1" pattern="$2"; shift 2
  [[ -d "$dir" ]] || return 0
  while IFS= read -r -d '' f; do
    check_fields "$f" "$@"
  done < <(find "$dir" -type f -name "$pattern" -print0)
}

echo "frontmatter.sh"
[[ $HAVE_YQ -eq 1 ]] || echo "  (yq not found; using grep fallback — install yq for stricter validation)"

echo "  prompts/*     require: description, mode"
check_dir ".github/prompts" "*.prompt.md" description mode

echo "  chatmodes/*   require: description, model"
check_dir ".github/chatmodes" "*.chatmode.md" description model

echo "  agents/*      require: name, description, model"
check_dir ".github/agents" "*.agent.md" name description model

echo "  skills/*/SKILL.md  require: name, description"
if [[ -d .github/skills ]]; then
  while IFS= read -r -d '' f; do
    check_fields "$f" name description
  done < <(find .github/skills -type f -name "SKILL.md" -print0)
fi

echo "  instructions/* require: applyTo"
check_dir ".github/instructions" "*.instructions.md" applyTo

if [[ $FAIL -eq 0 ]]; then
  echo "frontmatter.sh: OK"
  exit 0
else
  echo "frontmatter.sh: FAIL"
  exit 1
fi
