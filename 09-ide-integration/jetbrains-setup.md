# GitHub Copilot Setup: JetBrains IDEs

A single GitHub Copilot plugin works across the entire JetBrains product line. This guide covers installation, authentication, verification, the Chat panel, keyboard shortcuts, settings, and troubleshooting. The steps apply to IntelliJ IDEA, PyCharm, WebStorm, GoLand, Rider, CLion, and DataGrip unless noted otherwise.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Install the Plugin](#install-the-plugin)
3. [Sign In](#sign-in)
4. [Verify the Installation](#verify-the-installation)
5. [Chat Panel](#chat-panel)
6. [Inline Chat](#inline-chat)
7. [Keyboard Shortcuts](#keyboard-shortcuts)
8. [Settings](#settings)
9. [Feature Availability vs. VS Code](#feature-availability-vs-vs-code)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **JetBrains IDE version 2023.1 or later** — the Copilot plugin requires a recent IDE build. Check **Help → About** for your version.
- A GitHub account with an active Copilot subscription.
- Internet access. For corporate proxy requirements, see [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md).

---

## Install the Plugin

### From the IDE Plugins Marketplace

1. Open **Settings** (`Ctrl+Alt+S` on Windows/Linux, `Cmd+,` on macOS).
2. Navigate to **Plugins**.
3. Click the **Marketplace** tab.
4. Search for **"GitHub Copilot"**.
5. Click **Install** on the plugin published by **GitHub**.
6. Accept any license agreements when prompted.
7. Click **Restart IDE** when prompted — a restart is required after installation.

### From the JetBrains Toolbox / Plugin Repository

Alternatively, you can install the plugin from the [JetBrains Plugin Repository](https://plugins.jetbrains.com/plugin/17718-github-copilot) by clicking **Get** → **Install to IDE** with your IDE already open.

### Offline / Air-Gapped Installation

If your environment does not have direct internet access for plugin downloads:

1. Download the `.zip` plugin file from the JetBrains Plugin Repository on an internet-connected machine.
2. In the IDE: **Settings → Plugins → gear icon (⚙) → Install Plugin from Disk...** → select the `.zip` file.
3. Restart the IDE.

---

## Sign In

After installation and restart:

1. A notification bar appears at the top of the editor: **"Log In to GitHub"** — click it.
2. Alternatively, go to **Tools → GitHub Copilot → Login to GitHub**.
3. A device code (e.g., `ABCD-1234`) is displayed in a dialog.
4. Your browser opens to [github.com/login/device](https://github.com/login/device).
5. Enter the device code, sign in to GitHub if not already, and click **Authorize**.
6. Switch back to the IDE — authentication completes automatically.

The Copilot icon appears in the status bar at the bottom of the IDE window, confirming a successful login.

### Switching Accounts or Signing Out

Go to **Tools → GitHub Copilot → Logout** to sign out. Then go to **Tools → GitHub Copilot → Login to GitHub** to sign in with a different account.

---

## Verify the Installation

1. Create a new file in a supported language (e.g., `Test.java`, `test.py`, `test.ts`).
2. Type a comment describing a function:
   ```python
   # Sort a list of dictionaries by the value of a given key
   def
   ```
3. Pause for one second after typing `def`. Ghost text suggesting the function signature should appear in grey.
4. Press `Tab` to accept. If the completion inserts correctly, Copilot is working.

### Status Bar Icon

The Copilot icon in the status bar (bottom right of the IDE window) shows:
- **Normal icon**: Copilot is active
- **Icon with a line through it**: Copilot is disabled for the current file type
- **Warning icon**: Authentication error — click to re-authenticate

---

## Chat Panel

### Opening the Chat Panel

- **Via menu**: **View → Tool Windows → GitHub Copilot Chat**
- **Via keyboard**: The default shortcut varies by IDE and OS; check **Settings → Keymap → GitHub Copilot Chat**. A common binding is `Alt+Shift+G` or `Ctrl+Alt+G`.
- **Via the status bar**: Click the Copilot icon → **Open GitHub Copilot Chat**

### Using the Chat Panel

The Chat panel works similarly to VS Code's Copilot Chat:

- Type a question or instruction and press `Enter`
- Select code in the editor, then ask the chat to explain, fix, or refactor the selection
- Use slash commands: `/explain`, `/fix`, `/tests`, `/doc`

**Note on `@workspace`**: The `@workspace` agent (which searches your entire project) may have limited functionality in JetBrains compared to VS Code. It is available in recent versions of the plugin but its depth of project indexing differs. For best results with `@workspace` in JetBrains, ensure your project is fully indexed (**Help → Find Action → Rescan Project**).

---

## Inline Chat

Inline chat opens a floating input directly in the editor, letting you make targeted requests about the code at the cursor without switching to the Chat panel.

### Opening Inline Chat

- **Keyboard**: `Alt+\` (or right-click in the editor → **GitHub Copilot → Ask Copilot**)
- **Via the context menu**: Right-click any selection → **GitHub Copilot → (inline action)**

### Using Inline Chat

1. Select the code you want to ask about (optional but recommended)
2. Press `Alt+\`
3. Type your request in the floating input (e.g., "Refactor this to use streams" or "Add null checks")
4. Press `Enter` — Copilot generates an inline diff showing the suggested change
5. Press `Alt+Enter` or click **Accept** to apply, or press `Escape` to dismiss

---

## Keyboard Shortcuts

| Action | Default Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts ghost text |
| Dismiss suggestion | `Escape` | Clears ghost text |
| Next suggestion | `Alt+]` | Cycles forward through alternatives |
| Previous suggestion | `Alt+[` | Cycles backward |
| Accept next word | `Alt+Right` | Word-by-word acceptance (differs from VS Code's `Ctrl+Right`) |
| Trigger suggestion manually | `Alt+\` | Forces a completion request |
| Open inline chat | `Alt+\` (or right-click) | Opens floating input when no suggestion is shown |

### Customising Shortcuts

1. Open **Settings → Keymap**
2. Search for **"GitHub Copilot"** in the keymap search box
3. Double-click any action to rebind it

If `Alt+\` or `Tab` conflicts with another plugin or IDE action, resolve it here. The Copilot plugin's shortcuts are listed under the **GitHub Copilot** group in the keymap.

---

## Settings

Copilot-specific settings in JetBrains are found at:

**File → Settings → Tools → GitHub Copilot** (Windows/Linux)
**JetBrains IDE → Settings → Tools → GitHub Copilot** (macOS)

### Available Settings

| Setting | Description |
|---|---|
| Enable completions | Master toggle for inline ghost text completions |
| Enable automatic completions | Show suggestions while typing (disable for manual-trigger-only mode) |
| Enable proxy | Proxy configuration for Copilot API requests |
| Show Copilot icon in status bar | Toggle the status bar icon |

### Per-Language Enable/Disable

Unlike VS Code, JetBrains Copilot settings do not have a granular per-language `settings.json`. Instead:

1. Open a file of the language you want to disable
2. Click the Copilot icon in the status bar
3. Select **Disable Completions for [language]**

This writes a per-language setting that persists across IDE sessions.

---

## Feature Availability vs. VS Code

JetBrains provides strong Copilot support, but some features available in VS Code are absent or limited. Understanding these gaps helps you decide when to use JetBrains vs. VS Code.

| Feature | JetBrains | VS Code | Notes |
|---|---|---|---|
| Inline suggestions (ghost text) | Full | Full | Equivalent quality |
| Copilot Chat panel | Full | Full | `/explain`, `/fix`, `/tests` available |
| Inline chat (`Alt+\`) | Full | Full | Works on selections |
| `@workspace` agent | Partial | Full | JetBrains may not fully index all project files |
| `#file` context variable | Partial | Full | Available in recent plugin versions |
| `@terminal` agent | Not available | Full | VS Code only |
| `@vscode` agent | Not available | Full | VS Code only |
| Next Edit Suggestions (NES) | Not available | Full | VS Code only as of early 2026 |
| Custom instructions (`.github/copilot-instructions.md`) | Not available | Full | VS Code only |
| Copilot Extensions | Not available | Full | VS Code only |
| Copilot Workspace integration | Not available | Full | VS Code only |
| Rename suggestions | Not available | Full | VS Code only |

**Recommendation**: For projects where you need `@workspace` search, custom instructions, NES, or Copilot Extensions, use VS Code. For day-to-day coding with inline suggestions and Chat, JetBrains is a strong second choice.

---

## Troubleshooting

### Copilot Suggestions Not Appearing After Installation

The most common cause is forgetting to restart the IDE after installation. JetBrains plugins require a full restart to initialise.

1. Go to **Help → Find Action** → type **"Restart IDE"** → press Enter.
2. After restart, verify authentication: **Tools → GitHub Copilot → Login to GitHub**.

### Plugin Conflicts

If another plugin registers the same shortcuts (`Tab`, `Alt+]`, `Alt+[`), Copilot suggestions may not respond to keyboard input.

1. Check **Settings → Keymap** for conflicts on the Copilot keys.
2. Common culprits: Vim emulation plugins (IdeaVim), live template plugins, other code completion plugins.
3. Resolve by reassigning the conflicting plugin's key or the Copilot key.

### "GitHub Copilot plugin is not compatible with this IDE version"

Update your JetBrains IDE to a recent version (2023.1+). The Copilot plugin tracks the latest major IDE releases and drops support for older versions.

### Proxy / Network Configuration

If you are behind a corporate proxy:

1. Go to **Settings → Tools → GitHub Copilot → Proxy**
2. Enable the proxy and enter your proxy URL and port
3. If your proxy uses authentication, enter the credentials

Alternatively, set the system-level `HTTPS_PROXY` environment variable before launching the IDE.

See [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md) for full details.

### SSL Certificate Errors

If your corporate network performs SSL inspection (man-in-the-middle with a custom CA), the JetBrains IDE must trust the corporate CA certificate.

1. Go to **Settings → Tools → Server Certificates**
2. Add your corporate CA certificate (`.cer` or `.crt` file)
3. Restart the IDE

### Authentication Loop (Keeps Asking to Log In)

This can occur if the keychain/credential store used by the IDE cannot persist the GitHub token. Try:

1. **Tools → GitHub Copilot → Logout**
2. Clear any stored Copilot credentials from your OS keychain (macOS Keychain, Windows Credential Manager, or the relevant Linux secret store)
3. **Tools → GitHub Copilot → Login to GitHub** to re-authenticate

### Slow or No Suggestions in Large Files

Very large files (5,000+ lines) can cause slow suggestions because the IDE takes longer to send the file context. Strategies:

- Split large files into smaller modules
- Ensure the IDE is not in a high-memory-pressure state (check **Help → Diagnostic Tools → Activity Monitor**)
- Disable suggestions for specific languages or file types that are large but rarely need completion (e.g., generated `.pb.go` protobuf files)
