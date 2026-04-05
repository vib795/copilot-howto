# Chaining Slash Commands — Multi-Step Workflows

GitHub Copilot slash commands run one per message — there is no `&&` syntax to chain them in a single turn. But because the Chat panel retains conversation history across turns, each command you issue builds on the context established by previous turns. This enables powerful multi-step workflows.

---

## The Core Pattern

```
/explain → understand the code
  ↓
/fix or /simplify → improve the code
  ↓
/tests → verify the improvement
  ↓
/doc → document the final result
```

Each command is a separate chat message, but they share the same session context. Copilot remembers what files were attached, what the code looked like before and after changes, and what errors were discussed in earlier turns.

---

## Workflow 1: Debug a Failing Test

**Scenario:** A test is failing and you do not know why. Use `/explain` to understand the code under test, `/fix` to repair it, and `/tests` to verify the fix did not break other cases.

**Turn 1: Understand the failure.**
```
/explain #file:src/services/discount.service.ts @terminal
The test suite output above shows a failure in the calculateDiscount
method. Explain what the method is supposed to do, and based on the
error message, what you think is going wrong.
```

*Copilot explains: the method applies percentage discounts but the test expects integer rounding behavior that the current floating-point arithmetic does not provide.*

**Turn 2: Fix the root cause.**
```
/fix #file:src/services/discount.service.ts
Based on your explanation above: fix the calculateDiscount method so
that the final discounted price is always rounded down to the nearest
cent (floor, not round). Keep the existing type signatures.
```

*Copilot proposes a diff replacing `Math.round` with `Math.floor`.*

**Turn 3: Verify with tests.**
```
/tests #file:src/services/discount.service.ts
The fix above changed the rounding behavior. Add regression tests
specifically for boundary cases around rounding:
- An amount where round and floor would produce different results (e.g., $10.995 discount)
- A 0% discount
- A 100% discount (should result in $0.00, not -$0.01 due to floating point)
```

**Turn 4: Document the behavior.**
```
/doc #selection
Add a JSDoc comment to calculateDiscount explaining that prices are
floored (not rounded) to the nearest cent, and include a note about
why (to avoid customers being overcharged by rounding errors).
```

---

## Workflow 2: Add a Feature — `/new` → `/doc` → `/tests`

**Scenario:** You need to add a new service class for managing user sessions. You want it scaffolded, documented, and tested before committing.

**Turn 1: Scaffold the feature.**
```
/new
Create a TypeScript service class called SessionService in
src/services/session.service.ts.

It should manage user sessions stored in Redis.
Methods:
- createSession(userId: string, metadata: SessionMetadata): Promise<string>
  → stores the session in Redis with a 24-hour TTL, returns the session token
- getSession(token: string): Promise<Session | null>
  → retrieves session by token, returns null if expired or not found
- invalidateSession(token: string): Promise<void>
  → deletes the session from Redis
- invalidateAllUserSessions(userId: string): Promise<void>
  → deletes all sessions for a given userId (requires a userId → tokens index)

Use ioredis. The Redis client should be injected via the constructor.
Generate a random 32-byte hex token using crypto.randomBytes.
```

**Turn 2: Document the service.**
```
/doc #file:src/services/session.service.ts
Generate full JSDoc for the SessionService class:
- Class-level doc explaining the Redis storage strategy and TTL behavior
- Each method: @param, @returns, @throws (e.g., if Redis is unavailable)
- @example for createSession and getSession showing realistic usage
```

**Turn 3: Generate tests.**
```
/tests #file:src/services/session.service.ts
Generate Jest tests for SessionService. Use jest.mock for ioredis.
Test all four methods including:
- createSession: verify the session is stored with correct TTL and a 64-char hex token is returned
- getSession: test found, expired (returns null), and not found (returns null)
- invalidateSession: verify Redis.del is called with the correct key
- invalidateAllUserSessions: verify all tokens in the user's index are deleted
```

**Turn 4: Review coverage.**
```
Looking at the service implementation in #file:src/services/session.service.ts,
are there any error handling branches not yet covered by the tests?
List any gaps and generate tests for the most important ones.
```

---

## Workflow 3: Refactor a Module — `/explain` → `/simplify` → `/tests`

**Scenario:** You have inherited a complex module. You want to understand it first, simplify it, then verify the refactored version is still correct.

**Turn 1: Understand what you're working with.**
```
/explain #file:src/utils/query-string-parser.ts
Give me a high-level overview of this module. What does it do,
what edge cases does it handle, and what are the most complex parts?
I'm about to refactor it, so I want to know what I should be careful about.
```

