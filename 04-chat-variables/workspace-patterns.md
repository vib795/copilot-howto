# Effective @workspace Patterns

`@workspace` is the most powerful general-purpose context variable in Copilot Chat. It instructs Copilot to build a semantic index of your entire codebase before answering, enabling questions that span multiple files, directories, and architectural layers.

This guide covers 10 practical patterns with realistic prompts you can adapt to your own projects.

---

## When to Use @workspace

`@workspace` is the right choice when:

- You are asking a question whose answer might live in **any file** in the project
- You want to understand **relationships between parts** of the codebase
- You are new to a codebase and want a high-level orientation
- You are doing **impact analysis** before making a change

Prefer `#file` over `@workspace` when:
- You already know exactly which file is relevant
- You want to analyze a specific function or class in depth
- You want to maximize token efficiency (a targeted `#file` uses fewer tokens than @workspace)

---

## Pattern 1: Finding Where a Feature Is Implemented

**Scenario:** You are debugging a JWT refresh token issue but do not know which file handles token refresh.

```
@workspace where does the application handle JWT refresh tokens? Show me the file path and the function signature.
```

**What Copilot does:** Searches the semantic index for files mentioning JWT, refresh, token expiry, and related symbols. Returns a direct answer like: "Token refresh is handled in `src/auth/middleware.ts`, in the `refreshAccessToken` function on line 47."

**Variation — finding a specific error code:**
```
@workspace where does the code return a 403 Forbidden response? List all the locations.
```

**Variation — finding a configuration value:**
```
@workspace where is the database connection pool size configured? Is it in code or an environment variable?
```

---

## Pattern 2: Understanding Module Relationships

**Scenario:** You are onboarding and want to understand data flow through the application before modifying anything.

```
@workspace explain how data flows from an incoming HTTP request to the database. Walk through the layers: routing, middleware, service, repository.
```

**What Copilot does:** Traces the call chain through the codebase, identifies the architectural layers, and describes how each passes data to the next — effectively doing a code walk-through without you needing to read every file.

**Variation — understanding a specific subsystem:**
```
@workspace how does the notification system work? When is a notification created, who creates it, and how is it sent to the user?
```

**Variation — understanding dependency injection:**
```
@workspace how does this application do dependency injection? Is there a DI container or is it manual?
```

---

## Pattern 3: Finding Async Error Handling Gaps

**Scenario:** You want to find places in the codebase where async errors might be swallowed or unhandled before a production incident exposes them.

```
@workspace are there any places where we're not handling async errors? Look for async functions without try/catch and promise chains without .catch().
```

**What Copilot does:** Scans for `async function` declarations and arrow functions, identifies which ones lack error handling, and reports the file paths and approximate line numbers.

**Variation — finding unhandled rejections:**
```
@workspace find all places where we call async functions without awaiting them. These are potential fire-and-forget bugs.
```

**Variation — finding empty catch blocks:**
```
@workspace are there any catch blocks that swallow errors silently (empty catch or catch that only does nothing)?
```

---

## Pattern 4: Onboarding — Understanding Entry Points

**Scenario:** You just cloned an unfamiliar repository and want to understand where to start reading.

```
@workspace what are the main entry points to this application? How does it start up, what does it initialize, and where does request handling begin?
```

**What Copilot does:** Identifies files like `index.js`, `main.ts`, `app.py`, or `server.go`, describes what each does during startup, and explains the initialization order.

**Variation — understanding the folder structure:**
```
@workspace explain the folder structure of this project. What does each top-level directory contain and what is the naming convention for files?
```

**Variation — finding the configuration system:**
```
@workspace how does this application load configuration? Is it environment variables, config files, a secrets manager, or a combination?
```

---

## Pattern 5: Impact Analysis Before a Change

**Scenario:** You are about to change the `User` model's `email` field (rename it or change its type) and want to know what will break.

```
@workspace if I change the User model's email field from a plain string to an object with { value: string, verified: boolean }, what other code would I need to update?
```

**What Copilot does:** Finds every file that reads or writes `user.email`, `User.email`, and related patterns — route handlers, tests, email templates, validation schemas — and lists them with file paths.

**Variation — API change impact:**
```
@workspace if I remove the /api/v1/users/:id/profile endpoint, what client code would break? Are there any internal callers?
```

**Variation — environment variable rename:**
```
@workspace which parts of the codebase reference the DATABASE_URL environment variable? I need to rename it to DB_CONNECTION_STRING.
```

