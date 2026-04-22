# GitHub Copilot Feature Catalog

Use this as a reference when you know what you want to do but need to find the right Copilot feature. Each section covers a category of features with a lookup table mapping capabilities to the module that covers them.

---

## Section 1: Built-in Slash Commands

Slash commands are available in Copilot Chat. Type `/` to see the command picker.

| Command | What it does | Key context to add | Module |
|---|---|---|---|
| `/explain` | Explains selected code, a file, or a concept in plain language | `#selection` for a specific block; `#file` for a whole file; `@workspace` for project-wide understanding | `03-slash-commands/explain-with-context.md` |
| `/fix` | Identifies and fixes bugs, type errors, and logic problems in the selection | `#selection` of the broken code; `#terminalLastCommand` for a runtime error | `03-slash-commands/fix-with-selection.md` |
| `/tests` | Generates unit or integration tests for selected code | `#selection` of the function or class; `#file` of the module under test | `03-slash-commands/generate-tests.md` |
| `/doc` | Generates inline documentation (JSDoc, docstrings, etc.) for selected code | `#selection` of the function or class to document | `03-slash-commands/generate-docs.md` |
| `/new` | Scaffolds a new file, component, or module from a description | Description of what to create; optionally `#file` of a similar existing component | `03-slash-commands/new-component.md` |
| `/simplify` | Reduces complexity, removes duplication, and improves readability of selected code | `#selection` of the code to simplify | `03-slash-commands/simplify-refactor.md` |
| `/clear` | Clears the current Copilot Chat conversation history | None — use this when changing topic to restore full context budget | `03-slash-commands/README.md` |

---

## Section 2: Chat Participants

Chat participants are named actors prefixed with `@`. They have specialized context access beyond the current file.

| Participant | Scope | Best for | Module |
|---|---|---|---|
| `@workspace` | Entire VS Code workspace (semantic search over all files) | Cross-file questions, architecture questions, "where is X defined?" | `04-chat-variables/workspace-patterns.md` |
| `@terminal` | VS Code integrated terminal (recent output, current directory) | Debugging shell errors, explaining CLI output, writing shell commands | `04-chat-variables/terminal-integration.md` |
| `@vscode` | VS Code extension API and settings knowledge | Questions about VS Code configuration, keybindings, extension development | `02-ide-integration/vscode-setup.md` |
| `@github` | GitHub.com context: issues, PRs, repositories, discussions | Questions about a specific repo, PR, or issue by URL or reference | `12-github-actions/README.md` |
| `@extension-name` | Custom extension endpoint (skillset or agent) | Domain-specific actions: deployment status, ticket lookup, internal tooling | `14-extensions/README.md` |

---

## Section 3: Context Variables

Context variables are prefixed with `#` and inject specific content into your message. They are different from participants — they attach data, not behavior.

| Variable | What it attaches | Token cost (rough) | Module |
|---|---|---|---|
| `#file` | Full contents of one or more specific files, read at send time | Low to High (proportional to file size) | `04-chat-variables/file-context-patterns.md` |
| `#selection` | The text currently highlighted in the active editor | Very low (your selection only) | `03-slash-commands/README.md` |
| `#codebase` | Semantic search results from the workspace (top-ranked snippets) | Medium (typically 5–20 file sections) | `04-chat-variables/workspace-patterns.md` |
| `#terminalSelection` | Text currently selected in the VS Code integrated terminal | Very low | `04-chat-variables/terminal-integration.md` |
| `#terminalLastCommand` | The last command run in the terminal plus its full stdout/stderr output | Low to Medium (depends on output size) | `04-chat-variables/terminal-integration.md` |

---

## Section 4: Custom Instructions

Custom instructions let you establish persistent context and style rules without repeating them in every chat message.

