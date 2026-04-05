# VS Code Settings Reference for Copilot Completions

A complete reference for the VS Code settings that affect GitHub Copilot inline suggestion behaviour. Each entry includes the setting key, type, default value, a description, the `settings.json` snippet format, and a note on whether a reload is required.

---

## Quick Reference Table

| Setting | Type | Default | Reload Required? |
|---|---|---|---|
| `github.copilot.enable` | Object | `{ "*": true }` | No |
| `github.copilot.editor.enableAutoCompletions` | Boolean | `true` | No |
| `github.copilot.editor.enableCodeActions` | Boolean | `true` | No |
| `github.copilot.advanced.indentationMode` | Object | `{}` | No |
| `github.copilot.nextEditSuggestions.enabled` | Boolean | `false` | No |
| `github.copilot.chat.localeOverride` | String | `""` (use IDE locale) | No |
| `github.copilot.renameSuggestions.triggerAutomatically` | Boolean | `true` | No |

---

## Setting Details

### `github.copilot.enable`

**Type:** Object (language ID → boolean map)
**Default:** `{ "*": true }`
**Reload required:** No

Controls whether Copilot inline suggestions are active for specific languages. The key is a VS Code language identifier (the value shown in the bottom-right status bar when a file is open). The special key `"*"` applies to all languages not explicitly listed.

**Common language identifiers:**

| Language | Identifier |
|---|---|
| TypeScript | `typescript` |
| JavaScript | `javascript` |
| Python | `python` |
| Go | `go` |
| Rust | `rust` |
| Java | `java` |
| C# | `csharp` |
| C/C++ | `c`, `cpp` |
| Ruby | `ruby` |
| PHP | `php` |
| Markdown | `markdown` |
| Plain text | `plaintext` |
| YAML | `yaml` |
| JSON | `json` |
| Shell/Bash | `shellscript` |
| SQL | `sql` |

