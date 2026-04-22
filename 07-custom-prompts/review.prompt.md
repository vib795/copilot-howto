---
mode: ask
model: claude-sonnet-4-5
description: "Five-lens PR review with severity-tagged findings and merge recommendation"
---

# Code Review

Review the changes in `#changes` (or `#selection` if something is selected) across these five lenses. Do not skip any lens; say "no findings" if there are none.

## 1. Correctness

- Logic bugs, off-by-one, null / undefined / zero-value handling
- Incorrect async/await or Promise chaining
- Race conditions, unprotected shared state
- Error paths swallowed or rethrown incorrectly
- Assumptions that aren't enforced (e.g., "this list is never empty")

## 2. Security

- Injection (SQL, command, template, prompt)
- AuthN/AuthZ gaps, missing permission checks
- Secrets in code, logs, or commit messages
- Unsafe deserialisation, SSRF, path traversal
- OWASP Top 10 items relevant to the language/stack

## 3. Performance

- N+1 queries, missing indices, per-row DB calls
- Unbounded loops or memory allocations
- Unnecessary synchronous I/O on a hot path
- Algorithmic complexity worse than the input demands

## 4. Style

- Compliance with `.github/instructions/*.instructions.md`
- Naming, formatting, imports, file organisation
- Dead code, commented-out code, TODOs without owners
- Cross-cutting: log levels, error messages, metric names

## 5. Tests

- Is the new/changed logic covered?
- Are edge cases (empty, null, boundary, error) tested?
- Do tests assert behaviour, not implementation?
- Are flaky patterns (sleeps, real time, real network) introduced?

---

## Output format

For each finding, use this exact structure:

```
[severity] file:line
<one-sentence problem>
<suggested fix as a code block>
```

Severity values: `blocker`, `major`, `minor`, `nit`.

End with a summary block:

```
Summary
-------
Blocker: N  Major: N  Minor: N  Nit: N
Merge recommendation: <approve | request changes | block>
Reason: <one sentence>
```

Do not speculate about code outside the diff. If you need the full file for context, say so and request it via `#file:path`.
