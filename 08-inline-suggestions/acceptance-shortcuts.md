# Inline Suggestion Keyboard Shortcuts

A complete reference for accepting, dismissing, and navigating GitHub Copilot inline suggestions across every supported IDE.

---

## VS Code

| Action | Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the entire ghost text at the cursor |
| Dismiss suggestion | `Escape` | Clears the ghost text without inserting anything |
| Next suggestion | `Alt+]` | Cycles forward through alternative completions |
| Previous suggestion | `Alt+[` | Cycles backward through alternative completions |
| Accept next word | `Ctrl+Right` | Accepts one word of the ghost text at a time |
| Trigger suggestion manually | `Alt+\` | Forces a completion request at the current cursor position |
| Open completions panel | `Ctrl+Enter` | Opens a side panel showing up to 10 candidates |

### Notes on VS Code Shortcuts

**`Tab` conflicts with indentation**: By default, `Tab` both indents code and accepts Copilot suggestions. VS Code resolves this by only triggering acceptance when ghost text is currently visible. If no ghost text is shown, `Tab` behaves normally.

**`Ctrl+Right` for partial acceptance**: This is one of the most underutilised Copilot shortcuts. When the ghost text shows a function call like `fetchUserProfile(userId, options)` and you only want `fetchUserProfile(`, hold `Ctrl+Right` to accept word by word. The cursor advances through the suggestion word by word without committing to the full text.

**`Alt+\` for on-demand suggestions**: If you have disabled `github.copilot.editor.enableAutoCompletions` (to reduce noise while reading code), `Alt+\` is how you request a completion when you are ready. Many developers bind this to a more ergonomic key.

**`Ctrl+Enter` completions panel**: Opens a dedicated panel to the right of the editor with up to 10 full completions. Useful when the inline ghost text doesn't look right — you can scan the alternatives and click to insert the one you want.

---

## JetBrains IDEs

Applies to IntelliJ IDEA, PyCharm, WebStorm, GoLand, Rider, CLion, DataGrip, and other JetBrains products with the GitHub Copilot plugin installed.

| Action | Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the entire ghost text |
| Dismiss suggestion | `Escape` | Clears ghost text |
| Next suggestion | `Alt+]` | Cycles forward |
| Previous suggestion | `Alt+[` | Cycles backward |
| Accept next word | `Alt+Right` | Accepts one word at a time |
| Trigger suggestion manually | `Alt+\` | Forces a completion request |

### Notes on JetBrains Shortcuts

**`Alt+Right` vs `Ctrl+Right`**: JetBrains uses `Alt+Right` for word-level acceptance rather than `Ctrl+Right`, because `Ctrl+Right` is already bound to "Move Caret to Next Word" in JetBrains IDEs. Check your current keymap under **Settings → Keymap → GitHub Copilot** to confirm these bindings haven't been remapped by another plugin.

**Keymap conflicts**: The GitHub Copilot plugin registers its shortcuts in the JetBrains keymap system. If another plugin (e.g., a Vim emulation plugin) has claimed `Tab` or `Alt+]`, you may need to resolve the conflict in **Settings → Keymap**.

**Inline chat**: `Alt+\` also opens the inline Copilot chat input in newer versions of the plugin. If you are on an older plugin version, `Alt+\` only triggers ghost text.

---

## Neovim — copilot.vim (Official Plugin)

| Action | Default Binding | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the suggestion in insert mode |
| Dismiss suggestion | `Ctrl+]` | Clears ghost text |
| Next suggestion | `Alt+]` (or `<M-]>`) | Cycles forward |
| Previous suggestion | `Alt+[` (or `<M-[>`) | Cycles backward |
| Trigger suggestion manually | `:Copilot suggest` | Command-mode trigger |

### copilot.vim Configuration Example

```vim
" In your init.vim or .vimrc

" If Tab is used by another plugin (e.g. cmp, UltiSnips), remap acceptance:
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Disable Copilot for specific filetypes:
let g:copilot_filetypes = {
  \ 'markdown': v:false,
  \ 'yaml': v:false,
  \ '*': v:true
  \ }
```

### Tab Conflict with Completion Plugins

If you use `nvim-cmp`, `UltiSnips`, or another completion plugin that also uses `Tab`, you must disable copilot.vim's Tab mapping with `let g:copilot_no_tab_map = v:true` and bind acceptance to a different key (commonly `Ctrl+J` or `Ctrl+L`).

---

## Neovim — copilot.lua (Community Plugin by zbirenbaum)

`copilot.lua` does not set any default keybindings, giving you full control. Below are the recommended bindings from the project's documentation, which many users adopt as a starting point.

| Action | Recommended Binding | Lua API Call |
|---|---|---|
| Accept full suggestion | `Ctrl+J` | `require('copilot.suggestion').accept()` |
| Accept next word | `Ctrl+Right` | `require('copilot.suggestion').accept_word()` |
| Accept next line | `Ctrl+Down` | `require('copilot.suggestion').accept_line()` |
| Dismiss suggestion | `Ctrl+]` | `require('copilot.suggestion').dismiss()` |
| Next suggestion | `Alt+]` | `require('copilot.suggestion').next()` |
| Previous suggestion | `Alt+[` | `require('copilot.suggestion').prev()` |
| Toggle Copilot on/off | (custom) | `require('copilot.suggestion').toggle_auto_trigger()` |

### copilot.lua Configuration Example (lazy.nvim)

```lua
-- ~/.config/nvim/lua/plugins/copilot.lua
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = "<C-j>",
        accept_word = false,   -- set to a key if you want word-by-word
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<CR>",
        refresh = "gr",
        open = "<M-CR>",
      },
    },
    filetypes = {
      yaml = false,
      markdown = false,
      help = false,
      gitcommit = false,
      gitrebase = false,
      hgcommit = false,
      svn = false,
      cvs = false,
      ["."] = false,  -- disable for unnamed buffers
    },
  },
}
```

### CopilotChat.nvim Integration

`copilot.lua` pairs with `CopilotChat.nvim` to bring Copilot Chat into Neovim. Install both plugins and bind the chat toggle:

```lua
-- Open Copilot Chat with <leader>cc
vim.keymap.set({ "n", "v" }, "<leader>cc", "<cmd>CopilotChat<CR>", { desc = "Open Copilot Chat" })
```

---

## Xcode

| Action | Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the entire ghost text |
| Dismiss suggestion | `Escape` | Clears ghost text |

Xcode's Copilot integration is limited to inline suggestions (ghost text). There are no shortcut keys for cycling between alternative suggestions or partial acceptance. See [../09-ide-integration/xcode-setup.md](../09-ide-integration/xcode-setup.md) for full setup details.

---

## Visual Studio (Windows)

| Action | Shortcut | Notes |
|---|---|---|
| Accept full suggestion | `Tab` | Inserts the entire ghost text |
| Dismiss suggestion | `Escape` | Clears ghost text |
| Next suggestion | `Alt+.` | Cycles forward |
| Previous suggestion | `Alt+,` | Cycles backward |
| Trigger suggestion manually | `Alt+\` | Forces a completion request |

Note: Visual Studio uses `Alt+.` / `Alt+,` for cycling rather than `Alt+]` / `Alt+[`. Keep this in mind if you switch between VS Code and Visual Studio frequently.

---

## Changing the Accept Key in VS Code

Some developers prefer not to use `Tab` for Copilot acceptance because they rely on `Tab` for other purposes (e.g., snippet navigation, custom indentation behaviour). There are two approaches:

### Option 1: Disable Tab Acceptance Globally and Use a Custom Key

```json
// settings.json
{
  "github.copilot.editor.enableAutoCompletions": true
}
```

Then add a custom keybinding in `keybindings.json` (`Ctrl+Shift+P` → "Open Keyboard Shortcuts (JSON)"):

```json
[
  {
    "key": "ctrl+j",
    "command": "editor.action.inlineSuggest.commit",
    "when": "inlineSuggestionVisible && !editorReadonly"
  },
  {
    "key": "tab",
    "command": "-editor.action.inlineSuggest.commit",
    "when": "inlineSuggestionVisible && !editorReadonly"
  }
]
```

This rebinds acceptance to `Ctrl+J` and removes the `Tab` binding for Copilot. `Tab` continues to work normally for indentation and snippet navigation.

### Option 2: Use `editor.tabCompletion`

VS Code has a setting `editor.tabCompletion` which controls whether `Tab` triggers word-based completion from the built-in completion provider. This does not directly affect Copilot's ghost text acceptance, but it is relevant if you are diagnosing unexpected `Tab` behaviour:

```json
{
  "editor.tabCompletion": "off"
}
```

### Option 3: Coexist with Snippet Tab Stops

If you use snippets and find that `Tab` sometimes accepts Copilot instead of advancing to the next snippet tab stop, VS Code resolves this by giving snippet tab stops priority over Copilot acceptance when you are inside an active snippet session. No configuration change is needed; this is the default behaviour.

---

## Summary Table — Quick Reference

| IDE | Accept | Dismiss | Next | Prev | Accept Word | Manual Trigger |
|---|---|---|---|---|---|---|
| VS Code | `Tab` | `Esc` | `Alt+]` | `Alt+[` | `Ctrl+Right` | `Alt+\` |
| Visual Studio | `Tab` | `Esc` | `Alt+.` | `Alt+,` | — | `Alt+\` |
| IntelliJ / PyCharm / WebStorm | `Tab` | `Esc` | `Alt+]` | `Alt+[` | `Alt+Right` | `Alt+\` |
| Neovim (copilot.vim) | `Tab` | `Ctrl+]` | `Alt+]` | `Alt+[` | — | `:Copilot suggest` |
| Neovim (copilot.lua) | (custom) | (custom) | (custom) | (custom) | (custom) | (custom) |
| Xcode | `Tab` | `Esc` | — | — | — | — |
