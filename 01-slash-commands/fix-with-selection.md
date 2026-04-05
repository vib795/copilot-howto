# `/fix` with Selection — Practical Examples

The `/fix` command tells Copilot to diagnose and repair a specific problem. It works best when you give it _both_ the broken code and a description of the problem. The more precisely you describe the failure, the better the fix.

---

## Example 1: Fixing a Failing Test

**Scenario:** A test is failing with a runtime error. You have the error from the terminal and the relevant test code.

**Failing test (selected in editor):**
```typescript
it('should calculate the total price with discounts applied', () => {
  const cart = new ShoppingCart();
  cart.addItem({ id: '1', name: 'Widget', price: 9.99, quantity: 3 });
  cart.applyDiscount({ code: 'SAVE10', type: 'percentage', value: 10 });

  expect(cart.getTotal()).toBe(26.97);
});
```

**Terminal error:**
```
TypeError: Cannot read properties of undefined (reading 'type')
    at ShoppingCart.applyDiscount (src/models/shopping-cart.ts:44:28)
    at Object.<anonymous> (src/models/shopping-cart.test.ts:12:10)
```

**Prompt (select the test, then open Chat panel):**
```
/fix #selection @terminal
The test above is failing. The error says it cannot read 'type' on
undefined inside applyDiscount. Looking at the test, the discount
object I'm passing has a 'type' property, so the issue is likely
inside the method. Fix the method, not the test.
```

**Then attach the implementation:**
```
/fix #file:src/models/shopping-cart.ts @terminal
The applyDiscount method is throwing: Cannot read properties of
undefined (reading 'type') at line 44. Fix the null check
in applyDiscount — it should validate that the discount argument
exists before destructuring it.
```

---

## Example 2: Fixing TypeScript Type Errors

**Scenario:** TypeScript strict mode is turned on and you have a file with several type errors after a refactor.

**The errors (from the Problems panel):**
```
src/services/user.service.ts:23:5 - error TS2322:
  Type 'string | null' is not assignable to type 'string'.

src/services/user.service.ts:47:12 - error TS18047:
  'user' is possibly 'null'.

src/services/user.service.ts:61:3 - error TS2345:
  Argument of type '{ id: number; email: string; role: string | undefined; }'
  is not assignable to parameter of type 'CreateUserDTO'.
  Types of property 'role' are incompatible.
    Type 'string | undefined' is not assignable to type 'UserRole'.
```

**Prompt:**
```
/fix #file:src/services/user.service.ts
Fix all TypeScript strict-mode type errors in this file. The errors are:

1. Line 23: string | null is not assignable to string — add a null guard
2. Line 47: 'user' is possibly null — add a null check before accessing user.email
3. Line 61: role is string | undefined but CreateUserDTO.role expects UserRole enum —
   cast it properly or handle the undefined case

Do not change any business logic, only fix the types.
```

**What Copilot typically produces:**
- A null guard at line 23 (e.g., `if (result === null) throw new Error(...)`)
- An optional chain or early return at line 47
- A type assertion or enum mapping at line 61

**Tip:** When fixing type errors, telling Copilot "do not change any business logic" prevents it from making unintended refactors alongside the type fixes.

---

## Example 3: Fixing a SQL Injection Vulnerability

**Scenario:** You find a SQL query constructed by string concatenation during a security review.

**The vulnerable code (selected):**
```typescript
async function getUserByUsername(username: string): Promise<User | null> {
  const query = `SELECT * FROM users WHERE username = '${username}'`;
  const result = await db.query(query);
  return result.rows[0] ?? null;
}
```

**Prompt:**
```
/fix #selection
This function is vulnerable to SQL injection because it concatenates
user input directly into the query string. Fix it by using
parameterized queries with the pg library's $1 placeholder syntax.
Keep the same function signature and return type.
```

**Expected fix from Copilot:**
```typescript
async function getUserByUsername(username: string): Promise<User | null> {
  const query = 'SELECT * FROM users WHERE username = $1';
  const result = await db.query(query, [username]);
  return result.rows[0] ?? null;
}
```

**Follow-up for a whole file:**
```
/fix #file:src/repositories/user.repository.ts
Scan this entire repository file for SQL injection vulnerabilities —
any place where user input is concatenated into a query string —
and fix all of them using parameterized queries.
```

