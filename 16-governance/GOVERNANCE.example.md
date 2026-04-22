# GOVERNANCE — Lifecycle Process for Copilot Assets

Every prompt, skill, chatmode, agent, instruction file, MCP profile, and workflow that lives under `.github/` goes through a lifecycle: **propose → add → use → deprecate → remove**. This document is the process.

---

## Roles

| Role | Responsibility |
|---|---|
| **Asset owner** (team) | Maintains the asset. Responds to bugs. Drives deprecation when needed. |
| **Reviewer** | Reviews PRs touching assets. Required for non-trivial changes. |
| **Security team** | Required reviewer for any `classification: restricted` asset. |
| **Platform team** | Owns the governance infrastructure itself (eval, hooks, workflows). |

Owners are always teams, never individuals. When people move, teams persist.

---

## Adding a new asset

### 1. Decide the right primitive

Before writing a file, answer:

- Is this a one-shot task? → **Prompt** ([Module 07](../07-custom-prompts/README.md))
- A persistent persona? → **Chat mode** ([Module 08](../08-chat-modes/README.md))
- A runbook that should auto-apply? → **Skill** ([Module 09](../09-skills/README.md))
- A multi-step autonomous workflow? → **Agent** ([Module 10](../10-agents/README.md))
- A file-type-scoped rule? → **Instructions file** ([Module 05](../05-custom-instructions/README.md))

If you can't decide, start with a prompt. It's the lowest-commitment primitive.

### 2. Checklist for the PR

- [ ] File is in the right directory with the right extension (validated by `naming.sh`)
- [ ] Frontmatter has all required fields for the asset type (validated by `frontmatter.sh`)
- [ ] `model:` reference exists in `model-compatibility.json` (validated by `model-refs.sh`)
- [ ] If `tools:` is present, every tool exists in an active MCP server (validated by `tool-refs.sh`)
- [ ] Asset is added to `copilot-asset-manifest.json` with owner + classification (validated by `manifest-sync.sh`, `governance.sh`)
- [ ] `COPILOT-CHANGELOG.md` has an `Added` entry under `[Unreleased]`
- [ ] If classification is `restricted`, security team is in the reviewer list
- [ ] PR description explains *why* this asset is needed and what existing primitive it replaces, if any

### 3. CI gates

`copilot-eval.yml` runs on every PR touching `.github/`:

- `naming.sh` — file naming
- `frontmatter.sh` — YAML fields
- `model-refs.sh` — model IDs exist
- `tool-refs.sh` — tool names exist
- `manifest-sync.sh` — registry ↔ filesystem
- `governance.sh` — owner + classification present
- `doc-consistency.sh` — no stale references
- `deprecation.sh` — any `deprecated_on:` field is valid

All deterministic checks must pass. PRs that fail eval cannot be merged.

---

## Modifying an existing asset

### Minor changes (no behaviour change)

Examples: typo fixes, clarifying wording, renaming a section in a skill body.

- One reviewer from the asset owner team.
- Changelog entry under `Changed` (or skip for pure typos if the team convention allows).

### Behavioural changes

Examples: updating a prompt's output format, changing an agent's `tools:` list, updating a skill's procedure.

- Two reviewers, at least one from the owner team.
- Changelog entry under `Changed` with a sentence explaining the behavioural delta.
- If the change affects downstream agents / chains (e.g., plan agent changes its output format in a way the implement agent reads), update all affected assets in the same PR.

### Security-relevant changes

Examples: tightening or loosening an MCP profile, changing an agent's classification, adding/removing a hook.

- Security team is a required reviewer.
- Changelog entry under `Security`.
- For classification upgrades (`internal` → `restricted`), the PR description must explain why.

---

## Deprecating an asset

Deprecation is a first-class lifecycle event, not a quiet rename.

### Process

1. Add `deprecated_on: YYYY-MM-DD` to the asset's frontmatter.
2. Set a `removal_scheduled_on` date at least **60 days** after `deprecated_on`.
3. Update the manifest entry's `status` to `deprecated`.
4. Add an entry under `Deprecated` in `COPILOT-CHANGELOG.md`.
5. Name the replacement asset in the deprecation entry.
6. Communicate the deprecation to asset users — the discover script's output now labels the asset as deprecated.

