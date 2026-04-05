# GitHub Copilot Setup: Xcode

GitHub Copilot is available in Xcode as a native AI code completion feature. This guide covers installation, authentication, verification, keyboard shortcuts, and the limitations of the Xcode integration.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Options](#installation-options)
3. [Enable and Sign In](#enable-and-sign-in)
4. [Verify the Installation](#verify-the-installation)
5. [Keyboard Shortcuts](#keyboard-shortcuts)
6. [Limitations](#limitations)
7. [Alternative: VS Code for Full Copilot on Apple Platforms](#alternative-vs-code-for-full-copilot-on-apple-platforms)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- **Xcode 16 or later** — built-in GitHub Copilot support was introduced in Xcode 16. Check your Xcode version in **Xcode → About Xcode**.
- A GitHub account with an active Copilot subscription.
- macOS 14 (Sonoma) or later is required for Xcode 16.
- Internet access from macOS to `api.githubcopilot.com`.

If you are running Xcode 15 or earlier, see [Installation Options](#installation-options) for the standalone extension approach.

---

## Installation Options

### Option 1: Built-In (Xcode 16+) — Recommended

Xcode 16 includes GitHub Copilot as a built-in AI code completion provider. No separate installation is required beyond signing in (see [Enable and Sign In](#enable-and-sign-in)).

### Option 2: GitHub Copilot for Xcode Extension (Earlier Versions)

For Xcode 15 and earlier, GitHub provides a standalone macOS app — **GitHub Copilot for Xcode** — that integrates with Xcode via the Xcode Source Editor Extension mechanism.

**Installation steps for the standalone extension:**

1. Download **GitHub Copilot for Xcode** from the [GitHub Copilot for Xcode releases page](https://github.com/github/CopilotForXcode/releases/latest) or the Mac App Store.
2. Open the downloaded `.dmg` and drag the app to `/Applications`.
3. Launch the **GitHub Copilot for Xcode** app and complete the authentication flow (see next section).
4. Enable the extension in macOS: **System Settings → Privacy & Security → Extensions → Xcode Source Editor → GitHub Copilot for Xcode** — enable the checkbox.
5. In Xcode, the extension appears under **Editor → GitHub Copilot**.

**Note**: The standalone extension requires granting Accessibility permissions so it can interact with Xcode:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Find **GitHub Copilot for Xcode** and enable it

---

## Enable and Sign In

### Xcode 16+ (Built-In)

1. Open **Xcode → Settings** (or press `Cmd+,`)
2. Click the **Accounts** tab
3. Click the **+** button at the bottom left → **GitHub Copilot**
4. Click **Sign In** — Xcode opens your browser to GitHub's OAuth flow
5. Log in to GitHub and click **Authorize Xcode**
6. Return to Xcode — authentication completes and the account appears in the Accounts list

### Standalone Extension (Xcode 15 and Earlier)

1. Launch the **GitHub Copilot for Xcode** companion app from `/Applications`
2. Click **Sign In** in the companion app
3. A device code is displayed (e.g., `ABCD-1234`)
4. Open [github.com/login/device](https://github.com/login/device), enter the code, and complete the GitHub OAuth flow
5. The companion app shows **"Connected"** when authentication succeeds

---

## Verify the Installation

1. Open or create a Swift project in Xcode
2. Open a `.swift` file
3. In the code editor, write a comment followed by the beginning of a function:

```swift
// Returns the number of words in a string, treating multiple
// consecutive whitespace characters as a single word boundary
func wordCount(_ text: String) -> Int {
    ▌
```

4. After pausing for one second, ghost text should appear in grey, suggesting the function implementation.
5. Press `Tab` to accept.

If ghost text appears and is inserted correctly, Copilot is working in Xcode.

### Checking Status

For Xcode 16 built-in:
- The Copilot status is shown in **Xcode → Settings → Accounts** — your GitHub Copilot account should show **"Connected"**

For the standalone extension:
- Open the **GitHub Copilot for Xcode** companion app — the status bar shows **"Copilot: Enabled"**

---

## Keyboard Shortcuts

Xcode's Copilot integration supports a minimal set of keyboard interactions.

| Action | Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the entire ghost text |
| Dismiss suggestion | `Escape` | Clears the ghost text |

Unlike VS Code and JetBrains, Xcode's Copilot integration does not currently support:
- Cycling between alternative suggestions (`Alt+]` / `Alt+[`)
- Word-by-word partial acceptance (`Ctrl+Right`)
- A manual trigger shortcut (`Alt+\` equivalent)
- A completions panel showing multiple candidates

Suggestions appear automatically when you pause typing. If a suggestion appears and you do not want it, pressing any character key (instead of `Tab`) continues normal typing and dismisses the ghost text.

---

## Limitations

Xcode's Copilot integration is intentionally limited compared to VS Code and JetBrains. Understanding these limitations upfront prevents confusion.

### Inline Suggestions Only

Xcode provides **inline suggestions (ghost text) only**. The following Copilot features are **not available in Xcode**:

- Copilot Chat panel
- Inline chat (`Ctrl+I` equivalent)
- Slash commands (`/explain`, `/fix`, `/tests`, `/doc`)
- `@workspace`, `#file`, or other context variables
- Next Edit Suggestions (NES)
- Custom instructions
- Copilot Extensions

### No Cycling Between Suggestions

In VS Code and JetBrains, you can press `Alt+]` to see alternative completions. In Xcode, only a single suggestion is shown and there is no way to cycle to alternatives.

### No Partial Acceptance

There is no equivalent to VS Code's `Ctrl+Right` word-by-word acceptance in Xcode. Suggestions must be accepted in full or dismissed entirely.

### Language Support

Copilot in Xcode works for all languages that Xcode supports: Swift, Objective-C, and C/C++ (within Xcode projects). It does not provide suggestions for languages edited in Xcode but not natively compiled (e.g., shell scripts, Python scripts in Xcode phases).

### Context Window

Xcode sends the current file as context to Copilot. Unlike VS Code, Xcode does not include open tabs from other Swift files as neighboring-tab context. This means suggestions may be less accurate for code that relies on types or functions defined in other files in the same project.

---

## Alternative: VS Code for Full Copilot on Apple Platforms

If you need Copilot Chat, `/explain`, `@workspace` search, or any other advanced Copilot feature while developing for Apple platforms, the recommended approach is to use **VS Code alongside Xcode**, rather than relying solely on Xcode's built-in Copilot.

### Setup

1. Install VS Code and the GitHub Copilot extensions (see [vscode-setup.md](./vscode-setup.md))
2. Install the **Swift** extension for VS Code (`sswg.swift-lang`)
3. Install **Swift Language Server** (`sourcekit-lsp`) — this is included with Xcode's command-line tools
4. Open your Swift Package Manager (SPM) project in VS Code

### What Works in VS Code for Swift Development

- Full Copilot inline suggestions with neighboring-tab context
- Copilot Chat with `@workspace` indexing of your entire SPM package
- `/explain`, `/fix`, `/tests` slash commands on Swift code
- NES (Next Edit Suggestions) for Swift files
- IntelliSense (type checking, go to definition, code actions) via SourceKit-LSP

### Workflow

Many Apple platform developers maintain a split workflow:
- Use **VS Code** for writing and AI-assisted code editing (Copilot Chat, refactoring, test generation)
- Use **Xcode** for the Simulator, Interface Builder / Storyboards, provisioning profiles, and device deployment

SPM packages open seamlessly in both editors simultaneously, so you can edit in VS Code and build/run in Xcode without friction.

---

## Troubleshooting

### Ghost Text Not Appearing in Xcode 16

1. **Verify your account is connected**: **Xcode → Settings → Accounts** — ensure GitHub Copilot shows **"Connected"**. If it shows an error, click **Sign Out** and repeat the sign-in flow.
2. **Check your Copilot subscription**: Confirm your GitHub account has an active subscription at [github.com/settings/copilot](https://github.com/settings/copilot).
3. **Restart Xcode**: Quit Xcode entirely (`Cmd+Q`) and reopen it. Xcode's extension mechanisms sometimes require a full restart after initial setup.
4. **Check internet connectivity**: Copilot requires access to `api.githubcopilot.com`. If on a corporate network, ensure this host is allowlisted. See [../10-enterprise/network-proxy.md](../10-enterprise/network-proxy.md).

### Standalone Extension: "GitHub Copilot for Xcode is not enabled"

This error means the Xcode Source Editor Extension is not enabled in macOS System Settings:

1. Open **System Settings → Privacy & Security → Extensions → Xcode Source Editor**
2. Enable the checkbox for **GitHub Copilot for Xcode**
3. Restart Xcode

### Standalone Extension: Accessibility Permission Required

If Copilot suggestions do not appear after enabling the extension, the companion app may need Accessibility access:

1. Open **System Settings → Privacy & Security → Accessibility**
2. Find **GitHub Copilot for Xcode** and toggle it on
3. If it is not listed, click the **+** button and add the app from `/Applications`

### Authentication Expired (Standalone Extension)

The GitHub Copilot for Xcode companion app uses a token that expires. If suggestions stop working:

1. Open the **GitHub Copilot for Xcode** companion app
2. Click **Sign Out**
3. Click **Sign In** and complete the device code flow again
