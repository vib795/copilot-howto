# Combining Multiple Variables

The real power of Copilot chat variables emerges when you combine them. A single `#file` gives you deep knowledge of one file. `@workspace` gives you broad knowledge of the whole codebase. Combining them — or combining `@terminal` with `#file` — gives you answers that require simultaneous awareness of multiple contexts.

This guide covers the most useful combinations and the anti-patterns to avoid.

---

## The Core Principle

**Use the smallest context that answers your question.**

Every variable you add consumes part of the model's context window. More context is not always better — too much unrelated context dilutes the response quality because the model has to process everything simultaneously. Start minimal, add context only when you need it.

```
// Good starting point — narrow context:
#file:src/auth/jwt.ts is the expiry check correct?

// Add more context only if the narrow prompt isn't enough:
#file:src/auth/jwt.ts #file:src/config/auth.config.ts is the JWT_EXPIRY value from config being applied correctly?
```

---

## Combination 1: @workspace + #file

**Pattern:** Use `@workspace` to get broad codebase awareness, then pin it to a specific file for precise analysis.

**When to use:** When your question requires knowing both the big picture (how the system is designed) and the details of a specific implementation.

### Example: Finding Similar Implementations

```
@workspace #file:src/auth.ts are there other files in the project that implement authentication differently? I want to know if we have inconsistent auth patterns.
```

**What this does:** `@workspace` gives Copilot knowledge of the whole codebase's structure. `#file:src/auth.ts` gives it the exact implementation as a reference. Copilot can then compare the reference against what it knows from the workspace index and identify divergent patterns.

### Example: Impact Analysis with File Anchor

```
@workspace #file:src/models/user.ts if I add a required `timezone` field to this User model, what other files would need to be updated?
```

**What this does:** The `#file` provides the exact model definition (field names, types, validations). `@workspace` provides knowledge of all files that import or use the User model. Together they produce a precise, grounded impact analysis.

### Example: Architecture + Implementation

```
@workspace #file:src/services/payment-service.ts explain where this service fits in the overall architecture. What calls it, and what does it call?
```

---

## Combination 2: @terminal + #file

**Pattern:** Combine terminal error context with the source file that contains the failing code.

**When to use:** When you have a runtime error or failed test and you want Copilot to read both the error output and the code simultaneously.

### Example: Failed Migration

```
I ran the migration but it failed. @terminal #file:migrations/20240315_add_user_timezone.sql what went wrong and how do I fix it?
```

**What this does:** `@terminal` gives Copilot the database error output (e.g., "column already exists", "syntax error at position 47"). `#file` gives it the actual SQL. Copilot can cross-reference the error against the specific SQL statement that caused it.

### Example: Failed Test + Source File

```
@terminal #file:src/services/order-service.ts the test is failing with a null reference error. Looking at the service implementation, where would the null come from?
```

### Example: Build Error + Config File

```
@terminal #file:webpack.config.js the build is failing with a module resolution error. Does the webpack config have the right module aliases set up?
```

---

## Combination 3: Multiple #file

**Pattern:** Attach two to four directly related files when your question genuinely requires seeing all of them.

**When to use:** Cross-file consistency checks, interface conformance, before-and-after comparisons.

### Example: Route + Service + Model Triangle

```
#file:src/routes/orders.ts #file:src/services/order-service.ts #file:src/models/order.ts trace a POST /orders request through all three layers. Are there any type mismatches or validation gaps between layers?
```

**What this does:** Copilot reads all three files and traces data flow end-to-end — from the route's `req.body` parsing, through the service's business logic, to the model's database operations. It can spot issues that are invisible when you look at each file in isolation.

### Example: Comparing V1 and V2

```
#file:src/parsers/csv-v1.ts #file:src/parsers/csv-v2.ts what are the behavioral differences between these two parsers? Are there any edge cases that v1 handled but v2 does not?
```

### Example: Implementation + Test

