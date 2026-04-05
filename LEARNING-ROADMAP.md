# GitHub Copilot Learning Roadmap

A progressive, milestone-based learning path from first-time Copilot user to building custom Extensions.

---

## Find Your Starting Point

Answer these questions to find your level:

1. Have you used `@workspace` in Copilot Chat? (yes = +1)
2. Do you have a `.github/copilot-instructions.md` in any project? (yes = +1)
3. Have you used `#file` to attach context to a chat message? (yes = +1)
4. Have you used `gh copilot suggest` from the terminal? (yes = +1)
5. Have you written or installed a Copilot Extension? (yes = +2)

**Score 0-1:** Start at [Level 1 — Beginner](#level-1-beginner-3-4-hours)
**Score 2-3:** Start at [Level 2 — Intermediate](#level-2-intermediate-4-5-hours)
**Score 4-5:** Start at [Level 3 — Advanced](#level-3-advanced-3-4-hours)

---

## Level 1: Beginner (3-4 hours)

**Goal:** Master the built-in features that every Copilot user should know cold.

### Milestone 1A: Slash Commands + Inline Suggestions

**Read:** [01 Slash Commands](01-slash-commands/README.md) | [08 Inline Suggestions](08-inline-suggestions/README.md)

**Exercises:**
1. Open a file with a bug. Select the broken function. Type `/fix` in Copilot Chat with `#selection` attached. Apply the fix.
2. Open a function with no tests. Use `/tests` to generate a test suite. Review and apply.
3. Open a complex function. Use `/explain` to get a plain-English explanation.
4. Write a comment describing a function you want to create. Watch ghost text complete the implementation. Accept with `Tab`.
5. Get a multi-line ghost text suggestion. Accept just the first line with `Ctrl+Right` (VS Code).

**Checkpoint:** You can use all 6 built-in slash commands confidently without looking them up.

---

### Milestone 1B: Custom Instructions + IDE Setup

**Read:** [02 Custom Instructions](02-custom-instructions/README.md) | [09 IDE Integration](09-ide-integration/README.md)

**Exercises:**
1. Copy [project-copilot-instructions.md](02-custom-instructions/project-copilot-instructions.md) to `.github/copilot-instructions.md` in a project.
2. Customize it for your actual tech stack (replace Node.js/PostgreSQL/React with yours).
3. Ask Copilot to generate a function. Verify the output uses your naming conventions.
4. Set up user-level instructions in VS Code settings (or your IDE equivalent).
5. Use `/doc` on a function — verify the doc style matches your instructions.

**Checkpoint:** Copilot's output consistently reflects your team's coding standards without you having to repeat them in every prompt.

---

## Level 2: Intermediate (4-5 hours)

**Goal:** Use Copilot's context system effectively and connect it to your workflows.

### Milestone 2A: Chat Variables

**Read:** [04 Chat Variables](04-chat-variables/README.md)

**Exercises:**
1. Ask `@workspace "Where is authentication handled in this project?"` — navigate to the file it identifies.
2. Attach `#file:src/auth.ts` to a chat message. Ask Copilot to identify security issues in that specific file.
3. Run a failing test in the terminal. Use `@terminal #terminalLastCommand` to ask Copilot what went wrong.
4. Attach two files with `#file` in one message. Ask Copilot to explain how they interact.
5. Use `@vscode` to ask about a VS Code setting or keyboard shortcut.

**Checkpoint:** You instinctively add the right context variable for every Copilot Chat question.

---

### Milestone 2B: GitHub Actions Integration

**Read:** [05 GitHub Actions](05-github-actions/README.md)

**Exercises:**
1. Copy [pr-review-workflow.yml](05-github-actions/pr-review-workflow.yml) into `.github/workflows/`. Open a test PR. Verify the review runs.
2. Copy [format-check-workflow.yml](05-github-actions/format-check-workflow.yml). Push code with a formatting error. Confirm the check fails.
3. Add the PR review workflow as a required status check in your repo's branch protection rules.
4. Copy [pr-description-workflow.yml](05-github-actions/pr-description-workflow.yml). Open a PR without a description. Verify it gets auto-generated.

**Checkpoint:** At least two Copilot-powered checks run automatically on every PR in your project.

---

### Milestone 2C: Copilot CLI

**Read:** [07 CLI](07-cli/README.md)

**Exercises:**
1. Install: `gh extension install github/gh-copilot`
2. Run `gh copilot suggest "find all files modified in the last 7 days"`. Execute the suggested command.
3. Run `gh copilot explain "git rebase -i HEAD~3"` to understand a complex command.
4. Use `gh copilot suggest` to generate a `find` + `xargs` pipeline for a task you'd normally Google.

**Checkpoint:** You reach for `gh copilot suggest` before reaching for a search engine for shell commands.

---

## Level 3: Advanced (3-4 hours)

**Goal:** Build custom tooling and use Copilot for complex multi-step tasks.

### Milestone 3A: Copilot Workspace

**Read:** [06 Copilot Workspace](06-copilot-workspace/README.md)

**Exercises:**
1. Take a real GitHub issue in your project. Open it in Copilot Workspace. Review the generated plan.
2. Accept the plan. Step through the implementation file by file. Reject one change and manually edit.
3. Create a git branch before starting a risky refactor. Use VS Code Timeline to recover a file version after an unwanted change.
4. Write a task specification using the template in [task-specification-guide.md](06-copilot-workspace/task-specification-guide.md). Compare the plan quality vs. a vague issue.

**Checkpoint:** You use Copilot Workspace for at least one real feature, not just toy examples.

---

### Milestone 3B: Building Extensions

**Read:** [03 Extensions](03-extensions/README.md)

**Exercises:**
1. Browse the [marketplace extensions list](03-extensions/marketplace-extensions.md). Install one relevant to your stack. Use it in Copilot Chat.
2. Clone the [skillset extension scaffold](03-extensions/skillset-extension-scaffold/). Run it locally. Send it a test request.
3. Modify the scaffold to add a new skill endpoint (e.g., a `lint-check` skill).
4. Register the extension as a GitHub App (follow the scaffold README). Use `@your-extension` in Copilot Chat.
5. Clone the [agent extension scaffold](03-extensions/agent-extension-scaffold/). Modify the system prompt to create a domain-specific agent.

**Checkpoint:** You have a working Copilot Extension that your team can use via `@mention`.

---

### Milestone 3C: Enterprise Features

**Read:** [10 Enterprise](10-enterprise/README.md)

**Exercises:**
1. Identify at least one directory or file pattern in your repo that should be excluded from Copilot suggestions (e.g., `.env`, `secrets/`). Configure content exclusion.
2. Review your organization's Copilot policy settings. Confirm public code matching is configured appropriately for your compliance requirements.
3. Run a Copilot usage audit log query for your organization.

**Checkpoint:** You can explain your organization's Copilot configuration and why each policy exists.

---

## Expert Path: Production Integration

Once you complete all three levels, these are the next frontier:

| Topic | Description |
|---|---|
| Multi-extension workflows | Chaining multiple `@extension` calls in a single conversation |
| Extension + Actions integration | Extension that triggers GitHub Actions workflows |
| Custom instruction versioning | Managing `.github/copilot-instructions.md` across multiple repos via a shared template repo |
| Copilot in monorepos | Directory-level instruction patterns using `#file` context |
| Programmatic Copilot via API | Using the GitHub Models API for automated Copilot-style completions in scripts |

---

## Quick Reference: Learning Objectives by Module

| Module | Core Skill | Beginner Need | Advanced Need |
|--------|-----------|---------------|--------------|
| 01 Slash Commands | `/explain`, `/fix`, `/tests`, `/doc` | ★★★ | ★ |
| 02 Custom Instructions | `.github/copilot-instructions.md` | ★★★ | ★★ |
| 03 Extensions | Build + use custom agents/tools | ★ | ★★★ |
| 04 Chat Variables | `@workspace`, `#file`, `@terminal` | ★★ | ★★★ |
| 05 GitHub Actions | Copilot in CI/CD | ★★ | ★★★ |
| 06 Copilot Workspace | Task-based planning | ★★ | ★★ |
| 07 CLI | `gh copilot suggest/explain` | ★★ | ★ |
| 08 Inline Suggestions | Ghost text, NES, shortcuts | ★★★ | ★ |
| 09 IDE Integration | Per-IDE setup and features | ★★ | ★★ |
| 10 Enterprise | Policies, exclusions, audit | ★ | ★★★ |

★ = Useful | ★★ = Important | ★★★ = Essential for this level
