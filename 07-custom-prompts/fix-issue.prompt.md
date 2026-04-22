---
mode: edit
model: claude-sonnet-4-5
description: "Root-cause diagnosis + minimal fix + regression test for the bug at hand"
---

# Fix Issue

You are fixing a concrete bug. Work with whatever context I've attached — typically `#selection` (the buggy code), `#terminalLastCommand` (the failing command/output), and `#file:<path>` (surrounding module).

## Process

1. **Diagnose root cause.** Do not guess. Re-read the failing output and the code carefully. State, in one sentence, what is actually wrong. Distinguish root cause from symptom.

2. **Propose the minimal fix.** The smallest change that makes the failing case pass without changing unrelated behaviour. No drive-by refactors, no renaming, no "while we're here" cleanup.

3. **Apply the fix** as an edit — show the exact before/after in the diff.

4. **Add a regression test** that fails against the old code and passes against the new. Put it next to the existing tests (follow `.github/instructions/testing.instructions.md` if present). Name the test after the bug, not the code.

5. **Verify.** If you have access to `run_terminal_command`, run the test and the broader suite. Report the result.

## What NOT to do

- Do not catch the exception silently to make the symptom disappear.
- Do not add `try/except` or `if not None:` guards around the whole area — narrow them to the actual invariant that was violated.
- Do not rewrite the function "more cleanly" unless the rewrite is the fix.
- Do not add comments explaining the fix ("# Fixed bug where..."). The commit message and test name carry that context.
- Do not change the public API of a function to accommodate the fix without calling it out explicitly.

## Output

End with a one-paragraph summary:

```
Root cause: <one sentence>
Fix: <one sentence>
Test: <name of the regression test>
Risk: <anything else the reviewer should know — "none" is a valid answer>
```
