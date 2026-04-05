# GitHub Copilot IDE Integration Overview

GitHub Copilot is available across a wide range of development environments. This guide covers every supported IDE, explains which features are available in each, and provides links to the detailed setup guides.

---

## Table of Contents

1. [Supported IDEs](#supported-ides)
2. [Feature Matrix](#feature-matrix)
3. [Installation Overview](#installation-overview)
4. [Choosing the Right IDE](#choosing-the-right-ide)

---

## Supported IDEs

| IDE | Vendor | Plugin / Integration | Notes |
|---|---|---|---|
| **VS Code** | Microsoft | GitHub Copilot + GitHub Copilot Chat extensions | Most complete feature set |
| **Visual Studio** | Microsoft | GitHub Copilot extension (Windows only) | Strong for C# / .NET workflows |
| **IntelliJ IDEA** | JetBrains | GitHub Copilot plugin | Full JetBrains ecosystem support |
| **PyCharm** | JetBrains | GitHub Copilot plugin | Same plugin as IntelliJ IDEA |
| **WebStorm** | JetBrains | GitHub Copilot plugin | Same plugin as IntelliJ IDEA |
| **GoLand** | JetBrains | GitHub Copilot plugin | Same plugin as IntelliJ IDEA |
| **Rider** | JetBrains | GitHub Copilot plugin | .NET / C# on macOS and Linux |
| **CLion** | JetBrains | GitHub Copilot plugin | C/C++ focus |
| **DataGrip** | JetBrains | GitHub Copilot plugin | SQL and database tools |
| **Neovim** | Community | copilot.vim or copilot.lua | Highly customisable |
| **Vim** | Community | copilot.vim | Limited to inline suggestions |
| **Xcode** | Apple | Built-in (Xcode 16+) or Copilot for Xcode extension | Inline suggestions only in Xcode |
| **Azure Data Studio** | Microsoft | GitHub Copilot extension | SQL / data analytics workflows |
| **Eclipse** | Eclipse Foundation | GitHub Copilot plugin | Java-heavy environments |

---

## Feature Matrix

The table below summarises feature availability across the major IDEs. For a more detailed breakdown with additional features, see [feature-matrix.md](./feature-matrix.md).

| Feature | VS Code | Visual Studio | JetBrains Suite | Neovim | Xcode |
|---|---|---|---|---|---|
| Inline suggestions (ghost text) | Full | Full | Full | Full | Full |
| Copilot Chat panel | Full | Full | Full | Partial* | Not available |
| Inline chat (`Ctrl+I`) | Full | Full | Full | Not available | Not available |
| Slash commands (`/explain`, `/fix`) | Full | Partial | Partial | Not available | Not available |
| `@workspace` variable | Full | Partial | Partial | Not available | Not available |
| `#file` / `#selection` variables | Full | Partial | Partial | Not available | Not available |
| Next Edit Suggestions (NES) | Full | Not available | Not available | Not available | Not available |
| Custom instructions (project-level) | Full | Not available | Not available | Not available | Not available |
| Custom instructions (user-level) | Full | Not available | Not available | Not available | Not available |
| Copilot Extensions support | Full | Not available | Not available | Not available | Not available |
| Copilot Workspace integration | Full | Not available | Not available | Not available | Not available |
| Rename suggestions | Full | Not available | Not available | Not available | Not available |
| Code actions (lightbulb menu) | Full | Partial | Partial | Not available | Not available |

*Partial Neovim Chat support is available via the community plugin CopilotChat.nvim.

---

## Installation Overview

### VS Code

1. Open the Extensions sidebar (`Ctrl+Shift+X`)
2. Search for **"GitHub Copilot"**
3. Install **GitHub Copilot** and **GitHub Copilot Chat** (two separate extensions)
4. Sign in with your GitHub account when prompted

Full guide: [vscode-setup.md](./vscode-setup.md)

### Visual Studio

1. Open **Extensions → Manage Extensions**
2. Search for **"GitHub Copilot"**
3. Install the extension
4. Restart Visual Studio and sign in

### JetBrains IDEs (IntelliJ IDEA, PyCharm, WebStorm, GoLand, etc.)

1. Open **Settings → Plugins**
2. Search for **"GitHub Copilot"** in the Marketplace tab
3. Install and restart the IDE
4. Complete authentication via **Tools → GitHub Copilot → Login to GitHub**

Full guide: [jetbrains-setup.md](./jetbrains-setup.md)

### Neovim

**Option A (copilot.vim — official):**

```vim
" vim-plug
Plug 'github/copilot.vim'
```

Then run `:Copilot setup` and follow the browser authentication flow.

**Option B (copilot.lua — community):**

```lua
-- lazy.nvim
{ "zbirenbaum/copilot.lua" }
```

Full guide: [neovim-setup.md](./neovim-setup.md)

### Xcode

Xcode 16+ includes built-in Copilot support. Enable it under **Xcode → Settings → Accounts → GitHub Copilot → Sign In**.

Full guide: [xcode-setup.md](./xcode-setup.md)

---

## Choosing the Right IDE

### VS Code — Best Overall Copilot Experience

VS Code has the most complete and up-to-date Copilot feature set. New Copilot features (NES, Copilot Extensions, Workspace integration, custom instructions) ship to VS Code first, and some features are VS Code-exclusive. If you are choosing an IDE specifically for AI-assisted development, VS Code is the strongest choice.

**Best for:** JavaScript/TypeScript, Python, Go, Rust, general-purpose development, teams wanting the full Copilot feature set.

### JetBrains — Strong Second Choice

The JetBrains Copilot plugin provides inline suggestions and Copilot Chat (including inline chat) with a quality comparable to VS Code. The main gaps are NES, Copilot Extensions, custom instructions files, and some `@workspace` functionality. For developers who prefer JetBrains IDEs for their language-specific tooling (Java, Kotlin, C#, PHP), the Copilot plugin is a mature and reliable integration.

**Best for:** Java, Kotlin, Scala (IntelliJ IDEA), Python (PyCharm), JavaScript (WebStorm), Go (GoLand), .NET (Rider).

### Visual Studio — Windows .NET Workflows

Visual Studio on Windows has solid Copilot inline suggestions and a Chat panel, but lacks some of the more advanced features available in VS Code. It is the natural choice for C# and .NET developers who are already invested in the Visual Studio ecosystem.

**Best for:** C#, .NET, ASP.NET Core, MAUI (Windows only).

### Neovim — Power Users and Custom Workflows

Neovim integration requires more setup but offers the most customisation. If you already live in Neovim and have a highly tuned configuration, copilot.vim or copilot.lua integrates Copilot inline suggestions cleanly. Chat support is available via the community CopilotChat.nvim plugin but is not officially supported by GitHub.

**Best for:** Developers with existing Neovim workflows who prefer terminal-based environments.

### Xcode — Apple Platform Development

Xcode's Copilot integration covers inline suggestions for Swift. For full Copilot Chat support while building Apple platform apps, the recommended approach is to use VS Code with the **Swift** extension (via the Swift Package Manager toolchain) alongside Xcode for interface building and device management.

**Best for:** Swift / SwiftUI / Objective-C development (suggestions only).

---

## Further Reading

- [vscode-setup.md](./vscode-setup.md) — VS Code installation and configuration
- [jetbrains-setup.md](./jetbrains-setup.md) — JetBrains IDE setup
- [neovim-setup.md](./neovim-setup.md) — Neovim setup (copilot.vim and copilot.lua)
- [xcode-setup.md](./xcode-setup.md) — Xcode setup
- [feature-matrix.md](./feature-matrix.md) — Full feature availability matrix
- [../08-inline-suggestions/README.md](../08-inline-suggestions/README.md) — Inline suggestions deep dive
