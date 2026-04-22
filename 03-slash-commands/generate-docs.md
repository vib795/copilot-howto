# `/doc` — Practical Examples

The `/doc` command generates documentation for selected code. It works at multiple levels: a single function, a class, a module, or an entire API surface. The examples below cover each level with concrete prompts.

---

## Example 1: `/doc` on a Function (JSDoc)

**Scenario:** You have a utility function that is used in many places but has no documentation. You want to add JSDoc so your IDE shows tooltips and your doc generator can pick it up.

**The function (selected):**
```typescript
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxAttempts: number = 3,
  baseDelayMs: number = 500,
  shouldRetry: (error: unknown) => boolean = () => true
): Promise<T> {
  let lastError: unknown;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      if (attempt === maxAttempts || !shouldRetry(error)) {
        throw error;
      }
      const delay = baseDelayMs * Math.pow(2, attempt - 1);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw lastError;
}
```

**Prompt:**
```
/doc #selection
Add JSDoc to this function. Include:
- A description of what the function does and the retry strategy (exponential backoff)
- @param for each parameter with types and default values noted
- @returns describing the resolved value
- @throws describing when it throws
- @example showing a real-world usage with a fetch call
```

**Generated JSDoc (typical output):**
```typescript
/**
 * Retries an async operation with exponential backoff on failure.
 *
 * On each failed attempt, the function waits `baseDelayMs * 2^(attempt-1)` milliseconds
 * before retrying. For example, with `baseDelayMs = 500` and `maxAttempts = 3`, the
 * delays are 500ms, 1000ms, then the third failure is thrown immediately.
 *
 * @param fn - The async function to execute and retry on failure.
 * @param maxAttempts - Maximum number of attempts before giving up. Defaults to `3`.
 * @param baseDelayMs - Base delay in milliseconds for the first retry. Defaults to `500`.
 * @param shouldRetry - Predicate that receives the thrown error and returns `true` if the
 *   operation should be retried. Defaults to always retrying. Use this to avoid retrying
 *   on non-transient errors (e.g., 400 Bad Request should not be retried).
 *
 * @returns A promise that resolves with the return value of `fn` on success.
 *
 * @throws The last error thrown by `fn` if all attempts are exhausted or `shouldRetry`
 *   returns `false`.
 *
 * @example
 * // Retry a fetch call, but only on 5xx or network errors
 * const data = await retryWithBackoff(
 *   () => fetch('/api/orders').then(res => {
 *     if (!res.ok) throw new HttpError(res.status);
 *     return res.json();
 *   }),
 *   3,
 *   500,
 *   (err) => err instanceof HttpError && err.status >= 500
 * );
 */
```

---

## Example 2: `/doc` on a Python Function (Google-Style Docstring)

**Scenario:** Your team uses Google-style Python docstrings (e.g., via the Google docstring convention, enforced by `pydocstyle` with `--convention=google`).

**The function (selected):**
```python
def calculate_shipping_cost(
    weight_kg: float,
    destination_zone: int,
    express: bool = False
) -> float:
    base_rate = 2.50
    zone_multiplier = 1.0 + (destination_zone - 1) * 0.15
    weight_charge = max(weight_kg, 0.5) * 1.20
    express_surcharge = 8.00 if express else 0.0
    return round((base_rate + weight_charge) * zone_multiplier + express_surcharge, 2)
```

**Prompt:**
```
/doc #selection
Add a Google-style Python docstring to this function. Include:
- A one-line summary
- A longer description explaining the pricing formula
- An Args section with all parameters
- A Returns section
- A Raises section if applicable
- An Example section with a realistic call
```

**Generated docstring:**
```python
def calculate_shipping_cost(
    weight_kg: float,
    destination_zone: int,
    express: bool = False
) -> float:
    """Calculates the shipping cost for a parcel based on weight, zone, and speed.

    The cost is calculated as:
        (base_rate + weight_charge) * zone_multiplier + express_surcharge

    Where:
        - base_rate = $2.50 (fixed)
        - weight_charge = max(weight_kg, 0.5) * $1.20 (minimum 0.5 kg billed)
        - zone_multiplier = 1.0 + (destination_zone - 1) * 0.15
        - express_surcharge = $8.00 if express, else $0.00

    Args:
        weight_kg: Parcel weight in kilograms. Parcels under 0.5 kg are billed
            at the 0.5 kg minimum rate.
        destination_zone: Shipping zone (1–5). Zone 1 is local; Zone 5 is
            international. Each zone adds 15% to the base cost.
        express: If True, adds an $8.00 express surcharge. Defaults to False.

    Returns:
        The total shipping cost in USD, rounded to two decimal places.

    Example:
        >>> calculate_shipping_cost(2.0, 2)
        5.74
        >>> calculate_shipping_cost(1.5, 3, express=True)
        13.30
    """
```

