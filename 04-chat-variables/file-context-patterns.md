# Effective #file Patterns

`#file` is the most precise context variable in Copilot Chat. It reads a specific file and injects its full content into your prompt, giving Copilot exact, line-level knowledge of your code. Unlike `@workspace` (which summarizes the codebase), `#file` provides the raw source — every line, every comment, every import.

This makes it the right tool when you know exactly what you want to analyze.

---

## How to Attach a File

**Typing the path directly:**
```
#file:src/auth/jwt.ts explain this module
```

**Using the picker:** Type `#file` in the chat input and press Tab or Enter to open a file picker. Navigate to the file and select it. Copilot inserts the full file path for you.

**Dragging from the Explorer panel:** Drag a file from the VS Code Explorer sidebar into the chat input. Copilot converts it to a `#file` reference automatically.

---

## Pattern 1: Single-File Security Analysis

**Scenario:** You have a JWT implementation and want a focused security review of that one file.

```
#file:src/auth/jwt.ts identify security issues in this JWT implementation. Focus on: token verification, secret management, expiry handling, and algorithm selection.
```

**What Copilot does:** Reads the entire file and flags issues specific to the code — not generic JWT advice, but observations about your actual implementation: "Line 23 uses `jwt.decode()` instead of `jwt.verify()`, which skips signature validation."

**Variation — auditing a route handler:**
```
#file:src/routes/admin.ts are there any authorization checks missing on these admin endpoints? Each endpoint should verify the user has the ADMIN role.
```

**Variation — reviewing a database model:**
```
#file:src/models/payment.ts does this Sequelize model have proper field-level validation? Check for missing length constraints and type coercions.
```

---

## Pattern 2: Multi-File Context — Route Layer and Model Together

**Scenario:** You want to understand how a route handler uses the User model, but the route and model are in different files.

```
#file:src/models/user.ts #file:src/routes/users.ts how does the route layer use the User model? Is it calling any methods that do not exist on the model?
```

**What Copilot does:** Reads both files and compares them. It can spot mismatches — routes calling `user.deactivate()` when the model only has `user.setActive(false)` — that would only be visible by reading both files together.

**Variation — service + model:**
```
#file:src/models/order.ts #file:src/services/order-service.ts does the service correctly handle the Order model's lifecycle? Is it calling save() after mutations?
```

**Variation — controller + DTO:**
```
#file:src/dto/create-user.dto.ts #file:src/controllers/users.controller.ts does the controller validate the incoming request against the DTO before passing it to the service?
```

---

## Pattern 3: Interface Conformance Check

**Scenario:** You have a TypeScript interface that a service is supposed to implement. You want to verify the implementation is correct.

```
#file:src/types.ts #file:src/services/payment.ts does the PaymentService class correctly implement the IPaymentService interface defined in types.ts? List any missing methods or incorrect return types.
```

**What Copilot does:** Reads the interface definition from `types.ts` and checks every method signature against the implementation in `payment.ts`. It reports mismatches, missing methods, and type inconsistencies.

**Variation — checking a mock against an interface:**
```
#file:src/types.ts #file:tests/mocks/payment.mock.ts does the mock PaymentService implement all the methods declared in IPaymentService? Are the return types compatible with the real implementation?
```

---

## Pattern 4: Comparing Two Versions of a File

**Scenario:** You want to understand what changed between the old and new version of a parser — without reading a long git diff.

```
#file:src/v1/parser.ts #file:src/v2/parser.ts what changed between these two versions? Focus on behavioral differences, not just syntax. Are there any new edge cases handled in v2 that v1 missed?
```

**What Copilot does:** Reads both files and provides a semantic diff — describing what the code does differently, not just listing changed lines. It might say "v2 adds handling for null inputs that would have thrown in v1" or "the tokenization algorithm was changed from recursive to iterative."

**Variation — comparing test coverage between versions:**
```
#file:tests/v1/parser.test.ts #file:tests/v2/parser.test.ts did the test coverage improve in v2? Are there test cases in v1 that are missing in v2?
```

---

## Pattern 5: Spec Conformance — Does the Code Match the Documentation?

**Scenario:** You have an API specification in a Markdown or YAML file and want to verify the implementation matches it.

