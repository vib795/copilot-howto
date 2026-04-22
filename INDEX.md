# Copilot How-To: Complete File Index

> **16 modules · ~150 files · complete GitHub Copilot coverage (April 2026)**
>
> This index is the fastest way to find a specific file in the repository. Each entry links to the file and describes its purpose in one line.

---

## Repository Stats

| Stat | Value |
|---|---|
| Modules | 16 |
| Total files (approx.) | ~150 |
| Coverage | Foundations (01–06); the six primitives: prompts, chat modes, skills, agents (07–10); multi-model routing + MCP + `.copilotignore` (11); workflow integrations (12–14); org-scale: enterprise + governance (15–16) |

---

## Module 01 — Inline Suggestions

`01-inline-suggestions/`

| File | Description |
|---|---|
| `README.md` | Complete inline suggestions guide — ghost text, triggers, accepting and dismissing, IDE differences |
| `acceptance-shortcuts.md` | Keyboard shortcuts for accepting, dismissing, and cycling suggestions by IDE (VS Code, JetBrains, Neovim, Xcode) |
| `next-edit-suggestions.md` | Copilot Next Edit Suggestions (NES): how it predicts your next edit location, enabling/disabling |
| `effective-prompting-for-completion.md` | Writing code comments and function signatures that produce better inline completions |
| `settings-reference.md` | VS Code settings reference for inline suggestions: all `github.copilot.*` settings with descriptions |

---

## Module 02 — IDE Integration

`02-ide-integration/`

| File | Description |
|---|---|
| `README.md` | IDE overview: which IDEs are supported, feature availability summary, choosing an IDE |
| `vscode-setup.md` | VS Code complete setup: extension install, authentication, settings, keybindings, Insiders vs. Stable |
| `jetbrains-setup.md` | JetBrains IDEs setup: plugin install for IntelliJ, PyCharm, WebStorm, GoLand, and others |
| `neovim-setup.md` | Neovim setup guide for both `copilot.vim` and `copilot.lua` with recommended configurations |
| `xcode-setup.md` | Xcode setup: GitHub Copilot for Xcode extension install, configuration, and Swift-specific tips |
| `feature-matrix.md` | Feature availability by IDE: which features work in which editors (complete comparison table) |

---

## Module 03 — Slash Commands

`03-slash-commands/`

| File | Description |
|---|---|
| `README.md` | Complete slash commands guide — all built-in commands, when to use each, and how to combine them |
| `explain-with-context.md` | `/explain` patterns: using `#file`, `#selection`, and `@workspace` to give Copilot the right context |
| `fix-with-selection.md` | `/fix` patterns for bugs, type errors, and test failures — with before/after examples |
| `generate-tests.md` | `/tests` workflow: generating unit tests, integration tests, and edge case coverage |
| `generate-docs.md` | `/doc` generation patterns for functions, classes, APIs, and README sections |
| `new-component.md` | `/new` scaffolding examples: React components, Express routes, CLI tools |
| `simplify-refactor.md` | `/simplify` refactoring patterns: reducing complexity, removing duplication, improving readability |
| `chaining-commands.md` | Chaining multiple slash commands in sequence to complete multi-step workflows |

---

## Module 04 — Chat Variables

`04-chat-variables/`

| File | Description |
|---|---|
| `README.md` | Complete chat variables guide — all variables, resolution mechanics, token cost considerations |
| `workspace-patterns.md` | `@workspace` effective use patterns: project comprehension, cross-file questions, architecture queries |
| `file-context-patterns.md` | `#file` multi-file context patterns: referencing multiple files, large file strategies |
| `terminal-integration.md` | `@terminal` and `#terminalLastCommand` patterns for debugging build failures and runtime errors |
| `combining-variables.md` | Combining multiple context variables in a single prompt for complex questions |

---

## Module 05 — Custom Instructions

`05-custom-instructions/`

| File | Description |
|---|---|
| `README.md` | Complete custom instructions guide — project-level and user-level, effectiveness patterns, token budget |
| `project-copilot-instructions.md` | Production-ready template for `.github/copilot-instructions.md` with annotated sections |
| `personal-instructions-vscode.jsonc` | VS Code user-level settings snippet for `codeGeneration.instructions` and `testGeneration.instructions` |
| `scoped-instructions-api.md` | Directory-level instruction workarounds: patterns for repos with multiple languages or teams |

