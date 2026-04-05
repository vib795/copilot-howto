# GitHub Copilot CLI (`gh copilot`)

The GitHub Copilot CLI is a GitHub CLI extension that translates natural language into shell commands and explains unfamiliar commands. It runs in your terminal and integrates with the `gh` CLI you already use.

---

## What `gh copilot` Is

`gh copilot` is a GitHub CLI extension with exactly two commands:

| Command | What it does |
|---------|-------------|
| `gh copilot suggest` | Generates a shell command from a natural language description |
| `gh copilot explain` | Explains what a given shell command does |

That's it. This is a focused, single-purpose tool — not a general-purpose coding assistant.

The target use case is: **"I know what I want to do but I can't remember the exact command."** If you have used `tldr`, `cheat.sh`, or StackOverflow for this purpose, `gh copilot suggest` replaces those workflows with natural language.

---

## Installation

### Prerequisites

You need the GitHub CLI (`gh`) installed and authenticated before installing the Copilot extension.

**Install `gh` on macOS:**

```bash
brew install gh
```

**Install `gh` on Linux (Ubuntu/Debian):**

```bash
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y
```

**Install `gh` on Windows:**

```powershell
winget install --id GitHub.cli
# or
choco install gh
```

**Authenticate:**

```bash
gh auth login
# Follow the prompts to authenticate with your GitHub account
```

### Install the Copilot Extension

```bash
gh extension install github/gh-copilot
```

This downloads and registers the extension. No additional authentication is needed — it uses your existing `gh` auth token.

### Verify Installation

```bash
gh copilot --version
# Example output: 1.0.0
```

If this returns "command not found," see the Troubleshooting section below.

---

## `gh copilot suggest`

### Basic Usage

```bash
gh copilot suggest "compress the logs directory into a tar.gz file"
```

Copilot returns a suggested command:

```
Suggestion:

  tar -czf logs.tar.gz logs/

? What would you like to do?
  Copy command to clipboard
  Execute command
  Revise command
  Cancel
```

### The Interactive Flow

After suggesting a command, `gh copilot suggest` asks what you want to do:

1. **Copy command to clipboard** — copies the command without running it (useful when you want to inspect or modify it first)
2. **Execute command** — runs the command directly in your current shell
3. **Revise command** — lets you provide additional context or constraints ("make it recursive" / "exclude .git directories" / "add verbose output")
4. **Cancel** — exits without doing anything

The "Revise command" option is particularly useful for iterating:

```
Suggestion: tar -czf logs.tar.gz logs/

You: Revise command
Additional instructions: exclude files larger than 10MB

Updated suggestion: find logs/ -size -10M | tar -czf logs.tar.gz -T -
```

### Specifying Shell Type

By default, `gh copilot suggest` detects your shell from the `$SHELL` environment variable. You can override this with the `--shell-type` / `-t` flag:

```bash
# Generate a PowerShell command (even if running in bash)
gh copilot suggest -t powershell "find all .log files older than 7 days and delete them"

# Generate a fish shell command
gh copilot suggest -t fish "set an environment variable permanently"

# Generate a bash command explicitly
gh copilot suggest -t bash "list all running docker containers with their port mappings"

# Supported shell types: bash, zsh, fish, powershell
```

Shell type auto-detection reads `$SHELL`:

```bash
echo $SHELL
# /bin/zsh → generates zsh commands
# /bin/bash → generates bash commands
# /usr/bin/fish → generates fish commands
```

### Aliases for Faster Access

Many developers alias `gh copilot suggest` for daily use:

```bash
# Add to ~/.zshrc, ~/.bashrc, or ~/.bash_profile
alias suggest='gh copilot suggest'
alias ??='gh copilot suggest'     # "?? how do I..."
alias explain='gh copilot explain'
```

After adding these, reload your shell:

```bash
source ~/.zshrc   # or source ~/.bashrc
```

Then use the shorter forms:

```bash
suggest "find all node_modules directories and calculate their total size"
?? "kill all processes using port 3000"
```

---

