# Copilot Workspace: Real-World Examples

This document walks through five realistic Copilot Workspace scenarios. For each, you will see:
- The issue that triggered the Workspace session
- What Workspace generated as a task specification
- The plan Workspace produced
- What the implementation looked like
- What manual refinements were needed

---

## Example 1: Adding a New REST API Endpoint

### The Issue

```
Title: Add GET /api/v1/users/:id/preferences endpoint

When a user is authenticated, there should be a way to retrieve their
notification and display preferences via the API.

Acceptance criteria:
- [ ] GET /api/v1/users/:id/preferences returns 200 with preferences object
- [ ] Returns 404 if user does not exist
- [ ] Returns 403 if the requesting user is not :id and is not an admin
- [ ] Response shape: { notifications: { email: bool, push: bool }, display: { theme: string, language: string } }
- [ ] Add integration test covering 200, 403, and 404 cases
```

### Workspace Task Specification (Auto-Generated, Then Edited)

Workspace generated:
> Add a GET endpoint for user preferences. The endpoint should be authenticated, enforce ownership or admin access, and return the preferences object.

The developer edited it to add:
> Follow the same controller/service pattern used in `src/api/v1/users.ts`. Use the existing `AuthMiddleware` for authentication and `requireOwnerOrAdmin` for authorization. Add the route to `src/routes/v1/users.routes.ts`.

### The Plan

```
1. Modify src/api/v1/users.ts
   Add getPreferences controller method

2. Modify src/services/UserService.ts
   Add getUserPreferences(userId) method that reads from the database

3. Modify src/routes/v1/users.routes.ts
   Register GET /users/:id/preferences with auth and ownership middleware

4. Modify src/types/api.ts
   Add UserPreferencesResponse interface

5. Add tests/api/v1/users.preferences.test.ts
   Integration tests for 200, 403, and 404 responses
```

### What the Implementation Looked Like

The controller method (generated):

```typescript
// src/api/v1/users.ts
export async function getPreferences(req: Request, res: Response): Promise<void> {
  const userId = parseInt(req.params.id, 10);

  try {
    const prefs = await UserService.getUserPreferences(userId);
    if (!prefs) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    res.status(200).json(prefs);
  } catch (err) {
    logger.error('getPreferences error', { userId, err });
    res.status(500).json({ error: 'Internal server error' });
  }
}
```

The service method (generated):

```typescript
// src/services/UserService.ts
async getUserPreferences(userId: number): Promise<UserPreferencesResponse | null> {
  const user = await db.users.findUnique({
    where: { id: userId },
    select: {
      notificationEmailEnabled: true,
      notificationPushEnabled: true,
      displayTheme: true,
      displayLanguage: true,
    },
  });

  if (!user) return null;

  return {
    notifications: {
      email: user.notificationEmailEnabled,
      push: user.notificationPushEnabled,
    },
    display: {
      theme: user.displayTheme ?? 'light',
      language: user.displayLanguage ?? 'en',
    },
  };
}
```

### Manual Refinements Needed

1. The 403 check was missing in the controller — Workspace added the route with `requireOwnerOrAdmin` middleware but did not verify that the middleware was imported correctly. Needed to check the import.

2. The test file used `supertest` but Workspace used the wrong base URL (`/v1/users` vs `/api/v1/users`). Fixed in the file edit view before creating the PR.

3. The `UserPreferencesResponse` type was added to `api.ts` but also duplicated inline in `UserService.ts`. Removed the duplication.

**Overall verdict:** 80% complete out of the box. The fixes took about 5 minutes.

---

## Example 2: Fixing a Bug from a Stack Trace

### The Issue

```
Title: NullPointerException in OrderProcessor when discount code is expired

Stack trace from production (redacted):
  java.lang.NullPointerException: Cannot invoke method getAmount() on null
    at com.example.shop.OrderProcessor.applyDiscount(OrderProcessor.java:147)
    at com.example.shop.OrderProcessor.calculateTotal(OrderProcessor.java:89)
    at com.example.shop.OrderController.checkout(OrderController.java:203)

Reproduces when:
1. Add items to cart
2. Apply an expired discount code (status = EXPIRED in the DB)
3. Attempt checkout

Root cause hypothesis: getDiscountByCode() returns null for expired codes but
applyDiscount() does not check for null before calling getAmount().
```

### Workspace Task Specification (Auto-Generated)

> Fix the NullPointerException in OrderProcessor.applyDiscount() at line 147. The method does not handle the case where getDiscountByCode() returns null for expired discount codes.

### The Plan

```
1. Modify src/main/java/com/example/shop/OrderProcessor.java
   Add null check in applyDiscount() before calling getAmount()
   Return 0.0 (no discount) if the discount is null

2. Modify src/test/java/com/example/shop/OrderProcessorTest.java
   Add test: applyDiscount with expired code returns 0 discount
   Add test: applyDiscount with valid code applies correct amount
```

### What the Implementation Looked Like

Before (generated by Workspace showing the original):

