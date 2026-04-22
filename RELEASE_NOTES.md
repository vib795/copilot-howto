# Release Notes

## v2.1.0 — April 2026

**Module reordering for pedagogical progression.** 14 modules renumbered so reading the directory tree top-to-bottom teaches Copilot in the order a new user actually encounters features. Git history preserved via `git mv`; all cross-references in every doc and module README updated. Zero broken links.

See [CHANGELOG.md](CHANGELOG.md) for the full renumbering map.

## v2.0.0 — April 2026

**Six new modules** bring the repo to full April 2026 GitHub Copilot feature coverage, covering the six customisation primitives, multi-model routing, MCP, and governance:

- **Module 07: Custom Prompts** — `.github/prompts/*.prompt.md` (8 production-ready templates)
- **Module 08: Chat Modes** — `.github/chatmodes/*.chatmode.md` (6 persona templates)
- **Module 09: Skills** — `.github/skills/<name>/SKILL.md` (4 runbooks + authoring guides)
- **Module 10: Agents** — `.github/agents/*.agent.md` (plan → implement → review chain)
- **Module 11: Multi-Model + MCP** — model slots, `.vscode/mcp.json`, `.copilotignore`, MCP profiles
- **Module 16: Governance** — asset manifest, eval checks, policy hooks, CI workflows

Feature Gaps vs Claude Code table updated: MCP is now supported in Copilot (the old "not supported" claim was outdated).

## v1.0.0 — April 2026

Initial release of Copilot How To with 10 tutorial modules covering built-in Copilot features:

- Slash Commands, Custom Instructions, Extensions, Chat Variables, GitHub Actions, Copilot Workspace, CLI, Inline Suggestions, IDE Integration, Enterprise

### Converted from

This repository was converted from [claude-howto](https://github.com/luongnv89/claude-howto), a tutorial for Claude Code. The structure, progressive learning approach, and Mermaid diagram style are preserved.
