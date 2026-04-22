# GitHub Copilot Feature Availability Matrix

This table provides a detailed breakdown of every significant GitHub Copilot feature and its availability across all major IDEs. Use it to understand which IDE gives you access to the features you need.

> **Note**: Feature availability changes frequently as GitHub and IDE vendors release updates. This matrix reflects the state of Copilot as of early 2026. Always check the [official GitHub Copilot documentation](https://docs.github.com/en/copilot) for the latest status.

---

## Legend

| Symbol | Meaning |
|---|---|
| **Full** | Feature is fully supported and equivalent to the most complete implementation |
| **Partial** | Feature is available but with limitations compared to VS Code |
| **Not available** | Feature is not currently supported in this IDE |

---

## Feature Matrix

| Feature | VS Code | Visual Studio | IntelliJ / PyCharm / WebStorm | GoLand | Neovim | Xcode |
|---|---|---|---|---|---|---|
| **Inline Suggestions** | | | | | | |
| Inline ghost text (code completion) | Full | Full | Full | Full | Full | Full |
| Multi-line suggestions | Full | Full | Full | Full | Full | Full |
| Cycle through alternatives (Alt+] / Alt+[) | Full | Full | Full | Full | Full | Not available |
| Partial acceptance (word-by-word) | Full | Partial | Full | Full | Partial | Not available |
| Manual trigger | Full | Full | Full | Full | Full | Not available |
| Completions panel (multiple candidates) | Full | Not available | Not available | Not available | Partial | Not available |
| Next Edit Suggestions (NES) | Full | Not available | Not available | Not available | Not available | Not available |
| Rename suggestions | Full | Not available | Not available | Not available | Not available | Not available |
| **Copilot Chat** | | | | | | |
| Chat panel (conversational interface) | Full | Full | Full | Full | Partial* | Not available |
| Inline chat (in-editor floating input) | Full | Full | Full | Full | Not available | Not available |
| Chat history persistence | Full | Partial | Partial | Partial | Partial* | Not available |
| Code insertion from Chat response | Full | Full | Full | Full | Partial* | Not available |
| Diff view for Chat-suggested changes | Full | Partial | Partial | Partial | Not available | Not available |
| **Slash Commands** | | | | | | |
| `/explain` | Full | Full | Full | Full | Partial* | Not available |
| `/fix` | Full | Full | Full | Full | Partial* | Not available |
| `/tests` | Full | Full | Full | Full | Partial* | Not available |
| `/doc` | Full | Partial | Partial | Partial | Partial* | Not available |
| `/new` (scaffold a new file/project) | Full | Not available | Not available | Not available | Not available | Not available |
| `/simplify` | Full | Partial | Partial | Partial | Not available | Not available |
| `/fix` on compiler errors | Full | Full | Partial | Partial | Not available | Not available |
| **Chat Context Variables** | | | | | | |
| `@workspace` (whole-project context) | Full | Partial | Partial | Partial | Not available | Not available |
| `@terminal` (terminal output context) | Full | Not available | Not available | Not available | Not available | Not available |
| `@vscode` (VS Code API / extension help) | Full | Not available | Not available | Not available | Not available | Not available |
| `@github` (GitHub repos, PRs, issues) | Full | Not available | Not available | Not available | Not available | Not available |
| `#file` (attach a specific file) | Full | Partial | Partial | Partial | Not available | Not available |
| `#selection` (attach current selection) | Full | Full | Full | Full | Not available | Not available |
| `#editor` (attach current editor content) | Full | Partial | Partial | Partial | Not available | Not available |
| `#codebase` (semantic codebase search) | Full | Not available | Not available | Not available | Not available | Not available |
| **Custom Instructions** | | | | | | |
| Project-level (`.github/copilot-instructions.md`) | Full | Not available | Not available | Not available | Not available | Not available |
| User-level (IDE settings) | Full | Not available | Not available | Not available | Not available | Not available |
| Per-language instructions | Full | Not available | Not available | Not available | Not available | Not available |
| **Extensions and Integrations** | | | | | | |
| Copilot Extensions (3rd-party agents) | Full | Not available | Not available | Not available | Not available | Not available |
| Copilot Workspace integration | Full | Not available | Not available | Not available | Not available | Not available |
| Pull Request description generation | Full | Partial | Not available | Not available | Not available | Not available |
| Commit message generation | Full | Partial | Not available | Not available | Not available | Not available |
| Code review suggestions (on PRs) | Full | Not available | Not available | Not available | Not available | Not available |
| **Code Actions** | | | | | | |
| "Fix using Copilot" in lightbulb menu | Full | Partial | Partial | Partial | Not available | Not available |
| "Explain using Copilot" on hover | Full | Not available | Partial | Partial | Not available | Not available |
| Generate tests from context menu | Full | Not available | Partial | Partial | Not available | Not available |
| **Language Support** | | | | | | |
| All mainstream languages | Full | Full | Full | Full | Full | Swift / ObjC / C++ only |
| SQL / database queries | Full | Partial | Full (DataGrip) | Full | Full | Not available |
| Infrastructure as Code (YAML, HCL, Dockerfile) | Full | Partial | Full | Full | Full | Not available |
| Jupyter Notebooks | Full | Not available | Partial (DataSpell) | Not available | Not available | Not available |

*Partial Neovim support for Chat features is provided by the community plugin `CopilotChat.nvim`, which is not officially supported by GitHub.

---

## Notes by IDE

### VS Code

VS Code has the most complete and up-to-date Copilot feature set. It is the primary development target for new Copilot features. NES, Copilot Extensions, custom instructions, and `@workspace`/`@terminal`/`@vscode`/`@github` agents are all VS Code-first features.

### Visual Studio

Visual Studio (Windows) supports inline suggestions and Copilot Chat with a quality comparable to VS Code for C# and .NET workflows. `@workspace` support is available but the indexing depth differs. Most advanced context agents are not available.

### IntelliJ / PyCharm / WebStorm

JetBrains IDEs share a single plugin that provides inline suggestions and Copilot Chat including inline chat. `@workspace` is partially supported. The plugin is actively maintained and receives feature updates, but typically lags a few months behind VS Code for new features.

### GoLand

GoLand uses the same JetBrains plugin as IntelliJ/PyCharm/WebStorm. The Go-specific language tooling in GoLand (Go modules, debugging, testing) is separate from Copilot. Feature availability mirrors the JetBrains suite column.

### Neovim

Neovim's Copilot integration is limited to inline suggestions and (via community plugins) a basic Chat interface. The terminal-centric Neovim workflow means that many IDE-specific features (`@terminal`, `@vscode`, code actions) have no direct equivalent. `CopilotChat.nvim` provides `/explain`, `/fix`, and `/tests` in a Neovim buffer, but it is not officially supported.

### Xcode

Xcode's Copilot integration is the most limited of all supported IDEs. Only inline suggestions (ghost text for Swift, Objective-C, and C/C++) are available. There is no Chat, no slash commands, and no alternative suggestion cycling. For full Copilot functionality on Apple platform projects, use VS Code with the Swift extension alongside Xcode.

---

## Frequently Changing Features

The following features are under active development and their availability across IDEs changes frequently:

- `@workspace` depth and accuracy in JetBrains and Visual Studio
- NES rollout to JetBrains (planned but not yet available as of early 2026)
- Chat context variables (`#file`, `#selection`) in JetBrains
- Copilot Extensions support in non-VS Code IDEs
- Custom instructions support outside VS Code

Check the [GitHub Copilot changelog](https://github.blog/changelog/label/copilot/) for the latest updates.
