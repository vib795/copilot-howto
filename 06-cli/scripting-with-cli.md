# Using `gh copilot` in Scripts

`gh copilot suggest` is designed as an interactive tool — it prompts you to choose what to do with a suggestion. This makes it useful in daily terminal use but requires some adaptation for scripting and automation.

This document covers how to use `gh copilot` in a scripting context, its inherent limitations, and what to use instead for non-interactive scenarios.

---

## The Core Limitation: `gh copilot` is Interactive by Design

When you run `gh copilot suggest "some task"`, it:
1. Generates a suggestion
2. Prompts: "What would you like to do?" (copy / execute / revise / cancel)

There is no official `--non-interactive` or `--yes` flag that skips the prompt and auto-executes the suggestion. This is by design — automatically executing AI-generated commands without human confirmation is unsafe.

**If you need non-interactive command generation**, the right tool is the **GitHub Models API** directly, not `gh copilot suggest`. See the GitHub Models section below.

---

## Shell Aliases for Daily Use

The most practical scripting use of `gh copilot` is aliasing it for faster invocation:

### Basic Aliases

Add to your `~/.zshrc`, `~/.bashrc`, or `~/.config/fish/config.fish`:

```bash
# Short aliases
alias suggest='gh copilot suggest'
alias explain='gh copilot explain'

# Question-mark shortcuts (popular pattern)
alias '??'='gh copilot suggest'
alias '??!'='gh copilot suggest -t bash'  # Force bash output

# Shell-specific aliases
alias suggest-bash='gh copilot suggest -t bash'
alias suggest-zsh='gh copilot suggest -t zsh'
alias suggest-ps='gh copilot suggest -t powershell'
```

After adding aliases, reload your shell:
```bash
source ~/.zshrc   # or source ~/.bashrc
```

### Usage with aliases

```bash
?? "find all Python files modified in the last week"
explain "find . -name '*.py' -mtime -7"
suggest-bash "recursively set permissions on a directory"
```

---

## Shell Function Wrappers

While you cannot fully automate `gh copilot suggest` without human confirmation, you can write wrappers that improve the experience.

### Wrapper: Log Suggestions to History

This wrapper records what suggestion was generated for each prompt, so you can review what commands were suggested over time:

```bash
# Add to ~/.zshrc or ~/.bashrc

suggest() {
  local prompt="$*"
  local log_file="${HOME}/.gh-copilot-history"
  local timestamp

  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  # Run gh copilot suggest normally (interactive)
  gh copilot suggest "$prompt"
  local exit_code=$?

  # Log the prompt (not the output — we can't capture it without breaking interactivity)
  echo "[$timestamp] suggest: $prompt" >> "$log_file"

  return $exit_code
}
```

### Wrapper: Suggest with Shell Type Detection

Auto-detect and pass the right shell type flag:

```bash
smart-suggest() {
  local shell_type

  # Detect current shell
  case "$SHELL" in
    */bash) shell_type="bash" ;;
    */zsh)  shell_type="zsh" ;;
    */fish) shell_type="fish" ;;
    *)      shell_type="bash" ;;  # fallback
  esac

  gh copilot suggest -t "$shell_type" "$@"
}
```

### Wrapper: Safe Execution Helper

This wrapper helps with a common pattern: generate a command, inspect it, and run it only if it looks safe. This does not bypass the interactive prompt — it adds an additional safety layer for commands that were copied (not directly executed via the suggest prompt):

```bash
# Run a command after showing it and asking for confirmation
safe-run() {
  local cmd="$1"
  echo "Command to run:"
  echo "  $cmd"
  echo ""
  read -r -p "Run this command? [y/N] " response
  case "$response" in
    [yY][eE][sS]|[yY])
      eval "$cmd"
      ;;
    *)
      echo "Aborted."
      ;;
  esac
}

# Usage: copy a command from gh copilot suggest, then run:
# safe-run "find . -name '*.log' -mtime +7 -delete"
```

---

## Using GitHub Models API for Non-Interactive Scripting

For automation that needs to generate shell commands without user interaction, bypass `gh copilot suggest` entirely and call the **GitHub Models API** directly.

The GitHub Models API provides access to AI models (including GPT-4o and others) using your `GITHUB_TOKEN` or `gh auth token`.

### Requirements

- GitHub Copilot subscription (Individual, Business, or Enterprise)
- `gh` authenticated: `gh auth login`
- `jq` installed for JSON parsing

### Basic Shell Command Generation Script

