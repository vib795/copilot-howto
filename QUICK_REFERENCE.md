# GitHub Copilot Quick Reference

---

## Slash Commands (Copilot Chat)

| Command | What It Does | Best With |
|---------|-------------|-----------|
| `/explain` | Explain selected code or a file | `#selection`, `#file` |
| `/fix` | Fix bugs or improve selected code | `#selection` |
| `/tests` | Generate unit tests | `#file`, `#selection` |
| `/doc` | Generate documentation | `#selection` |
| `/new` | Scaffold new files/components | Plain description |
| `/simplify` | Simplify/clean up selected code | `#selection` |
| `/clear` | Clear the chat history | — |

---

## Chat Participants

| Participant | Scope | Example |
|-------------|-------|---------|
| `@workspace` | Entire codebase index | `@workspace where is auth handled?` |
| `@terminal` | Active terminal session | `@terminal why did this fail?` |
| `@vscode` | VS Code settings + commands | `@vscode how do I split the editor?` |
| `@github` | GitHub issues, PRs, repos | `@github summarize recent issues` |

---

## Context Variables

| Variable | What It Attaches | Example |
|----------|-----------------|---------|
| `#file` | A specific file | `#file:src/auth.ts explain this` |
| `#selection` | Current editor selection | `#selection /fix` |
| `#codebase` | Semantic codebase search | `#codebase find rate limiting` |
| `#terminalSelection` | Selected terminal text | `#terminalSelection what does this mean?` |
| `#terminalLastCommand` | Last terminal command + output | `#terminalLastCommand why did this fail?` |

---

## Keyboard Shortcuts (VS Code)

| Action | Shortcut |
|--------|----------|
| Accept inline suggestion | `Tab` |
| Dismiss inline suggestion | `Escape` |
| Accept next word only | `Ctrl+Right` (Win/Linux) / `Cmd+Right` (Mac) |
| Next suggestion | `Alt+]` |
| Previous suggestion | `Alt+[` |
| Open Copilot Chat | `Ctrl+Alt+I` (Win/Linux) / `Cmd+Shift+I` (Mac) |
| Inline chat at cursor | `Ctrl+I` (Win/Linux) / `Cmd+I` (Mac) |
| Open Copilot completions panel | `Ctrl+Enter` |

---

## Copilot CLI

```bash
# Install
gh extension install github/gh-copilot

# Suggest a shell command
gh copilot suggest "compress all png files in current dir"

# Explain a command
gh copilot explain "awk '{print $2}' file.txt"

# Shell type flag
gh copilot suggest --shell-type bash "list top 10 largest files"
gh copilot suggest --shell-type zsh "..."
gh copilot suggest --shell-type fish "..."
```

---

## Custom Instructions

**Project-level** (shared with team):
```bash
# Create
mkdir -p .github
touch .github/copilot-instructions.md
# Edit to add your standards — see 05-custom-instructions/project-copilot-instructions.md
```

**User-level** (VS Code settings.json):
```jsonc
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "text": "Prefer functional patterns. Never use var." }
  ],
  "github.copilot.chat.testGeneration.instructions": [
    { "text": "Use Jest. Prefer describe/it blocks." }
  ]
}
```

---

## GitHub Actions Integration