---

## Example 4: Fixing a Race Condition

**Scenario:** You have async code that has a subtle race condition.

**The broken code (selected):**
```typescript
class UserCache {
  private cache: Map<string, User> = new Map();
  private pending: Set<string> = new Set();

  async getUser(id: string): Promise<User> {
    if (this.cache.has(id)) {
      return this.cache.get(id)!;
    }

    if (!this.pending.has(id)) {
      this.pending.add(id);
      const user = await fetchUserFromDB(id);
      this.cache.set(id, user);
      this.pending.delete(id);
      return user;
    }

    // BUG: if another call is already fetching, we just... wait? But we never resolve.
    return this.getUser(id);
  }
}
```

**Prompt:**
```
/fix #selection
There is a race condition in getUser: when two concurrent calls come in
for the same id, the second call recurses into getUser() again before
the first has resolved, which can cause a busy loop. Fix this by storing
Promises in the pending map instead of just IDs, so concurrent callers
can await the same in-flight request.
```

---

## Example 5: Fixing a Memory Leak in a React Component

**Scenario:** A React component updates state after it has been unmounted, causing a memory leak warning.

**The component (selected):**
```tsx
function UserDashboard({ userId }: { userId: string }) {
  const [userData, setUserData] = useState<UserData | null>(null);

  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => setUserData(data)); // BUG: no cleanup if component unmounts
  }, [userId]);

  if (!userData) return <Spinner />;
  return <UserProfile data={userData} />;
}
```

**Warning in console:**
```
Warning: Can't perform a React state update on an unmounted component.
This is a no-op, but it indicates a memory leak in your application.
```

**Prompt:**
```
/fix #selection
Fix the memory leak warning. The fetch call updates state after the
component unmounts. Use AbortController to cancel the fetch on cleanup,
and check the abort signal before calling setUserData.
```

---

## Example 6: Fixing with Full Module Context

**Scenario:** A function in one file fails because it misuses a type defined in another file. You need to give Copilot both files.

**Prompt:**
```
/fix #file:src/api/order.controller.ts #file:src/models/order.model.ts
The createOrder controller is throwing a validation error at runtime:
"price must be a positive number". Looking at the model, price is
stored in cents (integer) but the controller is passing a float.
Fix the controller to convert the dollar amount to cents before
passing it to the model.
```

**Why this works:** By attaching both files, Copilot can see the mismatch between the controller's data and the model's expectations without you having to quote both manually.

---

## When to Use `/fix` vs. Inline Suggestion Cycling

GitHub Copilot offers two ways to get code corrections: the `/fix` command and the standard inline suggestion that appears as you type. Understanding when to use each saves time.

| Situation | Use `/fix` | Use Inline Suggestion Cycling |
|---|---|---|
| You have a specific error message | Yes | No |
| You know exactly which line is wrong | Sometimes | Yes |
| The bug requires understanding context from other files | Yes (with `#file`) | No |
| You want to keep typing and let Copilot complete the fix | No | Yes |
| The fix requires a multi-line structural change | Yes | No |
| You want to explain _why_ something is wrong | Yes | No |
| You are fixing a security vulnerability with a clear description | Yes | No |

**Inline suggestion cycling** (pressing `Alt+]` / `Option+]` to see alternate completions) is best for quick fixes where Copilot's first suggestion was close but not right. You cycle through alternatives without leaving the editor flow.

**`/fix`** is best when the problem requires diagnosis. Use it when you have an error message, a failing test, or a known bug class (SQL injection, memory leak, type mismatch) and you want Copilot to reason about the fix rather than just autocomplete.

---

## Reviewing Fix Suggestions Critically

Copilot's `/fix` suggestions are generally good but not always correct. Before accepting:

1. **Read the diff carefully.** What exactly changed? Did Copilot fix only what you asked, or did it also change unrelated code?

2. **Check for introduced bugs.** A common pattern is fixing a null check by adding a `!` non-null assertion — which silences the type error but does not actually handle the null case.

3. **Verify the fix is correct for your context.** Copilot may fix a function signature to match one calling convention, but your codebase may call it from many places in different ways.

4. **Run tests after accepting.** Always run your test suite after accepting a fix, especially for security-related changes.