*Copilot explains: it's a custom query string parser that handles arrays, nested objects, and URL encoding. The most complex part is the recursive object parsing.*

**Turn 2: Simplify the most complex part.**
```
/simplify #file:src/utils/query-string-parser.ts
Focus on the parseNestedObject function. It currently uses a recursive
approach with manual string splitting. Simplify it — can we replace
it with the URL API or a well-established library? If not, at least
simplify the internal logic using reduce or a cleaner recursive pattern.
Keep the behavior identical: the existing tests in
#file:src/utils/query-string-parser.test.ts must still pass.
```

**Turn 3: Run and check existing tests.**
After accepting the simplification, in your terminal:
```bash
npx jest src/utils/query-string-parser.test.ts
```

If tests fail, paste the output back:
```
/fix @terminal
The refactored parseNestedObject function is failing two tests with
the output above. Fix the issue without reverting to the original approach.
```

**Turn 4: Add tests for edge cases exposed by the refactor.**
```
/tests #file:src/utils/query-string-parser.ts #file:src/utils/query-string-parser.test.ts
Looking at the refactored implementation, are there any new edge cases
the simplified code might handle differently from the original?
Add tests that explicitly cover:
- Empty string values: ?key=
- Keys with no value: ?key
- Deeply nested objects: ?a[b][c]=1
- Array-like keys: ?items[]=a&items[]=b
```

---

## Workflow 4: Security Review Chain

**Scenario:** You need to harden a module before a production release.

**Turn 1: Explain for vulnerabilities.**
```
/explain #file:src/api/auth.controller.ts
Review this authentication controller for security concerns. Look for:
- SQL injection risks
- JWT misconfiguration (weak secrets, missing expiry validation)
- Mass assignment vulnerabilities
- Insufficient input validation
- Missing rate limiting
List all concerns you find, even if minor.
```

**Turn 2: Fix all issues.**
```
/fix #file:src/api/auth.controller.ts
Fix all the security concerns you identified above. Prioritize:
1. SQL injection (use parameterized queries)
2. JWT validation (add expiry check, verify issuer)
3. Input sanitization (strip unexpected fields from req.body)
Do not add rate limiting in this step — that requires middleware changes.
```

**Turn 3: Add security-focused tests.**
```
/tests #file:src/api/auth.controller.ts
Generate security-focused tests:
- Test that a SQL injection attempt in the email field is safely handled
- Test that an expired JWT returns 401
- Test that a JWT with the wrong issuer returns 401
- Test that extra body fields (e.g., isAdmin: true) are ignored and not persisted
```

---

## How Context Carries Across Turns

Understanding what Copilot remembers between turns helps you write better follow-up prompts.

**What carries over:**
- All previous messages in the current Chat panel session
- The content of any `#file` you attached in a previous turn (it is part of the conversation history)
- Code that Copilot generated in a previous turn
- The error messages or terminal output you pasted

**What does NOT carry over:**
- Your current text selection (you must re-select and use `#selection` or attach `#file` again)
- Changes you made to files after attaching them (if you edit a file mid-conversation, re-attach it)
- Context from a previous Chat session (sessions are not persisted between VS Code restarts by default)
- Context from inline chat (inline chat has its own isolated context)

**Practical implication:** If you accept a code change in the middle of a workflow and then want to reference the updated file in the next turn, you need to re-attach it with `#file`. Otherwise Copilot is reasoning about the old version of the file.

```
/fix #file:src/services/session.service.ts
(Re-attaching the file after accepting the previous changes — the version
above now includes the createSession method. Fix the getSession method
so it also validates the session metadata structure.)
```

---

## Tips for Effective Command Chaining

**1. Make each turn focused.**
One command, one clear goal. Avoid combining `/fix` and `/simplify` in the same message unless the simplification IS the fix.

**2. Reference earlier turns explicitly.**
```
Based on the security issues you identified two turns ago, now generate tests...
```
Copilot reads the full conversation, so explicit references to earlier findings help it stay coherent.

**3. Re-attach modified files.**
If you accepted changes to a file during the workflow, re-attach it with `#file` before the next command that needs the updated version.

**4. Use `/clear` to start a fresh workflow.**
When you finish one task and start a new one, use `/clear` to prevent context from the previous task from contaminating the new conversation.

**5. Save important outputs externally.**
There is no persistent chat history across VS Code sessions. If Copilot generated a useful analysis in turn 1, copy it somewhere before you close VS Code.
