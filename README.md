# Master GitHub Copilot in a Weekend

Go from typing your first suggestion to orchestrating custom extensions, GitHub Actions workflows, and Copilot Workspace tasks — with visual tutorials, copy-paste templates, and a guided learning path.

**[Get Started in 15 Minutes](#get-started-in-15-minutes)** | **[Find Your Level](#not-sure-where-to-start)** | **[Browse the Feature Catalog](CATALOG.md)**

---

## Table of Contents

- [The Problem](#the-problem)
- [How This Guide Fixes It](#how-this-guide-fixes-it)
- [How It Works](#how-it-works)
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

- **10 tutorial modules** covering every GitHub Copilot feature — from slash commands to custom Extensions
- **Copy-paste configs** — custom instruction templates, GitHub Actions workflows, Extension scaffolds, chat variable patterns
- **Mermaid diagrams** showing how each feature works internally, so you understand *why*, not just *how*
- **A guided learning path** that takes you from beginner to power user in 10-12 hours

**[Start the Learning Path ->](LEARNING-ROADMAP.md)**

---

## How It Works

### 1. Find your level

```
Beginner (0-2h Copilot use)  →  Start at Module 01
Intermediate (daily user)    →  Start at Module 04
Advanced (writing Extensions) →  Start at Module 09
```

### 2. Pick a module

```mermaid
graph LR
    A[01 Slash Commands] --> B[02 Custom Instructions]
    B --> C[03 Extensions]
    C --> D[04 Chat Variables]
    D --> E[05 GitHub Actions]
    E --> F[06 Copilot Workspace]
    F --> G[07 CLI]
    G --> H[08 Inline Suggestions]
    H --> I[09 IDE Integration]
    I --> J[10 Enterprise]
```

### 3. Copy the templates

Every module has copy-paste files. Copy them into your project and start using them immediately — no setup beyond having Copilot enabled.

---

## Not Sure Where to Start?

| If you... | Start here |
|---|---|
| Just enabled Copilot | [01 Slash Commands](01-slash-commands/README.md) |
| Use Copilot daily but want more control | [02 Custom Instructions](02-custom-instructions/README.md) |
| Want Copilot to understand your codebase better | [04 Chat Variables](04-chat-variables/README.md) |
| Want to automate workflows | [05 GitHub Actions](05-github-actions/README.md) |
| Want to build custom Copilot tools | [03 Extensions](03-extensions/README.md) |
| Work in a large organization | [10 Enterprise](10-enterprise/README.md) |

---

## Get Started in 15 Minutes

**Step 1:** Copy the project custom instructions template to your repo:

```bash
# Option A: Copy from this repo (if you've cloned it)
cp 02-custom-instructions/project-copilot-instructions.md .github/copilot-instructions.md

# Option B: Download directly (replace YOUR-USERNAME with your fork)
curl -o .github/copilot-instructions.md \
  https://raw.githubusercontent.com/YOUR-USERNAME/copilot-howto/main/02-custom-instructions/project-copilot-instructions.md
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
| Automated code review on every PR | Custom Instructions + GitHub Actions + Extensions | 02, 03, 05 |
| Team onboarding with consistent AI context | Custom Instructions + Chat Variables | 02, 04 |
| Security scanning in CI/CD | GitHub Actions + Copilot coding agent | 05 |
| Custom `/review` command for your team | Extensions (agent type) | 03 |
| Shell command generation from plain English | Copilot CLI | 07 |
| Complex refactoring with task planning | Copilot Workspace | 06 |
| Consistent docs generation | Custom Instructions + `/doc` | 02, 01 |

---

## Module Overview

| # | Module | What You Learn | Time |
|---|--------|---------------|------|
| 01 | [Slash Commands](01-slash-commands/README.md) | `/explain`, `/fix`, `/tests`, `/doc`, `/new`, `/simplify` | 45 min |
| 02 | [Custom Instructions](02-custom-instructions/README.md) | `.github/copilot-instructions.md`, VS Code user settings | 1 hr |
| 03 | [Extensions](03-extensions/README.md) | Skillset and agent extensions, building custom tools | 2 hr |
| 04 | [Chat Variables](04-chat-variables/README.md) | `@workspace`, `#file`, `#selection`, `@terminal` | 1 hr |
| 05 | [GitHub Actions](05-github-actions/README.md) | Copilot in CI/CD, automated review workflows | 1.5 hr |
| 06 | [Copilot Workspace](06-copilot-workspace/README.md) | Task-based planning and multi-file implementation | 1 hr |
| 07 | [CLI](07-cli/README.md) | `gh copilot suggest`, `gh copilot explain` | 30 min |
| 08 | [Inline Suggestions](08-inline-suggestions/README.md) | Ghost text, partial accept, NES, settings | 45 min |
| 09 | [IDE Integration](09-ide-integration/README.md) | VS Code, JetBrains, Neovim, Xcode | 1 hr |
| 10 | [Enterprise](10-enterprise/README.md) | Policies, content exclusion, audit logs, SSO | 1 hr |

---

## Feature Gaps vs. Claude Code

Coming from Claude Code? Some features don't have a Copilot equivalent:

| Claude Code Feature | Copilot Status | Workaround |
|---|---|---|
| Extended Thinking | Not available | Model reasoning depth is implicit; not user-configurable |
| Checkpoints / `/rewind` | Not available | VS Code Timeline for file history; git branches for safe experimentation |
| Intra-session hooks (PreToolUse, etc.) | Not available | VS Code tasks and launch configs for within-IDE automation |
| MCP protocol | Not supported | Copilot Extensions fill the functional role but don't implement MCP |
| `claude -p "..."` full automation | Limited | `gh copilot suggest` is narrower; use Copilot coding agent in Actions for pipelines |

---

## FAQ

**Q: Which version of GitHub Copilot do I need?**
Copilot Individual, Business, or Enterprise all work. Some features (enterprise policies, audit logs) require Business/Enterprise. Extensions require Copilot Individual or higher.

**Q: Which IDEs are supported?**
VS Code (best support), JetBrains IDEs (IntelliJ, PyCharm, WebStorm, etc.), Neovim, Vim, Xcode, and Azure Data Studio. See [09 IDE Integration](09-ide-integration/README.md).

**Q: Do I need to know JavaScript to build Extensions?**
The scaffold examples use Node.js/Express, but any language that can serve HTTP endpoints works. The agent extension scaffold includes a minimal Express server to get started.

**Q: Can I use custom instructions with JetBrains or Neovim?**
`.github/copilot-instructions.md` is IDE-agnostic — it works everywhere Copilot Chat is available. VS Code user-level instructions (via settings.json) are VS Code-specific.

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
