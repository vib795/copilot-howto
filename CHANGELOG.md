# Changelog

## v2.1.0 — 2026-04-22

### Changed — Module numbering reflects pedagogical progression

All 14 non-terminal modules renumbered so reading the directory tree top-to-bottom teaches Copilot in the order a new user actually encounters features:

| New | Old | Module |
|---|---|---|
| 01 | 08 | Inline Suggestions |
| 02 | 09 | IDE Integration |
| 03 | 01 | Slash Commands |
| 04 | 04 | Chat Variables (unchanged) |
| 05 | 02 | Custom Instructions |
| 06 | 07 | CLI |
| 07 | 11 | Custom Prompts |
| 08 | 12 | Chat Modes |
| 09 | 13 | Skills |
| 10 | 14 | Agents |
| 11 | 15 | Multi-Model + MCP |
| 12 | 05 | GitHub Actions |
| 13 | 06 | Copilot Workspace |
| 14 | 03 | Extensions |
| 15 | 10 | Enterprise |
| 16 | 16 | Governance (unchanged) |

Progression: Foundations (01–06) → Team primitives (07–10) → Platform config (11) → Workflow integrations (12–14) → Org scale (15–16). All cross-references in README, CATALOG, INDEX, LEARNING-ROADMAP, QUICK_REFERENCE, and every module README updated.

LEARNING-ROADMAP now has **six levels** mapped to new module ranges (Foundations, Context & Persistence, Six Primitives, Platform, Workflow Integrations, Org-Scale).

---

## v2.0.0 — 2026-04-22

### Added — Six-primitive + governance coverage

Six new modules, inspired by the [copilot-anatomy](https://github.com/vib795/copilot-anatomy) reference. Brings the repo to full April 2026 GitHub Copilot feature coverage.

- `07-custom-prompts/` — Custom slash commands via `.github/prompts/*.prompt.md` (8 production-ready templates: review, fix-issue, deploy, architect, security-scan, document, explain-codebase, test-gen, plus a frontmatter reference)
- `08-chat-modes/` — Persistent personas via `.github/chatmodes/*.chatmode.md` (6 templates: code-reviewer, security-auditor, architect, devops-assistant, longcontext-reader, test-writer)
- `09-skills/` — Auto-discovered runbooks via `.github/skills/<name>/SKILL.md` (4 runbooks: helm-upgrade, debug-eks, terraform-plan, incident-triage; plus a description-writing guide and SKILL.md anatomy reference)
- `10-agents/` — Autonomous multi-step agents via `.github/agents/*.agent.md` (plan → implement → review chain with handoffs; full tools reference and chain-pattern catalogue)
- `11-multi-model-mcp/` — Multi-model routing, MCP servers, `.copilotignore`, least-privilege profiles (settings.json, mcp.json, model-compatibility.json, copilot-mcp-profiles.json, extensions.json examples; model-routing and MCP-profile guides)
- `16-governance/` — Asset manifest, changelog, GOVERNANCE.md, eval checks, policy hooks, CI workflows (8 eval check scripts, 3 policy hook scripts, 3 workflows, 3 operator scripts: copilot-discover, copilot-health, copilot-onboarding)

### Changed

- `README.md` — module map now covers 16 modules, six-primitives mental model added, Feature Gaps table updated (MCP is now supported; agents/skills/hooks reflect actual April 2026 state)
- `CATALOG.md` — added sections for custom prompts, chat modes, skills, agents, multi-model routing, MCP, governance
- `LEARNING-ROADMAP.md` — added Level 4 (advanced primitives) and Level 5 (platform / governance) paths
- `INDEX.md` — new module entries with file-by-file descriptions
- `QUICK_REFERENCE.md` — added quick refs for the new primitives

### Security

- New governance hooks — `destructive-commands.sh`, `broad-permissions.sh`, `secret-hygiene.sh` — gate agent actions via `copilot-hooks.yml`
- `copilot-mcp-profiles.json` ships with deny-by-default `kubernetes.delete_namespace`, `terraform.destroy`, `github.delete_repository` in the `elevated` profile

---

## v1.0.0 — 2026-04-05

### Initial Release

Converted from claude-howto to copilot-howto. 10 modules covering all major GitHub Copilot features.

**Modules at v1.0.0 (note: these used the original numbering; see v2.1.0 for the remap):**

- `01-slash-commands/` — Built-in slash commands: /explain, /fix, /tests, /doc, /new, /simplify
- `02-custom-instructions/` — Project-level and user-level custom instructions
- `03-extensions/` — Skillset and agent extension scaffolds
- `04-chat-variables/` — Chat participants and context variables
- `05-github-actions/` — GitHub Actions + Copilot integration workflows
- `06-copilot-workspace/` — Copilot Workspace guide and examples
- `07-cli/` — gh copilot CLI reference
- `08-inline-suggestions/` — Inline suggestions, ghost text, and Next Edit Suggestions
- `09-ide-integration/` — IDE setup guides for VS Code, JetBrains, Neovim, and Xcode
- `10-enterprise/` — Enterprise policies, content exclusion, audit logs, SSO

**Root files added:**

- `copilot_concepts_guide.md` — Deep-dive concepts reference (request pipeline, context window, extension architecture, enterprise controls)
- `.github/copilot-instructions.md` — Live custom instructions example, auto-loaded by Copilot for all chat in this repo
- `INDEX.md` — Complete file index (~80 files across 10 modules)
- `CATALOG.md` — Feature catalog with lookup tables for all Copilot features
