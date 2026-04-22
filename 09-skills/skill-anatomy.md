# SKILL.md — Field Reference and Anatomy

Every field accepted in `.github/skills/<name>/SKILL.md` frontmatter, plus body conventions. Current as of April 2026.

---

## Required frontmatter fields

### `name` (string)

Identifier used for manual invocation (`/skills run <name>`) and in manifest entries. Must match the parent folder name and be kebab-case.

```yaml
name: helm-upgrade
```

Folder must be `.github/skills/helm-upgrade/` for this to be valid.

### `description` (string, multiline)

The trigger text. See [description-writing-guide.md](./description-writing-guide.md) for how to write one that works.

```yaml
description: >
  Use when the user asks to deploy, upgrade, or roll back a service ...
```

Multi-line YAML (`>` folded or `|` literal) is the norm. Keep it to 3–6 lines — enough to cover the trigger vocabulary, short enough that Copilot can scan all skills without blowing the token budget.

---

## Recommended frontmatter fields

### `owner` (string)

Team or role that owns this skill. Required by the governance eval in [Module 16](../16-governance/README.md).

```yaml
owner: "@org/platform-team"
```

### `classification` (enum)

Sensitivity / approval tier:

| Value | Meaning |
|---|---|
| `public` | Generic, safe to share externally |
| `internal` | References internal systems or workflows |
| `restricted` | Handles sensitive data or destructive operations |

```yaml
classification: internal
```

### `tags` (list of strings)

Organisational metadata. Used by the discover script and eval reporting.

```yaml
tags:
  - deploy
  - kubernetes
  - helm
```

---

## Optional frontmatter fields

### `model` (string)

Skills *can* pin a preferred model. Normally they don't — they work with whatever model the chat mode / prompt / picker has selected. Only pin when the skill's content genuinely requires a specific model's capabilities (e.g., 1M context for a codebase-scan skill).

```yaml
model: gemini-2.5-pro    # for skills that need to read very large files
```

Gotcha: pinning a model on a skill overrides the user's picker and the mode's model for the duration of the skill's use. Do this only with strong reason.

### `requires` (list of strings)

MCP servers or tools this skill needs in order to execute. If missing, the skill triggers but warns that it can't complete.

```yaml
requires:
  - kubernetes
  - filesystem
```

### `version` (string)

Semantic version of the skill itself. Used by governance eval to detect stale versions.

```yaml
version: "1.2.0"
```

### `deprecated_on` (string, ISO date)

Marks the skill for removal. The deprecation eval in Module 16 enforces a 60-day grace period and warns if the date has passed.

```yaml
deprecated_on: "2026-06-01"
```

---

## Body conventions

The body below the frontmatter is instructions Copilot follows when the skill is loaded. Write it like a runbook for a new hire.

### Recommended sections

Not all sections apply to every skill, but this ordering works:

```markdown
# <Skill name — human readable>

<One-paragraph purpose statement — what problem this skill solves>

## Prerequisites
<What access, tools, env vars are needed before running the procedure>

## Decide: <X> or <Y>?
<Decision table when the skill handles multiple related tasks>

## <X> procedure
### 1. ...
### 2. ...
### 3. ...

## <Y> procedure
### 1. ...
### 2. ...

## Verification
<How to confirm each step worked>

## Rollback / Undo
<How to back out if something goes wrong>

## Common errors
<Lookup table of error messages -> causes -> fixes>

## Escalation
<Who to page and when>

## What you do NOT do from this skill
<Explicit blocklist of destructive or out-of-scope operations>
```

### Style

- **Imperative voice.** Copilot is following the runbook. Say "run this command" not "this command could be run."
- **Exact commands, copy-pasteable.** Fenced code blocks, `<ANGLE_BRACKETS>` for placeholders.
- **Small commits of instruction.** One idea per numbered step. Not a wall of prose.
- **Decision tables over nested if/else.** Tables are easier for a model to apply correctly.
- **Cite real file paths, real error messages.** "common-errors.md" is useful; "the error reference" is not.

### What NOT to include in the body

- Long motivational intros ("In today's cloud-native world...")
- Tutorials explaining *why* something works (unless it directly affects a decision point)
- Personal opinions / editorial
- Anything that could be derived from the code or docs

---

## Bundled files

A skill can include more than SKILL.md. Put supporting files next to it:

```
.github/skills/incident-triage/
├── SKILL.md                     # The main runbook (frontmatter + body)
├── postmortem-template.md       # Referenced from SKILL.md
└── runbook.sh                   # Script the user can run
```

Reference bundled files by relative path *from the skill folder*:

```markdown
Use the template at [postmortem-template.md](./postmortem-template.md).
```

---

## Validation

The governance eval checks in Module 16 validate every skill:

```bash
bash .github/eval/checks/naming.sh         # folder + file naming
bash .github/eval/checks/frontmatter.sh    # required fields present
bash .github/eval/checks/governance.sh     # owner + classification + manifest entry
bash .github/eval/checks/manifest-sync.sh  # every skill folder is in the manifest
```

---

## Discovery path

Copilot finds skills at these locations, in priority order:

| Path | Scope |
|---|---|
| `.github/skills/<name>/SKILL.md` | Project, committed |
| `.claude/skills/<name>/SKILL.md` | Project, committed (works with Copilot and Claude Code) |
| `~/.copilot/skills/<name>/SKILL.md` | Personal, not shared |

A project-level skill with the same name as a personal skill wins within that project.

---

## Quick reference

| Field | Required | Values | Default |
|---|---|---|---|
| `name` | yes | kebab-case string, matches folder | — |
| `description` | yes | multi-line YAML | — |
| `owner` | gov. | string | — |
| `classification` | gov. | `public` / `internal` / `restricted` | — |
| `tags` | no | list of strings | `[]` |
| `model` | no | model ID | none (picker wins) |
| `requires` | no | list of MCP server names | `[]` |
| `version` | no | semver string | — |
| `deprecated_on` | no | ISO date | — |