---

## Module 06 — CLI

`06-cli/`

| File | Description |
|---|---|
| `README.md` | `gh copilot` CLI complete reference — all commands, flags, output formats |
| `suggest-patterns.md` | `gh copilot suggest` examples: shell commands, git operations, system administration |
| `explain-patterns.md` | `gh copilot explain` examples: understanding unfamiliar commands, documenting scripts |
| `installation.md` | Installation and setup: `gh` CLI prerequisites, extension install, authentication |
| `scripting-with-cli.md` | Using `gh copilot` in shell scripts and CI/CD pipelines — automation patterns and limitations |

---

## Module 07 — Custom Prompts

`07-custom-prompts/`

| File | Description |
|---|---|
| `README.md` | Custom slash commands via `.github/prompts/*.prompt.md` — frontmatter, modes (ask/edit/agent), pinning models |
| `review.prompt.md` | `/review` — five-lens PR review (correctness / security / performance / style / tests), model: `claude-sonnet-4-5` |
| `fix-issue.prompt.md` | `/fix-issue` — root-cause diagnosis + minimal fix + regression test, mode: edit |
| `deploy.prompt.md` | `/deploy` — pre-deploy checklist + Helm/kubectl commands, model: `gpt-4.1` |
| `architect.prompt.md` | `/architect` — trade-off analysis + ADR document, model: `o3` |
| `security-scan.prompt.md` | `/security-scan` — OWASP + threat model audit, model: `claude-opus-4-5` |
| `document.prompt.md` | `/document` — idiomatic Javadoc / GoDoc / docstrings by language |
| `explain-codebase.prompt.md` | `/explain-codebase` — codebase explanation using Gemini 2.5 Pro's 1M context |
| `test-gen.prompt.md` | `/test-gen` — comprehensive tests with happy paths, edge cases, error paths |
| `frontmatter-reference.md` | Every prompt-file frontmatter field: description, mode, model, tools, temperature, tags, owner, classification |

---

## Module 08 — Chat Modes

`08-chat-modes/`

| File | Description |
|---|---|
| `README.md` | Persistent personas via `.github/chatmodes/*.chatmode.md` — difference from prompts/agents, how loading works |
| `code-reviewer.chatmode.md` | Staff engineer code reviewer persona, model: `claude-sonnet-4-5` |
| `security-auditor.chatmode.md` | Deep security audit persona, model: `claude-opus-4-5`, classification: restricted |
| `architect.chatmode.md` | Systems architect persona with trade-off discipline, model: `o3` |
| `devops-assistant.chatmode.md` | DevOps / SRE troubleshooter — commands first, explanations after, model: `gpt-4.1` |
| `longcontext-reader.chatmode.md` | Codebase-onboarding persona using Gemini 2.5 Pro's 1M context |
| `test-writer.chatmode.md` | TDD-style test-writing pair, model: `claude-sonnet-4-5` |
| `enabling-chatmodes.md` | Troubleshooting: why the mode picker is empty, frontmatter validation, MCP env issues |

---

## Module 09 — Skills

`09-skills/`

| File | Description |
|---|---|
| `README.md` | Auto-discovered runbooks via `.github/skills/<name>/SKILL.md` — how description-based triggering works |
| `helm-upgrade/SKILL.md` | Helm deploy, rollback, and release runbook |
| `debug-eks/SKILL.md` | Kubernetes pod and node debugging (CrashLoopBackOff, OOMKilled, ImagePullBackOff, etc.) |
| `debug-eks/common-errors.md` | Lookup table of K8s error messages → causes → fixes |
| `terraform-plan/SKILL.md` | Safe `tofu plan` / `apply` runbook with state-lock, drift, and destructive-operation gates |
| `incident-triage/SKILL.md` | Incident response and postmortem workflow |
| `incident-triage/postmortem-template.md` | Blameless postmortem template (summary, timeline, root cause, action items) |
| `incident-triage/runbook.sh` | Capture pod + events + logs evidence during an incident |
| `description-writing-guide.md` | How to write `description:` fields that actually trigger |
| `skill-anatomy.md` | Every SKILL.md field, body conventions, bundled resources, discovery path |

---

## Module 10 — Agents

`10-agents/`

