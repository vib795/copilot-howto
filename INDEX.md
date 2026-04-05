# Copilot How-To: Complete File Index

> **10 modules · ~80 files · all major GitHub Copilot features**
>
> This index is the fastest way to find a specific file in the repository. Each entry links to the file and describes its purpose in one line.

---

## Repository Stats

| Stat | Value |
|---|---|
| Modules | 10 |
| Total files (approx.) | ~80 |
| Coverage | Slash commands, custom instructions, extensions, chat variables, GitHub Actions, Copilot Workspace, CLI, inline suggestions, IDE integration, enterprise |

---

## Module 01 — Slash Commands

`01-slash-commands/`

| File | Description |
|---|---|
| `README.md` | Complete slash commands guide — all built-in commands, when to use each, and how to combine them |
| `explain-with-context.md` | `/explain` patterns: using `#file`, `#selection`, and `@workspace` to give Copilot the right context |
| `fix-with-selection.md` | `/fix` patterns for bugs, type errors, and test failures — with before/after examples |
| `generate-tests.md` | `/tests` workflow: generating unit tests, integration tests, and edge case coverage |
| `generate-docs.md` | `/doc` generation patterns for functions, classes, APIs, and README sections |
| `new-component.md` | `/new` scaffolding examples: React components, Express routes, CLI tools |
| `simplify-refactor.md` | `/simplify` refactoring patterns: reducing complexity, removing duplication, improving readability |
| `chaining-commands.md` | Chaining multiple slash commands in sequence to complete multi-step workflows |

---

## Module 02 — Custom Instructions

`02-custom-instructions/`

| File | Description |
|---|---|
| `README.md` | Complete custom instructions guide — project-level and user-level, effectiveness patterns, token budget |
| `project-copilot-instructions.md` | Production-ready template for `.github/copilot-instructions.md` with annotated sections |
| `personal-instructions-vscode.jsonc` | VS Code user-level settings snippet for `codeGeneration.instructions` and `testGeneration.instructions` |
| `scoped-instructions-api.md` | Directory-level instruction workarounds: patterns for repos with multiple languages or teams |

---

## Module 03 — Extensions

`03-extensions/`

| File | Description |
|---|---|
| `README.md` | Complete extensions guide — GitHub App setup, skillset vs. agent, registration walkthrough |
| `skillset-extension-scaffold/README.md` | Skillset extension setup guide: prerequisites, registration steps, testing with ngrok |
| `skillset-extension-scaffold/index.js` | Express server implementing a skillset extension endpoint with signature verification |
| `skillset-extension-scaffold/skillset-definition.yaml` | Skills definition file: function names, parameter schemas, descriptions |
| `agent-extension-scaffold/README.md` | Agent extension setup guide: SSE streaming, conversational loop, error handling |
| `agent-extension-scaffold/index.js` | Express server implementing an agent extension with SSE response streaming |
| `code-review-extension.md` | Full worked example: a code review extension that integrates with a GitHub PR workflow |
| `marketplace-extensions.md` | Curated list of public Copilot extensions from the GitHub Marketplace with use cases |

---

## Module 04 — Chat Variables

`04-chat-variables/`

| File | Description |
|---|---|
| `README.md` | Complete chat variables guide — all variables, resolution mechanics, token cost considerations |
| `workspace-patterns.md` | `@workspace` effective use patterns: project comprehension, cross-file questions, architecture queries |
| `file-context-patterns.md` | `#file` multi-file context patterns: referencing multiple files, large file strategies |
| `terminal-integration.md` | `@terminal` and `#terminalLastCommand` patterns for debugging build failures and runtime errors |
| `combining-variables.md` | Combining multiple context variables in a single prompt for complex questions |

---

## Module 05 — GitHub Actions

`05-github-actions/`

| File | Description |
|---|---|
| `README.md` | GitHub Actions + Copilot integration guide — Copilot coding agent, workflow triggers, best practices |
| `pr-review-workflow.yml` | Automated PR code review workflow using Copilot coding agent |
| `security-scan-workflow.yml` | Security scanning workflow with Copilot-generated fix suggestions |
| `format-check-workflow.yml` | Code format validation workflow with automated Copilot fix PR creation |
| `test-on-push-workflow.yml` | Test runner with Copilot-generated failure summary comments on PRs |
| `pr-description-workflow.yml` | Auto-generate PR descriptions from diff using Copilot coding agent |
| `copilot-in-actions.md` | Guide to using the Copilot coding agent in GitHub Actions: setup, configuration, limitations |

