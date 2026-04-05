# Installing and Setting Up `gh copilot`

This guide covers installation, verification, updating, removal, and troubleshooting for the GitHub Copilot CLI extension.

---

## Prerequisites

### 1. GitHub Account with Copilot Access

You need an active GitHub Copilot subscription:
- **Individual**: github.com → Settings → Copilot → Subscribe
- **Business/Enterprise**: provided by your organization administrator

Verify your subscription is active at: **github.com/settings/copilot**

### 2. GitHub CLI (`gh`) Installed and Authenticated

The Copilot extension runs on top of the GitHub CLI. Install it first.

#### Install `gh` on macOS

```bash
# Using Homebrew (recommended)
brew install gh

# Verify
gh --version
# Expected: gh version 2.x.x (...)
```

#### Install `gh` on Linux

**Ubuntu / Debian:**
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

**Fedora / RHEL / CentOS:**
```bash
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh
```

**Arch Linux:**
```bash
sudo pacman -S github-cli
```

#### Install `gh` on Windows

**Using winget (Windows Package Manager):**
```powershell
winget install --id GitHub.cli
```

**Using Chocolatey:**
```powershell
choco install gh
```

**Using scoop:**
```powershell
scoop install gh
```

#### Verify `gh` Installation

```bash
gh --version
# Expected output: gh version 2.x.x (YYYY-MM-DD)
```

### 3. Authenticate `gh` with Your GitHub Account

```bash
gh auth login
```

Follow the interactive prompts:
- Select **GitHub.com** (not GitHub Enterprise, unless your organization uses it)
- Select **HTTPS** as the protocol
- Choose **Login with a web browser** (opens github.com/login/device)
- Enter the one-time code shown in your terminal
- Authorize the GitHub CLI

**Verify authentication:**
```bash
gh auth status
# Expected output:
# github.com
#   ✓ Logged in to github.com account yourname (keyring)
#   - Active account: true
#   - Git operations protocol: https
#   - Token: gho_****
#   - Token scopes: 'gist', 'read:org', 'repo', 'workflow'
```

---

## Install the Copilot Extension

Once `gh` is installed and authenticated, install the Copilot extension:

```bash
gh extension install github/gh-copilot
```

Expected output:
```
✓ Installed extension github/gh-copilot
```

This downloads the extension binary and registers it with the `gh` CLI. No additional authentication is needed.

---

## Verify the Installation

```bash
gh copilot --version
# Expected: 1.x.x

gh copilot --help
# Expected: Shows help text with suggest and explain subcommands
```

**Test a basic suggestion:**
```bash
gh copilot suggest "list all running processes sorted by CPU usage"
```

If you see a command suggestion and the interactive prompt, the installation is successful.

---

## Update the Extension

GitHub occasionally releases updates to the Copilot extension. Update it with:

```bash
gh extension upgrade copilot
```

Or update all extensions at once:

```bash
gh extension upgrade --all
```

**Check current version:**
```bash
gh copilot --version
```

**Check for updates (without installing):**
```bash
gh extension list
# Shows installed extensions and their versions
```

---

## Uninstall the Extension

To remove the Copilot CLI extension:

```bash
gh extension remove copilot
```

This removes the extension binary but does not affect your `gh` installation, authentication, or any other extensions.

---

## Troubleshooting

### "gh: command not found"

The GitHub CLI is not installed or not in your PATH.

```bash
# Check if gh is installed
which gh
# or
type gh

# If installed but not in PATH, find the binary
find /usr /opt /home -name "gh" 2>/dev/null
```

If installed via Homebrew and not found:
```bash
# Add Homebrew to PATH (add to ~/.zshrc or ~/.bashrc)
eval "$(/opt/homebrew/bin/brew shellenv)"  # Apple Silicon
# or
eval "$(/usr/local/bin/brew shellenv)"     # Intel Mac
source ~/.zshrc
```

---

### "gh copilot: unknown command" or "not installed"

The extension is not installed, or the installation failed.

```bash
# Check installed extensions
gh extension list

# If copilot is not listed, install it
gh extension install github/gh-copilot

# If install fails, check gh version first
gh --version
# gh version 2.32.0 or later is required for extension support
```

If `gh` is too old, update it:
```bash
brew upgrade gh           # macOS
sudo apt upgrade gh       # Ubuntu/Debian
sudo dnf upgrade gh       # Fedora/RHEL
```

---

### Authentication Errors

**"You are not logged in"** or **"authentication required"**

```bash
# Check your current auth status
gh auth status

# Re-authenticate
gh auth logout
gh auth login
```

**"Your Copilot subscription is not active"** or similar

1. Go to **github.com/settings/copilot** and verify your subscription is active
2. If using an organization subscription, ask your admin to verify you have a seat assigned
3. Run `gh auth refresh` to refresh your token with any new scopes:

```bash
gh auth refresh -s copilot
```

---

### Proxy and Network Issues

If you are behind a corporate proxy, `gh` may not be able to reach GitHub's APIs.

**Set proxy environment variables:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export HTTPS_PROXY=http://proxy.company.com:8080
export HTTP_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1,.company.internal
```

**Configure gh to use the proxy:**
```bash
gh config set http-proxy http://proxy.company.com:8080
```

**If the proxy uses a custom CA certificate:**
```bash
# Set the certificate bundle path
export GH_CA_CERT=/path/to/company-ca-bundle.crt
# or
gh config set capath /path/to/company-ca-bundle.crt
```

---

### Extension Version Mismatch

If you get unexpected errors or the extension seems to behave incorrectly:

```bash
# Remove and reinstall the extension
gh extension remove copilot
gh extension install github/gh-copilot

# Check the version of gh itself
gh --version
```

Some extension features require a minimum version of `gh`. If you are on an older version:
```bash
brew upgrade gh           # macOS (Homebrew)
# For other platforms, refer to github.com/cli/cli/releases
```

---

### "permission denied" on Linux

```bash
# The extension binary may not be executable
ls -la ~/.local/share/gh/extensions/gh-copilot/
# Check if gh-copilot binary has execute permissions

# Fix permissions if needed
chmod +x ~/.local/share/gh/extensions/gh-copilot/gh-copilot
```

---

## Shell Completion (Optional)

Enable shell completion for `gh` commands, including the copilot extension:

**Zsh:**
```bash
echo 'eval "$(gh completion -s zsh)"' >> ~/.zshrc
source ~/.zshrc
```

**Bash:**
```bash
echo 'eval "$(gh completion -s bash)"' >> ~/.bashrc
source ~/.bashrc
```

**Fish:**
```bash
echo 'gh completion -s fish | source' >> ~/.config/fish/config.fish
```

After enabling completion, pressing Tab after `gh copilot` will suggest `suggest` and `explain`.

---

## GitHub Enterprise Server

If your organization uses GitHub Enterprise Server (GHES), additional configuration is needed:

```bash
# Authenticate against your GHES instance
gh auth login --hostname github.your-company.com

# Install the extension (it is fetched from github.com, not your GHES instance)
gh extension install github/gh-copilot

# Note: gh copilot uses the Copilot API on github.com, not your GHES instance
# Your GHES instance must be licensed for GitHub Copilot
```

Contact your GitHub Enterprise administrator if you cannot access the Copilot API through your GHES configuration.

---

## Summary

| Task | Command |
|------|---------|
| Install | `gh extension install github/gh-copilot` |
| Verify | `gh copilot --version` |
| Update | `gh extension upgrade copilot` |
| Uninstall | `gh extension remove copilot` |
| Check auth | `gh auth status` |
| Re-authenticate | `gh auth login` |
| List all extensions | `gh extension list` |