**settings.json example:**

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": false,
    "json": true,
    "yaml": true
  }
}
```

**When to customise this:**
- Disable for `markdown` if you write prose documentation and find suggestions distracting.
- Disable for `plaintext` to prevent suggestions in `.txt` files and commit message editors.
- You can also toggle per-language from the VS Code status bar: click the Copilot icon → "Disable for [language]".

---

### `github.copilot.editor.enableAutoCompletions`

**Type:** Boolean
**Default:** `true`
**Reload required:** No

When `true`, Copilot shows ghost text automatically after a short debounce period as you type. When `false`, ghost text is never shown automatically; you must press `Alt+\` to request a completion manually.

**settings.json example:**

```json
{
  "github.copilot.editor.enableAutoCompletions": false
}
```

**When to set to `false`:**
- When reviewing or reading code (you don't want ghost text flickering as you scroll)
- When working in very large files where the debounce delay is noticeable
- When you prefer a more deliberate workflow (type, pause, explicitly request a suggestion)

**Note:** Even with auto-completions disabled, the Copilot status bar icon remains active and `Alt+\` continues to work.

---

### `github.copilot.editor.enableCodeActions`

**Type:** Boolean
**Default:** `true`
**Reload required:** No

Controls whether Copilot options appear in the VS Code **Code Actions** lightbulb menu (the yellow lightbulb that appears on hover or when you press `Ctrl+.`). When enabled, the lightbulb menu may include options such as "Fix using Copilot" or "Explain using Copilot" in addition to the standard VS Code quick-fix options.

**settings.json example:**

```json
{
  "github.copilot.editor.enableCodeActions": true
}
```

**When to set to `false`:**
- If you find the Copilot entries in the lightbulb menu cluttering the quick-fix list
- If you prefer to interact with Copilot only through the Chat panel or inline suggestions, not through code actions

---

### `github.copilot.advanced.indentationMode`

**Type:** Object (language ID → indentation mode string map)
**Default:** `{}`
**Reload required:** No

Controls how Copilot handles indentation in its completions for specific languages. This is an advanced setting that most users do not need to change. It is primarily useful when Copilot's indentation in a suggestion does not match the project's style (e.g., Copilot suggests 4-space indentation but the project uses 2 spaces).

**Accepted values per language:**
- `"preserveIndentation"` — Copilot matches the indentation of the surrounding code
- `"insertSpaces"` — Force space-based indentation in suggestions
- `"insertTabs"` — Force tab-based indentation in suggestions

**settings.json example:**

```json
{
  "github.copilot.advanced.indentationMode": {
    "python": "preserveIndentation",
    "go": "insertTabs",
    "javascript": "insertSpaces"
  }
}
```

**Note:** In practice, Copilot usually inherits indentation settings from `editor.insertSpaces` and `editor.tabSize`. Only adjust this if you see persistent indentation mismatches in a specific language.

---

### `github.copilot.nextEditSuggestions.enabled`

**Type:** Boolean
**Default:** `false`
**Reload required:** No

Enables the **Next Edit Suggestions** (NES) feature. When enabled, Copilot watches your edits and displays an arrow indicator in the gutter when it predicts a related edit elsewhere in the current file. See [next-edit-suggestions.md](./next-edit-suggestions.md) for a full guide.

**settings.json example:**

```json
{
  "github.copilot.nextEditSuggestions.enabled": true
}
```

**When to enable:**
- When you frequently make changes that require updating related code in the same file (renaming, changing signatures, updating constants)
- When you are doing active refactoring sessions

**When to leave disabled:**
- If you find the gutter arrows distracting during focused reading or debugging
- If NES latency (the brief delay after each edit) disrupts your flow

---

### `github.copilot.chat.localeOverride`

**Type:** String (IETF BCP 47 language tag)
**Default:** `""` (inherits from VS Code's display language)
**Reload required:** No

Overrides the language that Copilot Chat uses for its responses. By default, Copilot Chat responds in the same language as VS Code's UI locale. Use this setting to force a specific response language without changing the entire VS Code UI language.

**settings.json example:**

```json
{
  "github.copilot.chat.localeOverride": "en"
}
```

**Accepted values (examples):**

| Value | Language |
|---|---|
| `"en"` | English |
| `"fr"` | French |
| `"de"` | German |
| `"ja"` | Japanese |
| `"zh-CN"` | Simplified Chinese |
| `"pt-BR"` | Brazilian Portuguese |
| `"es"` | Spanish |
| `"ko"` | Korean |

**Note:** This setting only affects Copilot Chat panel responses and inline chat responses. It does not affect the language of inline ghost text suggestions (which are always code, not prose).

---

### `github.copilot.renameSuggestions.triggerAutomatically`

**Type:** Boolean
**Default:** `true`
**Reload required:** No

When `true`, Copilot automatically suggests alternative names when you trigger VS Code's **Rename Symbol** command (`F2`). The suggestions appear in the rename input box as you type, or as a dropdown of Copilot-generated alternatives.

**settings.json example:**

```json
{
  "github.copilot.renameSuggestions.triggerAutomatically": false
}
```

**When to set to `false`:**
- If you find the rename suggestions dropdown disruptive when you already know the new name
- If you use rename frequently and the extra suggestions slow down the UI

---

## Complete `settings.json` Template

The following is a ready-to-use template with all Copilot completion-related settings. Copy it into your `settings.json` and adjust as needed.

```json
{
  // ------------------------------------------------------------------
  // GitHub Copilot: Inline Suggestion Settings
  // ------------------------------------------------------------------

  // Enable/disable Copilot per language.
  // "*" is the fallback for any language not explicitly listed.
  "github.copilot.enable": {
    "*": true,
    "plaintext": false,
    "markdown": false
  },

  // Show ghost text automatically as you type (true = auto, false = manual only).
  // Manual trigger: Alt+\ in VS Code.
  "github.copilot.editor.enableAutoCompletions": true,

  // Show Copilot options in the Code Actions lightbulb menu (Ctrl+.).
  "github.copilot.editor.enableCodeActions": true,

  // Force specific indentation behaviour per language (leave empty to use defaults).
  "github.copilot.advanced.indentationMode": {},

  // ------------------------------------------------------------------
  // GitHub Copilot: Next Edit Suggestions (NES)
  // ------------------------------------------------------------------

  // Predict and surface the next related edit after you make a change.
  "github.copilot.nextEditSuggestions.enabled": true,

  // ------------------------------------------------------------------
  // GitHub Copilot: Chat Settings
  // ------------------------------------------------------------------

  // Override the response language for Copilot Chat.
  // Leave empty ("") to use VS Code's UI locale.
  "github.copilot.chat.localeOverride": "",

  // ------------------------------------------------------------------
  // GitHub Copilot: Rename Suggestions
  // ------------------------------------------------------------------

  // Automatically show Copilot name suggestions when using F2 rename.
  "github.copilot.renameSuggestions.triggerAutomatically": true
}
```

---

## How to Open `settings.json` in VS Code

1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS) to open the Command Palette.
2. Type `Open User Settings JSON` and press Enter.
3. The file opens at `~/.config/Code/User/settings.json` (Linux), `~/Library/Application Support/Code/User/settings.json` (macOS), or `%APPDATA%\Code\User\settings.json` (Windows).

To open **workspace** settings (only apply to the current project):

1. Press `Ctrl+Shift+P` → `Open Workspace Settings JSON`.
2. The file is stored at `.vscode/settings.json` in the project root.

Workspace settings override user settings. This is useful for setting per-project `github.copilot.enable` values (e.g., disabling Copilot for a repository that contains sensitive data).

---

## Settings Requiring a VS Code Reload

Based on current extension behaviour, **none** of the settings listed in this reference require a full VS Code window reload to take effect. Changes apply immediately because the GitHub Copilot extension watches for configuration changes via VS Code's extension API.

However, the following scenarios may still require a reload or extension restart:

- **Installing or uninstalling the Copilot extension** — requires a reload.
- **Switching GitHub accounts** — requires a reload to re-authenticate.
- **Extension version updates** — VS Code prompts you to reload after an extension update.
- **Changes to proxy or network settings** (`http.proxy`) — these are VS Code network settings that apply at startup; a reload ensures they are picked up.

If a Copilot setting change does not seem to take effect, try reloading the window with `Ctrl+Shift+P` → `Developer: Reload Window` before filing a bug report.