```
#file:docs/api-spec.md #file:src/routes/api.ts does this implementation match the API spec? List any endpoints that are in the spec but not implemented, and any implementations that deviate from the specified request/response format.
```

**What Copilot does:** Reads both files and cross-references every endpoint. It will catch: missing endpoints, wrong HTTP methods, incorrect response shapes, and undocumented endpoints.

**Variation — OpenAPI spec:**
```
#file:openapi.yaml #file:src/controllers/users.controller.ts does the users controller implement all the operations defined in the OpenAPI spec for /users and /users/{id}?
```

**Variation — checking error codes:**
```
#file:docs/error-codes.md #file:src/middleware/error-handler.ts does our error handler return the error codes documented in error-codes.md? Are there any documented codes that the handler never produces?
```

---

## Pattern 6: Code Review for a Specific Concern

**Scenario:** You are reviewing a PR and want to check a specific concern — not a full review, just one dimension.

```
#file:src/services/billing.ts are there any places in this file where we are not handling the case where a Stripe API call fails? I want to make sure every Stripe call has error handling that prevents silent failures.
```

**What Copilot does:** Reads the file and maps out every Stripe SDK call, checking whether each has appropriate error handling (try/catch, `.catch()`, or explicit error status checking).

**Variation — checking idempotency:**
```
#file:src/workers/email-sender.ts is this worker idempotent? If it crashes and restarts midway through sending an email batch, could it send duplicate emails?
```

---

## Pattern 7: Generating Tests for an Existing File

**Scenario:** You want Copilot to generate a complete test file for a module you just wrote.

```
#file:src/utils/date-helpers.ts write a comprehensive test suite for these utility functions using Jest. Cover: happy path, edge cases (null, undefined, invalid dates), and boundary conditions (leap years, timezone handling).
```

**What Copilot does:** Reads every exported function in the file, infers the expected behavior from the implementation, and generates a test file with named test cases. The tests reference the actual function signatures from your file, so they are ready to run (or nearly so).

**Variation — testing error paths:**
```
#file:src/services/user-service.ts generate tests specifically for the error paths in this service. What happens when the database is unreachable? When a user is not found? When a duplicate email is inserted?
```

---

## Pattern 8: Explaining an Unfamiliar File

**Scenario:** You are new to a repository and encounter a complex file you have never seen before.

```
#file:src/core/event-bus.ts explain how this event bus works. What is the publish/subscribe pattern it implements? How do other parts of the application use it?
```

**What Copilot does:** Reads the file and produces a plain-language explanation of the design pattern, the public API, and the intended usage — like having a senior engineer walk you through it.

**Variation — understanding a complex regex or algorithm:**
```
#file:src/parsers/markdown.ts explain the tokenizer in this file. What states does the parser move through, and how does it handle edge cases like nested formatting?
```

---

## Tips for Better #file Results

**Be specific about what you are looking for.** Attaching a file without a question produces generic summaries. Adding a focused question produces actionable analysis.

```
// Too generic:
#file:src/auth/session.ts tell me about this file

// Focused — produces actionable output:
#file:src/auth/session.ts does this session management implementation protect against session fixation attacks? Specifically, does it regenerate the session ID after login?
```

**Attach the files that are actually relevant.** Attaching too many unrelated files dilutes the response quality. Copilot will try to incorporate everything, which can produce unfocused answers.

```
// Good — directly related files:
#file:src/models/invoice.ts #file:src/services/invoice-service.ts

// Not ideal — too many files, not all equally relevant:
#file:src/models/invoice.ts #file:src/models/user.ts #file:src/models/order.ts #file:src/services/invoice-service.ts #file:src/routes/invoices.ts
```

**The practical limit is 2–4 files per prompt.** Beyond that, the context window fills up with file content, leaving less room for the model's reasoning. Use `@workspace` first to find the right 1–2 files, then use `#file` on those.

**Use `#selection` for intra-file focus.** If you only care about one function in a large file, select just that function and use `#selection` instead of `#file`. This uses far fewer tokens and keeps the focus tight.

**Reference line numbers in your question when you know them.** "The function on line 47" is more precise than "the function that handles payments."
