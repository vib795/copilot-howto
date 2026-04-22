# GitHub Copilot Learning Roadmap

A progressive, milestone-based learning path from first-time Copilot user to platform / governance operator.

---

## Find Your Starting Point

Answer these questions:

1. Have you accepted a ghost-text suggestion? (yes = +1)
2. Have you used `@workspace` or `#file` in Copilot Chat? (yes = +1)
3. Do you have a `.github/copilot-instructions.md` in any project? (yes = +1)
4. Have you authored a custom prompt file or chat mode? (yes = +2)
5. Have you configured MCP servers or an agent chain? (yes = +2)

**Score 0–1:** Start at [Level 1 — Foundations](#level-1-foundations-3-4-hours)
**Score 2–3:** Start at [Level 2 — Context & Persistence](#level-2-context--persistence-3-4-hours)
**Score 4–5:** Start at [Level 3 — The Six Primitives](#level-3-the-six-primitives-4-5-hours)
**Score 6+:** Start at [Level 4 — Platform](#level-4-platform-2-3-hours)

---

## Level 1: Foundations (3-4 hours)

**Goal:** Use Copilot's day-1 features reliably in your IDE.

### Milestone 1A: Inline Suggestions

**Read:** [01 Inline Suggestions](01-inline-suggestions/README.md)

**Exercises:**
1. Write a function signature with a clear name. Watch ghost text complete the body. Accept with `Tab`.
2. Write a comment describing what you want. Let Copilot draft the implementation.
3. Get a multi-line suggestion. Accept just the first word with `Ctrl+Right` / `Cmd+Right`.
4. Dismiss a suggestion with `Esc`. Cycle through alternatives with `Alt+]` / `Alt+[`.
5. Read [next-edit-suggestions.md](01-inline-suggestions/next-edit-suggestions.md) — use NES to predict your next edit location.

**Checkpoint:** Accepting, partial-accepting, and dismissing ghost text is automatic. You don't fight it.

---

### Milestone 1B: IDE Integration

**Read:** [02 IDE Integration](02-ide-integration/README.md)

**Exercises:**
1. Follow the setup guide for your IDE (VS Code / JetBrains / Neovim / Xcode).
2. Verify your keyboard shortcuts match the [acceptance-shortcuts](01-inline-suggestions/acceptance-shortcuts.md) doc.
3. Open the feature-matrix table and confirm your IDE supports the features you plan to use.
4. Configure per-language enable/disable in `settings.json` so Copilot is silent in generated / vendored files.

**Checkpoint:** Copilot works the way you expect in your IDE — including chat, inline, and shortcuts.

---

### Milestone 1C: Slash Commands

**Read:** [03 Slash Commands](03-slash-commands/README.md)

**Exercises:**
1. Open a file with a bug. Select the broken function. Type `/fix` in Copilot Chat with `#selection` attached. Apply the fix.
2. Open a function with no tests. Use `/tests` to generate a test suite. Review and apply.
3. Open a complex function. Use `/explain` to get a plain-English explanation.
4. Chain commands: `/explain` → question → `/doc` on the same selection.
5. Use `/clear` when switching topics to free up context budget.

**Checkpoint:** You can use all six built-in slash commands confidently without looking them up.

---

## Level 2: Context & Persistence (3-4 hours)

**Goal:** Make Copilot aware of your code and your team's rules.

### Milestone 2A: Chat Variables

**Read:** [04 Chat Variables](04-chat-variables/README.md)

**Exercises:**
1. Ask `@workspace "Where is authentication handled in this project?"` — navigate to the file it identifies.
2. Attach `#file:src/auth.ts` to a chat message. Ask Copilot to identify security issues in that specific file.
3. Run a failing test in the terminal. Use `@terminal #terminalLastCommand` to ask Copilot what went wrong.
4. Attach two files with `#file` in one message. Ask Copilot to explain how they interact.
5. Use `#codebase` for a semantic search across the workspace.

**Checkpoint:** You instinctively add the right context variable for every chat question.

---

### Milestone 2B: Custom Instructions

**Read:** [05 Custom Instructions](05-custom-instructions/README.md)

**Exercises:**
1. Copy [project-copilot-instructions.md](05-custom-instructions/project-copilot-instructions.md) to `.github/copilot-instructions.md` and customize for your stack.
2. Ask Copilot to generate a function; verify the output uses your naming conventions.
3. Set up user-level instructions in VS Code `settings.json` (`codeGeneration.instructions`, `testGeneration.instructions`).
4. Use `/doc` on a function — verify the doc style matches your instructions.
5. Read [scoped-instructions-api.md](05-custom-instructions/scoped-instructions-api.md) — add one scoped `*.instructions.md` for a subdirectory.

**Checkpoint:** Copilot's output reflects your team's coding standards without you re-stating them in prompts.

---

### Milestone 2C: Copilot CLI

**Read:** [06 CLI](06-cli/README.md)

**Exercises:**
1. Install: `gh extension install github/gh-copilot`
2. Run `gh copilot suggest "find all files modified in the last 7 days"`. Execute the suggested command.
3. Run `gh copilot explain "git rebase -i HEAD~3"`.
4. Use `gh copilot suggest` to generate a `find` + `xargs` pipeline for a task you'd normally Google.

**Checkpoint:** You reach for `gh copilot suggest` before a search engine for shell commands.

---

## Level 3: The Six Primitives (4-5 hours)

**Goal:** Author team-shared prompts, chat modes, skills, and agent chains. This is where compound-interest leverage kicks in.

### Milestone 3A: Custom Prompt Files

**Read:** [07 Custom Prompts](07-custom-prompts/README.md)

**Exercises:**
1. Copy [`07-custom-prompts/review.prompt.md`](07-custom-prompts/review.prompt.md) to `.github/prompts/review.prompt.md`. Invoke `/review` on an open PR.
2. Copy [`07-custom-prompts/fix-issue.prompt.md`](07-custom-prompts/fix-issue.prompt.md). Reproduce a bug, run `/fix-issue` — verify the fix lands as a diff and a regression test appears.
3. Write your own prompt: `/add-feature-flag` that takes a flag name and adds it to the feature-flag config with a consistent pattern.
4. Validate frontmatter locally with [`16-governance/eval/checks/frontmatter.sh`](16-governance/eval/checks/frontmatter.sh).

**Checkpoint:** Your team's most-repeated Copilot prompts are codified as `/commands` shared in git.

---

### Milestone 3B: Chat Modes

**Read:** [08 Chat Modes](08-chat-modes/README.md)

**Exercises:**
1. Enable `"github.copilot.chat.experimental.chatModes": true` in `.vscode/settings.json` and restart.
2. Copy [`08-chat-modes/security-auditor.chatmode.md`](08-chat-modes/security-auditor.chatmode.md). Audit a file in your codebase over 5+ back-and-forth turns.
3. Write your own chat mode for a persona your team repeatedly needs (release manager? tech-writer? data scientist?).
4. If the mode picker is empty, troubleshoot using [`enabling-chatmodes.md`](08-chat-modes/enabling-chatmodes.md).

**Checkpoint:** You switch between modes naturally — different personas for different tasks, each pinned to the right model.

---

### Milestone 3C: Skills

**Read:** [09 Skills](09-skills/README.md)

**Exercises:**
1. Copy [`09-skills/helm-upgrade/SKILL.md`](09-skills/helm-upgrade/SKILL.md) to `.github/skills/helm-upgrade/SKILL.md`. Ask Copilot "how do I roll back the payment service?" — verify the skill auto-loads.
2. Write a skill for a runbook your team has (incident escalation? DB migration? canary rollout?).
3. Iterate on the `description:` using [description-writing-guide.md](09-skills/description-writing-guide.md) until it triggers on phrases teammates actually say.
4. Bundle a supporting file (template, script) with the skill and reference it from SKILL.md.

**Checkpoint:** Team runbooks are skills — new hires don't have to remember command names; Copilot surfaces the right runbook automatically.

---

### Milestone 3D: Agents (plan → implement → review)

**Read:** [10 Agents](10-agents/README.md)

**Exercises:**
1. Copy [`plan.agent.md`](10-agents/plan.agent.md), [`implement.agent.md`](10-agents/implement.agent.md), [`review.agent.md`](10-agents/review.agent.md) to `.github/agents/`.
2. Invoke `@plan <small feature>` in Copilot Chat. Follow the handoff chain through implement and review. Inspect the artefacts at each phase.
3. Assign a GitHub issue to the Copilot coding agent. Observe the agent using the chain end-to-end.
4. Modify `review.agent.md` to add a focus area specific to your team (e.g., performance regressions).
5. Read [`handoff-chains.md`](10-agents/handoff-chains.md) and sketch a chain for a non-standard workflow (research→plan→implement→benchmark→review).

**Checkpoint:** You can describe a feature in plain English and let the agent chain produce a PR with plan, diff, and review attached.

---

## Level 4: Platform (2-3 hours)

**Goal:** Wire up multi-model routing and MCP tools so the primitives you built in Level 3 use the right model for each task and have live access to GitHub, Kubernetes, databases, etc.

### Milestone 4A: Multi-Model Routing

**Read:** [11 Multi-Model + MCP](11-multi-model-mcp/README.md) | [model-routing-guide.md](11-multi-model-mcp/model-routing-guide.md)

**Exercises:**
1. Copy [`11-multi-model-mcp/settings.json.example`](11-multi-model-mcp/settings.json.example) into your `.vscode/settings.json` (merge the `github.copilot.chat.models` slots into your existing config).
2. Rewrite one of your Level-3 prompts to use `model: slot/thorough` instead of a raw model ID.
3. Copy [`model-compatibility.json`](11-multi-model-mcp/model-compatibility.json) to `.github/model-compatibility.json`. Verify your raw-ID references resolve.

**Checkpoint:** Prompts / modes / agents reference slots (not raw model IDs) — when a new model ships, you update one file.

---

### Milestone 4B: MCP Servers and `.copilotignore`

**Read:** [11 Multi-Model + MCP](11-multi-model-mcp/README.md) | [mcp-profiles.md](11-multi-model-mcp/mcp-profiles.md)

**Exercises:**
1. Copy [`mcp.json.example`](11-multi-model-mcp/mcp.json.example) to `.vscode/mcp.json`. Set `GITHUB_TOKEN` and `KUBECONFIG`. Restart VS Code. Verify tools appear in agent mode.
2. Copy [`copilotignore.example`](11-multi-model-mcp/copilotignore.example) to `.copilotignore`. Identify three specific noise sources in your repo (build dirs, large fixtures, generated code) and add them.
3. Copy [`copilot-mcp-profiles.json`](11-multi-model-mcp/copilot-mcp-profiles.json). Set `COPILOT_MCP_PROFILE=read-only` as the default; switch to `standard` only when needed.

**Checkpoint:** MCP tools work end-to-end in agent mode. Context window is clean. The elevated profile is denied unless explicitly opted into.

---

## Level 5: Workflow Integrations (3-4 hours)

**Goal:** Plug Copilot into your CI/CD, issue workflow, and extension ecosystem.

### Milestone 5A: GitHub Actions

**Read:** [12 GitHub Actions](12-github-actions/README.md)

**Exercises:**
1. Copy [pr-review-workflow.yml](12-github-actions/pr-review-workflow.yml) into `.github/workflows/`. Open a test PR. Verify the review runs.
2. Copy [format-check-workflow.yml](12-github-actions/format-check-workflow.yml). Push code with a formatting error. Confirm the check fails.
3. Add the PR review workflow as a required status check in your repo's branch protection rules.
4. Copy [pr-description-workflow.yml](12-github-actions/pr-description-workflow.yml). Open a PR without a description. Verify it gets auto-generated.

**Checkpoint:** At least two Copilot-powered checks run automatically on every PR in your project.

---

### Milestone 5B: Copilot Workspace

**Read:** [13 Copilot Workspace](13-copilot-workspace/README.md)

**Exercises:**
1. Take a real GitHub issue in your project. Open it in Copilot Workspace. Review the generated plan.
2. Accept the plan. Step through the implementation file by file. Reject one change and manually edit.
3. Create a git branch before starting a risky refactor. Use VS Code Timeline to recover a file version after an unwanted change.
4. Write a task specification using [task-specification-guide.md](13-copilot-workspace/task-specification-guide.md). Compare the plan quality vs. a vague issue.

**Checkpoint:** You use Copilot Workspace for at least one real feature, not just toy examples.

---

### Milestone 5C: Extensions

**Read:** [14 Extensions](14-extensions/README.md)

**Exercises:**
1. Browse the [marketplace extensions list](14-extensions/marketplace-extensions.md). Install one relevant to your stack. Use it in Copilot Chat.
2. Clone the [skillset extension scaffold](14-extensions/skillset-extension-scaffold/). Run it locally. Send it a test request.
3. Modify the scaffold to add a new skill endpoint (e.g., a `lint-check` skill).
4. Register the extension as a GitHub App (follow the scaffold README). Use `@your-extension` in Copilot Chat.
5. Clone the [agent extension scaffold](14-extensions/agent-extension-scaffold/). Modify the system prompt to create a domain-specific agent.

**Checkpoint:** You have a working Copilot Extension that your team can use via `@mention`.

---

## Level 6: Org-Scale (3-4 hours)

**Goal:** Operate Copilot across an organisation — policies, audit, and CI-enforced governance of the assets you've created.

### Milestone 6A: Enterprise Features

**Read:** [15 Enterprise](15-enterprise/README.md)

**Exercises:**
1. Identify at least one directory / file pattern in your repo that should be excluded from Copilot suggestions (e.g., `.env`, `secrets/`). Configure content exclusion.
2. Review your organization's Copilot policy settings. Confirm public code matching is configured appropriately.
3. Run a Copilot usage audit log query for your organization.
4. Read [policy-management.md](15-enterprise/policy-management.md) — confirm "allow additional models" is enabled for your org if you plan to use Claude / Gemini via Copilot.

**Checkpoint:** You can explain your organization's Copilot configuration and why each policy exists.

---

### Milestone 6B: Governance

**Read:** [16 Governance](16-governance/README.md) | [asset-lifecycle.md](16-governance/asset-lifecycle.md)

**Exercises:**
1. Copy [`copilot-asset-manifest.json.example`](16-governance/copilot-asset-manifest.json.example) to `.github/copilot-asset-manifest.json`. Register every Copilot asset you built in Level 3.
2. Copy the eval check scripts from [`16-governance/eval/checks/`](16-governance/eval/checks/) into `.github/eval/checks/`. Run them all locally; fix any failures.
3. Copy [`copilot-eval.yml`](16-governance/workflows/copilot-eval.yml). Open a PR modifying a prompt — verify the eval workflow runs.
4. Copy the hook scripts and [`copilot-hooks.yml`](16-governance/workflows/copilot-hooks.yml). Test `secret-hygiene.sh` by adding a fake API key — verify the hook flags it.
5. Copy [`copilot-setup-steps.yml`](16-governance/workflows/copilot-setup-steps.yml). Assign a test issue to the Copilot coding agent; verify the toolchain bootstraps.
6. Do a full deprecation cycle on a Level-3 asset following the [asset-lifecycle](16-governance/asset-lifecycle.md) walkthrough.

**Checkpoint:** New Copilot assets can't be merged without passing CI eval. Deprecated assets have scheduled removal dates. Health dashboard shows owner and classification coverage ≥ 95%.

---

## Expert Path: Production Integration

Once you complete Levels 1–6, these are the next frontier:

| Topic | Description |
|---|---|
| Specialised agent chains | Security-gated, perf-investigation, data-migration chains beyond the default |
| Custom MCP servers | Building an org-internal MCP server for your internal APIs |
| Copilot in monorepos | Directory-level instruction patterns + scoped skills |
| Usage analytics | Correlating `copilot-health.sh` output with PR merge rate and incident rate |
| Multi-extension workflows | Chaining multiple `@extension` calls in a single conversation |
| Programmatic Copilot via API | Using the GitHub Models API for automated Copilot-style completions in scripts |

---

## Quick Reference: Learning Objectives by Module

| Module | Core Skill | Beginner Need | Advanced Need |
|--------|-----------|---------------|--------------|
| 01 Inline Suggestions | Ghost text, NES, shortcuts | ★★★ | ★ |
| 02 IDE Integration | Per-IDE setup and features | ★★★ | ★★ |
| 03 Slash Commands | `/explain`, `/fix`, `/tests`, `/doc` | ★★★ | ★ |
| 04 Chat Variables | `@workspace`, `#file`, `@terminal` | ★★ | ★★★ |
| 05 Custom Instructions | `.github/copilot-instructions.md` | ★★★ | ★★ |
| 06 CLI | `gh copilot suggest/explain` | ★★ | ★ |
| 07 Custom Prompts | `.github/prompts/*.prompt.md` | ★ | ★★★ |
| 08 Chat Modes | `.chatmode.md` personas | ★ | ★★★ |
| 09 Skills | `SKILL.md` runbooks | ★ | ★★★ |
| 10 Agents | `.agent.md` chains + handoffs | — | ★★★ |
| 11 Multi-Model + MCP | slots, `mcp.json`, `.copilotignore`, profiles | — | ★★★ |
| 12 GitHub Actions | Copilot in CI/CD | ★★ | ★★★ |
| 13 Copilot Workspace | Task-based planning on github.com | ★★ | ★★ |
| 14 Extensions | Build custom HTTP-endpoint extensions | ★ | ★★★ |
| 15 Enterprise | Policies, exclusions, audit | ★ | ★★★ |
| 16 Governance | manifest, eval, hooks, workflows | — | ★★★ |

★ = Useful | ★★ = Important | ★★★ = Essential for this level