```java
private BigDecimal applyDiscount(String code, BigDecimal subtotal) {
    Discount discount = discountRepository.getDiscountByCode(code);
    return subtotal.subtract(discount.getAmount());  // NPE here
}
```

After (generated by Workspace):

```java
private BigDecimal applyDiscount(String code, BigDecimal subtotal) {
    if (code == null || code.isBlank()) {
        return subtotal;
    }

    Discount discount = discountRepository.getDiscountByCode(code);

    if (discount == null) {
        logger.warn("Discount code not found or expired: {}", code);
        return subtotal;
    }

    if (discount.getStatus() == DiscountStatus.EXPIRED) {
        logger.info("Expired discount code applied: {}", code);
        return subtotal;
    }

    return subtotal.subtract(discount.getAmount());
}
```

### Manual Refinements Needed

1. The logger call used SLF4J but the class was using `java.util.logging`. Changed to match the existing pattern.

2. The test file imported the wrong test fixtures class. Updated import.

3. Workspace also suggested adding an error response to the controller (to return a user-friendly "discount code has expired" message) — this was a good suggestion that went beyond the issue scope but was accepted as a bonus.

**Overall verdict:** The core fix was correct. Import issues and logger style needed adjustment.

---

## Example 3: Refactoring a Module to Use a New Pattern

### The Issue

```
Title: Refactor UserRepository to use the Repository pattern interface

Currently UserRepository is a concrete class with no interface. This makes
unit testing controllers difficult because we can't mock it.

Goal: Extract an IUserRepository interface and make UserRepository implement it.
Update all usages to depend on IUserRepository rather than UserRepository.

Files to update:
- src/repositories/UserRepository.ts → implement IUserRepository
- src/repositories/IUserRepository.ts → create this file
- src/services/UserService.ts → change constructor to accept IUserRepository
- src/controllers/UserController.ts → no change needed (uses UserService)
- tests/services/UserService.test.ts → mock IUserRepository instead of actual class
- src/container.ts → register IUserRepository binding (using InversifyJS)
```

### Workspace Task Specification (Developer-Edited)

> Extract IUserRepository interface from UserRepository. Update UserService to depend on the interface, not the concrete class. Register the binding in the InversifyJS container in src/container.ts. Follow the same pattern used by IProductRepository (src/repositories/IProductRepository.ts) as a reference.

Adding the reference to `IProductRepository` significantly improved plan quality.

### The Plan

```
1. Create src/repositories/IUserRepository.ts
   Define interface with all public methods from UserRepository

2. Modify src/repositories/UserRepository.ts
   Implement IUserRepository interface

3. Modify src/services/UserService.ts
   Change constructor parameter type from UserRepository to IUserRepository

4. Modify src/container.ts
   Add: container.bind<IUserRepository>(TYPES.IUserRepository).to(UserRepository)

5. Modify tests/services/UserService.test.ts
   Create mock implementation of IUserRepository for tests
```

### What the Implementation Looked Like

The generated interface (mirroring the IProductRepository pattern):

```typescript
// src/repositories/IUserRepository.ts
import { User } from '../models/User';
import { CreateUserDto } from '../dto/CreateUserDto';
import { UpdateUserDto } from '../dto/UpdateUserDto';

export interface IUserRepository {
  findById(id: number): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  findAll(options?: { limit?: number; offset?: number }): Promise<User[]>;
  create(data: CreateUserDto): Promise<User>;
  update(id: number, data: UpdateUserDto): Promise<User | null>;
  delete(id: number): Promise<boolean>;
}
```

### Manual Refinements Needed

1. The `findAll` options interface was missing a `where` clause filter — added manually.

2. The container registration used the wrong symbol key (`TYPES.UserRepository` instead of `TYPES.IUserRepository`) — typo in the generated code.

3. The mock in the test file was a `jest.fn()` stub but didn't match the return types exactly (missing `Promise` wrappers on some methods). Fixed in the file edit view.

**Overall verdict:** The refactoring was structurally correct. The mock generation was the weakest part.

---

## Example 4: Adding Tests to an Undertested Module

### The Issue

```
Title: Add unit tests for PaymentGateway module — currently 0% coverage

The PaymentGateway module (src/gateways/PaymentGateway.ts) has no unit tests.
It handles Stripe integration and is critical path code.

Test cases needed:
- processPayment: success, card declined, network error
- refundPayment: full refund success, partial refund, refund on non-existent charge
- validateCard: valid card, expired card, invalid CVV
- webhookHandler: valid webhook signature, invalid signature, unknown event type

Use Jest with ts-jest. Mock the Stripe SDK using jest.mock('stripe').
Look at tests/gateways/StripeGateway.test.ts for test structure reference.
```

### Workspace Task Specification (Auto-Generated)

> Add comprehensive unit tests for PaymentGateway covering the scenarios listed in the issue. Mock the Stripe SDK. Follow the pattern in the existing StripeGateway test file.

### The Plan

```
1. Create tests/gateways/PaymentGateway.test.ts
   Full test suite with all specified test cases
   Mock stripe using jest.mock
```

### What the Implementation Looked Like

The generated test structure:

