# Next Edit Suggestions (NES)

Next Edit Suggestions (NES) is a Copilot mode that predicts **where in the current file you will want to make your next edit**, based on a change you just made. Rather than completing code at your cursor, NES watches your edits and proactively surfaces the next logical location — and a suggested change to make there.

---

## Table of Contents

1. [What NES Is](#what-nes-is)
2. [How It Works](#how-it-works)
3. [Use Cases](#use-cases)
4. [How to Enable NES in VS Code](#how-to-enable-nes-in-vs-code)
5. [How to Navigate NES](#how-to-navigate-nes)
6. [Limitations](#limitations)

---

## What NES Is

Traditional Copilot inline suggestions complete code *at* your cursor. NES is different: it reasons about the *consequence* of an edit you just made and identifies another location in the same file where a related change is needed.

Think of it as Copilot saying: "I see you just renamed that parameter — there are three places in this file that reference the old name. Let me take you there and show you what to change."

NES is surfaced as a subtle arrow indicator (→) in the editor gutter, pointing to the next suggested edit location. You can either follow it (press `Tab` to jump and apply) or ignore it (press `Escape` or simply continue editing elsewhere).

**NES is not the same as:**
- Inline ghost text completion at the cursor (the standard Copilot ghost text experience)
- Copilot Chat suggestions
- VS Code's built-in rename refactoring (`F2`), which operates across all files in a workspace

NES is specifically about predicting the *next* edit, not completing the *current* one.

---

## How It Works

After you make an edit — rename a variable, change a function parameter, update a return type — NES analyses the diff between the before and after state. It then scans the rest of the current file for locations that are semantically related to your change and constructs a suggested edit for each.

The flow looks like this:

```
You make an edit (rename, signature change, logic update)
         │
         ▼
NES engine diffs the change and builds context
         │
         ▼
NES scans the current file for related locations
         │
         ▼
Arrow indicator (→) appears in the gutter at the next suggested location
         │
         ▼
You press Tab → cursor jumps to that location, edit is pre-populated as ghost text
         │
         ▼
You press Tab again to accept, or Escape to dismiss
```

The NES indicator appears within a second or two of you stopping your edit. If you make another edit before following the NES arrow, NES re-evaluates from scratch based on the latest change.

---

## Use Cases

### 1. Updating All Call Sites After Changing a Function Signature

You change a function from:

```typescript
function createUser(name: string, email: string): User
```

to:

```typescript
function createUser(name: string, email: string, role: UserRole): User
```

NES identifies every call to `createUser` in the same file and suggests adding the `role` argument. For each call site, it pre-populates a sensible default:

```typescript
// Before (call site):
const admin = createUser("Alice", "alice@example.com");

// NES suggestion at this call site:
const admin = createUser("Alice", "alice@example.com", UserRole.Admin);
```

### 2. Updating Tests After Changing an Implementation

You change the return type of a service method from `boolean` to `{ success: boolean; error?: string }`. In the same file, if there is a test asserting `expect(result).toBe(true)`, NES suggests updating it to `expect(result.success).toBe(true)`.

### 3. Fixing Related Code After Renaming a Variable

You rename `userObj` to `currentUser` throughout a function body. If there are references in the same function that were not captured by your rename (perhaps inside a callback or template literal), NES points to them one by one.

### 4. Keeping Destructuring in Sync

You add a property to an object you are returning:

```typescript
return { id: user.id, name: user.name, email: user.email };
```

Later in the same file, a destructuring line reads:

```typescript
const { id, name } = getUser();
```

NES suggests updating the destructuring to include `email`.

### 5. Aligning Constants and Enum Usage

You add a new value to an enum:

```typescript
enum Status { Active, Inactive, Suspended }
```

A `switch` statement in the same file does not yet handle `Suspended`. NES points to the `switch` and suggests adding the missing `case`.

---

## How to Enable NES in VS Code

NES is controlled by a single VS Code setting:

```json
// settings.json
{
  "github.copilot.nextEditSuggestions.enabled": true
}
```

**Steps:**

1. Open the Command Palette (`Ctrl+Shift+P` / `Cmd+Shift+P`).
2. Type **"Open User Settings (JSON)"** and press Enter.
3. Add the setting above.
4. No reload is required — the setting takes effect immediately.

Alternatively, use the Settings UI:

1. Open Settings (`Ctrl+,`).
2. Search for **"next edit suggestions"**.
3. Check the **GitHub Copilot: Next Edit Suggestions** checkbox.

**Availability note**: NES is a newer feature and may be gated behind VS Code Insiders or a specific Copilot extension version. If the setting does not appear, update the GitHub Copilot and GitHub Copilot Chat extensions to their latest versions.

---

## How to Navigate NES

Once NES is enabled and you have made an edit:

### Seeing the Arrow Indicator

An arrow (`→`) appears in the editor gutter (the column to the left of line numbers, where breakpoints are placed). This arrow points at the line where NES believes your next edit should go.

If there are multiple related locations, after you address the first one, the arrow updates to point to the next location.

### Jumping and Accepting

| Action | Key | Effect |
|---|---|---|
| Jump to NES location and preview edit | `Tab` | Cursor moves to the NES location; ghost text is shown for the suggested edit |
| Accept the suggested edit | `Tab` (second press) | Inserts the ghost text at the NES location |
| Dismiss NES at the current location | `Escape` | Clears the arrow indicator and the preview; Copilot stops suggesting for this edit sequence |
| Ignore NES and continue editing | (just keep typing) | NES will re-evaluate based on your latest edit |

The two-step `Tab` flow (first `Tab` to jump, second `Tab` to accept) means you can preview the NES suggestion before committing. You can also modify the ghost text after jumping before pressing `Tab` to accept — it behaves like ordinary ghost text once the cursor is at the suggested location.

### Multiple NES Locations

If a single edit triggers suggestions at several locations in the file (e.g., renaming a parameter that appears five times), NES queues them. After you accept or dismiss the first suggestion, the arrow moves to the next location. You can work through all of them with repeated `Tab` presses, or press `Escape` at any point to stop following the NES sequence.

---

## Limitations

Understanding NES's current limitations helps set expectations:

### File-Scope Only

NES operates within the boundaries of the **currently open file**. It does not find related edits in other files in your project, even if those files are open in other editor tabs. For cross-file refactoring, use VS Code's **Rename Symbol** (`F2`) or Copilot Chat's `/fix` or `/explain` with `@workspace` context.

### No Semantic Analysis

NES is driven by the language model's understanding of code patterns, not a language server or compiler. This means it can miss some related locations and can occasionally surface false positives — edits that look related but are not actually required by the change you made. Always review NES suggestions before accepting.

### May Suggest Unwanted Edits

NES predicts based on patterns. If your file has code that superficially resembles the change you made but is intentionally different (e.g., an overridden method with the same name), NES may still suggest editing it. Use `Escape` to dismiss suggestions you do not want.

### Not Available in All IDEs

As of early 2026, NES is only available in VS Code. JetBrains, Neovim, and Xcode support standard inline ghost text but not NES. Check the [feature matrix](../09-ide-integration/feature-matrix.md) for the latest status.

### Latency

NES analysis runs after your edit, which means there is a brief delay (typically 500 ms to 2 seconds) before the arrow indicator appears. On very large files (thousands of lines), this delay may be longer.

---

## Relationship to Other Copilot Features

| Feature | Triggered By | Operates On | Multi-file? |
|---|---|---|---|
| Inline ghost text | Typing / manual trigger | Cursor position | No |
| NES | Making an edit | Rest of current file | No |
| Copilot Chat `/fix` | Explicit chat request | Selected code or `@workspace` | Yes (with `@workspace`) |
| Rename Symbol (VS Code built-in) | `F2` | Symbol across workspace | Yes |

NES fills the gap between inline ghost text (which only looks forward from the cursor) and full Copilot Chat refactoring (which requires an explicit prompt). It is designed for the "I just changed one thing and I know I need to update a few related things" workflow that developers encounter dozens of times per day.
