#!/usr/bin/env bash
# manifest-sync.sh — ensure the asset manifest and the filesystem agree.
#
# Two rules:
#   A) Every tracked file under governed dirs has an entry in the manifest.
#   B) Every manifest entry points at an existing file, UNLESS status = removed.
#
# Requires: jq

set -uo pipefail

MANIFEST=".github/copilot-asset-manifest.json"
FAIL=0

if [[ ! -f "$MANIFEST" ]]; then
  echo "FAIL  $MANIFEST not found"
  exit 1
fi

echo "manifest-sync.sh"

# Rule A: fs -> manifest
GOVERNED_PATHS=()
for f in \
  $(find .github/prompts -type f -name "*.prompt.md" 2>/dev/null) \
  $(find .github/chatmodes -type f -name "*.chatmode.md" 2>/dev/null) \
  $(find .github/agents -type f -name "*.agent.md" 2>/dev/null) \
  $(find .github/skills -type f -name "SKILL.md" 2>/dev/null) \
  $(find .github/instructions -type f -name "*.instructions.md" 2>/dev/null) \
  ; do
  GOVERNED_PATHS+=("$f")
done

MANIFEST_PATHS="$(jq -r '.assets[].path' "$MANIFEST")"

for f in "${GOVERNED_PATHS[@]}"; do
  if ! echo "$MANIFEST_PATHS" | grep -qxF "$f"; then
    echo "FAIL  filesystem file not in manifest: $f"
    FAIL=1
  fi
done

# Rule B: manifest -> fs
while IFS=$'\t' read -r path status; do
  if [[ "$status" == "removed" ]]; then
    continue
  fi
  if [[ ! -f "$path" ]]; then
    echo "FAIL  manifest entry has no file (status=$status): $path"
    FAIL=1
  fi
done < <(jq -r '.assets[] | [.path, (.status // "active")] | @tsv' "$MANIFEST")

if [[ $FAIL -eq 0 ]]; then
  echo "manifest-sync.sh: OK"
  exit 0
else
  echo "manifest-sync.sh: FAIL"
  exit 1
fi
