# GitHub Copilot Feature Catalog

Use this as a reference when you know what you want to do but need to find the right Copilot feature. Each section covers a category of features with a lookup table mapping capabilities to the module that covers them.

---

## Section 1: Built-in Slash Commands

Slash commands are available in Copilot Chat. Type `/` to see the command picker.

| Command | What it does | Key context to add | Module |
|---|---|---|---|
| `/explain` | Explains selected code, a file, or a concept in plain language | `#selection` for a specific block; `#file` for a whole file; `@workspace` for project-wide understanding | `01-slash-commands/explain-with-context.md` |
| `/fix` | Identifies and fixes bugs, type errors, and logic problems in the selection | `#selection` of the broken code; `#terminalLastCommand` for a runtime error | `01-slash-commands/fix-with-selection.md` |
| `/tests` | Generates unit or integration tests for selected code | `#selection` of the function or class; `#file` of the module under test | `01-slash-commands/generate-tests.md` |
| `/doc` | Generates inline documentation (JSDoc, docstrings, etc.) for selected code | `#selection` of the function or class to document | `01-slash-commands/generate-docs.md` |
| `/new` | Scaffolds a new file, component, or module from a description | Description of what to create; optionally `#file` of a similar existing component | `01-slash-commands/new-component.md` |
| `/simplify` | Reduces complexity, removes duplication, and improves readability of selected code | `#selection` of the code to simplify | `01-slash-commands/simplify-refactor.md` |
| `/clear` | Clears the current Copilot Chat conversation history | None — use this when changing topic to restore full context budget | `01-slash-commands/README.md` |

---

## Section 2: Chat Participants

Chat participants are named actors prefixed with `@`. They have specialized context access beyond the current file.

| Participant | Scope | Best for | Module |
|---|---|---|---|
| `@workspace` | Entire VS Code workspace (semantic search over all files) | Cross-file questions, architecture questions, "where is X defined?" | `04-chat-variables/workspace-patterns.md` |
| `@terminal` | VS Code integrated terminal (recent output, current directory) | Debugging shell errors, explaining CLI output, writing shell commands | `04-chat-variables/terminal-integration.md` |
| `@vscode` | VS Code extension API and settings knowledge | Questions about VS Code configuration, keybindings, extension development | `09-ide-integration/vscode-setup.md` |
| `@github` | GitHub.com context: issues, PRs, repositories, discussions | Questions about a specific repo, PR, or issue by URL or reference | `05-github-actions/README.md` |
| `@extension-name` | Custom extension endpoint (skillset or agent) | Domain-specific actions: deployment status, ticket lookup, internal tooling | `03-extensions/README.md` |

---

## Section 3: Context Variables

Context variables are prefixed with `#` and inject specific content into your message. They are different from participants — they attach data, not behavior.

| Variable | What it attaches | Token cost (rough) | Module |
|---|---|---|---|
| `#file` | Full contents of one or more specific files, read at send time | Low to High (proportional to file size) | `04-chat-variables/file-context-patterns.md` |
| `#selection` | The text currently highlighted in the active editor | Very low (your selection only) | `01-slash-commands/README.md` |
| `#codebase` | Semantic search results from the workspace (top-ranked snippets) | Medium (typically 5–20 file sections) | `04-chat-variables/workspace-patterns.md` |
| `#terminalSelection` | Text currently selected in the VS Code integrated terminal | Very low | `04-chat-variables/terminal-integration.md` |
| `#terminalLastCommand` | The last command run in the terminal plus its full stdout/stderr output | Low to Medium (depends on output size) | `04-chat-variables/terminal-integration.md` |

---

## Section 4: Custom Instructions

Custom instructions let you establish persistent context and style rules without repeating them in every chat message.

| Level | File / Setting | Scope | Auto-loaded? | Module |
|---|---|---|---|---|
| Project-level | `.github/copilot-instructions.md` at repository root | All users in that repository | Yes — prepended to every chat request automatically | `02-custom-instructions/project-copilot-instructions.md` |
| User-level — code generation | `github.copilot.chat.codeGeneration.instructions` in VS Code `settings.json` | That user only, across all repositories | Yes — appended on top of project instructions | `02-custom-instructions/personal-instructions-vscode.jsonc` |
| User-level — test generation | `github.copilot.chat.testGeneration.instructions` in VS Code `settings.json` | That user only, scoped to `/tests` and test generation requests | Yes — used specifically for test generation tasks | `02-custom-instructions/personal-instructions-vscode.jsonc` |

