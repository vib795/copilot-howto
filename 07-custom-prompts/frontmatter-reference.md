# Prompt File Frontmatter Reference

Every field accepted in `.github/prompts/*.prompt.md` frontmatter, with valid values, defaults, and gotchas. Current as of April 2026.

---

## Required fields

### `description` (string)

One-line hint shown in the `/` command picker.

- **Length**: keep under ~120 characters; longer values are truncated in the picker
- **Style**: start with a verb; describe what the command does, not what it is
- **Example**: `description: "Five-lens PR review with severity-tagged findings"`

---

## Strongly recommended fields

### `mode` (enum)

What the prompt is allowed to do. Default is `ask` if omitted.

| Value | Effect | Picker icon |
|---|---|---|
| `ask` | Chat reply only. Cannot edit files or run commands. | speech bubble |
| `edit` | Produces edits as a diff the user accepts or rejects. Can read files. Cannot run commands. | pencil |
| `agent` | Full agent mode — can read, write, and run terminal commands. Requires `tools:` allowlist. | robot |

Gotcha: `mode: agent` requires that your org has agent mode enabled in Copilot policy. If disabled, the prompt silently degrades to `ask` — it does not error.

### `model` (string)

Which model to run the prompt against. Overrides the user's active picker selection for this one prompt invocation.

Valid values (as of April 2026 — actual availability depends on your subscription and org policy):

**OpenAI**
- `o3` — deep reasoning, high cost
- `o4-mini` — fast, low cost
- `gpt-4.1` — balanced

**Anthropic**
- `claude-sonnet-4-5` — code generation, review, docs, tests
- `claude-opus-4-5` — deep reasoning, security audits, maximum thoroughness
- `claude-haiku-4-5` — fast and cheap, light review

**Google**
- `gemini-2.5-pro` — 1M-token context, entire-codebase reads
- `gemini-2.0-flash` — fast long-context, multi-file scan

**Auto**
- omit the `model:` field entirely, or use a named slot (see below) — lets the user's picker choice win

Gotchas:
- If a specified model is unavailable (not enabled in org policy, or Copilot itself is down for that provider), behaviour depends on your `model-compatibility.json` fallback policy — see [Module 11](../11-multi-model-mcp/README.md).
- Model IDs are case-sensitive and must match exactly. `Claude-Opus-4-5` will fail silently.
- Model availability changes. Check the [GitHub Copilot supported-models list](https://docs.github.com/en/copilot/reference/ai-models/supported-models) for the current catalogue.

### Named model slots (alternative to raw IDs)

Instead of hardcoding model IDs, you can reference a slot defined in `.vscode/settings.json`:

```yaml
model: slot/thorough    # resolves via .vscode/settings.json → claude-opus-4-5
```

Slots allow the team to roll forward to a newer model by changing one place. See [Module 11](../11-multi-model-mcp/README.md) for the slot configuration.

---

## Optional fields

### `tools` (list of strings)

Only meaningful when `mode: agent`. Restricts which tools/MCP servers the agent is allowed to call. Empty or omitted means "all tools available to this workspace."

Common values:

```yaml
tools:
  - read_file
  - write_file
  - run_terminal_command
  - github.get_issue
  - github.list_pull_requests
  - kubernetes.list_pods
  - kubernetes.get_logs
```

Server-wide wildcards:

```yaml
tools:
  - github.*
  - filesystem.*
```

See [Module 11 — MCP profiles](../11-multi-model-mcp/mcp-profiles.md) for the three-tier least-privilege pattern (`read-only`, `standard`, `elevated`).

### `temperature` (number, 0.0–1.0)

Controls model output randomness. Default is model-dependent (typically 0.2–0.4 for Copilot).

```yaml
temperature: 0.0   # deterministic — good for /review, /document
temperature: 0.7   # creative — good for /architect, brainstorming
```

Not all models honour this identically. Reasoning models (`o3`) ignore it.

### `max_tokens` (integer)

Caps the response length. Rarely needed — Copilot manages this by default. Set it if you want a strictly short answer.

```yaml
max_tokens: 500
```

### `tags` (list of strings)

Organisational metadata. Not enforced by Copilot, but used by the governance eval checks in [Module 16](../16-governance/README.md) for filtering and reporting.

```yaml
tags:
  - review
  - security
```

### `owner` (string)

The team or individual responsible for this prompt. Required by the governance manifest check in Module 16.

```yaml
owner: "@org/platform-team"
```

### `classification` (enum)

Sensitivity / approval tier. Interpreted by hooks and eval checks.

| Value | Meaning |
|---|---|
| `public` | Safe for external share, no sensitive data in the prompt body |
| `internal` | Internal workflows; may reference private systems by name |
| `restricted` | Handles sensitive data paths; requires extra review |

```yaml
classification: internal
```

---

## Full example

```yaml
---
description: "Five-lens PR review with severity-tagged findings"
mode: ask
model: slot/code
temperature: 0.1
tools:
  - read_file
tags:
  - review
  - quality
owner: "@org/platform-team"
classification: internal
---

Review the diff in #changes across five lenses...
```

---

## Validation

Use the eval checks in [Module 16](../16-governance/README.md) to validate every prompt file in CI:

```bash
bash .github/eval/checks/frontmatter.sh   # required fields present
bash .github/eval/checks/model-refs.sh    # model IDs exist in model-compatibility.json
bash .github/eval/checks/naming.sh         # kebab-case, .prompt.md extension
```

---

## Quick reference

| Field | Required | Values | Default |
|---|---|---|---|
| `description` | yes | string, ~120 chars | — |
| `mode` | recommended | `ask` / `edit` / `agent` | `ask` |
| `model` | recommended | model ID or `slot/<name>` | active picker |
| `tools` | if `mode: agent` | list of strings | all tools |
| `temperature` | no | 0.0–1.0 | model default |
| `max_tokens` | no | integer | unlimited |
| `tags` | no | list of strings | `[]` |
| `owner` | gov. | string | — |
| `classification` | gov. | `public` / `internal` / `restricted` | — |
