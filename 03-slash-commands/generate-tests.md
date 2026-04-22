# `/tests` — Practical Examples

The `/tests` command generates test code for selected functions, classes, or modules. The more context you provide — the testing framework, coverage requirements, and which edge cases matter — the more useful the output will be.

---

## Example 1: `/tests` on a Pure Function

**Scenario:** You have a utility function with no side effects. Pure functions are the easiest to test and the best starting point for learning the `/tests` workflow.

**The function (selected in editor):**
```typescript
/**
 * Formats a number as a currency string.
 * @param amount - The amount in minor units (cents)
 * @param currency - ISO 4217 currency code (e.g. 'USD', 'EUR')
 * @param locale - BCP 47 locale tag (e.g. 'en-US')
 */
export function formatCurrency(
  amount: number,
  currency: string,
  locale: string = 'en-US'
): string {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
  }).format(amount / 100);
}
```

**Prompt (select the function, open inline chat or Chat panel):**
```
/tests
Generate Jest unit tests for this formatCurrency function. Include:
- Happy path tests for USD and EUR
- A test with a non-default locale (e.g., 'de-DE' for German formatting)
- Edge cases: amount of 0, negative amounts, very large amounts
- A test that verifies the locale parameter defaults to 'en-US'
```

**Generated tests (typical output):**
```typescript
import { formatCurrency } from './currency.utils';

describe('formatCurrency', () => {
  describe('USD formatting', () => {
    it('formats a positive USD amount correctly', () => {
      expect(formatCurrency(1099, 'USD')).toBe('$10.99');
    });

    it('formats a round USD amount with two decimal places', () => {
      expect(formatCurrency(1000, 'USD')).toBe('$10.00');
    });

    it('formats a large USD amount with thousand separators', () => {
      expect(formatCurrency(1234567, 'USD')).toBe('$12,345.67');
    });
  });

  describe('EUR formatting', () => {
    it('formats a EUR amount with the correct symbol', () => {
      expect(formatCurrency(1099, 'EUR', 'en-US')).toBe('€10.99');
    });
  });

  describe('locale formatting', () => {
    it('uses en-US as the default locale', () => {
      // Implicitly tested: calling without locale param produces en-US format
      expect(formatCurrency(1099, 'USD')).toBe('$10.99');
    });

    it('formats using German locale conventions', () => {
      const result = formatCurrency(1099, 'EUR', 'de-DE');
      // de-DE uses comma as decimal separator
      expect(result).toMatch(/10,99/);
    });
  });

  describe('edge cases', () => {
    it('formats zero amount', () => {
      expect(formatCurrency(0, 'USD')).toBe('$0.00');
    });

    it('formats negative amounts', () => {
      expect(formatCurrency(-1099, 'USD')).toBe('-$10.99');
    });

    it('formats very large amounts without overflow', () => {
      expect(formatCurrency(99999999, 'USD')).toBe('$999,999.99');
    });
  });
});
```

**How to accept and iterate:** Click "Insert at cursor" (or copy) to place the tests in the appropriate file. Then run:
```bash
npx jest src/utils/currency.utils.test.ts
```
If any tests fail, paste the error back into the chat:
```
/fix @terminal Two of the locale tests failed with the output above. Fix the assertions.
```

---

## Example 2: `/tests` with Custom Framework Instructions

**Scenario:** You want tests in a specific framework (Jest vs. pytest vs. Vitest) with a specific style.

### Jest with React Testing Library

**Prompt:**
```
/tests #file:src/components/LoginForm.tsx
Write Jest tests using React Testing Library for this LoginForm component.
Use the "Arrange / Act / Assert" comment structure. Test:
1. The form renders with email and password fields and a submit button
2. Validation shows an error when email is empty on submit
3. Validation shows an error when password is shorter than 8 characters
4. A successful submission calls the onSubmit prop with the email and password
5. The submit button is disabled while submission is in progress (isLoading prop)
```

### pytest with parametrize

**Prompt:**
```
/tests #file:src/validators/password_validator.py
Write pytest tests for the validate_password function.
Use pytest.mark.parametrize to test multiple inputs in a single test function.
Include a fixture for a default password policy config.
Test: minimum length, uppercase requirement, number requirement,
special character requirement, and common password rejection.
```

