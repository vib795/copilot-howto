#!/usr/bin/env bash
# copilot-onboarding.sh — interactive onboarding for new team members.
#
# - Verifies prerequisites (VS Code, Copilot extension, MCP env vars)
# - Shows a role-based quick start (developer / reviewer / platform)
# - Points at the right docs and the right first commands to try

set -uo pipefail

BOLD=$'\033[1m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RESET=$'\033[0m'

ok()   { echo "${GREEN}✓${RESET} $*"; }
warn() { echo "${YELLOW}!${RESET} $*"; }
fail() { echo "${RED}✗${RESET} $*"; }

section() { echo; echo "${BOLD}== $* ==${RESET}"; }

check_prereq() {
  local label="$1"; shift
  if "$@" >/dev/null 2>&1; then
    ok "$label"
  else
    fail "$label"
    return 1
  fi
}

section "Prerequisites"
check_prereq "VS Code installed"               command -v code
check_prereq "GitHub CLI installed"            command -v gh
check_prereq "jq installed"                    command -v jq
check_prereq "Node.js 18+ (for MCP servers)"   node --version
check_prereq "Copilot extension configured"    gh auth status
check_prereq "GITHUB_TOKEN set in env"         [ -n "${GITHUB_TOKEN:-}" ] && true

if [[ -n "${KUBECONFIG:-}" ]]; then ok "KUBECONFIG set"; else warn "KUBECONFIG not set (OK if you don't use Kubernetes)"; fi
if [[ -n "${DB_READONLY_URL:-}" ]]; then ok "DB_READONLY_URL set"; else warn "DB_READONLY_URL not set (OK if you don't use the postgres MCP)"; fi

section "Workspace files"
for f in .github/copilot-instructions.md .vscode/settings.json .vscode/mcp.json .copilotignore .github/copilot-asset-manifest.json; do
  if [[ -f "$f" ]]; then ok "$f"; else warn "missing: $f"; fi
done

section "Role"
echo "  1) Developer (writing code day to day)"
echo "  2) Reviewer (reviewing PRs, security, architecture)"
echo "  3) Platform / SRE (deploys, infra, incident response)"
echo "  4) New to Copilot (skip role for now)"
echo
read -rp "choose [1-4]: " role

case "$role" in
  1)
    cat <<EOF

${BOLD}Developer quick start${RESET}

Try these in Copilot Chat:

  /review                          — five-lens PR review of your current changes
  /fix-issue                       — root-cause-fix your current failing test
  /test-gen                        — generate tests for selected code

Chat modes (pick from the dropdown):
  Code reviewer                    — for conversations about a PR
  Test writer                      — for TDD sessions

Recommended reading:
  01-slash-commands/README.md
  02-custom-instructions/README.md
  11-custom-prompts/README.md
  12-chat-modes/README.md
EOF
    ;;
  2)
    cat <<EOF

${BOLD}Reviewer quick start${RESET}

Try these in Copilot Chat:

  /review                          — five-lens review
  /security-scan                   — OWASP + threat model audit
  /architect                       — trade-off analysis + ADR

Chat modes:
  Code reviewer                    — PR review conversations
  Security auditor                 — deep audit sessions (model: claude-opus-4-5)
  Architect                        — system design conversations (model: o3)

Recommended reading:
  11-custom-prompts/README.md
  12-chat-modes/README.md
  16-governance/README.md
EOF
    ;;
  3)
    cat <<EOF

${BOLD}Platform / SRE quick start${RESET}

Your MCP profile should be 'elevated' — confirm with:
  echo \$COPILOT_MCP_PROFILE

Try these:

  /deploy                          — pre-deploy checklist + Helm commands

Chat modes:
  DevOps assistant                 — fast, pragmatic troubleshooting

Skills auto-load when relevant:
  helm-upgrade                     — deploy / rollback / release
  debug-eks                        — pod / node debugging
  terraform-plan                   — infra changes
  incident-triage                  — during incidents

Recommended reading:
  13-skills/README.md
  14-agents/README.md
  15-multi-model-mcp/mcp-profiles.md
  16-governance/README.md
EOF
    ;;
  4|*)
    cat <<EOF

${BOLD}Copilot orientation${RESET}

Start with the introductory modules:
  01-slash-commands/README.md      — built-in commands (/explain, /fix, ...)
  02-custom-instructions/README.md — the file that shapes every response
  04-chat-variables/README.md      — #file, @workspace, #selection

Then the reusable primitives:
  11-custom-prompts/README.md      — your team's own /commands
  12-chat-modes/README.md          — persistent personas
  13-skills/README.md              — auto-discovered runbooks

Finally, the multi-model + governance layer:
  15-multi-model-mcp/README.md
  16-governance/README.md
EOF
    ;;
esac

echo
section "Next"
echo "  Read the module(s) above, then come back and run:"
echo "    bash 16-governance/scripts/copilot-discover.sh"
echo "  to browse the assets in this repo."
