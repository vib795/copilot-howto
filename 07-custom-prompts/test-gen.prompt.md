---
mode: edit
model: claude-sonnet-4-5
description: "Generate comprehensive tests with edge cases for the selected code"
---

# Test Generation

Generate tests for the code in `#selection` (or `#file` if nothing is selected). Follow the project's testing conventions from `.github/instructions/testing.instructions.md` if present, otherwise detect the framework from existing tests.

## Detect, don't assume

Before writing any tests, look at one existing test file to determine:

- Test framework (JUnit 5, pytest, Jest, Go testing, RSpec, etc.)
- File naming pattern (`foo.test.ts`, `test_foo.py`, `FooTest.java`)
- Assertion style (`expect(x).toBe(y)` vs `assertEquals(y, x)` vs `assert x == y`)
- Setup / teardown conventions (fixtures, `@BeforeEach`, context managers)
- Mock library, if any

Match the existing style. Do not introduce a new framework.

## Coverage goals

For each public function / method / endpoint, cover:

### Happy paths
- Typical inputs producing typical outputs — at least one case per meaningful branch

### Edge cases
- Empty input (`""`, `[]`, `{}`, `null` if valid)
- Boundary values (min, max, one-off-boundary)
- Unicode / non-ASCII / long strings
- Zero, negative, very large numbers (if numeric)
- Concurrent / ordering (only if the code is concurrent)

### Error paths
- Invalid input → specific exception or error
- Downstream failure (DB error, HTTP 5xx) → graceful handling
- Timeout / cancellation (if async)

## Writing style

- **One assertion per test**, or at minimum one logical concept per test.
- **Test names describe behaviour**: `returns_empty_list_when_filter_matches_nothing`, not `test_1` or `test_filter`.
- **Arrange–Act–Assert** structure, with blank lines or comments separating the sections when it helps.
- **No shared mutable state** between tests unless the framework explicitly isolates them.
- **Fast and deterministic** — no `sleep()`, no real network, no real time-of-day.

## What NOT to do

- Do not test private methods directly if they're reachable through the public API.
- Do not assert internal implementation details (e.g., "called the cache 3 times") unless that's the contract.
- Do not copy-paste 10 near-identical tests; use a parameterised / table-driven pattern if the framework supports it.
- Do not mock things you don't own without a reason — prefer fakes, or integration tests, for your own code.
- Do not silence warnings or catch-all exceptions to make a test pass.

## Output

Apply the edits. End with:

```
Tests added: <N>
Covered: <list of function names>
Framework: <detected framework>
Note: <anything the reviewer should know, e.g. "payment client is mocked; consider contract test">
```