| Level | File / Setting | Scope | Auto-loaded? | Module |
|---|---|---|---|---|
| Project-level | `.github/copilot-instructions.md` at repository root | All users in that repository | Yes — prepended to every chat request automatically | `05-custom-instructions/project-copilot-instructions.md` |
| User-level — code generation | `github.copilot.chat.codeGeneration.instructions` in VS Code `settings.json` | That user only, across all repositories | Yes — appended on top of project instructions | `05-custom-instructions/personal-instructions-vscode.jsonc` |
| User-level — test generation | `github.copilot.chat.testGeneration.instructions` in VS Code `settings.json` | That user only, scoped to `/tests` and test generation requests | Yes — used specifically for test generation tasks | `05-custom-instructions/personal-instructions-vscode.jsonc` |

---

## Section 5: GitHub Actions Patterns

These workflow files in `12-github-actions/` are ready to use. Copy into `.github/workflows/` and adjust the trigger and permissions to match your repository.

| Workflow | Trigger | Purpose | File |
|---|---|---|---|
| PR code review | `pull_request` (opened, synchronize) | Copilot coding agent reviews the PR diff and posts a review comment | `12-github-actions/pr-review-workflow.yml` |
| Security scan | `push` to main, `pull_request` | Scans code for security issues and posts Copilot-generated fix suggestions | `12-github-actions/security-scan-workflow.yml` |
| Format check | `pull_request` | Validates code formatting and creates a fix PR if formatting is off | `12-github-actions/format-check-workflow.yml` |
| Test on push | `push`, `pull_request` | Runs the test suite and posts a Copilot-generated failure summary if tests fail | `12-github-actions/test-on-push-workflow.yml` |
| PR description | `pull_request` (opened) | Auto-generates a PR description from the diff using Copilot coding agent | `12-github-actions/pr-description-workflow.yml` |

---

## Section 6: Copilot CLI Commands

The `gh copilot` extension for the GitHub CLI provides AI assistance in the terminal. Install with `gh extension install github/gh-copilot`.

| Command | Description | Key flags | Module |
|---|---|---|---|
| `gh copilot suggest` | Suggests a shell command for a natural-language task | `-t shell` (default), `-t git`, `-t gh` to target a command type | `06-cli/suggest-patterns.md` |
| `gh copilot explain` | Explains what a shell command does in plain language | Pass the command as a quoted string argument | `06-cli/explain-patterns.md` |

---

## Section 7: Extension Types

| Type | Invocation | Best for | Module |
|---|---|---|---|
| Skillset extension | Copilot automatically routes relevant questions to your skill; no explicit user invocation needed | Read-only data retrieval from external systems (deployment status, metrics, tickets) | `14-extensions/skillset-extension-scaffold/` |
| Agent extension | User explicitly types `@your-extension-name` in Copilot Chat | Multi-turn conversations, write operations, complex workflows requiring full conversational control | `14-extensions/agent-extension-scaffold/` |
| Marketplace extension | User installs from GitHub Marketplace and invokes with `@extension-name` | Third-party integrations (Sentry, Datadog, Jira, etc.) without building your own extension | `14-extensions/marketplace-extensions.md` |

---

## Section 8: Custom Prompt Files (`.github/prompts/*.prompt.md`)

Your own slash commands. Copilot loads the file, honours its frontmatter, and runs it as `/filename`.

| Command | Mode | Model | File |
|---|---|---|---|
| `/review` | ask | `claude-sonnet-4-5` | `07-custom-prompts/review.prompt.md` |
| `/fix-issue` | edit | `claude-sonnet-4-5` | `07-custom-prompts/fix-issue.prompt.md` |
| `/deploy` | ask | `gpt-4.1` | `07-custom-prompts/deploy.prompt.md` |
| `/architect` | ask | `o3` | `07-custom-prompts/architect.prompt.md` |
| `/security-scan` | ask | `claude-opus-4-5` | `07-custom-prompts/security-scan.prompt.md` |
| `/document` | edit | `claude-sonnet-4-5` | `07-custom-prompts/document.prompt.md` |
| `/explain-codebase` | ask | `gemini-2.5-pro` | `07-custom-prompts/explain-codebase.prompt.md` |
| `/test-gen` | edit | `claude-sonnet-4-5` | `07-custom-prompts/test-gen.prompt.md` |

