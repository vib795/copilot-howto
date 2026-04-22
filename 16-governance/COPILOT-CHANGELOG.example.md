# Copilot Assets Changelog

All notable changes to Copilot assets (prompts, skills, agents, chatmodes, instructions, workflows, configuration) are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added
- (example) `.github/agents/perf-diagnose.agent.md` — specialised performance-diagnosis agent
- (example) `.github/skills/canary-rollout/SKILL.md` — canary deploy runbook

### Changed
- (example) `review.prompt.md` — now uses `slot/code` instead of hardcoded `claude-sonnet-4-5`

### Deprecated
- (example) `.github/prompts/old-deploy.prompt.md` — superseded by helm-upgrade skill; removal scheduled 2026-06-15

### Removed
- (example) `.github/chatmodes/legacy-reviewer.chatmode.md` — replaced by code-reviewer.chatmode.md (deprecated 2026-02-10)

### Security
- (example) `copilot-mcp-profiles.json` — `elevated` profile now denies `kubernetes.delete_namespace`

---

## [1.0.0] — 2026-04-15

### Added

- Asset manifest (`.github/copilot-asset-manifest.json`) — single source of truth for all Copilot assets with owner + classification
- Model compatibility matrix (`.github/model-compatibility.json`) — defines available models, capabilities, slots, fallback policy
- MCP least-privilege profiles (`.github/copilot-mcp-profiles.json`) — three-tier: read-only (default), standard, elevated
- Evaluation harness (`.github/eval/checks/`) — deterministic checks for naming, frontmatter, model-refs, manifest-sync, governance, doc-consistency, deprecation, tool-refs
- CI eval workflow (`.github/workflows/copilot-eval.yml`) — runs validation on PRs touching Copilot assets
- Hooks workflow (`.github/workflows/copilot-hooks.yml`) — pre/post-action policy gates
- Setup-steps workflow (`.github/workflows/copilot-setup-steps.yml`) — bootstraps the coding-agent toolchain
- Governance guide (`.github/GOVERNANCE.md`) — lifecycle process for adding, deprecating, transferring ownership
- Policy check: destructive commands (`.github/hooks/scripts/destructive-commands.sh`)
- Policy check: broad permissions (`.github/hooks/scripts/broad-permissions.sh`)
- Policy check: secret hygiene (`.github/hooks/scripts/secret-hygiene.sh`)

- Prompts (8): review, fix-issue, deploy, architect, security-scan, document, explain-codebase, test-gen
- Skills (4): helm-upgrade, debug-eks, terraform-plan, incident-triage
- Chatmodes (6): code-reviewer, security-auditor, architect, devops-assistant, longcontext-reader, test-writer
- Agents (3): plan, implement, review

- Operator scripts: copilot-discover.sh, copilot-health.sh, copilot-onboarding.sh

### Changed

- `copilot-instructions.md` — added governance references, model compatibility link, MCP security posture

### Deprecated

- None

### Removed

- None

### Security

- MCP server `postgres` configured to use `DB_READONLY_URL` — never the prod primary
- `elevated` MCP profile explicitly denies: `github.delete_repository`, `kubernetes.delete_namespace`, `terraform.destroy`, `postgres.execute`

---

## Template for future entries

```markdown
## [YYYY-MM-DD]

### Added
- [asset-type] path — description

### Changed
- [asset-type] path — description of behavioural change

### Deprecated
- [asset-type] path — description — removal scheduled YYYY-MM-DD (60-day minimum)

### Removed
- [asset-type] path — description — deprecated on YYYY-MM-DD

### Security
- [asset-type] path — description of security-relevant change
```

---

## Rules

1. **Every PR that adds, changes, deprecates, or removes a Copilot asset must include a changelog entry.**
2. **Deprecation entries MUST include the scheduled removal date** (minimum 60 days out).
3. **Removal entries MUST reference the date the asset was deprecated.**
4. **Security entries are additive** — do not remove historical security entries; they're part of the audit trail.
5. **Version tags** (`[1.1.0]`, `[1.0.0]`) map to semver of the Copilot asset set, NOT of the product code.