```typescript
// tests/gateways/PaymentGateway.test.ts
import { PaymentGateway } from '../../src/gateways/PaymentGateway';
import Stripe from 'stripe';

jest.mock('stripe');
const MockStripe = Stripe as jest.MockedClass<typeof Stripe>;

describe('PaymentGateway', () => {
  let gateway: PaymentGateway;
  let stripeMock: jest.Mocked<Stripe>;

  beforeEach(() => {
    jest.clearAllMocks();
    stripeMock = new MockStripe('test-key') as jest.Mocked<Stripe>;
    gateway = new PaymentGateway('test-key');
  });

  describe('processPayment', () => {
    it('returns success result for valid charge', async () => {
      stripeMock.paymentIntents.create.mockResolvedValue({
        id: 'pi_test_123',
        status: 'succeeded',
        amount: 2000,
      } as Stripe.PaymentIntent);

      const result = await gateway.processPayment({
        amount: 2000,
        currency: 'usd',
        paymentMethod: 'pm_card_visa',
      });

      expect(result.success).toBe(true);
      expect(result.transactionId).toBe('pi_test_123');
    });

    it('returns failure result when card is declined', async () => {
      stripeMock.paymentIntents.create.mockRejectedValue(
        new Stripe.errors.StripeCardError({
          type: 'card_error',
          code: 'card_declined',
          message: 'Your card was declined.',
          param: '',
          doc_url: '',
        })
      );

      const result = await gateway.processPayment({ /* ... */ });

      expect(result.success).toBe(false);
      expect(result.errorCode).toBe('card_declined');
    });

    // ... additional test cases
  });
});
```

### Manual Refinements Needed

1. The `StripeCardError` constructor signature differed from the actual Stripe SDK type — the generated code passed an object but the real constructor takes named parameters. Fixed by referring to the SDK types.

2. Some tests were missing `await` on async assertions. Added.

3. The webhook test cases were incomplete (only tested valid signature, not invalid). Extended those tests manually.

**Overall verdict:** Good structure and coverage for happy-path cases. Error handling tests needed more care. Saved approximately 60% of the test-writing time.

---

## Example 5: Updating Documentation to Match Changed Code

### The Issue

```
Title: Update API documentation — v2 endpoints changed in last sprint

The docs in docs/api/v2/ are out of date after the sprint-23 changes.
Specific outdated sections:

1. docs/api/v2/authentication.md: The token refresh endpoint changed from
   POST /auth/refresh to POST /auth/tokens/refresh
   The response now includes `expires_at` (ISO 8601) instead of `expires_in` (seconds)

2. docs/api/v2/users.md: GET /users now supports `?include=preferences,addresses`
   query parameter (was not documented before)

3. docs/api/v2/pagination.md: We switched from offset/limit to cursor-based
   pagination. All list endpoints now return `next_cursor` and `prev_cursor`
   instead of `total_count` and `page`.

Reference the OpenAPI spec at openapi/v2.yaml for the authoritative source of truth.
```

### Workspace Task Specification (Auto-Generated)

> Update the API documentation files to reflect the v2 endpoint changes. Use the OpenAPI spec (openapi/v2.yaml) as the source of truth.

The developer added:
> Keep the same documentation style and heading structure as the existing files. Do not rewrite sections that are not mentioned in the issue.

### The Plan

```
1. Modify docs/api/v2/authentication.md
   Update endpoint path, update response field documentation

2. Modify docs/api/v2/users.md
   Document the new ?include= query parameter

3. Modify docs/api/v2/pagination.md
   Rewrite pagination section to reflect cursor-based pagination
   Add example showing next_cursor usage
```

### What the Implementation Looked Like

The generated diff for `authentication.md` correctly updated:
- The endpoint path in the description and all code examples
- The response table (added `expires_at`, removed `expires_in`)
- The example request/response JSON blocks

The generated diff for `pagination.md` was thorough — it produced a clear before/after comparison of the two pagination styles with working code examples.

### Manual Refinements Needed

1. Workspace changed a table column header from `Field` to `Property` — stylistic inconsistency with other docs files. Reverted.

2. The `pagination.md` rewrite accidentally removed the section about error handling for invalid cursors — restored from the original.

3. The `users.md` `?include=` documentation listed `addresses` as available but the OpenAPI spec showed it was only available in certain account tiers. Added a note about the tier requirement.

**Overall verdict:** Documentation updates are a strong use case for Workspace. The output was ~90% correct and saved significant manual work.

---

## Summary: When to Use Copilot Workspace

| Task Type | Workspace Fit | Notes |
|-----------|--------------|-------|
| New endpoint following existing pattern | Excellent | Point Workspace to a reference implementation |
| Bug fix with clear reproduction steps | Good | Include the stack trace in the issue |
| Refactoring to a new pattern | Good | Include a reference file that shows the target pattern |
| Adding tests to untested code | Good | Specify test cases explicitly in the issue |
| Updating documentation | Excellent | Reference the source of truth (OpenAPI spec, etc.) |
| Large-scale architecture changes | Poor | Too many files; inconsistent results |
| Changes requiring external access | Not supported | Use Copilot coding agent in Actions instead |