## `gh copilot explain`

### Basic Usage

Pass a shell command as a string argument:

```bash
gh copilot explain "git log --oneline --graph --decorate --all"
```

Output (example):

```
This command displays the git commit history with the following options:

• --oneline: Condenses each commit to a single line showing the hash and subject
• --graph: Shows a text-based graphical representation of the branch structure
  as a series of ASCII art lines and characters
• --decorate: Shows branch names, tags, and HEAD pointer next to commits
• --all: Includes all branches (not just the currently checked-out one) in the output

Combined, this is commonly used to get a quick visual overview of all branches
and their relationship in the repository.
```

### Explaining Complex Commands

The explain command is especially useful for multi-part pipelines:

```bash
gh copilot explain "find . -name '*.js' -not -path '*/node_modules/*' | xargs grep -l 'TODO' | sort"
```

```bash
# Or use single quotes to avoid shell interpretation issues
gh copilot explain 'awk -F: '\''NR==FNR{a[$1]=$2; next} $1 in a {print $0, a[$1]}'\'' file1 file2'
```

---

## Capability Gap: `gh copilot suggest` vs. `claude -p`

This is the most important limitation to understand:

### `gh copilot suggest` can only:
- Suggest a single shell command
- Explain a shell command
- Revise a suggestion based on your feedback

### `gh copilot suggest` cannot:
- Execute a sequence of commands that depend on each other's output
- Read, create, or modify files (beyond what a shell command does)
- Maintain context across multiple suggestions
- Reason about your codebase
- Chain tasks together in an automated pipeline
- Be used non-interactively in CI/CD (it is interactive by design)

### Claude Code (`claude -p`) can:
- Execute a complete multi-step task ("refactor this module, run the tests, fix the failing ones, and open a PR")
- Maintain context and conversation history
- Read and modify multiple files
- Use tools (browser, search, code execution)
- Be used non-interactively with `claude -p "prompt"` in scripts

### For Automation Pipelines

If you previously used `claude -p` as part of a CI/CD pipeline or automation script, the closest Copilot equivalent is the **Copilot coding agent in GitHub Actions** (not `gh copilot suggest`). See [../05-github-actions/copilot-in-actions.md](../05-github-actions/copilot-in-actions.md).

---

## Use Cases

### Translating Natural Language to Shell Commands

When you know what you want but not the exact syntax:

```bash
suggest "find all files modified in the last 24 hours, sorted by size"
suggest "show me which process is using port 8080"
suggest "create a git tag and push it to remote"
suggest "compare two directories and show only files that differ"
```

### Understanding Unfamiliar Commands

When you encounter a command in a script or documentation and want to understand it:

```bash
gh copilot explain "rsync -avz --delete --exclude='.git' src/ user@server:/var/www/"
gh copilot explain "lsof -i TCP:3000 | grep LISTEN | awk '{print \$2}' | xargs kill"
```

### Generating Complex Pipelines

When you need a multi-step pipeline and would rather describe it in plain English:

```bash
suggest "find all JavaScript files, count the lines of code in each, and show the top 10 largest files"
suggest "git log the last 30 days of commits, group by author, and count commits per author"
```

---

## Troubleshooting

See [installation.md](./installation.md) for detailed installation troubleshooting.

**Quick fixes:**

```bash
# Extension not found
gh extension list   # Check if copilot is listed

# Re-install
gh extension remove copilot
gh extension install github/gh-copilot

# Auth issues
gh auth status      # Check authentication status
gh auth refresh     # Refresh auth token

# Update to latest version
gh extension upgrade copilot
```

---

## Related Files

| File | Content |
|------|---------|
| [suggest-patterns.md](./suggest-patterns.md) | 10+ real examples for `gh copilot suggest` |
| [explain-patterns.md](./explain-patterns.md) | Examples for `gh copilot explain` |
| [installation.md](./installation.md) | Full installation and troubleshooting guide |
| [scripting-with-cli.md](./scripting-with-cli.md) | Using `gh copilot` in scripts and wrappers |
