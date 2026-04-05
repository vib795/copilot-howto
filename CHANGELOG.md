# Changelog

## v1.0.0 — 2026-04-05

### Initial Release

Converted from claude-howto to copilot-howto. 10 modules covering all major GitHub Copilot features.

**Modules included:**

- `01-slash-commands/` — Built-in slash commands: /explain, /fix, /tests, /doc, /new, /simplify
- `02-custom-instructions/` — Project-level and user-level custom instructions
- `03-extensions/` — Skillset and agent extension scaffolds
- `04-chat-variables/` — Chat participants and context variables
- `05-github-actions/` — GitHub Actions + Copilot integration workflows
- `06-copilot-workspace/` — Copilot Workspace guide and examples
- `07-cli/` — gh copilot CLI reference
- `08-inline-suggestions/` — Inline suggestions, ghost text, and Next Edit Suggestions
- `09-ide-integration/` — IDE setup guides for VS Code, JetBrains, Neovim, and Xcode
- `10-enterprise/` — Enterprise policies, content exclusion, audit logs, SSO

**Root files added:**

- `copilot_concepts_guide.md` — Deep-dive concepts reference (request pipeline, context window, extension architecture, enterprise controls)
- `.github/copilot-instructions.md` — Live custom instructions example, auto-loaded by Copilot for all chat in this repo
- `INDEX.md` — Complete file index (~80 files across 10 modules)
- `CATALOG.md` — Feature catalog with lookup tables for all Copilot features
