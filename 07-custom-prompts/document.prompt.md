---
mode: edit
model: claude-sonnet-4-5
description: "Generate idiomatic docstrings / Javadoc / GoDoc for the selected code"
---

# Document

Add documentation comments to the code in `#selection` (or `#file` if nothing is selected). Detect the language and use its native doc format.

## Style by language

| Language | Format |
|---|---|
| Python | PEP 257 docstrings, Google or Sphinx style — match whatever the file already uses |
| TypeScript / JavaScript | JSDoc with `@param`, `@returns`, `@throws` |
| Java | Javadoc with `@param`, `@return`, `@throws`, `@since` if unclear drop it |
| Go | GoDoc — sentence starting with the identifier name, no parameter tags |
| Rust | `///` doc comments with Markdown, `# Examples` section |
| C# | XML doc `<summary>`, `<param>`, `<returns>`, `<exception>` |
| Ruby | YARD or RDoc — match the project |

If the file already has docs in one style, follow that style — do not mix.

## Per-symbol requirements

**Public functions / methods**:
- One-line summary starting with a verb
- Longer explanation only when behaviour is non-obvious
- Parameters: name, type (if the language doesn't infer), meaning, constraints
- Returns: what and when
- Errors / exceptions: which ones, under what conditions
- Example for anything with non-trivial usage (only if short)

**Public types / classes**:
- What it represents, not how it's implemented
- Key invariants
- Thread-safety or async contract, if relevant

**Private / internal symbols**:
- Only document the non-obvious. No `/** Gets the name */` for a getter called `getName()`.

## What NOT to include

- Do not describe what the code does line-by-line — the code does that.
- Do not restate types that the compiler/typechecker already enforces.
- Do not write "TODO" placeholders for docs you don't know how to fill — ask, or leave undocumented.
- Do not invent edge-case behaviour. If you're not sure whether `null` is valid, read the callers or ask, don't assume.

## Output

Apply the edits directly. End with a one-line summary:

```
Documented: <N> symbols in <file>
Skipped: <M> (reason: <obvious getters / private / unclear contract>)
```
