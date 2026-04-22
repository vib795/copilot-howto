#!/usr/bin/env bash
# naming.sh — validate file naming and extensions for Copilot assets.
#
# Rules enforced:
#   .github/prompts/*.prompt.md        kebab-case filename
#   .github/skills/<name>/SKILL.md     name folder kebab-case; file literally SKILL.md
#   .github/chatmodes/*.chatmode.md    kebab-case filename
#   .github/agents/*.agent.md          kebab-case filename
#   .github/instructions/*.instructions.md  kebab-case filename
#
# Exit non-zero if any file violates.
# Run from repo root: bash .github/eval/checks/naming.sh

set -uo pipefail

FAIL=0

is_kebab() {
  [[ "$1" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]
}

check_kebab_extension() {
  local dir="$1" ext="$2"
  [[ -d "$dir" ]] || return 0
  while IFS= read -r -d '' f; do
    base="${f##*/}"
    name="${base%.$ext}"
    if [[ "$base" == "$name" ]]; then
      echo "FAIL  wrong extension: $f (expected .${ext})"
      FAIL=1
      continue
    fi
    if ! is_kebab "$name"; then
      echo "FAIL  not kebab-case: $f"
      FAIL=1
    fi
  done < <(find "$dir" -maxdepth 1 -type f -print0)
}

check_skill_folders() {
  local dir=".github/skills"
  [[ -d "$dir" ]] || return 0
  for skill in "$dir"/*/; do
    [[ -d "$skill" ]] || continue
    name="$(basename "$skill")"
    if ! is_kebab "$name"; then
      echo "FAIL  skill folder not kebab-case: $skill"
      FAIL=1
    fi
    if [[ ! -f "${skill}SKILL.md" ]]; then
      echo "FAIL  missing SKILL.md in: $skill"
      FAIL=1
    fi
    # Anything else in the folder must be kebab-case-ish — we allow mixed-case for bundled templates
  done
}

echo "naming.sh"
echo "  prompts/      .prompt.md"
check_kebab_extension ".github/prompts" "prompt.md"
echo "  chatmodes/    .chatmode.md"
check_kebab_extension ".github/chatmodes" "chatmode.md"
echo "  agents/       .agent.md"
check_kebab_extension ".github/agents" "agent.md"
echo "  instructions/ .instructions.md"
check_kebab_extension ".github/instructions" "instructions.md"
echo "  skills/       folder + SKILL.md"
check_skill_folders

if [[ $FAIL -eq 0 ]]; then
  echo "naming.sh: OK"
  exit 0
else
  echo "naming.sh: FAIL"
  exit 1
fi
