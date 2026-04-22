# Effective Prompting for Inline Completions

Copilot's inline suggestions are only as good as the context you give it. Because the model cannot read your mind or your entire codebase, the code and comments *surrounding* your cursor are the primary signal it uses to decide what to suggest. This guide covers practical techniques to consistently get high-quality completions.

---

## Table of Contents

1. [Comments as Prompts](#comments-as-prompts)
2. [Comment Style: JSDoc vs. Inline](#comment-style-jsdoc-vs-inline)
3. [Descriptive Variable Names](#descriptive-variable-names)
4. [Imports as Context Signals](#imports-as-context-signals)
5. [Function Signature as a Prompt](#function-signature-as-a-prompt)
6. [Test File Patterns](#test-file-patterns)
7. [Five Practical Examples](#five-practical-examples)
8. [Anti-Patterns to Avoid](#anti-patterns-to-avoid)

---

## Comments as Prompts

The single most reliable technique for getting better Copilot completions is writing a comment that describes what you want *before* you start writing the function.

Copilot treats comments as natural-language prompts embedded in code. A well-written comment gives the model:
- The **intent** of the function (what it should do)
- The **inputs and outputs** (types, formats, constraints)
- The **approach** (algorithm, library, error handling strategy)
- The **edge cases** to handle

**Without a comment:**
```python
def process(items):
    ▌
# Copilot might generate anything: a loop, a filter, a sort —
# it has no way to know what "process" means.
```

**With a descriptive comment:**
```python
# Filter items to only those with a non-zero quantity and a valid SKU,
# then sort by price ascending. Returns an empty list if items is None.
def process(items):
    ▌
# Copilot now generates:
    if not items:
        return []
    valid = [item for item in items if item.quantity > 0 and item.sku]
    return sorted(valid, key=lambda x: x.price)
```

The comment is essentially the spec. The more precise the spec, the more precise the implementation.

---

## Comment Style: JSDoc vs. Inline

Not all comment styles are equally effective. **JSDoc-style block comments** (or their equivalents in other languages) placed *before* a function declaration consistently produce better completions than inline comments or vague single-line descriptions.

### Why JSDoc-Style Comments Work Better

JSDoc-style comments appear in the training data of virtually every open-source JavaScript/TypeScript project, and their equivalents (`"""` docstrings in Python, `///` XML docs in C#, `/** */` in Java) appear throughout open-source code. The model has learned to associate these structured comments with specific function implementations.

Additionally, JSDoc comments include typed parameter and return annotations, which give Copilot precise type information even in languages that don't enforce static types.

### JavaScript / TypeScript (JSDoc)

```typescript
/**
 * Validates a password against the application's strength requirements.
 *
 * @param password - The plaintext password to validate.
 * @returns An object with `valid: boolean` and an array of `errors` describing
 *          which requirements were not met. Returns `{ valid: true, errors: [] }`
 *          if all requirements are satisfied.
 *
 * Requirements:
 * - Minimum 12 characters
 * - At least one uppercase letter
 * - At least one number
 * - At least one special character (!@#$%^&*)
 */
function validatePassword(password: string): { valid: boolean; errors: string[] } {
    ▌
```

Copilot generates a full implementation including all four checks.

### Python (docstring)

```python
def parse_iso_date(date_string: str) -> datetime | None:
    """
    Parse an ISO 8601 date string into a Python datetime object.

    Handles both date-only strings ('2024-01-15') and full datetime strings
    ('2024-01-15T10:30:00Z'). Returns None if the string cannot be parsed
    rather than raising an exception.

    Args:
        date_string: A string in ISO 8601 format.

    Returns:
        A timezone-aware datetime object, or None on parse failure.
    """
    ▌
```

### Inline Comments (Less Effective)

```typescript
function validatePassword(password: string) { // check password
    ▌
// Copilot may still generate a check, but the spec is ambiguous.
// Which requirements? What does it return on failure?
```

Inline comments placed *after* code are the weakest prompt style because they describe code that already exists, rather than specifying code that Copilot should generate.

---

## Descriptive Variable Names

Variable names are part of the context Copilot uses. A variable named `userAccountCreationTimestamp` tells the model far more than one named `t` or `data`. This affects not just the variable's own completions, but every line of code that references it afterward.

### Impact on Suggestions

```javascript
// Generic names → generic, possibly wrong suggestions
const d = await fetch('/api/data');
const r = await d.json();
// Copilot doesn't know what r.??? fields to access

// Descriptive names → accurate, domain-specific suggestions
const productCatalogResponse = await fetch('/api/products');
const productCatalog = await productCatalogResponse.json();
// Copilot now knows to suggest productCatalog.items, productCatalog.totalCount, etc.
```

### Naming Conventions That Help

- **camelCase with clear semantics**: `userAccessToken`, `invoiceLineItems`, `maxRetryCount`
- **Type-indicating names**: `userIds` (array), `userById` (map/object), `isLoading` (boolean), `onSubmit` (callback)
- **Domain-specific vocabulary**: Use the same terminology as your domain model. If your domain calls it an `invoice` not a `bill`, use `invoice` consistently — Copilot will suggest methods and properties consistent with the domain language it has learned.

### Avoid Abbreviations That Lose Semantics

| Less Effective | More Effective |
|---|---|
| `usr` | `currentUser` |
| `cfg` | `databaseConfig` |
| `cb` | `onPaymentSuccess` |
| `temp` | `temporaryAuthToken` |
| `arr` | `filteredProductIds` |
| `n` | `totalPageCount` |

This is not about code style purism — it is about giving the model enough signal to generate code that actually fits your intent.

---

## Imports as Context Signals

The imports at the top of a file are powerful context signals. Copilot reads them to determine which libraries, frameworks, and utilities are available, and adjusts suggestions accordingly.

### Example: HTTP Library Choice

```typescript
// File A: uses axios
import axios from 'axios';

async function getUser(id: string) {
    ▌
// Copilot suggests: return (await axios.get(`/users/${id}`)).data;
```

```typescript
// File B: uses native fetch
// (no axios import)

async function getUser(id: string) {
    ▌
// Copilot suggests: const res = await fetch(`/users/${id}`); return res.json();
```

Same function signature, different implementation — driven entirely by the import context.

### Practical Technique: Add Imports Before Writing the Function

If you know you want to use a specific library, add its import *before* writing the function body, even if your IDE would normally add it automatically afterward. This ensures Copilot sees the import as context when generating the implementation.

```python
# Add the import first:
import re
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

# Now write the function — Copilot knows to use re, datetime, and zoneinfo:
def normalize_timestamp(raw: str, target_tz: str) -> str:
    ▌
```

### Framework Detection

Copilot uses imports to detect frameworks and suggest idiomatic patterns:

```python
# Django detected:
from django.db import models
from django.contrib.auth.models import User

class Post(models.Model):
    ▌
# Copilot suggests Django ORM fields, not SQLAlchemy or raw SQL
```

```python
# SQLAlchemy detected:
from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import DeclarativeBase

class Post(DeclarativeBase):
    ▌
# Copilot suggests SQLAlchemy column definitions
```

---

## Function Signature as a Prompt

A carefully written function signature — with meaningful parameter names and accurate type annotations — acts as a detailed prompt even without any comments.

### Parameters Names Drive Suggestions

```typescript
// Minimal parameter names:
function transform(a: string, b: number, c: boolean): string {
    ▌
// Copilot doesn't know what transformation to perform.

// Descriptive parameter names:
function truncateWithEllipsis(text: string, maxLength: number, breakAtWord: boolean): string {
    ▌
// Copilot generates: logic to truncate at maxLength, optionally at word boundaries,
// and append "..." — because the parameter names describe the algorithm.
```

### Return Type as Constraint

Specifying the return type narrows what Copilot can suggest. This is especially useful for TypeScript and other statically typed languages:

```typescript
interface PaginatedResult<T> {
    items: T[];
    totalCount: number;
    page: number;
    pageSize: number;
    hasNextPage: boolean;
}

async function fetchOrders(
    customerId: string,
    page: number,
    pageSize: number
): Promise<PaginatedResult<Order>> {
    ▌
// Copilot generates a full implementation that constructs and returns a PaginatedResult<Order>
```

### Overload Signatures in TypeScript

Providing overload signatures before the implementation function is an extremely effective technique — Copilot can infer the full dispatch logic from the overloads:

```typescript
function formatDate(date: Date): string;
function formatDate(date: string): string;
function formatDate(date: Date | string): string {
    ▌
// Copilot generates: if (date instanceof Date) ... else ...
```

---

## Test File Patterns

Test files are one of the best scenarios for Copilot completions because test structure is highly regular and the model has been trained on enormous amounts of test code.

### Starting a Test Suite

Write the `describe` block with a meaningful name. Copilot uses the subject name to look up the corresponding source class/module (especially if it's in an open tab) and suggests test cases based on the public interface:

```typescript
// userService.test.ts — with UserService open in another tab

import { UserService } from './userService';

describe('UserService', () => {
    ▌
// Copilot suggests: beforeEach with mock setup, then individual it() blocks
// for each method on UserService
```

### Naming the `it` Block

The description in `it('should...')` is the most precise prompt for a test body. Be specific:

```typescript
it('should return null when the user does not exist', () => {
    ▌
// Copilot generates: a test that calls getUser with a non-existent ID and asserts null
```

vs.

```typescript
it('handles missing users', () => {
    ▌
// Vaguer — Copilot may still guess correctly, but the suggestion is less reliable
```

### Repeating Patterns for Multiple Test Cases

After writing one test case manually, subsequent `it` blocks benefit from the pattern Copilot has seen:

```typescript
describe('InputValidator', () => {
    it('should return true for a valid email address', () => {
        expect(InputValidator.isValidEmail('user@example.com')).toBe(true);
    });

    it('should return false for an email missing the @ symbol', () => {
        ▌
// Copilot completes: expect(InputValidator.isValidEmail('userexample.com')).toBe(false);
    });

    it('should return false for an email with no domain', () => {
        ▌
// Copilot completes: expect(InputValidator.isValidEmail('user@')).toBe(false);
    });
```

---

## Five Practical Examples

### Example 1: Comment → Implementation (Python)

**You write:**
```python
# Using the Stripe API, create a payment intent for the given amount and currency.
# amount is in the smallest currency unit (e.g. cents for USD).
# Returns the client_secret from the PaymentIntent object.
# Raises stripe.error.StripeError on failure.
def create_payment_intent(amount: int, currency: str, customer_id: str) -> str:
    ▌
```

**Copilot generates:**
```python
def create_payment_intent(amount: int, currency: str, customer_id: str) -> str:
    intent = stripe.PaymentIntent.create(
        amount=amount,
        currency=currency,
        customer=customer_id,
        automatic_payment_methods={"enabled": True},
    )
    return intent.client_secret
```

---

### Example 2: JSDoc → TypeScript Implementation

**You write:**
```typescript
/**
 * Retries an async function up to `maxAttempts` times with exponential backoff.
 *
 * @param fn - The async function to retry.
 * @param maxAttempts - Maximum number of attempts (including the first). Default: 3.
 * @param baseDelayMs - Initial delay in milliseconds before the first retry. Default: 200.
 * @returns The resolved value of `fn` on success.
 * @throws The last error thrown by `fn` if all attempts fail.
 */
async function withRetry<T>(
    fn: () => Promise<T>,
    maxAttempts = 3,
    baseDelayMs = 200
): Promise<T> {
    ▌
```

**Copilot generates:**
```typescript
    let lastError: unknown;
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error;
            if (attempt < maxAttempts) {
                const delay = baseDelayMs * Math.pow(2, attempt - 1);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }
    throw lastError;
}
```

---

### Example 3: Signature + Imports → Go HTTP Handler

**You write:**
```go
package main

import (
    "encoding/json"
    "net/http"
    "github.com/go-chi/chi/v5"
)

// GetUserHandler returns an http.HandlerFunc that retrieves a user by ID
// from the UserService and writes JSON. Returns 404 if not found, 500 on error.
func GetUserHandler(svc *UserService) http.HandlerFunc {
    ▌
```

**Copilot generates:**
```go
    return func(w http.ResponseWriter, r *http.Request) {
        id := chi.URLParam(r, "id")
        user, err := svc.GetByID(r.Context(), id)
        if err != nil {
            http.Error(w, "internal server error", http.StatusInternalServerError)
            return
        }
        if user == nil {
            http.Error(w, "user not found", http.StatusNotFound)
            return
        }
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(user)
    }
}
```

---

### Example 4: Test Description → Test Body (Jest + React Testing Library)

**You write:**
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
    it('should display a validation error when the email field is left empty and the form is submitted', () => {
        ▌
```

**Copilot generates:**
```typescript
        render(<LoginForm onSubmit={jest.fn()} />);
        fireEvent.click(screen.getByRole('button', { name: /sign in/i }));
        expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    });
```

---

### Example 5: SQL Comment → Query

**You write:**
```sql
-- Find all customers who placed at least 3 orders in the last 90 days,
-- along with the total value of those orders, ordered by total value descending.
SELECT
    ▌
```

**Copilot generates:**
```sql
SELECT
    c.id,
    c.name,
    c.email,
    COUNT(o.id) AS order_count,
    SUM(o.total_amount) AS total_value
FROM customers c
JOIN orders o ON o.customer_id = c.id
WHERE o.created_at >= NOW() - INTERVAL '90 days'
GROUP BY c.id, c.name, c.email
HAVING COUNT(o.id) >= 3
ORDER BY total_value DESC;
```

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Produces Poor Suggestions | Better Alternative |
|---|---|---|
| Single-letter variable names (`x`, `n`, `i` outside loops) | No semantic signal; Copilot generates generic code | Use `pageIndex`, `userCount`, `productId` |
| Generic container names (`data`, `result`, `response`, `temp`) | No domain signal; Copilot cannot infer the shape | Use `invoiceList`, `authTokenResponse`, `parsedConfig` |
| Vague function names (`process`, `handle`, `do_stuff`) | Copilot cannot infer intent from the name | Use `processPaymentRefund`, `handleUserSessionExpiry` |
| No imports before writing domain-specific code | Copilot doesn't know which libraries to use | Add imports first, then write the function |
| Very long functions (300+ lines) | Copilot's context window is finite; distant code loses influence | Break functions into smaller units |
| Inconsistent naming in the same file | Mixed signals confuse the model | Pick a convention (e.g., `Id` vs `ID`) and stick to it |
| Commented-out code left in place | Stale code creates conflicting context | Remove or archive commented-out code |
| Mixing languages in a single file without clear delineation | Language detection becomes ambiguous | Use template literals, HEREDOCS, or separate files |

### The Descriptive Name Dividend

Investing in clear, descriptive names pays dividends beyond Copilot completions: it improves code review, makes the codebase searchable, and reduces onboarding time for new developers. Copilot's suggestions are a side-effect of good naming discipline — not a reason to adopt it, but a confirmation that it works.