```bash
#!/usr/bin/env bash
# generate-command.sh — Generate a shell command using GitHub Models API
# Usage: ./generate-command.sh "find all .log files older than 7 days"

set -euo pipefail

PROMPT="$1"
SHELL_TYPE="${2:-bash}"

if [[ -z "$PROMPT" ]]; then
  echo "Usage: $0 <prompt> [shell-type]" >&2
  exit 1
fi

# Get auth token from gh
TOKEN=$(gh auth token)

# Build the API request
SYSTEM_PROMPT="You are a shell command generator. Given a task description, respond with ONLY the shell command to accomplish the task. No explanations, no markdown, no code blocks. Shell type: ${SHELL_TYPE}. Command only."

RESPONSE=$(curl -s \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://models.inference.ai.azure.com/chat/completions" \
  -d "$(jq -n \
    --arg system "$SYSTEM_PROMPT" \
    --arg prompt "$PROMPT" \
    '{
      model: "gpt-4o-mini",
      messages: [
        {role: "system", content: $system},
        {role: "user", content: $prompt}
      ],
      max_tokens: 200,
      temperature: 0.1
    }'
  )")

# Extract the generated command
COMMAND=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty' | tr -d '\n')

if [[ -z "$COMMAND" ]]; then
  echo "Error: No command generated. API response:" >&2
  echo "$RESPONSE" | jq . >&2
  exit 1
fi

echo "$COMMAND"
```

**Usage:**

```bash
chmod +x generate-command.sh

# Generate and inspect
./generate-command.sh "find all .log files older than 7 days"
# Output: find . -name "*.log" -mtime +7 -print

# Generate and execute (use with caution — review first)
COMMAND=$(./generate-command.sh "list all running docker containers with their ports")
echo "Generated: $COMMAND"
read -r -p "Execute? [y/N] " confirm
[[ "$confirm" == "y" ]] && eval "$COMMAND"
```

### Non-Destructive Command Executor

A more complete wrapper that generates a command, categorizes it as safe or potentially destructive, and acts accordingly:

```bash
#!/usr/bin/env bash
# smart-suggest.sh — Generate and optionally execute shell commands safely

set -euo pipefail

PROMPT="$1"
TOKEN=$(gh auth token)

# Step 1: Generate the command
COMMAND=$(curl -s \
  -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://models.inference.ai.azure.com/chat/completions" \
  -d "$(jq -n \
    --arg prompt "$PROMPT" \
    '{
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: "Generate only the shell command for this task. No explanations."
        },
        {role: "user", content: $prompt}
      ],
      max_tokens: 150,
      temperature: 0.1
    }'
  )" | jq -r '.choices[0].message.content' | tr -d '\n')

echo ""
echo "Suggested command:"
echo "  $COMMAND"
echo ""

# Step 2: Check for destructive patterns
DESTRUCTIVE_PATTERNS=("rm -rf" "rm -r" "drop table" "delete from" "truncate" "> /dev/" "mkfs" "dd if=")
IS_DESTRUCTIVE=false

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    IS_DESTRUCTIVE=true
    break
  fi
done

# Step 3: Act based on destructive classification
if $IS_DESTRUCTIVE; then
  echo "WARNING: This command may be destructive."
  echo ""
  read -r -p "Type 'yes' to execute, or anything else to abort: " confirm
  if [[ "$confirm" == "yes" ]]; then
    eval "$COMMAND"
  else
    echo "Aborted."
    exit 1
  fi
else
  read -r -p "Execute? [Y/n] " confirm
  confirm="${confirm:-y}"
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    eval "$COMMAND"
  else
    echo "Aborted."
  fi
fi
```

---

## CI/CD Note: `gh copilot` is Not for CI/CD

`gh copilot suggest` is interactive and not designed for CI/CD pipelines. Do not use it in GitHub Actions workflows or other automated pipelines.

**Why it does not work in CI/CD:**
- Requires interactive terminal input (the "what would you like to do?" prompt)
- Not designed for unattended execution
- Rate limited for interactive use, not bulk processing

**What to use instead for CI/CD automation:**

| Use case | Right tool |
|----------|-----------|
| Auto-implement an issue in CI | Copilot coding agent (`github/copilot-coding-agent@v1`) |
| Auto-review PRs | `github/copilot-code-review@v1` |
| Generate a PR description | GitHub Models API via `curl` in a workflow step |
| Run a shell command based on AI output | GitHub Models API → `eval` (with caution) |

For CI/CD pipelines that need AI-generated shell commands, use the GitHub Models API directly with your `GITHUB_TOKEN` (as shown in the script examples above), not `gh copilot suggest`.

---

## Quick Reference

```bash
# Daily use aliases (add to ~/.zshrc or ~/.bashrc)
alias suggest='gh copilot suggest'
alias explain='gh copilot explain'
alias '??'='gh copilot suggest'

# Update the extension
gh extension upgrade copilot

# Generate a command non-interactively (using GitHub Models API)
TOKEN=$(gh auth token)
curl -s -X POST \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  "https://models.inference.ai.azure.com/chat/completions" \
  -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"bash command to find large files"}],"max_tokens":100}'
```