```
#file:src/utils/currency.ts #file:tests/currency.test.ts looking at both the implementation and the tests, are there any inputs that the tests do not cover that might cause the implementation to fail?
```

---

## Combination 4: #selection + #file

**Pattern:** Select a specific code block from the editor and combine it with the file that the selection depends on.

**When to use:** When you want to ask about a specific function's behavior in the context of the module it imports from.

### Example: Questioning a Specific Call

```
#selection #file:src/lib/db.ts this selected code calls db.transaction() — does it use the transaction correctly according to how the db library defines that method?
```

**How to execute:**
1. Select the function body in the editor
2. Type `#selection #file:src/lib/db.ts` in Copilot Chat
3. Add your question

### Example: Selected Code + Its Type Definitions

```
#selection #file:src/types/api.ts does this selected code correctly handle all the cases defined in the ApiResponse type?
```

---

## Combination 5: @github + #file

**Pattern:** Combine GitHub repository data with local file content.

**When to use:** When you want to compare a PR's description against the actual implementation, or check if an issue's reproduction steps match the code.

### Example: PR vs. Implementation

```
@github #file:src/auth/session.ts PR #89 claims to fix the session fixation vulnerability. Does the implementation in the current file actually address the attack described in the PR?
```

### Example: Issue + Code

```
@github #file:src/services/billing.ts issue #234 reports that refunds are being applied twice. Does this billing service implementation have a race condition that could cause duplicate refunds?
```

---

## Anti-Patterns: What to Avoid

### Anti-Pattern 1: Attaching Too Many Files

```
// Too much — Copilot has to process 6 files simultaneously
#file:src/models/user.ts #file:src/models/order.ts #file:src/models/product.ts
#file:src/services/user-service.ts #file:src/services/order-service.ts
#file:src/routes/api.ts does our API follow REST conventions?
```

**Why it's a problem:** The context window fills with file content, leaving less room for the model's reasoning. The response tends to be shallower, and the most important files may not get the focus they need.

**Better approach:** Use `@workspace` first to find the 1–2 most relevant files, then use `#file` on those.

### Anti-Pattern 2: Using @workspace When #file Is More Precise

```
// Unnecessarily broad for a file-specific question:
@workspace what are the exported functions in src/utils/date-helpers.ts?
```

**Better:**
```
#file:src/utils/date-helpers.ts list all exported functions and their signatures
```

`@workspace` is best for questions that require codebase-wide knowledge. When you already know which file to look in, `#file` is faster, cheaper (fewer tokens), and more focused.

### Anti-Pattern 3: Attaching a File That Is Not Actually Relevant

```
// The test configuration file is not relevant to a logic question:
#file:jest.config.ts #file:src/services/payment.ts does the payment service handle currency conversion correctly?
```

The `jest.config.ts` adds noise without adding value. Only attach files that directly contain information relevant to the question.

### Anti-Pattern 4: Using #terminalLastCommand When Only a Part Is Relevant

```
// If your test output is 500 lines, this attaches all 500 lines:
@terminal #terminalLastCommand what caused the failure?
```

**Better approach for long outputs:**
1. Scroll to the relevant error section in the terminal
2. Select just those lines
3. Use `#terminalSelection` instead:

```
@terminal #terminalSelection what does this specific error mean?
```

---

## Practical Decision Rule

When deciding which variables to use, ask these questions in order:

1. **Do I know exactly which file contains the answer?** → Use `#file`
2. **Is the answer somewhere in the codebase but I'm not sure where?** → Use `@workspace` or `#codebase`
3. **Is the answer in the terminal output?** → Use `@terminal`, `#terminalLastCommand`, or `#terminalSelection`
4. **Do I need both file content AND codebase structure?** → Combine `@workspace + #file`
5. **Do I need file content AND terminal error context?** → Combine `@terminal + #file`
6. **Do I need to compare two files?** → Use `#file:A #file:B`

If the answer is still unclear after one prompt, do not add more variables — refine the question instead. A sharper question with less context usually produces a better answer than a vague question with lots of context.
