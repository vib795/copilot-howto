# GitHub Copilot Setup: VS Code

VS Code provides the most complete GitHub Copilot experience available in any IDE. This guide covers installation, authentication, verification, key panels and shortcuts, essential settings, and troubleshooting.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install the Extensions](#install-the-extensions)
3. [Sign In](#sign-in)
4. [Verify the Installation](#verify-the-installation)
5. [Key Panels and Interfaces](#key-panels-and-interfaces)
6. [Keyboard Shortcuts](#keyboard-shortcuts)
7. [Essential Settings](#essential-settings)
8. [Useful Extensions to Pair with Copilot](#useful-extensions-to-pair-with-copilot)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **VS Code version 1.85 or later** (check via **Help → About**)
- A GitHub account with an active Copilot subscription (Individual, Business, or Enterprise)
- Internet access to `api.githubcopilot.com` (see [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md) for corporate network configuration)

---

## Install the Extensions

Copilot in VS Code is delivered as two separate extensions. Both are required for the full experience.

### Option 1: Extensions Sidebar

1. Open the Extensions sidebar: `Ctrl+Shift+X` (Windows/Linux) or `Cmd+Shift+X` (macOS)
2. Search for **"GitHub Copilot"**
3. Click **Install** on the extension by **GitHub** (publisher verified with a blue checkmark)
4. Search for **"GitHub Copilot Chat"** and install that as well

### Option 2: Command Palette

1. Press `Ctrl+Shift+P` → type **"Extensions: Install Extensions"**
2. Search for and install both extensions as above

### Option 3: From the Web

Visit the extension pages directly:
- [GitHub Copilot](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [GitHub Copilot Chat](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)

Click **Install** → VS Code opens and installs the extension.

After installation, VS Code may prompt you to **Reload**. Click **Reload** or press `Ctrl+Shift+P` → **Developer: Reload Window**.

---

## Sign In

After installation, VS Code prompts you to sign in to GitHub. The authentication flow:

1. A notification appears: **"Sign in to use GitHub Copilot"** — click **Sign In**.
2. VS Code opens your browser to GitHub's OAuth authorisation page.
3. Log in with your GitHub credentials if not already logged in.
4. Click **Authorize Visual Studio Code**.
5. The browser redirects back to VS Code with the message **"You are now signed in"**.

If the automatic prompt does not appear:

1. Click the **Accounts** icon in the Activity Bar (bottom of the left sidebar, person silhouette icon).
2. Select **Sign in with GitHub to use GitHub Copilot**.

### Verifying Your Subscription

After signing in, VS Code checks your GitHub account for an active Copilot subscription. If you see an error like **"You don't have access to GitHub Copilot"**, confirm that:
- Your GitHub account has an active Copilot subscription at [github.com/settings/copilot](https://github.com/settings/copilot)
- If you are in an organisation, your org admin has assigned you a Copilot seat

---

## Verify the Installation

### Method 1: Ghost Text Test

1. Create a new file: `Ctrl+N`, then save it as `test.py` (or any supported language)
2. Type the following comment:
   ```python
   # Function to check if a number is prime
   def
   ```
3. After typing `def`, pause for one second. Ghost text (greyed-out completion) should appear suggesting the function signature and body.
4. Press `Tab` to accept the suggestion.

If ghost text appears and is accepted, Copilot is working correctly.

### Method 2: Status Bar Icon

The Copilot icon (a pair of overlapping circles, similar to a GitHub Copilot logo) appears in the VS Code status bar at the bottom of the window.

- **Active (white/normal)**: Copilot is enabled and ready
- **Yellow warning icon**: Authentication issue — click to resolve
- **Spinning**: A completion request is in-flight
- **Line through the icon**: Copilot is disabled for the current file type

Click the icon to access per-language enable/disable options and other quick settings.

---

## Key Panels and Interfaces

### Copilot Chat Sidebar

The Chat panel provides a conversational interface with Copilot, supporting `@workspace`, `#file`, `/explain`, `/fix`, and other commands.

- **Open**: Click the Copilot Chat icon in the Activity Bar (chat bubble icon), or press `Ctrl+Alt+I`
- **Close**: Click the icon again or press `Ctrl+B` to toggle the sidebar

### Inline Chat

Inline chat opens a floating input directly in the editor at your cursor position. Use it to ask a focused question about the code around the cursor, or to ask Copilot to refactor, explain, or generate code in-place.

- **Open inline chat**: `Ctrl+I` (Windows/Linux) or `Cmd+I` (macOS)
- **Close**: `Escape`
- **Accept inline chat change**: Click **Accept** or press `Alt+Enter`

### Completions Panel

The completions panel shows up to 10 inline suggestion candidates simultaneously, rather than the single ghost text candidate shown at the cursor.

- **Open**: `Ctrl+Enter` while a file is open and the cursor is in an active position
- **Insert a candidate**: Click **Accept** next to the candidate you want

The completions panel is useful when the primary ghost text suggestion is not quite right but you want to compare alternatives before deciding.

---

## Keyboard Shortcuts

For the full cross-IDE shortcut reference, see [../08-inline-suggestions/acceptance-shortcuts.md](../08-inline-suggestions/acceptance-shortcuts.md).

| Action | Shortcut |
|---|---|
| Accept inline suggestion | `Tab` |
| Dismiss inline suggestion | `Escape` |
| Next suggestion | `Alt+]` |
| Previous suggestion | `Alt+[` |
| Accept word-by-word | `Ctrl+Right` |
| Trigger suggestion manually | `Alt+\` |
| Open completions panel | `Ctrl+Enter` |
| Open Copilot Chat | `Ctrl+Alt+I` |
| Open inline chat | `Ctrl+I` |

---

## Essential Settings

Open your `settings.json` (`Ctrl+Shift+P` → **Open User Settings JSON**) and configure the following:

### Enable/Disable per Language

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": false
  }
}
```

### Custom Instructions via `.github/copilot-instructions.md`

For project-level custom instructions (applied to every Copilot request in the workspace), create the file `.github/copilot-instructions.md` in your project root:

```markdown
# Project Instructions for GitHub Copilot

- This project uses TypeScript with strict mode enabled.
- All functions must include JSDoc comments.
- Use `async/await` rather than `.then()` chains.
- Error handling must use custom error classes from `src/errors/`.
- Tests use Vitest, not Jest.
```

For user-level custom instructions (applied globally, not tied to a project), configure them in settings:

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    {
      "text": "Always add a complexity comment (O(n) notation) above functions with non-trivial algorithms."
    }
  ]
}
```

### Next Edit Suggestions

```json
{
  "github.copilot.nextEditSuggestions.enabled": true
}
```

### Disable Auto-Completions (Manual Trigger Only)

```json
{
  "github.copilot.editor.enableAutoCompletions": false
}
```

When disabled, use `Alt+\` to request a completion on demand.

---

## Useful Extensions to Pair with Copilot

These extensions complement Copilot and are commonly used together:

### GitLens

**Extension ID**: `eamodio.gitlens`

GitLens enhances VS Code's built-in Git capabilities with inline blame annotations, commit history exploration, and repository visualisation. It complements Copilot by giving you deep context about *why* code was written a certain way (via blame and history), which helps you write better prompts and evaluate suggestions more accurately.

**Key features:**
- Inline Git blame on the current line
- File and line history
- Visual branch and commit explorer
- Code authorship heatmap

### Error Lens

**Extension ID**: `usernamehw.errorlens`

Error Lens displays diagnostic messages (errors, warnings, info) inline on the affected line, rather than requiring you to hover over the squiggly underline. This pairs well with Copilot because you can immediately see whether a Copilot suggestion introduced a type error or lint warning without leaving the edit position.

**Key feature:** Inline error and warning text on the same line as the problem.

### GitHub Pull Requests and Issues

**Extension ID**: `GitHub.vscode-pull-request-github`

Integrates GitHub PR and issue workflows directly into VS Code. When paired with Copilot Chat's `@github` agent (which can reference PRs and issues), this extension lets you manage the full review-and-merge lifecycle without leaving the editor.

---

## Troubleshooting

### Copilot Suggestions Not Appearing

**Step 1: Check the Copilot status bar icon.**
- Yellow icon or error message → authentication issue. Click the icon and re-authenticate.
- Icon with a line through it → Copilot is disabled for this language. Click the icon → **Enable for [language]**.

**Step 2: Check that the language is enabled.**
```json
// In settings.json, verify:
{
  "github.copilot.enable": {
    "*": true
    // Make sure the current language is not set to false
  }
}
```

**Step 3: Check that auto-completions are on.**
```json
{
  "github.copilot.editor.enableAutoCompletions": true
}
```

**Step 4: Verify your subscription.**
Go to [github.com/settings/copilot](https://github.com/settings/copilot) in a browser. If the page shows "You don't have an active subscription," contact your GitHub admin or purchase a plan.

**Step 5: Try a manual trigger.**
Position the cursor in a code file and press `Alt+\`. If a suggestion appears, the issue is with the auto-trigger debounce (possibly a slow network or high CPU load), not with Copilot itself.

### Proxy Errors / Network Issues

If you are behind a corporate proxy or firewall, see [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md) for configuration instructions.

Quick check — test Copilot endpoint reachability:

```bash
curl -v https://api.githubcopilot.com
# Should return HTTP 200 or 401 (auth required), not a connection error
```

Configure proxy in VS Code settings:

```json
{
  "http.proxy": "https://your-proxy.corp.example.com:8080",
  "http.proxyStrictSSL": false  // only if using SSL inspection
}
```

### Copilot Stopped Working After Updating VS Code

Extension updates sometimes require a reload. Press `Ctrl+Shift+P` → **Developer: Reload Window**. If the issue persists, check the Extensions sidebar for any pending updates to the Copilot extensions.

### "GitHub Copilot could not connect to server"

This error typically means the Copilot API endpoint is unreachable. Possible causes:
- No internet connection
- Corporate firewall blocking `api.githubcopilot.com`
- VPN configuration that routes Copilot traffic incorrectly

Refer to [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md) for firewall configuration.

### Suggestion Quality Is Poor

If suggestions seem generic or incorrect:
- Ensure the relevant files are open in editor tabs (Copilot uses neighboring tabs as context)
- Add or improve comments describing the function's intent
- Check that imports for the relevant libraries are present
- See [../08-inline-suggestions/effective-prompting-for-completion.md](../08-inline-suggestions/effective-prompting-for-completion.md) for prompting strategies
