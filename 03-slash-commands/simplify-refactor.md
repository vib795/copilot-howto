# `/simplify` — Practical Examples

The `/simplify` command asks Copilot to make code more readable, idiomatic, or concise while preserving its behavior. It is a refactoring tool, not a bug-fixing tool. Use it when code works correctly but is hard to understand, maintain, or extend.

---

## Example 1: Simplifying a Deeply Nested Conditional

**Scenario:** A function has accumulated nested if/else branches over time until it has become nearly unreadable.

**The original code (selected):**
```typescript
function getOrderStatus(order: Order): string {
  if (order.isCancelled) {
    return 'cancelled';
  } else {
    if (order.isDelivered) {
      return 'delivered';
    } else {
      if (order.isShipped) {
        if (order.isDelayed) {
          return 'delayed';
        } else {
          return 'shipped';
        }
      } else {
        if (order.isProcessing) {
          return 'processing';
        } else {
          if (order.isPending) {
            return 'pending';
          } else {
            return 'unknown';
          }
        }
      }
    }
  }
}
```

**Prompt:**
```
/simplify #selection
This nested if/else chain has 5 levels of nesting. Simplify it using
early returns (guard clauses) so each case is at the same indentation level.
Preserve the exact same priority order: cancelled > delivered > shipped > delayed > processing > pending > unknown.
```

**Simplified output (typical):**
```typescript
function getOrderStatus(order: Order): string {
  if (order.isCancelled) return 'cancelled';
  if (order.isDelivered) return 'delivered';
  if (order.isShipped && order.isDelayed) return 'delayed';
  if (order.isShipped) return 'shipped';
  if (order.isProcessing) return 'processing';
  if (order.isPending) return 'pending';
  return 'unknown';
}
```

**Review checklist after simplifying:**
- Does the priority order match? In the original, `isDelayed` is only checked inside `isShipped`. Does the simplified version preserve that?
- Are all the original branches represented? Count them: 7 possible returns in the original, 7 in the simplified.
- Run the tests to confirm identical behavior.

---

## Example 2: Replacing a Verbose Loop with Array Methods

**Scenario:** A function was written procedurally and can be expressed more idiomatically using JavaScript's built-in array methods.

**The original code (selected):**
```typescript
function getSummary(orders: Order[]): OrderSummary {
  let totalRevenue = 0;
  let completedCount = 0;
  const productIds: string[] = [];

  for (let i = 0; i < orders.length; i++) {
    const order = orders[i];
    if (order.status === 'completed') {
      totalRevenue = totalRevenue + order.totalCents;
      completedCount = completedCount + 1;
      for (let j = 0; j < order.items.length; j++) {
        if (!productIds.includes(order.items[j].productId)) {
          productIds.push(order.items[j].productId);
        }
      }
    }
  }

  return {
    totalRevenue,
    completedCount,
    uniqueProductCount: productIds.length,
  };
}
```

**Prompt:**
```
/simplify #selection
Rewrite this function using idiomatic JavaScript array methods (filter,
reduce, flatMap, Set). Keep the same return type and behavior.
Prefer readability over maximum brevity — do not compress it into
a single expression.
```

**Simplified output:**
```typescript
function getSummary(orders: Order[]): OrderSummary {
  const completedOrders = orders.filter(o => o.status === 'completed');

  const totalRevenue = completedOrders.reduce((sum, o) => sum + o.totalCents, 0);

  const uniqueProductIds = new Set(
    completedOrders.flatMap(o => o.items.map(item => item.productId))
  );

  return {
    totalRevenue,
    completedCount: completedOrders.length,
    uniqueProductCount: uniqueProductIds.size,
  };
}
```

**Note: "prefer readability over maximum brevity."** Without this instruction, Copilot sometimes produces a single chained expression that is technically concise but harder to read than the original.

---

## Example 3: Extracting Repeated Code Blocks

**Scenario:** The same validation logic appears in three route handlers, slightly varied. The variation is cosmetic (different field names) but the pattern is identical.

**The original code (selected — all three handlers):**
```typescript
router.post('/users', async (req, res) => {
  if (!req.body.email) {
    return res.status(400).json({ error: 'email is required' });
  }
  if (typeof req.body.email !== 'string') {
    return res.status(400).json({ error: 'email must be a string' });
  }
  if (!req.body.name) {
    return res.status(400).json({ error: 'name is required' });
  }
  if (typeof req.body.name !== 'string') {
    return res.status(400).json({ error: 'name must be a string' });
  }
  // ... handler logic
});

router.post('/products', async (req, res) => {
  if (!req.body.title) {
    return res.status(400).json({ error: 'title is required' });
  }
  if (typeof req.body.title !== 'string') {
    return res.status(400).json({ error: 'title must be a string' });
  }
  if (!req.body.price) {
    return res.status(400).json({ error: 'price is required' });
  }
  if (typeof req.body.price !== 'number') {
    return res.status(400).json({ error: 'price must be a number' });
  }
  // ... handler logic
});
```

