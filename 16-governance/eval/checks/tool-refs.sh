#!/usr/bin/env bash
# tool-refs.sh — validate that every tool listed in an agent's `tools:` frontmatter
# resolves to a tool exposed by an active MCP server in .vscode/mcp.json, or is a
# core Copilot tool (read_file, write_file, run_terminal_command, etc.).
#
# This is a best-effort check; MCP servers publish their tool list at runtime and
# we can't introspect without running them. We maintain a manually-curated list
# of known tool patterns per server.

set -uo pipefail

FAIL=0
MCP=".vscode/mcp.json"

echo "tool-refs.sh"

# Core tools always available in agent mode
CORE_TOOLS=(
  read_file write_file list_files run_terminal_command
  search_workspace get_symbol_info
)

# Known tool prefixes by MCP server (updated as servers add features)
declare -A KNOWN_PREFIXES=(
  [github]="github.get_issue github.list_issues github.get_pull_request github.list_pull_requests github.list_pull_request_files github.get_pull_request_comments github.search_code github.get_workflow_run github.list_workflow_runs github.get_commit github.create_branch github.create_commit github.create_pull_request github.add_pull_request_comment github.add_pull_request_review github.close_issue github.merge_pull_request github.delete_branch github.delete_repository"
  [filesystem]="filesystem.read filesystem.write filesystem.list filesystem.exists"
  [kubernetes]="kubernetes.list_pods kubernetes.get_pod kubernetes.get_logs kubernetes.describe_resource kubernetes.get_events kubernetes.list_deployments kubernetes.list_services kubernetes.get_config_map kubernetes.apply kubernetes.rollout_restart kubernetes.scale_deployment kubernetes.delete_resource kubernetes.delete_namespace"
  [postgres]="postgres.list_tables postgres.describe_table postgres.query postgres.explain postgres.execute"
  [brave-search]="brave.search brave.fetch"
  [memory]="memory.store memory.recall memory.forget"
  [aws-docs]="aws_docs.search"
)

active_servers() {
  [[ -f "$MCP" ]] || return
  jq -r '.servers | to_entries[] | select(.key | test("-DISABLED$") | not) | .key' "$MCP" 2>/dev/null
}

SERVERS=($(active_servers))

is_known_tool() {
  local tool="$1"
  # Wildcard or namespace wildcard?
  [[ "$tool" == "*" ]] && return 0
  # Core?
  for c in "${CORE_TOOLS[@]}"; do [[ "$c" == "$tool" ]] && return 0; done
  # Namespace wildcard: github.* -> is github in active servers?
  if [[ "$tool" == *.\* ]]; then
    local ns="${tool%.*}"
    for s in "${SERVERS[@]}"; do [[ "$s" == "$ns" ]] && return 0; done
    return 1
  fi
  # Namespaced tool: match against KNOWN_PREFIXES of an active server
  local ns="${tool%%.*}"
  for s in "${SERVERS[@]}"; do
    if [[ "$s" == "$ns" ]]; then
      # Accept any tool from an active server at best-effort; optional: check KNOWN_PREFIXES
      local known="${KNOWN_PREFIXES[$ns]:-}"
      [[ -z "$known" ]] && return 0
      local found=0
      for k in $known; do
        # Allow trailing wildcards: github.get_*
        if [[ "$k" == "$tool" ]]; then found=1; break; fi
        if [[ "$tool" == *\* ]]; then
          local tpre="${tool%\*}"
          [[ "$k" == ${tpre}* ]] && { found=1; break; }
        fi
      done
      (( found == 1 )) && return 0
    fi
  done
  return 1
}

extract_tools() {
  # Emit each tool on its own line from the tools: block in a frontmatter
  awk '
    /^---$/ {c++; next}
    c==1 && /^tools:/ {in=1; next}
    c==1 && in && /^[^[:space:]-]/ {in=0}
    c==1 && in && /^[[:space:]]*-/ {
      gsub(/^[[:space:]]*-[[:space:]]*/, "")
      gsub(/[[:space:]]*#.*$/, "")
      gsub(/["\x27]/, "")
      print
    }
    c>1 {exit}
  ' "$1"
}

check_file() {
  local f="$1"
  while IFS= read -r t; do
    [[ -z "$t" ]] && continue
    if ! is_known_tool "$t"; then
      echo "FAIL  $f  unknown tool: $t"
      FAIL=1
    fi
  done < <(extract_tools "$f")
}

for d in .github/agents .github/prompts .github/chatmodes; do
  [[ -d "$d" ]] || continue
  while IFS= read -r -d '' f; do
    check_file "$f"
  done < <(find "$d" -type f \( -name "*.agent.md" -o -name "*.prompt.md" -o -name "*.chatmode.md" \) -print0)
done

if [[ $FAIL -eq 0 ]]; then
  echo "tool-refs.sh: OK"
  exit 0
else
  echo "tool-refs.sh: FAIL  — update .vscode/mcp.json or KNOWN_PREFIXES table in this script"
  exit 1
fi