Frontmatter reference: `07-custom-prompts/frontmatter-reference.md`. Valid `mode` values are `ask` / `edit` / `agent`.

---

## Section 9: Chat Modes (`.github/chatmodes/*.chatmode.md`)

Persistent personas picked from the VS Code mode dropdown. Pinned `model` and `tools` for the entire session.

| Mode | Model | Use for | File |
|---|---|---|---|
| Code Reviewer | `claude-sonnet-4-5` | PR review conversations | `08-chat-modes/code-reviewer.chatmode.md` |
| Security Auditor | `claude-opus-4-5` | Deep audit sessions | `08-chat-modes/security-auditor.chatmode.md` |
| Architect | `o3` | System design, trade-offs | `08-chat-modes/architect.chatmode.md` |
| DevOps Assistant | `gpt-4.1` | Troubleshooting, commands | `08-chat-modes/devops-assistant.chatmode.md` |
| Long-Context Reader | `gemini-2.5-pro` | Codebase onboarding | `08-chat-modes/longcontext-reader.chatmode.md` |
| Test Writer | `claude-sonnet-4-5` | TDD, backfilling tests | `08-chat-modes/test-writer.chatmode.md` |

Requires: `"github.copilot.chat.experimental.chatModes": true` in `settings.json`.

---

## Section 10: Skills (`.github/skills/<name>/SKILL.md`)

Auto-discovered runbooks. Copilot reads `description:` from every skill; if it matches your request, the full runbook body is injected.

| Skill | Triggers on | File |
|---|---|---|
| `helm-upgrade` | deploy, upgrade, rollback, helm, image tag | `09-skills/helm-upgrade/SKILL.md` |
| `debug-eks` | CrashLoopBackOff, OOMKilled, ImagePullBackOff, kubectl | `09-skills/debug-eks/SKILL.md` |
| `terraform-plan` | tofu plan, terraform apply, state lock, drift | `09-skills/terraform-plan/SKILL.md` |
| `incident-triage` | production incident, alert firing, postmortem | `09-skills/incident-triage/SKILL.md` |

Description-writing guide: `09-skills/description-writing-guide.md`. Skill anatomy: `09-skills/skill-anatomy.md`.

---

## Section 11: Agents (`.github/agents/*.agent.md`)

Autonomous multi-step workers. The standard chain is `plan` → `implement` → `review`.

| Agent | Model | Tools | Hands off to | File |
|---|---|---|---|---|
| `plan` | `o3` | Read-only | `implement` | `10-agents/plan.agent.md` |
| `implement` | `claude-sonnet-4-5` | Read + Write + Terminal | `review` | `10-agents/implement.agent.md` |
| `review` | `claude-opus-4-5` | Read-only (enforced) | — | `10-agents/review.agent.md` |

Chain patterns: `10-agents/handoff-chains.md`. Tool catalogue: `10-agents/tools-reference.md`.

---

## Section 12: Multi-Model Routing and MCP

Configuration layer. Named model slots go in `.vscode/settings.json`; MCP servers go in `.vscode/mcp.json`; profiles filter tool access.

| File | Purpose |
|---|---|
| `11-multi-model-mcp/settings.json.example` | Team settings with named model slots (`slot/fast`, `slot/code`, `slot/thorough`, `slot/longctx`, etc.) |
| `11-multi-model-mcp/mcp.json.example` | MCP servers: github, filesystem, kubernetes, postgres, brave-search, memory |
| `11-multi-model-mcp/model-compatibility.json` | Model matrix: capabilities, context windows, premium multipliers, fallback policy |
| `11-multi-model-mcp/copilot-mcp-profiles.json` | Three-tier least-privilege profiles: read-only, standard, elevated |
| `11-multi-model-mcp/copilotignore.example` | `.copilotignore` template for context exclusion |
| `11-multi-model-mcp/extensions.json.example` | Recommended VS Code extensions |
| `11-multi-model-mcp/model-routing-guide.md` | Task → model decision tree |
| `11-multi-model-mcp/mcp-profiles.md` | Profile inheritance, precedence, auditing |

