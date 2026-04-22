#!/usr/bin/env bash
# governance.sh — every manifest entry with status != removed must have owner + classification.
# Additionally, classification must be one of: public | internal | restricted.
#
# Requires: jq

set -uo pipefail

MANIFEST=".github/copilot-asset-manifest.json"
FAIL=0

if [[ ! -f "$MANIFEST" ]]; then
  echo "FAIL  $MANIFEST not found"
  exit 1
fi

echo "governance.sh"

while IFS=$'\t' read -r path owner classification status; do
  status="${status:-active}"
  [[ "$status" == "removed" ]] && continue

  if [[ -z "$owner" || "$owner" == "null" ]]; then
    echo "FAIL  $path  missing owner"
    FAIL=1
  fi

  if [[ -z "$classification" || "$classification" == "null" ]]; then
    echo "FAIL  $path  missing classification"
    FAIL=1
  else
    case "$classification" in
      public|internal|restricted) ;;
      *) echo "FAIL  $path  invalid classification: $classification"; FAIL=1 ;;
    esac
  fi
done < <(jq -r '.assets[] | [.path, (.owner // ""), (.classification // ""), (.status // "active")] | @tsv' "$MANIFEST")

if [[ $FAIL -eq 0 ]]; then
  echo "governance.sh: OK"
  exit 0
else
  echo "governance.sh: FAIL"
  exit 1
fi
