# Master GitHub Copilot in a Weekend

Go from typing your first suggestion to orchestrating custom extensions, GitHub Actions workflows, and Copilot Workspace tasks — with visual tutorials, copy-paste templates, and a guided learning path.

**[Get Started in 15 Minutes](#get-started-in-15-minutes)** | **[Find Your Level](#not-sure-where-to-start)** | **[Browse the Feature Catalog](CATALOG.md)**

---

## Table of Contents

- [The Problem](#the-problem)
- [How This Guide Fixes It](#how-this-guide-fixes-it)
- [How It Works](#how-it-works)
- [The Six Primitives](#the-six-primitives)
- [Not Sure Where to Start?](#not-sure-where-to-start)
- [Get Started in 15 Minutes](#get-started-in-15-minutes)
- [What Can You Build With This?](#what-can-you-build-with-this)
- [Feature Gaps vs. Claude Code](#feature-gaps-vs-claude-code)
- [FAQ](#faq)
- [Contributing](#contributing)
- [License](#license)

---

## The Problem

You enabled GitHub Copilot. The ghost text shows up. Now what?

- **The official docs describe features — but don't show you how to combine them.** You know `/explain` exists, but not how to chain it with custom instructions, chat variables, and Extensions into a workflow that saves hours.
- **There's no clear learning path.** Should you learn Extensions before custom instructions? Chat variables before the CLI? You end up skimming everything and mastering nothing.
- **Examples are too basic.** A "hello world" custom instruction doesn't help you build a production code-review workflow that uses `@workspace`, delegates to a custom Extension, and runs security scans via GitHub Actions automatically.

You're leaving 90% of Copilot's power on the table — and you don't know what you don't know.

---

## How This Guide Fixes It

This isn't another feature reference. It's a **structured, visual, example-driven guide** that teaches you to use every GitHub Copilot feature with real-world templates you can copy into your project today.

| | Official Docs | This Guide |
|--|---------------|------------|
| **Format** | Reference documentation | Visual tutorials with Mermaid diagrams |
| **Depth** | Feature descriptions | How it works under the hood |
| **Examples** | Basic snippets | Production-ready templates you use immediately |
| **Structure** | Feature-organized | Progressive learning path (beginner to advanced) |
| **Onboarding** | Self-directed | Guided roadmap with time estimates |

### What you get:

- **16 tutorial modules** covering every GitHub Copilot feature — from slash commands and custom instructions to prompt files, skills, chat modes, agents, MCP, and governance
- **Copy-paste configs** — instructions, prompt files, chat modes, skills, agent chains, MCP server config, asset manifest, eval checks, policy hooks, CI workflows
- **Mermaid diagrams** showing how each feature works internally, so you understand *why*, not just *how*
- **A guided learning path** that takes you from beginner to power user

**[Start the Learning Path ->](LEARNING-ROADMAP.md)**

---

## How It Works

### 1. Find your level

```
Beginner (0-2h Copilot use)      →  Start at Module 01
Intermediate (daily user)        →  Start at Module 04
Advanced (team primitives)       →  Start at Module 07
Platform / Governance            →  Start at Module 11
```

### 2. Pick a module

```mermaid
graph LR
    A[01 Inline Suggestions] --> B[02 IDE Integration]
    B --> C[03 Slash Commands]
    C --> D[04 Chat Variables]
    D --> E[05 Custom Instructions]
    E --> F[06 CLI]
    F --> G[07 Custom Prompts]
    G --> H[08 Chat Modes]
    H --> I[09 Skills]
    I --> J[10 Agents]
    J --> K[11 Multi-Model + MCP]
    K --> L[12 GitHub Actions]
    L --> M[13 Copilot Workspace]
    M --> N[14 Extensions]
    N --> O[15 Enterprise]
    O --> P[16 Governance]
```

### 3. Copy the templates

Every module has copy-paste files. Copy them into your project and start using them immediately — no setup beyond having Copilot enabled.

---

## The Six Primitives

GitHub Copilot has **six customisation primitives**. Each solves a different problem, and you compose them together for real workflows.

| Primitive | Trigger | Persistence | File location | Module |
|---|---|---|---|---|
| **Team instructions** | Always | Every interaction | `.github/copilot-instructions.md` | [05](05-custom-instructions/README.md) |
| **Instruction files** | Auto, by file type | Matching files | `.github/instructions/*.instructions.md` | [05](05-custom-instructions/README.md) |
| **Prompt files** | Manual — `/command` | One-shot | `.github/prompts/*.prompt.md` | [07](07-custom-prompts/README.md) |
| **Skills** | Auto-discovered by description | Loaded when relevant | `.github/skills/<name>/SKILL.md` | [09](09-skills/README.md) |
| **Chat modes** | Manual — mode picker | Persistent session | `.github/chatmodes/*.chatmode.md` | [08](08-chat-modes/README.md) |
| **Agents** | Manual or chained | Until done or handoff | `.github/agents/*.agent.md` | [10](10-agents/README.md) |

Layered, innermost to outermost:

```
Always on:   [team instructions] + [instruction files scoped to current file type]
On demand:   [slash command prompts] ← you type /review
Auto-loaded: [skills] ← Copilot decides based on what you're asking
Interactive: [chat modes] ← you pick the persona from the dropdown
Autonomous:  [agents] ← runs a full workflow, can chain to other agents
```

Around the primitives sit the configuration layer ([Module 11](11-multi-model-mcp/README.md)): named model slots, MCP tool servers, `.copilotignore`, least-privilege profiles. Around that sits governance ([Module 16](16-governance/README.md)): asset manifest, changelog, eval checks, policy hooks.

---

## Not Sure Where to Start?

| If you... | Start here |
|---|---|
| Just enabled Copilot | [01 Inline Suggestions](01-inline-suggestions/README.md) |
| Setting up a new IDE | [02 IDE Integration](02-ide-integration/README.md) |
| Ready to use chat | [03 Slash Commands](03-slash-commands/README.md) |
| Want Copilot to understand your codebase better | [04 Chat Variables](04-chat-variables/README.md) |
| Use Copilot daily but want more control | [05 Custom Instructions](05-custom-instructions/README.md) |
| Want shell-command help | [06 CLI](06-cli/README.md) |
| Want your own team slash commands | [07 Custom Prompts](07-custom-prompts/README.md) |
| Want persistent expert personas | [08 Chat Modes](08-chat-modes/README.md) |
| Want Copilot to auto-apply runbooks | [09 Skills](09-skills/README.md) |
| Want autonomous plan → implement → review | [10 Agents](10-agents/README.md) |
| Need multi-model routing + MCP tools | [11 Multi-Model + MCP](11-multi-model-mcp/README.md) |
| Want to automate workflows | [12 GitHub Actions](12-github-actions/README.md) |
| Want task-based planning on github.com | [13 Copilot Workspace](13-copilot-workspace/README.md) |
| Want to build custom Copilot tools | [14 Extensions](14-extensions/README.md) |
| Work in a large organization | [15 Enterprise](15-enterprise/README.md) |
| Managing assets at scale (governance) | [16 Governance](16-governance/README.md) |

---

## Get Started in 15 Minutes

**Step 1:** Copy the project custom instructions template to your repo:

```bash
# Option A: Copy from this repo (if you've cloned it)
cp 05-custom-instructions/project-copilot-instructions.md .github/copilot-instructions.md

# Option B: Download directly (replace YOUR-USERNAME with your fork)
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/YOUR-USERNAME/copilot-howto/main/05-custom-instructions/project-copilot-instructions.md
```

**Step 2:** Edit `.github/copilot-instructions.md` to match your stack and standards.

**Step 3:** Open Copilot Chat and ask:

```
@workspace What are the main modules in this project and how do they interact?
```

You're now using custom instructions + `@workspace` context together. That's 80% of what most users never learn to combine.

---

## What Can You Build With This?

| Use Case | Features Used | Module |
|---|---|---|
| Automated code review on every PR | Custom Instructions + GitHub Actions + Extensions | 05, 12, 14 |
| Team onboarding with consistent AI context | Custom Instructions + Chat Variables | 04, 05 |
| Security scanning in CI/CD | GitHub Actions + Copilot coding agent | 12 |
| Custom `/review` command for your team | Custom Prompt Files | 07 |
| Shell command generation from plain English | Copilot CLI | 06 |
| Complex refactoring with task planning | Copilot Workspace | 13 |
| Consistent docs generation | Custom Instructions + `/doc` | 03, 05 |
| Persistent "Security Auditor" chat persona | Chat Modes | 08 |
| Auto-loading Helm deploy runbook when asked to deploy | Skills | 09 |
| Plan → implement → review pipeline for a whole feature | Agents + Handoffs | 10 |
| Route `/architect` to `o3`, `/security-scan` to Opus | Multi-Model Routing | 11 |
| Give Copilot live K8s / DB / GitHub access | MCP (Model Context Protocol) | 11 |
| CI-validated Copilot asset changes with owner + audit trail | Governance (manifest, eval, hooks) | 16 |

---

## Module Overview

| # | Module | What You Learn | Time |
|---|--------|---------------|------|
| 01 | [Inline Suggestions](01-inline-suggestions/README.md) | Ghost text, partial accept, NES, settings — what you see Day 1 | 45 min |
| 02 | [IDE Integration](02-ide-integration/README.md) | VS Code, JetBrains, Neovim, Xcode — setup and keybindings | 1 hr |
| 03 | [Slash Commands](03-slash-commands/README.md) | `/explain`, `/fix`, `/tests`, `/doc`, `/new`, `/simplify` | 45 min |
| 04 | [Chat Variables](04-chat-variables/README.md) | `@workspace`, `#file`, `#selection`, `@terminal` | 1 hr |
| 05 | [Custom Instructions](05-custom-instructions/README.md) | `.github/copilot-instructions.md`, VS Code user settings, scoped `*.instructions.md` | 1 hr |
| 06 | [CLI](06-cli/README.md) | `gh copilot suggest`, `gh copilot explain` | 30 min |
| 07 | [Custom Prompts](07-custom-prompts/README.md) | `.github/prompts/*.prompt.md` — your team's own `/commands` with pinned model + mode | 1 hr |
| 08 | [Chat Modes](08-chat-modes/README.md) | `.github/chatmodes/*.chatmode.md` — persistent personas (Code Reviewer, Security Auditor, Architect, ...) | 1 hr |
| 09 | [Skills](09-skills/README.md) | `.github/skills/<name>/SKILL.md` — auto-discovered runbooks triggered by `description:` | 1.5 hr |
| 10 | [Agents](10-agents/README.md) | `.github/agents/*.agent.md` — autonomous plan → implement → review chain with handoffs | 2 hr |
| 11 | [Multi-Model + MCP](11-multi-model-mcp/README.md) | Named model slots, `.vscode/mcp.json`, `.copilotignore`, MCP least-privilege profiles | 2 hr |
| 12 | [GitHub Actions](12-github-actions/README.md) | Copilot in CI/CD, automated review workflows | 1.5 hr |
| 13 | [Copilot Workspace](13-copilot-workspace/README.md) | Task-based planning and multi-file implementation | 1 hr |
| 14 | [Extensions](14-extensions/README.md) | Skillset and agent extensions, building custom tools (HTTP endpoints) | 2 hr |
| 15 | [Enterprise](15-enterprise/README.md) | Policies, content exclusion, audit logs, SSO | 1 hr |
| 16 | [Governance](16-governance/README.md) | Asset manifest, changelog, eval checks, policy hooks, `copilot-setup-steps.yml` | 2 hr |

---

## Feature Gaps vs. Claude Code

Coming from Claude Code? As of April 2026, most of the gaps have closed — Copilot now supports MCP, agents, and session-level hooks. A few true gaps remain:

| Claude Code Feature | Copilot Status (as of April 2026) | Workaround / Equivalent |
|---|---|---|
| Extended Thinking | Not user-controllable. The underlying Claude/o3 models have thinking; Copilot doesn't expose a toggle. | Use `o3` or `claude-opus-4-5` via `model:` frontmatter — they think under the hood. |
| Checkpoints / `/rewind` | Not available in Copilot Chat. | VS Code Timeline for file-level rewind; git branches for conversation-level safe experimentation. |
| Intra-session tool-call hooks (PreToolUse / PostToolUse) | **Partial.** Workflow-level hooks exist via `copilot-hooks.yml` ([Module 16](16-governance/README.md)). True intra-session hooks (interrupting a specific tool call in-chat) are not yet exposed. | Use `.github/workflows/copilot-hooks.yml` for pre/post-action gates on the coding agent; use MCP profiles for tool-level allow/deny ([Module 11](11-multi-model-mcp/mcp-profiles.md)). |
| MCP protocol | **Supported.** `.vscode/mcp.json` configures GitHub, filesystem, Kubernetes, Postgres, search, memory, and custom servers. | Use [Module 11](11-multi-model-mcp/README.md). |
| Agents with plan → implement → review handoffs | **Supported.** `.github/agents/*.agent.md` files + handoff chains. | Use [Module 10](10-agents/README.md). |
| Skills (auto-discovered runbooks) | **Supported.** `.github/skills/<name>/SKILL.md` with description-based triggers. | Use [Module 09](09-skills/README.md). |
| `claude -p "..."` full non-interactive automation | Limited. `gh copilot suggest` is narrower than `claude -p`. | For full automation, use the Copilot coding agent assigned to issues (GitHub automatically runs `copilot-setup-steps.yml` + agent chains). See [Module 16 — setup-steps](16-governance/workflows/copilot-setup-steps.yml). |
| Hierarchical per-directory instructions | **Partial.** `.github/instructions/*.instructions.md` with `applyTo:` globs replaces most hierarchical use cases. No `src/api/CLAUDE.md` equivalent. | Use scoped instruction files with `applyTo:` — see [Module 05](05-custom-instructions/scoped-instructions-api.md). |

---

## FAQ

**Q: Which version of GitHub Copilot do I need?**
Copilot Individual, Business, or Enterprise all work. Some features (enterprise policies, audit logs) require Business/Enterprise. Extensions require Copilot Individual or higher.

**Q: Which IDEs are supported?**
VS Code (best support), JetBrains IDEs (IntelliJ, PyCharm, WebStorm, etc.), Neovim, Vim, Xcode, and Azure Data Studio. See [02 IDE Integration](02-ide-integration/README.md). Chat modes, skills, agents, and MCP are VS Code-first; other IDEs have varying support.

**Q: Do I need to know JavaScript to build Extensions?**
The scaffold examples use Node.js/Express, but any language that can serve HTTP endpoints works. The agent extension scaffold includes a minimal Express server to get started.

**Q: Can I use custom instructions with JetBrains or Neovim?**
`.github/copilot-instructions.md` is IDE-agnostic — it works everywhere Copilot Chat is available. VS Code user-level instructions (via settings.json), chat modes, and MCP servers are VS Code-specific.

**Q: What's the difference between a Copilot Extension and a Skill / Agent file?**
Copilot **Extensions** (Module 14) are HTTP endpoints you register with GitHub, invoked via `@extension-name`. They're for integrating external services.
**Skills** (Module 09) are markdown runbooks in your repo, auto-discovered when a request matches the description.
**Agents** (Module 10) are markdown files describing autonomous workflows that can chain together.
Extensions run on your server; skills and agents are context for the models Copilot already uses.

**Q: Does Copilot support MCP (Model Context Protocol)?**
Yes, as of late 2025 / early 2026. Configure servers in `.vscode/mcp.json` and they become available in agent mode. See [Module 11](11-multi-model-mcp/README.md). The old "not supported" answer is outdated.

**Q: Which Copilot tier do I need for chat modes, agents, and MCP?**
Chat modes and agent mode are in all tiers as of 2026, but several models (Claude Opus, Gemini Pro, o3) require Copilot Business or Enterprise. The coding agent (assigning issues to Copilot) requires Business or Enterprise. See [Module 15](15-enterprise/README.md) and [Module 11 model-compatibility.json](11-multi-model-mcp/model-compatibility.json) for the current matrix.

**Q: Where do I get help?**
- [GitHub Copilot documentation](https://docs.github.com/copilot)
- [VS Code Copilot Chat docs](https://code.visualstudio.com/docs/copilot/overview)
- [GitHub Community discussions](https://github.com/orgs/community/discussions/categories/copilot)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports, new templates, and additional IDE guides are all welcome.

---

## License

MIT — see [LICENSE](LICENSE).