| File | Description |
|---|---|
| `README.md` | Autonomous agents via `.github/agents/*.agent.md` — plan → implement → review chain, handoffs, separation of duties |
| `plan.agent.md` | Plan agent: read-only, produces file-by-file plan, model: `o3`, hands off to `implement` |
| `implement.agent.md` | Implement agent: executes plan, runs tests, iterates on failures, model: `claude-sonnet-4-5` |
| `review.agent.md` | Review agent: READ-ONLY by design, five-lens review, model: `claude-opus-4-5` |
| `handoff-chains.md` | Chain patterns beyond plan→implement→review (security-gated, research→plan, perf-investigation, docs) |
| `tools-reference.md` | Full catalogue of tool names available in `tools:` frontmatter, by MCP server |

---

## Module 11 — Multi-Model + MCP

`11-multi-model-mcp/`

| File | Description |
|---|---|
| `README.md` | Named model slots, `.vscode/mcp.json`, `.copilotignore`, MCP profiles — the configuration layer that ties the primitives together |
| `settings.json.example` | Team `.vscode/settings.json` with named model slots (slot/fast, slot/code, slot/thorough, slot/longctx, etc.) |
| `mcp.json.example` | `.vscode/mcp.json` with common MCP servers (github, filesystem, kubernetes, postgres, brave-search, memory) |
| `model-compatibility.json` | Model matrix (o3, o4-mini, gpt-4.1, claude-sonnet-4-5, claude-opus-4-5, claude-haiku-4-5, gemini-2.5-pro, gemini-2.0-flash) with capabilities, premium multipliers, and fallback policy |
| `copilot-mcp-profiles.json` | Three-tier least-privilege MCP profiles: read-only, standard, elevated |
| `copilotignore.example` | Full `.copilotignore` template (build artefacts, secrets, generated code, IDE noise) |
| `extensions.json.example` | `.vscode/extensions.json` recommended extensions list |
| `model-routing-guide.md` | Task → model mapping with rationale (when to use o3 vs Sonnet vs Opus vs Gemini Pro) |
| `mcp-profiles.md` | Least-privilege profile pattern in detail: inheritance, precedence, auditing |

---

## Module 12 — GitHub Actions

`12-github-actions/`

| File | Description |
|---|---|
| `README.md` | GitHub Actions + Copilot integration guide — Copilot coding agent, workflow triggers, best practices |
| `pr-review-workflow.yml` | Automated PR code review workflow using Copilot coding agent |
| `security-scan-workflow.yml` | Security scanning workflow with Copilot-generated fix suggestions |
| `format-check-workflow.yml` | Code format validation workflow with automated Copilot fix PR creation |
| `test-on-push-workflow.yml` | Test runner with Copilot-generated failure summary comments on PRs |
| `pr-description-workflow.yml` | Auto-generate PR descriptions from diff using Copilot coding agent |
| `copilot-in-actions.md` | Guide to using the Copilot coding agent in GitHub Actions: setup, configuration, limitations |

---

## Module 13 — Copilot Workspace

`13-copilot-workspace/`

| File | Description |
|---|---|
| `README.md` | Copilot Workspace complete guide — browser UI, plan format, iterating on plans, opening in Codespaces |
| `workspace-examples.md` | Real-world Workspace scenarios: adding a feature, fixing a bug, refactoring a module |
| `task-specification-guide.md` | Writing effective task specifications: issue format, level of detail, what Workspace needs to succeed |
| `vs-code-timeline.md` | Using VS Code Timeline as a lightweight checkpoint alternative when Workspace is not available |

---

## Module 14 — Extensions

`14-extensions/`

| File | Description |
|---|---|
| `README.md` | Complete extensions guide — GitHub App setup, skillset vs. agent, registration walkthrough |
| `skillset-extension-scaffold/README.md` | Skillset extension setup guide: prerequisites, registration steps, testing with ngrok |
| `skillset-extension-scaffold/index.js` | Express server implementing a skillset extension endpoint with signature verification |
| `skillset-extension-scaffold/skillset-definition.yaml` | Skills definition file: function names, parameter schemas, descriptions |
| `agent-extension-scaffold/README.md` | Agent extension setup guide: SSE streaming, conversational loop, error handling |
| `agent-extension-scaffold/index.js` | Express server implementing an agent extension with SSE response streaming |
| `code-review-extension.md` | Full worked example: a code review extension that integrates with a GitHub PR workflow |
| `marketplace-extensions.md` | Curated list of public Copilot extensions from the GitHub Marketplace with use cases |