Example:

```yaml
# old-deploy.prompt.md
---
description: "Deployment checklist [DEPRECATED — use /helm-upgrade instead]"
mode: ask
model: slot/balanced
deprecated_on: "2026-04-16"
removal_scheduled_on: "2026-06-15"
replaced_by: "skills/helm-upgrade"
---
```

### 60-day rule

The `deprecation.sh` eval check enforces:

- `removal_scheduled_on` is at least 60 days after `deprecated_on`
- If today > `removal_scheduled_on`, the asset is ready to remove (or the deprecation date slipped and should be pushed out)

Deprecating today and removing tomorrow is forbidden even in emergencies. If an asset is actively harmful, *remove* it (see below) — don't deprecate.

---

## Removing an asset

After the 60-day grace period:

1. Delete the file(s).
2. Update the manifest entry's `status` to `removed`.
3. Add an entry under `Removed` in `COPILOT-CHANGELOG.md`, referencing the `deprecated_on` date.
4. Do NOT remove the manifest entry itself — `status: removed` entries are kept as an audit trail. `manifest-sync.sh` allows `status: removed` entries to exist without a matching file.

---

## Emergency removal

For genuine harm (leaked secret in a prompt body, security finding in a hook, a skill that's been teaching the wrong procedure for a production outage):

1. Remove immediately in an emergency PR with minimum one reviewer.
2. Changelog entry under `Security` with severity and scope.
3. Post-mortem within 7 days analysing how the asset got into the state that required emergency removal.
4. Action items to prevent recurrence (usually: a new eval check or hook).

Emergency removal bypasses the 60-day rule. Everything else about bypasses is not OK.

---

## Transferring ownership

Ownership transfer is common (team reorgs, handoffs). Process:

1. Old owner team and new owner team both approve the PR changing the `owner:` field in the manifest and the asset frontmatter.
2. Changelog entry under `Changed`.
3. New owner team does a "load-bearing review" — reads the asset end to end, confirms they understand it, and would be able to maintain / deprecate it if needed.

Ownership with zero institutional knowledge is worse than clear deprecation. If the new team can't commit to maintaining, deprecate the asset instead.

---

## Classifications

| Classification | Criteria | Review requirements |
|---|---|---|
| `public` | Generic, safe to share externally. No internal system names. | 1 reviewer |
| `internal` | References internal systems, workflows. Most assets. | 1 reviewer from owner team |
| `restricted` | Destructive capabilities, security-sensitive, handles secrets or PII paths. | +1 security team reviewer |

Examples:

- **public**: a generic `/document` prompt with no company-specifics
- **internal**: `/deploy` referencing your internal cluster names and Helm chart layout
- **restricted**: `security-auditor.chatmode.md` (reads all code), `destructive-commands.sh`, anything in the `elevated` MCP profile

---

## Quality bar

New assets should meet:

- **Clear single purpose.** If it does five things, split it.
- **Non-trivial value.** An asset that duplicates a built-in command is waste.
- **Tested behaviour.** Try it on three real inputs before merging. Note results in the PR.
- **Documented.** Users shouldn't have to read the frontmatter to know what the asset does.

---

## Review heuristics

For reviewers:

- **Is the `description:` trigger-worthy?** (Skills especially — does it match what people actually say?)
- **Does `model:` match the work?** (See [model-routing-guide.md](../11-multi-model-mcp/model-routing-guide.md).)
- **Is `tools:` as narrow as the job allows?** (For agents.)
- **What's the failure mode?** (Imagine the asset doing the wrong thing — is the blast radius acceptable?)
- **Does the changelog entry match the diff?** (Drift here is a sign of a rushed PR.)

---

## Related

- [COPILOT-CHANGELOG.example.md](./COPILOT-CHANGELOG.example.md) — template
- [copilot-asset-manifest.json.example](./copilot-asset-manifest.json.example) — registry
- [asset-lifecycle.md](./asset-lifecycle.md) — walk-through of a full add → deprecate cycle