```yaml
# .github/workflows/copilot-review.yml — minimal setup
name: Copilot PR Review
on:
  pull_request:
    types: [opened, synchronize]
jobs:
  review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - uses: github/copilot-code-review@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

---

## Content Exclusion (Enterprise)

```yaml
# .github/copilot-ignore (repo-level)
# Exclude secrets and generated files
.env
.env.*
secrets/
**/generated/**
coverage/
```

---

## Extension `@mention` Syntax

```
# Use a marketplace extension
@github list open PRs in this repo

# Use a custom extension (once installed)
@your-extension-name /skill-name argument here
```

---

## The Six Primitives (at a glance)

| Primitive | Trigger | Where |
|---|---|---|
| Team instructions | Always | `.github/copilot-instructions.md` |
| Scoped instructions | Auto, by file type | `.github/instructions/*.instructions.md` |
| Prompt files | Manual — `/command` | `.github/prompts/*.prompt.md` |
| Skills | Auto-discovered | `.github/skills/<name>/SKILL.md` |
| Chat modes | Manual — mode picker | `.github/chatmodes/*.chatmode.md` |
| Agents | Manual or chained | `.github/agents/*.agent.md` |

---

## Custom Prompt Files

```yaml
# .github/prompts/review.prompt.md
---
mode: ask           # ask | edit | agent
model: claude-sonnet-4-5    # or slot/code
description: "Five-lens PR review"
tools: [read_file]  # only needed for mode: agent
---

Review the diff in #changes across correctness, security, performance, style, tests.
```

Triggers as `/review` in Copilot Chat. See [Module 07](07-custom-prompts/README.md).

---

## Chat Modes

```yaml
# .github/chatmodes/security-auditor.chatmode.md
---
description: "Deep security audit persona"
model: claude-opus-4-5
tools: [read_file, github.search_code]
---

You are a senior application-security engineer ...
```

Prerequisite: `"github.copilot.chat.experimental.chatModes": true` in settings.json. See [Module 08](08-chat-modes/README.md).

---

## Skills (Auto-discovered)

```yaml
# .github/skills/helm-upgrade/SKILL.md
---
name: helm-upgrade
description: >
  Use when asked to deploy, upgrade, roll back a service to Kubernetes.
  Also: "bump the image", "release", "promote to prod".
---

# Runbook body with numbered procedure, decision tables, rollback, etc.
```

Copilot reads only `description:` for scanning — write it as query-language, not a title. See [Module 09](09-skills/README.md).

---

## Agents (plan → implement → review)

```yaml
# .github/agents/plan.agent.md
---
name: plan
model: o3
tools: [read_file, github.search_code]
handoffs: [implement]
---
```

```yaml
# .github/agents/implement.agent.md
---
name: implement
model: claude-sonnet-4-5
tools: [read_file, write_file, run_terminal_command]
handoffs: [review]
---
```

```yaml
# .github/agents/review.agent.md
---
name: review
model: claude-opus-4-5
tools: [read_file]    # READ-ONLY by design
---
```

See [Module 10](10-agents/README.md).

---

## Multi-Model Slots

```json
// .vscode/settings.json
{
  "github.copilot.chat.models": {
    "slot/fast":     "o4-mini",
    "slot/reason":   "o3",
    "slot/code":     "claude-sonnet-4-5",
    "slot/thorough": "claude-opus-4-5",
    "slot/longctx":  "gemini-2.5-pro"
  }
}
```

Then `model: slot/thorough` in any prompt / chatmode / agent. See [Module 11](11-multi-model-mcp/README.md).

---

## MCP — `.vscode/mcp.json`

```json
{
  "servers": {
    "github":      { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-github"],
                     "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${env:GITHUB_TOKEN}" } },
    "kubernetes":  { "command": "npx", "args": ["-y", "mcp-server-kubernetes"],
                     "env": { "KUBECONFIG": "${env:KUBECONFIG}" } },
    "filesystem":  { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"] }
  }
}
```

Restart VS Code after editing. See [Module 11](11-multi-model-mcp/README.md).

---

## `.copilotignore`

Gitignore-syntax exclusion of files from the Copilot context window:

```gitignore
target/
node_modules/
*.tfstate
*.pem
.env
coverage/
```

See [Module 11](11-multi-model-mcp/copilotignore.example) for the full template.

---

## Governance: Running Eval Checks Locally

```bash
# From repo root
for f in .github/eval/checks/*.sh; do bash "$f" || echo "FAIL: $f"; done
```

Or individually — `naming.sh`, `frontmatter.sh`, `model-refs.sh`, `manifest-sync.sh`, `governance.sh`, `doc-consistency.sh`, `deprecation.sh`, `tool-refs.sh`. See [Module 16](16-governance/README.md).

---

## Module Quick Links

| Module | Link |
|--------|------|
| Slash Commands | [03-slash-commands/README.md](03-slash-commands/README.md) |
| Custom Instructions | [05-custom-instructions/README.md](05-custom-instructions/README.md) |
| Extensions | [14-extensions/README.md](14-extensions/README.md) |
| Chat Variables | [04-chat-variables/README.md](04-chat-variables/README.md) |
| GitHub Actions | [12-github-actions/README.md](12-github-actions/README.md) |
| Copilot Workspace | [13-copilot-workspace/README.md](13-copilot-workspace/README.md) |
| CLI | [06-cli/README.md](06-cli/README.md) |
| Inline Suggestions | [01-inline-suggestions/README.md](01-inline-suggestions/README.md) |
| IDE Integration | [02-ide-integration/README.md](02-ide-integration/README.md) |
| Enterprise | [15-enterprise/README.md](15-enterprise/README.md) |
| Custom Prompts | [07-custom-prompts/README.md](07-custom-prompts/README.md) |
| Chat Modes | [08-chat-modes/README.md](08-chat-modes/README.md) |
| Skills | [09-skills/README.md](09-skills/README.md) |
| Agents | [10-agents/README.md](10-agents/README.md) |
| Multi-Model + MCP | [11-multi-model-mcp/README.md](11-multi-model-mcp/README.md) |
| Governance | [16-governance/README.md](16-governance/README.md) |