**Prompt:**
```
/simplify #selection
Extract the repeated field validation pattern into a reusable helper function.
The helper should accept a list of field specs (name, required, type) and return
a 400 response if any validation fails. Replace the inline checks in both handlers
with calls to the helper.
```

**Simplified output (typical):**
```typescript
interface FieldSpec {
  name: string;
  required?: boolean;
  type?: 'string' | 'number' | 'boolean';
}

function validateBody(
  body: Record<string, unknown>,
  fields: FieldSpec[],
  res: Response
): boolean {
  for (const field of fields) {
    if (field.required && !body[field.name]) {
      res.status(400).json({ error: `${field.name} is required` });
      return false;
    }
    if (field.type && body[field.name] !== undefined && typeof body[field.name] !== field.type) {
      res.status(400).json({ error: `${field.name} must be a ${field.type}` });
      return false;
    }
  }
  return true;
}

router.post('/users', async (req, res) => {
  if (!validateBody(req.body, [
    { name: 'email', required: true, type: 'string' },
    { name: 'name', required: true, type: 'string' },
  ], res)) return;
  // ... handler logic
});
```

---

## Example 4: Simplifying Promise Chains to Async/Await

**Scenario:** Old code written with `.then()` chains can be rewritten to async/await for clarity.

**The original code (selected):**
```typescript
function loadUserDashboard(userId: string) {
  return getUser(userId)
    .then(user => {
      return getOrders(user.id)
        .then(orders => {
          return getNotifications(user.id)
            .then(notifications => {
              return {
                user,
                orders,
                notifications,
              };
            });
        });
    })
    .catch(error => {
      logger.error('Failed to load dashboard', { userId, error });
      throw error;
    });
}
```

**Prompt:**
```
/simplify #selection
Rewrite this nested .then() chain as async/await. Run the three data
fetches in parallel using Promise.all where possible, since user, orders,
and notifications are independent after we have the userId. Keep the
catch/logging behavior.
```

**Simplified output:**
```typescript
async function loadUserDashboard(userId: string) {
  try {
    const user = await getUser(userId);
    const [orders, notifications] = await Promise.all([
      getOrders(user.id),
      getNotifications(user.id),
    ]);
    return { user, orders, notifications };
  } catch (error) {
    logger.error('Failed to load dashboard', { userId, error });
    throw error;
  }
}
```

**Semantic change to review:** The simplified version runs `getOrders` and `getNotifications` in parallel, whereas the original ran them sequentially. This is generally faster and correct — but verify that your system can handle the concurrent requests (e.g., that there are no database lock conflicts).

---

## `/simplify` vs. `/fix`: Knowing Which to Use

This is a common point of confusion. The key distinction:

| | `/simplify` | `/fix` |
|---|---|---|
| **When the code is** | Correct but complex | Incorrect or broken |
| **Goal** | Improve readability / reduce complexity | Correct behavior / repair a bug |
| **Starting assumption** | The code works as intended | The code has a defect |
| **Risk** | May inadvertently change semantics | May introduce new bugs while fixing |
| **Tests should** | Still pass after simplification | Start passing after the fix |

**Edge cases:**

- Code that is _both_ broken _and_ complex: use `/fix` first to make it correct, then `/simplify` to make it readable. Never simplify broken code — you will simplify the bug in.

- Code that is "too defensive" (excessive null checks that can never be null due to type guarantees): use `/simplify` with explicit instruction: "Remove null checks that TypeScript's type system already prevents."

- Code with a performance bug: neither `/simplify` nor `/fix` is perfect. Use `/fix` if you have a measurable regression, or `/simplify` with explicit instruction: "This loop is O(n²). Rewrite it to be O(n log n) or better."

---

## Reviewing `/simplify` Suggestions Critically

Copilot's `/simplify` suggestions are not always semantically equivalent. Before accepting:

**1. Check for short-circuit evaluation changes.**
A chain of `&&` conditions may have a different execution order than nested if-blocks that use early returns. Copilot may reorder conditions.

**2. Check for changed falsy handling.**
`if (x) { ... }` and `if (x !== undefined) { ... }` behave differently for `0`, `''`, and `false`. Simplifications that change the condition can silently alter behavior.

**3. Check that error handling is preserved.**
When simplifying try/catch blocks or `.catch()` chains, verify that every error path is still handled and that no errors are silently swallowed.

**4. Run the full test suite.**
Even a seemingly safe simplification (like replacing a loop with `reduce`) can produce different results if the accumulator behavior is not identical.

**5. Review the diff, not just the output.**
Use VS Code's diff view when accepting an inline chat suggestion. Pay attention to what changed in addition to what Copilot added.
