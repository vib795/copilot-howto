# GitHub Copilot Setup: Neovim

Neovim offers two distinct plugin options for GitHub Copilot: the official `copilot.vim` plugin and the community `copilot.lua` plugin. Both provide high-quality inline suggestions. `copilot.lua` is more customisable and integrates with `CopilotChat.nvim` for Chat support. This guide covers both options with complete configuration examples.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Option A: copilot.vim (Official, Simpler)](#option-a-copilotvim-official-simpler)
3. [Option B: copilot.lua (Community, More Customisable)](#option-b-copilotlua-community-more-customisable)
4. [Copilot Chat in Neovim (CopilotChat.nvim)](#copilot-chat-in-neovim-copilotchatnvim)
5. [Authentication Setup (Both Plugins)](#authentication-setup-both-plugins)
6. [Verifying the Installation](#verifying-the-installation)
7. [Choosing Between the Two Plugins](#choosing-between-the-two-plugins)

---

## Prerequisites

Both plugins share the same system requirements:

| Requirement | Minimum Version | Check Command |
|---|---|---|
| Neovim | 0.6.0 | `nvim --version` |
| Node.js | 18.0.0 | `node --version` |
| curl or wget | Any recent | `curl --version` |
| Git | Any recent | `git --version` |

**Why Node.js?** The Copilot plugin communicates with the GitHub Copilot API through a Node.js language server agent bundled with the plugin. Neovim itself does not run JavaScript, but the plugin spawns a Node.js subprocess.

**Neovim version note**: Neovim 0.6+ is the minimum, but 0.9+ is strongly recommended for the best experience with `copilot.lua` and `CopilotChat.nvim`. Use the latest stable release when possible.

---

## Option A: copilot.vim (Official, Simpler)

`copilot.vim` is the official GitHub Copilot plugin for Vim and Neovim. It is maintained by GitHub and is the most straightforward way to get Copilot inline suggestions in Neovim.

### Installation with vim-plug

Add to your `init.vim` or `~/.vimrc`:

```vim
call plug#begin()
  Plug 'github/copilot.vim'
call plug#end()
```

Then restart Neovim and run `:PlugInstall`.

### Installation with lazy.nvim (Recommended for Neovim)

Add to your Neovim config (`~/.config/nvim/lua/plugins/copilot.lua` or equivalent):

```lua
return {
  "github/copilot.vim",
  event = "InsertEnter",
}
```

Run `:Lazy sync` to install.

### Installation with packer.nvim

```lua
use { 'github/copilot.vim' }
```

Run `:PackerSync`.

### Authentication

After installation, run:

```vim
:Copilot setup
```

This displays a one-time device code. Open [github.com/login/device](https://github.com/login/device) in a browser, enter the code, and complete the GitHub OAuth flow. See [Authentication Setup](#authentication-setup-both-plugins) for the full step-by-step.

### Default Keybindings

`copilot.vim` sets these bindings by default in insert mode:

| Action | Default Key |
|---|---|
| Accept full suggestion | `Tab` |
| Dismiss suggestion | `Ctrl+]` |
| Next suggestion | `Alt+]` (`<M-]>`) |
| Previous suggestion | `Alt+[` (`<M-[>`) |
| Trigger suggestion manually | (automatic; no manual trigger by default) |

### Remapping the Accept Key

If `Tab` is already used by another plugin (e.g., `nvim-cmp`, `UltiSnips`, `LuaSnip`), disable copilot.vim's Tab map and bind acceptance to a different key:

```vim
" In init.vim

" Disable copilot.vim's default Tab mapping
let g:copilot_no_tab_map = v:true

" Bind Ctrl+J to accept the suggestion
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")

" Alternatively, bind to Ctrl+L:
" imap <silent><script><expr> <C-L> copilot#Accept("\<CR>")
```

### Per-Filetype Configuration

```vim
" Disable Copilot for specific filetypes:
let g:copilot_filetypes = {
  \ 'markdown': v:false,
  \ 'yaml':     v:false,
  \ 'text':     v:false,
  \ '*':        v:true
  \ }
```

### Disabling copilot.vim for Specific Buffers

```vim
" Disable in the current buffer
:Copilot disable

" Re-enable
:Copilot enable

" Check status
:Copilot status
```

### Limitations of copilot.vim

- No Copilot Chat support. Chat is not available within `copilot.vim`; for Chat in Neovim, you need `CopilotChat.nvim` (see below).
- Limited customisation compared to `copilot.lua` — keybindings are set via Vimscript globals rather than a Lua configuration table.
- Panel mode (showing multiple completions at once) is available via `:Copilot panel` but is less polished than the VS Code completions panel.

---

## Option B: copilot.lua (Community, More Customisable)

`copilot.lua` is a community-maintained Lua rewrite of the Copilot plugin by [zbirenbaum](https://github.com/zbirenbaum/copilot.lua). It provides the same inline suggestions as `copilot.vim` but with full Lua configuration, a richer API, and better integration with the Neovim plugin ecosystem.

### Installation with lazy.nvim

```lua
-- ~/.config/nvim/lua/plugins/copilot.lua
return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,  -- ms to wait after last keystroke before requesting a suggestion
        keymap = {
          accept         = "<C-j>",       -- accept the full suggestion
          accept_word    = "<C-Right>",   -- accept the next word
          accept_line    = false,         -- accept the next line (set to a key to enable)
          next           = "<M-]>",       -- next suggestion
          prev           = "<M-[>",       -- previous suggestion
          dismiss        = "<C-]>",       -- dismiss suggestion
        },
      },
      panel = {
        enabled      = true,
        auto_refresh = false,
        layout = {
          position = "bottom",  -- "top", "bottom", "left", "right"
          ratio    = 0.4,
        },
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept    = "<CR>",
          refresh   = "gr",
          open      = "<M-CR>",
        },
      },
      -- Disable Copilot for specific filetypes:
      filetypes = {
        yaml         = false,
        markdown     = false,
        help         = false,
        gitcommit    = false,
        gitrebase    = false,
        hgcommit     = false,
        svn          = false,
        cvs          = false,
        ["."]        = false,  -- disable for unnamed (scratch) buffers
      },
      -- copilot_node_command: path to Node.js executable
      -- Only needed if "node" is not in your PATH:
      -- copilot_node_command = "/usr/local/bin/node",
    },
  },
}
```

### Authentication

`copilot.lua` uses the same authentication command as `copilot.vim`:

```vim
:Copilot auth
```

See [Authentication Setup](#authentication-setup-both-plugins) for the full flow.

### Using copilot.lua's API in Your Config

`copilot.lua` exposes a Lua API that lets you interact with Copilot programmatically:

```lua
local suggestion = require("copilot.suggestion")

-- Accept the full suggestion:
suggestion.accept()

-- Accept word by word:
suggestion.accept_word()

-- Accept line by line:
suggestion.accept_line()

-- Navigate between suggestions:
suggestion.next()
suggestion.prev()

-- Dismiss the current suggestion:
suggestion.dismiss()

-- Check if a suggestion is visible:
suggestion.is_visible()

-- Toggle auto-trigger on/off:
suggestion.toggle_auto_trigger()
```

This API is useful for building conditional keybindings. For example, only accept with `Tab` when a suggestion is visible, otherwise fall through to another plugin:

```lua
vim.keymap.set("i", "<Tab>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    -- Fall through to nvim-cmp or default Tab behaviour:
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Tab>", true, false, true),
      "n", false
    )
  end
end, { desc = "Accept Copilot suggestion or Tab" })
```

### Integration with nvim-cmp

If you use `nvim-cmp` for completion, add `copilot.lua` as a source via `copilot-cmp`:

```lua
-- lazy.nvim
{
  "zbirenbaum/copilot-cmp",
  dependencies = { "zbirenbaum/copilot.lua" },
  config = function()
    require("copilot_cmp").setup()
  end,
}
```

Then add it to your `nvim-cmp` sources:

```lua
sources = cmp.config.sources({
  { name = "copilot", priority = 1000 },
  { name = "nvim_lsp" },
  { name = "luasnip" },
  { name = "buffer" },
})
```

---

## Copilot Chat in Neovim (CopilotChat.nvim)

`copilot.vim` does not include Chat support. `copilot.lua` also does not include Chat natively, but `CopilotChat.nvim` integrates Chat into Neovim when used alongside either plugin.

### Installation with lazy.nvim

```lua
-- ~/.config/nvim/lua/plugins/copilot-chat.lua
return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      "zbirenbaum/copilot.lua",   -- or "github/copilot.vim"
      "nvim-lua/plenary.nvim",
    },
    opts = {
      -- Chat window size and position:
      window = {
        layout = "float",     -- "float", "vertical", "horizontal"
        width  = 0.8,         -- as a fraction of the editor width
        height = 0.7,
        border = "rounded",
      },
      -- Show user and Copilot avatars in the chat:
      show_help = true,
      -- Map for opening the chat:
    },
    keys = {
      {
        "<leader>cc",
        "<cmd>CopilotChat<CR>",
        mode = { "n", "v" },
        desc = "Open Copilot Chat",
      },
      {
        "<leader>ce",
        "<cmd>CopilotChatExplain<CR>",
        mode = "v",
        desc = "Explain selected code",
      },
      {
        "<leader>cf",
        "<cmd>CopilotChatFix<CR>",
        mode = "v",
        desc = "Fix selected code",
      },
      {
        "<leader>ct",
        "<cmd>CopilotChatTests<CR>",
        mode = "v",
        desc = "Generate tests for selection",
      },
    },
  },
}
```

### CopilotChat.nvim Commands

| Command | Description |
|---|---|
| `:CopilotChat` | Open the Chat window |
| `:CopilotChatExplain` | Explain the selected code |
| `:CopilotChatFix` | Fix issues in the selected code |
| `:CopilotChatTests` | Generate tests for the selection |
| `:CopilotChatDocs` | Generate documentation for the selection |
| `:CopilotChatOptimize` | Suggest optimisations for the selection |
| `:CopilotChatClose` | Close the Chat window |
| `:CopilotChatReset` | Clear the Chat history |

**Note**: `CopilotChat.nvim` is a community project and is not officially supported by GitHub. Feature parity with VS Code's Copilot Chat (especially `@workspace`) is limited.

---

## Authentication Setup (Both Plugins)

Both `copilot.vim` and `copilot.lua` use the same authentication mechanism.

### Step-by-Step

1. In Neovim, run:
   ```vim
   :Copilot setup    " for copilot.vim
   :Copilot auth     " for copilot.lua
   ```

2. A device code is displayed in the Neovim message area, e.g.:
   ```
   Your one-time code is: ABCD-1234
   ```

3. Press `Enter` to open the GitHub device activation page in your default browser, or manually navigate to [github.com/login/device](https://github.com/login/device).

4. Enter the device code on the GitHub page.

5. Sign in to GitHub if not already signed in.

6. Click **Authorize GitHub Copilot Plugin**.

7. Switch back to Neovim. The authentication completes automatically, and you will see a confirmation message.

### Where Authentication Tokens Are Stored

The Copilot plugin stores its authentication token at:

```
~/.config/github-copilot/hosts.json      # Linux/macOS
%APPDATA%\GitHub Copilot\hosts.json      # Windows
```

To sign out or force re-authentication, delete this file and run `:Copilot setup` or `:Copilot auth` again.

### Re-authentication After Token Expiry

If the Copilot token expires (after approximately 8 hours of inactivity), Neovim shows an error like `"Not signed in"` or suggestions silently stop appearing. Run `:Copilot status` to check, and `:Copilot setup` / `:Copilot auth` to re-authenticate.

---

## Verifying the Installation

1. Open a new file in a supported language:
   ```vim
   :e /tmp/test.py
   ```

2. Enter insert mode (`i`) and type:
   ```python
   # Calculate the Fibonacci sequence up to n terms
   def fibonacci(
   ```

3. After a brief pause, ghost text should appear suggesting the function signature and body.

4. Press the configured accept key (`Tab` for copilot.vim, `Ctrl+J` or your configured key for copilot.lua).

### Checking Plugin Status

```vim
" For copilot.vim:
:Copilot status

" Expected output:
" Copilot: Enabled and online
```

```lua
-- For copilot.lua, in Neovim command mode:
:lua print(vim.inspect(require("copilot.api").status()))
```

---

## Choosing Between the Two Plugins

| Criteria | copilot.vim | copilot.lua |
|---|---|---|
| Maintenance | GitHub (official) | Community (zbirenbaum) |
| Configuration style | Vimscript globals | Lua opts table |
| Keybinding flexibility | Limited (global vars) | Full Lua API |
| nvim-cmp integration | Possible but manual | First-class via copilot-cmp |
| Chat support | None natively | Via CopilotChat.nvim |
| Neovim minimum | 0.6 | 0.8 recommended |
| Panel (multi-completion view) | `:Copilot panel` | Via copilot.lua panel config |
| Stability | Very stable (GitHub-backed) | Stable, active development |

**Recommendation**: If you want the simplest possible setup with minimal configuration, use `copilot.vim`. If you want a fully Lua-configured Neovim setup, integration with `nvim-cmp`, and Chat support via `CopilotChat.nvim`, use `copilot.lua`.
