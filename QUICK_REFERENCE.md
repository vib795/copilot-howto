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
# Edit to add your standards — see 02-custom-instructions/project-copilot-instructions.md
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

## Module Quick Links

| Module | Link |
|--------|------|
| Slash Commands | [01-slash-commands/README.md](01-slash-commands/README.md) |
| Custom Instructions | [02-custom-instructions/README.md](02-custom-instructions/README.md) |
| Extensions | [03-extensions/README.md](03-extensions/README.md) |
| Chat Variables | [04-chat-variables/README.md](04-chat-variables/README.md) |
| GitHub Actions | [05-github-actions/README.md](05-github-actions/README.md) |
| Copilot Workspace | [06-copilot-workspace/README.md](06-copilot-workspace/README.md) |
| CLI | [07-cli/README.md](07-cli/README.md) |
| Inline Suggestions | [08-inline-suggestions/README.md](08-inline-suggestions/README.md) |
| IDE Integration | [09-ide-integration/README.md](09-ide-integration/README.md) |
| Enterprise | [10-enterprise/README.md](10-enterprise/README.md) |
