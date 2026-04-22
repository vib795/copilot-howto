#!/usr/bin/env bash
# copilot-discover.sh — map a natural-language task to the Copilot assets that handle it.
#
# Usage:
#   copilot-discover.sh                         # interactive menu
#   copilot-discover.sh "rollback the payment service"   # keyword match
#   copilot-discover.sh --list prompts          # list all prompts
#   copilot-discover.sh --list all              # list everything
#
# Relies on: .github/copilot-asset-manifest.json
# Requires: jq

set -uo pipefail

MANIFEST=".github/copilot-asset-manifest.json"

if [[ ! -f "$MANIFEST" ]]; then
  echo "error: $MANIFEST not found — run from repo root"
  exit 1
fi

print_asset() {
  local path="$1" type="$2" desc="$3" status="$4"
  local marker=""
  [[ "$status" == "deprecated" ]] && marker="  [DEPRECATED]"
  [[ "$status" == "removed" ]] && return
  printf "  %-8s  %s%s\n" "$type" "$path" "$marker"
  [[ -n "$desc" && "$desc" != "null" ]] && printf "            %s\n" "$desc"
}

list_by_type() {
  local want="$1"
  jq -r --arg t "$want" '.assets[] | select(.type == $t or $t == "all") | [.path, .type, .description, (.status // "active")] | @tsv' "$MANIFEST" |
  while IFS=$'\t' read -r path type desc status; do
    print_asset "$path" "$type" "$desc" "$status"
  done
}

search() {
  local query="$1"
  local query_lc="$(echo "$query" | tr '[:upper:]' '[:lower:]')"

  echo "Results for: $query"
  echo
  jq -r '.assets[] | [.path, .type, (.description // ""), (.status // "active"), (.tags // [] | join(","))] | @tsv' "$MANIFEST" |
  while IFS=$'\t' read -r path type desc status tags; do
    [[ "$status" == "removed" ]] && continue
    haystack="$(echo "$path $desc $tags" | tr '[:upper:]' '[:lower:]')"
    score=0
    for token in $query_lc; do
      if echo "$haystack" | grep -qF -- "$token"; then
        score=$((score + 1))
      fi
    done
    if (( score > 0 )); then
      # Also try to scan skill body for trigger phrases (descriptions are gold)
      print_asset "$path" "$type" "$desc" "$status"
    fi
  done
}

interactive_menu() {
  echo "Copilot asset discovery"
  echo "----------------------"
  echo "1) Search by keyword"
  echo "2) List all prompts"
  echo "3) List all skills"
  echo "4) List all chatmodes"
  echo "5) List all agents"
  echo "6) List everything"
  echo "q) Quit"
  echo
  read -rp "choice: " c
  case "$c" in
    1) read -rp "query: " q; search "$q" ;;
    2) list_by_type prompt ;;
    3) list_by_type skill ;;
    4) list_by_type chatmode ;;
    5) list_by_type agent ;;
    6) list_by_type all ;;
    q|Q) exit 0 ;;
    *) echo "unknown"; exit 1 ;;
  esac
}

if [[ $# -eq 0 ]]; then
  interactive_menu
elif [[ "$1" == "--list" ]]; then
  list_by_type "${2:-all}"
else
  search "$*"
fi