---

## Module 15 — Enterprise

`15-enterprise/`

| File | Description |
|---|---|
| `README.md` | Enterprise features overview: seat management, policy hierarchy, audit logs, content exclusion |
| `content-exclusion.md` | Excluding files from Copilot: glob patterns, testing exclusions, org vs. repo level |
| `policy-management.md` | Managing org and enterprise policies: allowed IDEs, model selection, network requirements |
| `audit-logs.md` | Querying Copilot audit logs via API and the GitHub web UI — fields, filters, export formats |
| `network-proxy.md` | Proxy and firewall configuration: required endpoints, certificate pinning, MITM proxy considerations |
| `sso-setup.md` | SAML and OIDC SSO integration: seat provisioning with SCIM, deprovisioning, IdP-specific notes |

---

## Module 16 — Governance

`16-governance/`

| File | Description |
|---|---|
| `README.md` | Governance overview: manifest, changelog, eval checks, hooks, workflows — end-to-end flow diagram |
| `copilot-asset-manifest.json.example` | Single source of truth — every prompt, skill, chatmode, agent with owner + classification |
| `COPILOT-CHANGELOG.example.md` | Keep a Changelog format for Copilot-asset changes |
| `GOVERNANCE.example.md` | Lifecycle process: add, modify, deprecate, remove, transfer ownership |
| `asset-lifecycle.md` | Worked example — full add → deprecate → remove cycle with eval output at each step |
| `eval/checks/naming.sh` | Validate kebab-case file names and correct extensions |
| `eval/checks/frontmatter.sh` | Validate required YAML frontmatter fields per asset type |
| `eval/checks/model-refs.sh` | `model:` references resolve to a registered model or slot |
| `eval/checks/manifest-sync.sh` | Filesystem ↔ manifest consistency (no orphan files, no missing files) |
| `eval/checks/governance.sh` | Every manifest entry has `owner` + valid `classification` |
| `eval/checks/doc-consistency.sh` | Scan for stale references (slots, handoffs, agent names that don't exist) |
| `eval/checks/deprecation.sh` | Enforce 60-day minimum grace period between deprecation and removal |
| `eval/checks/tool-refs.sh` | Agent `tools:` entries resolve to real MCP-server tools |
| `hooks/scripts/destructive-commands.sh` | Pre-action hook: warn/fail on `rm -rf /`, `DROP TABLE`, `terraform destroy`, etc. |
| `hooks/scripts/broad-permissions.sh` | Pre-action hook: warn/fail on IAM `"*"`, `cluster-admin`, `Owner`/`Contributor` roles |
| `hooks/scripts/secret-hygiene.sh` | Pre-action hook: scan for API key patterns, private keys, JWTs in diffs |
| `workflows/copilot-eval.yml` | CI workflow — runs every eval check on PRs touching Copilot assets |
| `workflows/copilot-hooks.yml` | CI workflow — pre/post-action policy gates invoked by the Copilot coding agent |
| `workflows/copilot-setup-steps.yml` | CI workflow — bootstrap the coding agent's toolchain (Java, Go, Python, Helm, kubectl, tofu) |
| `scripts/copilot-discover.sh` | Task → asset mapping CLI with keyword search and interactive menu |
| `scripts/copilot-health.sh` | Health dashboard: JSON canonical + Markdown summary of asset coverage and eval pass rate |
| `scripts/copilot-onboarding.sh` | Role-based onboarding CLI for new hires (developer / reviewer / platform / novice paths) |

---

## Root Files

| File | Description |
|---|---|
| `README.md` | Main guide: repository overview, quick start, how to navigate the modules |
| `LEARNING-ROADMAP.md` | Progressive learning path from beginner to advanced with time estimates per module |
| `INDEX.md` | This file — complete repository file index |
| `CATALOG.md` | Feature catalog and reference tables: look up any Copilot feature and find where it lives |
| `QUICK_REFERENCE.md` | One-page cheat sheet: most-used commands, shortcuts, and variables |
| `copilot_concepts_guide.md` | Deep-dive concepts reference: request pipeline, context window, extensions architecture, enterprise policies |
| `.github/copilot-instructions.md` | Live custom instructions example — auto-loaded by Copilot for all chat interactions in this repo |