---

## Pattern 6: Finding Test Coverage Gaps

**Scenario:** You want a quick audit of which modules have no tests before writing a sprint worth of tests.

```
@workspace which modules or services have no corresponding test files? List them by directory.
```

**What Copilot does:** Compares the list of source files against test files (matching by naming conventions like `*.test.ts`, `*.spec.js`, `_test.go`), and reports files with no obvious test counterpart.

**Variation — finding untested public functions:**
```
@workspace are there any exported functions in src/services/ that are not referenced in any test file?
```

**Variation — finding integration test gaps:**
```
@workspace do we have integration tests for the payment flow? Or only unit tests?
```

---

## Pattern 7: Finding Duplicate or Inconsistent Implementations

**Scenario:** You suspect the team has independently implemented the same utility function in multiple places and want to consolidate.

```
@workspace are there any utility functions that appear to be implemented more than once across different files? For example, date formatting, string truncation, or pagination helpers.
```

**What Copilot does:** Identifies semantically similar functions with different implementations and lists where each lives, giving you a consolidation target.

**Variation — finding inconsistent patterns:**
```
@workspace are there multiple ways we handle database errors in the codebase? I want to standardize on one approach.
```

**Variation — finding API inconsistency:**
```
@workspace do all our REST endpoints follow the same response format? Some might return { data: [...] } and others return the array directly.
```

---

## Pattern 8: Understanding Third-Party Integration Points

**Scenario:** You are switching email providers and want to understand every place the current email service is used.

```
@workspace where does the application integrate with SendGrid? List all the files that import or call SendGrid APIs.
```

**What Copilot does:** Finds all imports of the SendGrid SDK, all files that use it, and describes what each integration point does — making it easy to estimate the migration effort.

**Variation — dependency audit:**
```
@workspace which third-party services does this application depend on at runtime? Databases, caches, message queues, external APIs?
```

**Variation — SDK usage:**
```
@workspace how do we use the AWS SDK? What services do we call (S3, SQS, DynamoDB)?
```

---

## Pattern 9: Security Audit

**Scenario:** You want a quick security scan of patterns that commonly lead to vulnerabilities — without running a separate tool.

```
@workspace are there any places where user input is used in SQL queries without parameterization? Also look for eval() usage and hardcoded secrets.
```

**What Copilot does:** Scans for common vulnerability patterns and reports file paths. Note: this is not a replacement for a dedicated security scanner (like Semgrep or Snyk), but it is a fast first pass.

**Variation — authentication checks:**
```
@workspace do all our API endpoints have authentication middleware? Or are some endpoints accessible without a valid token?
```

**Variation — sensitive data handling:**
```
@workspace does the application log any sensitive fields like passwords, tokens, or credit card numbers?
```

---

## Pattern 10: Preparing a Technical Specification

**Scenario:** You are writing a tech spec for a new feature and want Copilot to help you understand what already exists before you design the new parts.

```
@workspace I'm adding a feature to let users export their data as a CSV. Before I design it, tell me: how does the application currently handle file downloads? Is there a pattern I should follow?
```

**What Copilot does:** Finds any existing file-serving or download endpoints, describes the pattern used, and helps you understand whether you are building on existing infrastructure or starting fresh.

**Variation — researching a library the project uses:**
```
@workspace this project uses Prisma. How is it configured and what patterns do we use for transactions?
```

---

## Tips for Better @workspace Results

**Ask specific questions, not broad ones.** The more specific you are, the more targeted the answer.

```
// Too broad — likely to produce a generic answer:
@workspace how does auth work?

// Specific — Copilot can point to exact code:
@workspace what function validates the Bearer token in the Authorization header, and where is it used as middleware?
```

**Use @workspace for navigation, #file for deep analysis.** @workspace tells you where something is; `#file` lets you reason about the details.

```
// Step 1: Find the file
@workspace which file handles password reset?

// Step 2: Analyze it
#file:src/auth/password-reset.ts are there any security issues in the token expiry logic?
```

**Combine @workspace with a hypothesis.** Giving Copilot a starting hypothesis produces more useful answers.

```
@workspace I think the application has a race condition in the order fulfillment flow. The problem is that two requests can both read stock count=1 and both decrement it. Can you find the relevant code and confirm or deny this?
```

**Use @workspace for "is there a..." questions.**

```
@workspace is there already a utility function for parsing environment variables with type coercion, or do we do that inline everywhere?
```