**Generated test (example):**
```python
import pytest
from src.validators.password_validator import validate_password, PasswordPolicy

@pytest.fixture
def default_policy():
    return PasswordPolicy(
        min_length=8,
        require_uppercase=True,
        require_numbers=True,
        require_special=True,
    )

@pytest.mark.parametrize("password,expected_valid,expected_error", [
    ("Short1!", False, "at least 8 characters"),
    ("alllowercase1!", False, "uppercase letter"),
    ("NoNumbers!", False, "at least one number"),
    ("NoSpecial1", False, "special character"),
    ("password123!", False, "too common"),
    ("ValidP@ss1", True, None),
    ("Str0ng&P@ssword", True, None),
])
def test_validate_password(password, expected_valid, expected_error, default_policy):
    result = validate_password(password, default_policy)
    assert result.is_valid == expected_valid
    if expected_error:
        assert expected_error in result.error_message
    else:
        assert result.error_message is None
```

---

## Example 3: `/tests` for Edge Cases

**Scenario:** The basic happy path tests already exist. You want Copilot to focus specifically on boundary conditions and unusual inputs.

**Existing test file (attach with #file):**
```
/tests #file:src/utils/pagination.ts #file:src/utils/pagination.test.ts
The existing tests cover the basic case. Generate additional tests
targeting only edge cases and boundary conditions:
- Page number of 0 or negative
- Page size of 0 or negative
- Page number greater than total pages
- Total items of 0
- Non-integer page values
- Very large page sizes (larger than total item count)
- Page size of 1 (minimum valid)
For each, assert what the function should return and add a comment
explaining why that behavior is correct.
```

**Why this pattern works:** By attaching the existing test file, Copilot can see what is already covered and will not generate duplicates. It also mirrors your existing test style (describe blocks, assertion style, etc.).

---

## Example 4: `/tests` with `@workspace` for Integration Tests

**Scenario:** You want integration tests that match the patterns already used in your codebase, rather than starting from scratch.

**Prompt:**
```
/tests @workspace #file:src/api/orders/orders.controller.ts
Generate integration tests for the OrdersController that match the
pattern used in existing controller tests in this project. The tests
should:
- Use supertest to make HTTP requests against an Express test server
- Seed the test database with fixtures before each test
- Test: GET /api/v1/orders returns paginated results
- Test: POST /api/v1/orders creates an order and returns 201
- Test: POST /api/v1/orders with invalid body returns 400 with validation errors
- Test: GET /api/v1/orders/:id returns 404 for a non-existent order
Look at the existing integration tests to match the beforeAll/afterAll
setup pattern and the fixture helper functions already defined.
```

**What `@workspace` adds here:** Copilot searches the workspace for existing integration test files, understands the setup pattern (e.g., how the test database is seeded, what fixture helpers exist), and generates tests that use those same helpers rather than inventing new ones.

---

## Example 5: Iterating on Generated Tests

Generated tests are almost never perfect on the first attempt. Here is a practical iteration workflow.

**Step 1:** Generate initial tests.
```
/tests #file:src/services/email.service.ts
Generate Jest unit tests for the EmailService class. Mock the
nodemailer transport. Test: sendWelcomeEmail, sendPasswordReset,
and sendOrderConfirmation methods.
```

**Step 2:** Run the tests.
```bash
npx jest src/services/email.service.test.ts
```

**Step 3:** If tests fail, paste the error back.
```
/fix @terminal
Two tests failed with the errors above. The mock for nodemailer.createTransport
is not being applied correctly. Fix the mock setup.
```

**Step 4:** Ask for more coverage.
```
The generated tests cover the happy path. Add tests for:
1. What happens when the transport rejects (simulated SMTP error)
2. What happens when the recipient email is malformed
3. That the 'from' address is always set to the value from config, never overridable by the caller
```

**Step 5:** Ask Copilot to check its own coverage.
```
Looking at the EmailService source in #file:src/services/email.service.ts,
are there any branches or code paths in the tests that are not yet covered
by the tests you generated? List them and then add tests for the most
important gaps.
```

---

## Tips for Better Test Generation

**1. Tell Copilot the testing framework upfront.**
```
/tests Use Jest with ts-jest. Do not use Jasmine matchers.
```

**2. Specify mock style.**
```
/tests Use jest.spyOn for mocking, not jest.mock(). I prefer spies over full module mocks.
```

**3. Ask for test descriptions that read like specifications.**
```
/tests Write test names that read as "should [behavior] when [condition]",
e.g., "should return null when the user does not exist"
```

**4. Request tests that document intent, not implementation.**
```
/tests Focus on testing the public API contract, not internal implementation
details. Do not test private methods directly.
```

**5. Ask for one assertion per test.**
```
/tests Follow the "one assertion per test" rule where practical. If a test
needs multiple assertions, explain why in a comment.
```