---

## Section 5: GitHub Actions Patterns

These workflow files in `05-github-actions/` are ready to use. Copy into `.github/workflows/` and adjust the trigger and permissions to match your repository.

| Workflow | Trigger | Purpose | File |
|---|---|---|---|
| PR code review | `pull_request` (opened, synchronize) | Copilot coding agent reviews the PR diff and posts a review comment | `05-github-actions/pr-review-workflow.yml` |
| Security scan | `push` to main, `pull_request` | Scans code for security issues and posts Copilot-generated fix suggestions | `05-github-actions/security-scan-workflow.yml` |
| Format check | `pull_request` | Validates code formatting and creates a fix PR if formatting is off | `05-github-actions/format-check-workflow.yml` |
| Test on push | `push`, `pull_request` | Runs the test suite and posts a Copilot-generated failure summary if tests fail | `05-github-actions/test-on-push-workflow.yml` |
| PR description | `pull_request` (opened) | Auto-generates a PR description from the diff using Copilot coding agent | `05-github-actions/pr-description-workflow.yml` |

---

## Section 6: Copilot CLI Commands

The `gh copilot` extension for the GitHub CLI provides AI assistance in the terminal. Install with `gh extension install github/gh-copilot`.

| Command | Description | Key flags | Module |
|---|---|---|---|
| `gh copilot suggest` | Suggests a shell command for a natural-language task | `-t shell` (default), `-t git`, `-t gh` to target a command type | `07-cli/suggest-patterns.md` |
| `gh copilot explain` | Explains what a shell command does in plain language | Pass the command as a quoted string argument | `07-cli/explain-patterns.md` |

---

## Section 7: Extension Types

| Type | Invocation | Best for | Module |
|---|---|---|---|
| Skillset extension | Copilot automatically routes relevant questions to your skill; no explicit user invocation needed | Read-only data retrieval from external systems (deployment status, metrics, tickets) | `03-extensions/skillset-extension-scaffold/` |
| Agent extension | User explicitly types `@your-extension-name` in Copilot Chat | Multi-turn conversations, write operations, complex workflows requiring full conversational control | `03-extensions/agent-extension-scaffold/` |
| Marketplace extension | User installs from GitHub Marketplace and invokes with `@extension-name` | Third-party integrations (Sentry, Datadog, Jira, etc.) without building your own extension | `03-extensions/marketplace-extensions.md` |

---

## Section 8: Feature Gaps

Copilot does not have a direct equivalent for every AI coding tool feature. This table documents known gaps and the best available workarounds.

| Feature | Status in Copilot | Workaround |
|---|---|---|
| Extended Thinking (deep reasoning mode) | Not available in Copilot Chat or inline suggestions. The underlying models support it but GitHub has not exposed a user-controlled reasoning toggle. | Select Claude as your Copilot model where available; ask Copilot to "think step by step" in your prompt — this is a prompt-engineering workaround, not a guaranteed capability. |
| Checkpoints / conversation rewind | Copilot Chat has no checkpoint or undo mechanism for chat turns. Once you send a message, you cannot revert to the state before it. | Use `/clear` to start fresh. Use VS Code's Timeline feature (File → Open Timeline) to rewind file changes. See `06-copilot-workspace/vs-code-timeline.md`. |
| Intra-session hooks (pre/post tool call) | No hook API exists in Copilot Chat or the extension SDK. You cannot intercept or transform Copilot's responses programmatically. | Use GitHub Actions to run post-processing on Copilot-generated PRs (e.g., run linting after a Copilot coding agent PR). |
| MCP protocol (Model Context Protocol) | Copilot does not implement the MCP protocol as of April 2026. Extensions use the Copilot Extension API (skillset/agent), not MCP. | Build a Copilot skillset or agent extension using the `03-extensions/` scaffolds. The interfaces are conceptually similar (function calling). |
| Full CLI automation (non-interactive batch mode) | `gh copilot suggest` and `gh copilot explain` are interactive by design. There is no `--non-interactive` or `--output json` mode for scripting. | Use the Copilot API directly via the REST endpoint (requires Copilot API access, currently limited). See `07-cli/scripting-with-cli.md` for documented workarounds. |
