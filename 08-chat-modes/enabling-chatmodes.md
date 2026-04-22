# Enabling and Troubleshooting Chat Modes

Chat modes are gated behind a VS Code setting and a few common misconfigurations. This page walks through the exact fixes.

---

## Prerequisite: VS Code Setting

Chat modes only appear in the picker when this is set in `.vscode/settings.json` (or user settings):

```json
{
  "github.copilot.chat.experimental.chatModes": true
}
```

Restart VS Code after toggling.

---

## Diagnostic: Why Is My Mode Dropdown Empty?

Step through these in order — one of them is the cause.

### 1. Is the setting on?

```bash
grep -r "chatModes" .vscode/settings.json
```

If this returns nothing, add the setting above and restart VS Code.

### 2. Are there any `.chatmode.md` files Copilot can see?

```bash
ls .github/chatmodes/*.chatmode.md 2>/dev/null || echo "none"
```

Personal modes:

```bash
ls ~/.copilot/chatmodes/*.chatmode.md 2>/dev/null || echo "none"
```

### 3. Is the frontmatter valid YAML?

```bash
for f in .github/chatmodes/*.chatmode.md; do
  echo "== $f =="
  sed -n '1,/^---$/p' "$f" | sed '1d;$d' | yq eval '.' - >/dev/null 2>&1 && echo "ok" || echo "INVALID YAML"
done
```

Common YAML mistakes:
- Tab characters in indentation (YAML requires spaces).
- Unquoted strings containing `:` or `#`.
- Missing closing quote.

### 4. Is the filename correct?

Must end in `.chatmode.md` literally. `security-auditor.md` and `security.chatmode.yaml` are invisible.

### 5. Is the model actually available to you?

If `model: claude-opus-4-5` but your org hasn't enabled Anthropic models, the mode may be hidden. Either:
- Ask an org admin to enable it (see [Module 15 — Enterprise](../15-enterprise/README.md))
- Change `model:` to one you have access to
- Remove `model:` entirely and let the picker decide

### 6. Is Copilot Chat's feature set current?

```
VS Code → Extensions → GitHub Copilot Chat → check for updates
```

Chat modes are a recent feature. Versions older than ~2025-12 may not render the picker correctly.

### 7. Is this a VS Code Insiders-only feature?

As of April 2026 chat modes are in stable VS Code, but some underlying flags are still marked `experimental`. If nothing else works, try VS Code Insiders with the same settings to rule out a stable-channel regression.

---

## Diagnostic: The Mode Appears, But Uses the Wrong Model

1. **Check your picker.** The chat model picker in the chat panel still shows, but the mode's `model:` overrides it for every message. If the header in replies names a different model than the `model:` you wrote, your frontmatter isn't being parsed.
2. **Verify frontmatter.** See step 3 above.
3. **Check org model policy.** If `model: o3` is in the file but your org only has `gpt-4.1` enabled, Copilot silently falls back. The [model-compatibility.json](../11-multi-model-mcp/model-compatibility.json) fallback policy controls this — set it to `fail-closed` for any mode where model pinning is a security-relevant invariant.

---

## Diagnostic: Tools Aren't Available in the Mode

1. **MCP servers need to be configured.** `tools: [kubernetes.list_pods]` is only usable if `.vscode/mcp.json` defines a `kubernetes` server. See [Module 11 — MCP](../11-multi-model-mcp/README.md).
2. **MCP env vars need to exist.** If the `kubernetes` MCP server requires `KUBECONFIG`, and it's empty in your shell, the server fails silently and tools don't register.
3. **Tool name typos.** `kubernetes.list_pods` is not the same as `k8s.listPods`. Match exactly.

Restart VS Code after changing `.vscode/mcp.json` — MCP servers are spawned at startup.

---

## Where Chat Modes Live (Precedence)

| Path | Scope | Precedence |
|---|---|---|
| `.github/chatmodes/*.chatmode.md` | Project team | Shown to everyone on the project |
| `~/.copilot/chatmodes/*.chatmode.md` | Personal, all projects | Shown only to you |

If two files have the same name, the project-level file wins within that project.

---

## Verifying End-to-End

```bash
# 1. File exists
ls .github/chatmodes/security-auditor.chatmode.md

# 2. Frontmatter valid
sed -n '/^---$/,/^---$/p' .github/chatmodes/security-auditor.chatmode.md | head -20

# 3. Setting on
grep chatModes .vscode/settings.json

# 4. In VS Code: reload window (Cmd+Shift+P → "Developer: Reload Window")

# 5. Chat panel → mode dropdown → "Security auditor" should appear
```