### Supported models (April 2026)

| Model | Provider | Ideal for | Premium |
|---|---|---|---|
| `o3` | OpenAI | Reasoning, architecture | ~5x |
| `o4-mini` | OpenAI | Inline completions, speed | ~1x |
| `gpt-4.1` | OpenAI | Balanced, DevOps | ~1x |
| `claude-sonnet-4-5` | Anthropic | Code gen, review, docs | ~1x |
| `claude-opus-4-5` | Anthropic | Deep review, security | ~5x |
| `claude-haiku-4-5` | Anthropic | Fast + cheap | ~1x |
| `gemini-2.5-pro` | Google | 1M token context | ~5x |
| `gemini-2.0-flash` | Google | Fast long-context scan | ~1x |

---

## Section 13: Governance

Asset registry, changelog, eval checks, policy hooks, workflows.

| File | Purpose |
|---|---|
| `16-governance/copilot-asset-manifest.json.example` | Registry — every asset with owner + classification |
| `16-governance/COPILOT-CHANGELOG.example.md` | Keep-a-Changelog format |
| `16-governance/GOVERNANCE.example.md` | Lifecycle process |
| `16-governance/eval/checks/naming.sh` | Kebab-case + extension validator |
| `16-governance/eval/checks/frontmatter.sh` | Required YAML fields per asset type |
| `16-governance/eval/checks/model-refs.sh` | `model:` resolves to registered model/slot |
| `16-governance/eval/checks/manifest-sync.sh` | Filesystem ↔ manifest consistency |
| `16-governance/eval/checks/governance.sh` | Owner + classification present |
| `16-governance/eval/checks/doc-consistency.sh` | No stale references |
| `16-governance/eval/checks/deprecation.sh` | 60-day grace period |
| `16-governance/eval/checks/tool-refs.sh` | Agent tools resolve to MCP tools |
| `16-governance/hooks/scripts/destructive-commands.sh` | Block `rm -rf`, `DROP TABLE`, `terraform destroy` |
| `16-governance/hooks/scripts/broad-permissions.sh` | Block IAM wildcards, `cluster-admin` |
| `16-governance/hooks/scripts/secret-hygiene.sh` | Scan for API keys, private keys |
| `16-governance/workflows/copilot-eval.yml` | PR-time eval workflow |
| `16-governance/workflows/copilot-hooks.yml` | Agent-action pre/post gates |
| `16-governance/workflows/copilot-setup-steps.yml` | Coding agent toolchain bootstrap |

---

## Section 14: Feature Gaps (vs Claude Code, as of April 2026)

Copilot has closed most historical gaps. A few remain:

| Feature | Status in Copilot | Workaround |
|---|---|---|
| Extended Thinking (user-controlled toggle) | Not user-exposed. The models themselves (o3, Opus) think under the hood. | Use `model: o3` or `claude-opus-4-5` for tasks that need it. |
| Checkpoints / conversation rewind | Not available. | `/clear` + VS Code Timeline for file history; git branches for conversation-level safety. |
| Intra-session tool-call hooks (per-call PreToolUse) | Partial. Workflow-level hooks via `copilot-hooks.yml`. Per-call in-chat hooks are not exposed. | Use workflow hooks + MCP profile filtering at the tool-registration layer. |
| MCP protocol | **Supported.** `.vscode/mcp.json`. | Module 11. |
| Agents with handoffs | **Supported.** `.github/agents/*.agent.md`. | Module 10. |
| Skills with auto-discovery | **Supported.** `.github/skills/<name>/SKILL.md`. | Module 09. |
| `claude -p "..."` full non-interactive automation | Limited. | Copilot coding agent assigned to issues is the closest equivalent; see `16-governance/workflows/copilot-setup-steps.yml`. |
| Hierarchical per-directory instructions | Partial. `.github/instructions/*.instructions.md` with `applyTo:` globs. | Module 05 scoped-instructions-api.md. |