---

## Module 06 — Copilot Workspace

`06-copilot-workspace/`

| File | Description |
|---|---|
| `README.md` | Copilot Workspace complete guide — browser UI, plan format, iterating on plans, opening in Codespaces |
| `workspace-examples.md` | Real-world Workspace scenarios: adding a feature, fixing a bug, refactoring a module |
| `task-specification-guide.md` | Writing effective task specifications: issue format, level of detail, what Workspace needs to succeed |
| `vs-code-timeline.md` | Using VS Code Timeline as a lightweight checkpoint alternative when Workspace is not available |

---

## Module 07 — CLI

`07-cli/`

| File | Description |
|---|---|
| `README.md` | `gh copilot` CLI complete reference — all commands, flags, output formats |
| `suggest-patterns.md` | `gh copilot suggest` examples: shell commands, git operations, system administration |
| `explain-patterns.md` | `gh copilot explain` examples: understanding unfamiliar commands, documenting scripts |
| `installation.md` | Installation and setup: `gh` CLI prerequisites, extension install, authentication |
| `scripting-with-cli.md` | Using `gh copilot` in shell scripts and CI/CD pipelines — automation patterns and limitations |

---

## Module 08 — Inline Suggestions

`08-inline-suggestions/`

| File | Description |
|---|---|
| `README.md` | Complete inline suggestions guide — ghost text, triggers, accepting and dismissing, IDE differences |
| `acceptance-shortcuts.md` | Keyboard shortcuts for accepting, dismissing, and cycling suggestions by IDE (VS Code, JetBrains, Neovim, Xcode) |
| `next-edit-suggestions.md` | Copilot Next Edit Suggestions (NES): how it predicts your next edit location, enabling/disabling |
| `effective-prompting-for-completion.md` | Writing code comments and function signatures that produce better inline completions |
| `settings-reference.md` | VS Code settings reference for inline suggestions: all `github.copilot.*` settings with descriptions |

---

## Module 09 — IDE Integration

`09-ide-integration/`

| File | Description |
|---|---|
| `README.md` | IDE overview: which IDEs are supported, feature availability summary, choosing an IDE |
| `vscode-setup.md` | VS Code complete setup: extension install, authentication, settings, keybindings, Insiders vs. Stable |
| `jetbrains-setup.md` | JetBrains IDEs setup: plugin install for IntelliJ, PyCharm, WebStorm, GoLand, and others |
| `neovim-setup.md` | Neovim setup guide for both `copilot.vim` and `copilot.lua` with recommended configurations |
| `xcode-setup.md` | Xcode setup: GitHub Copilot for Xcode extension install, configuration, and Swift-specific tips |
| `feature-matrix.md` | Feature availability by IDE: which features work in which editors (complete comparison table) |

---

## Module 10 — Enterprise

`10-enterprise/`

| File | Description |
|---|---|
| `README.md` | Enterprise features overview: seat management, policy hierarchy, audit logs, content exclusion |
| `content-exclusion.md` | Excluding files from Copilot: glob patterns, testing exclusions, org vs. repo level |
| `policy-management.md` | Managing org and enterprise policies: allowed IDEs, model selection, network requirements |
| `audit-logs.md` | Querying Copilot audit logs via API and the GitHub web UI — fields, filters, export formats |
| `network-proxy.md` | Proxy and firewall configuration: required endpoints, certificate pinning, MITM proxy considerations |
| `sso-setup.md` | SAML and OIDC SSO integration: seat provisioning with SCIM, deprovisioning, IdP-specific notes |

---

## Root Files

| File | Description |
|---|---|
| `README.md` | Main guide: repository overview, quick start, how to navigate the modules |
| `LEARNING-ROADMAP.md` | Progressive learning path from beginner to advanced with time estimates per module |
| `INDEX.md` | This file — complete repository file index |
| `CATALOG.md` | Feature catalog and reference tables: look up any Copilot feature and find where it lives |
| `QUICK_REFERENCE.md` | One-page cheat sheet: most-used commands, shortcuts, and variables |
| `copilot_concepts_guide.md` | Deep-dive concepts reference: request pipeline, context window, extensions architecture, enterprise policies |
| `.github/copilot-instructions.md` | Live custom instructions example — auto-loaded by Copilot for all chat interactions in this repo |