**Tip for enforcing doc style:** Add to your `.github/copilot-instructions.md`:
```
When generating Python docstrings, always use Google-style format
(Args:, Returns:, Raises:, Example:). Never use NumPy or Sphinx rst style.
```

---

## Example 3: `/doc` on a TypeScript Class

**Scenario:** You have a service class with several public methods. You want full class-level and method-level documentation.

**Prompt:**
```
/doc #file:src/services/notification.service.ts
Generate full JSDoc for the NotificationService class:
1. Class-level JSDoc: what the service does, what external dependencies it uses
   (e.g., which email provider, which SMS gateway), and how it is instantiated.
2. Constructor JSDoc with @param for each injected dependency.
3. JSDoc for every public method with @param, @returns, @throws, and @example.
4. Do not add JSDoc to private methods.
```

**After Copilot generates it:**
Review that:
- The `@throws` entries accurately reflect what the service actually throws (not generic `Error`)
- The `@example` calls show realistic inputs from your domain
- Class-level `@remarks` or `@see` tags link to relevant external documentation if applicable

---

## Example 4: `/doc` at Module Level — Generating a Module README

**Scenario:** You have a payments module that is used by several other teams. You want to generate a README that explains what it exports and how to use it.

**Prompt:**
```
/doc #file:src/payments/index.ts #file:src/payments/payment.service.ts #file:src/payments/payment.types.ts
Write a module-level README for the payments module. Include:
1. What the module does in 2-3 sentences
2. Installation / prerequisites (e.g., required environment variables)
3. Quick start: the most common use case in 10 lines of code
4. API reference: a table listing every exported function, class, and type,
   with a one-line description of each
5. Error handling: what errors the module throws and how callers should handle them
6. Known limitations or gotchas
Format it as Markdown suitable for a README.md in the payments directory.
```

---

## Example 5: Customizing Doc Style via Custom Instructions

You can make Copilot always generate docs in a specific style without having to specify it every time. Add to `.github/copilot-instructions.md`:

```markdown
## Documentation Standards

When generating documentation:
- TypeScript/JavaScript: always use JSDoc with @param, @returns, @throws, and @example
- Python: always use Google-style docstrings
- Every public function must have an @example showing a realistic use case
- Do not document private methods or implementation details
- For React components: document the props interface, not the component function
- For REST endpoints: use OpenAPI-style JSDoc (@openapi tags if using swagger-jsdoc)
```

With these instructions in place, a bare `/doc` command will automatically produce the right format.

---

## Example 6: `/doc` + `/new` to Scaffold a Documented API Endpoint

**Scenario:** You want to create a new REST endpoint that is documented from the start.

**Step 1:** Use `/new` to scaffold the endpoint.
```
/new
Create an Express route handler for GET /api/v1/products/:id.
It should:
- Validate that the id param is a positive integer
- Call ProductService.findById(id)
- Return 200 with the product JSON on success
- Return 404 if the product is not found
- Return 400 if the id is not a valid integer
```

**Step 2:** After reviewing and accepting the scaffolded code, document it.
```
/doc #selection
Add JSDoc to the route handler I just created. Include:
- A description of the endpoint's behavior
- @param for req and res
- @throws or inline error comments for each error response (400, 404, 500)
- An @example showing the expected request and response JSON
```

**Result:** You get a documented endpoint in one workflow, without writing a word of documentation manually.

---

## Tips for Better Documentation Generation

**1. Tell Copilot which doc format to use.**
```
/doc Use TSDoc format (not standard JSDoc). Use @remarks instead of @description.
```

**2. Ask for examples with realistic domain values.**
```
/doc The @example should show a real user object with realistic field values
(not placeholder strings like "string" or "value").
```

**3. Ask Copilot to document error scenarios.**
```
/doc Make sure the @throws section lists every exception the function can throw,
including what triggers each one.
```

**4. Review for accuracy before committing.**
Generated docs can contain subtle inaccuracies — especially in `@throws` and `@example` sections. Always verify that the described behavior matches what the code actually does.

**5. Use `/doc` after `/fix` to keep docs in sync.**
After fixing a bug that changes a function's behavior, always run `/doc #selection` to update the documentation to reflect the corrected behavior.
