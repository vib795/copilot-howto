# Scoped Instructions — Handling Subsystem-Specific Context

## The Limitation

GitHub Copilot's `.github/copilot-instructions.md` is a single flat file for the entire repository. There is no equivalent of Claude Code's hierarchical `CLAUDE.md` system, where you can place a `CLAUDE.md` inside `src/api/` and have it automatically apply only to interactions about that subdirectory.

**What Claude Code supports but Copilot does not:**

```
# Claude Code CLAUDE.md hierarchy (NOT how Copilot works)
CLAUDE.md                    ← applies everywhere
src/
  api/
    CLAUDE.md                ← applies only to src/api/
  frontend/
    CLAUDE.md                ← applies only to src/frontend/
```

In Copilot, there is only one file and it applies everywhere. If you put API-specific instructions in that file, they are sent to Copilot even when you are working on frontend code, consuming context budget unnecessarily and potentially creating confusing guidance.

---

## Workaround 1: `#file` Reference — Manual Attachment Per Interaction

The most reliable workaround is to keep subsystem documentation in dedicated README or spec files, and manually attach them with `#file` when asking about that subsystem.

**Directory structure:**
```
src/
  api/
    README.md          ← API-specific context (patterns, conventions, gotchas)
  frontend/
    README.md          ← Frontend-specific context
  workers/
    README.md          ← Background job worker context
  db/
    README.md          ← Database schema and query patterns
docs/
  architecture.md      ← High-level architecture
  api-conventions.md   ← API design decisions and examples
```

**Using `#file` for a subsystem-specific question:**
```
/explain #file:src/api/README.md #file:src/api/routes/orders.ts
Explain how this orders route connects to the service layer and the database.
I want to understand the full call chain.
```

```
/new #file:src/api/README.md
Add a new endpoint for GET /api/v1/products/:id following the patterns
described in the API README. Match the error handling and response shape
of the existing endpoints.
```

**Why this works well:** The attached README is visible to Copilot for that specific interaction, so it can apply API-specific patterns without those patterns polluting unrelated interactions.

**The tradeoff:** You must remember to attach the right README for each interaction. It is a manual step. Build it into your habit: before asking about a specific subsystem, attach its README.

---

## Workaround 2: Subsystem Map in the Main Instructions File

Include a routing table in `.github/copilot-instructions.md` that points to where subsystem-specific context lives. This way, Copilot knows where to tell the user to look.

**In `.github/copilot-instructions.md`:**
```markdown
## Subsystem Context

This repository contains multiple subsystems. For questions about a specific
subsystem, ask the user to attach the relevant documentation with #file:

| Subsystem | Key documentation |
|---|---|
| API routes and controllers | `src/api/README.md` |
| Database schema and query patterns | `src/db/README.md` |
| Frontend component library | `src/frontend/README.md` |
| Background workers and job queue | `src/workers/README.md` |
| Authentication and authorization | `docs/auth-design.md` |
| Payment processing | `docs/payments-design.md` |

When answering a question that is clearly about one of these subsystems,
mention to the user which file they should attach for better context.
```

With this in place, if you ask:
```
How do I add a new background job?
```

Copilot may respond: "For detailed conventions on background jobs, you should attach `src/workers/README.md` using `#file:src/workers/README.md`. In the meantime, here is what I can tell you..."

This does not automatically give Copilot the context, but it creates a self-documenting system where the instructions guide users to the right documentation.

---

## Workaround 3: Per-Subsystem README Files as Instruction Fragments

Write subsystem README files in a style that works well as instruction context — not just as human documentation, but as structured guidance for AI assistance.

**Example: `src/api/README.md` designed for both human readers and Copilot:**

```markdown
# API Subsystem

## Purpose
Express.js REST API. All routes live in src/api/routes/, controllers in src/api/controllers/,
services in src/api/services/.

## Adding a New Endpoint — Pattern

1. Create a route file in src/api/routes/<resource>.route.ts
2. Create a controller in src/api/controllers/<resource>.controller.ts
3. Create a service in src/api/services/<resource>.service.ts
4. Register the router in src/api/app.ts

## Route Handler Pattern

All route handlers follow this structure:
\`\`\`typescript
export async function createOrder(req: Request, res: Response): Promise<void> {
  const validationResult = validateBody(req.body, createOrderSchema);
  if (!validationResult.success) {
    res.status(422).json(formatValidationError(validationResult.errors));
    return;
  }
  try {
    const order = await orderService.create(validationResult.data);
    res.status(201).json({ data: order });
  } catch (error) {
    if (error instanceof CustomerNotFoundError) {
      res.status(404).json(formatError('CUSTOMER_NOT_FOUND', error.message));
      return;
    }
    throw error; // Let global error handler catch unexpected errors
  }
}
\`\`\`

## Validation

Use Zod schemas in src/api/schemas/. Always validate req.body, req.params,
and req.query before use. Return 422 (not 400) for validation failures.

## Error Response Shape

{ "error": { "code": "ERROR_CODE", "message": "Human message" } }

Error codes are UPPER_SNAKE_CASE strings defined in src/api/errors/codes.ts.

## Tests

Integration tests in src/api/test/integration/<resource>.test.ts.
Unit tests co-located: src/api/controllers/<resource>.controller.test.ts.
Use the seedTestDatabase() helper from src/api/test/helpers.ts.
```

This README doubles as human documentation and as a highly effective instruction fragment when attached with `#file`.

---

## Example: Working With the `/api` Subdirectory Effectively

Here is a complete worked example showing how to use these patterns together when adding a new API endpoint.

### Step 1: Scaffold the new endpoint

```
/new #file:src/api/README.md #file:src/api/routes/orders.route.ts
Add a new endpoint for GET /api/v1/orders/:orderId/items.
It should:
- Validate that orderId is a positive integer
- Call OrderItemService.findByOrderId(orderId)
- Return 200 with { data: OrderItem[] }
- Return 404 if the order does not exist
Follow the same route handler pattern used in the existing orders routes.
Create three files: the route registration, controller, and a stub service method.
```

### Step 2: Generate tests

```
/tests #file:src/api/README.md #file:src/api/controllers/order-items.controller.ts
Generate integration tests for the new GET /api/v1/orders/:orderId/items endpoint.
Follow the test pattern from src/api/README.md:
- Use the seedTestDatabase() helper
- Test the 200 case with real seeded data
- Test the 404 case for a non-existent order
- Test the 400 case for an invalid (non-integer) orderId
```

### Step 3: Add documentation

```
/doc #file:src/api/README.md #file:src/api/controllers/order-items.controller.ts
Add JSDoc to the controller including an @openapi annotation for the
GET /api/v1/orders/:orderId/items endpoint. Follow the format used in
other controllers. Include the 200, 400, and 404 response schemas.
```

---

## Practical Prompt Template

Bookmark or save this template for use when working on any specific subsystem:

```
Using #file:<subsystem-readme> as context, [your request here]

For example:
Using #file:src/api/README.md as context, help me add a new endpoint for
PATCH /api/v1/users/:userId that allows updating the user's name and email.
Follow the existing patterns exactly.
```

The key phrase "using X as context" signals to Copilot that the attached file should strongly influence the output — not just be a loose reference.

---

## Summary of Trade-offs

| Approach | Pros | Cons |
|---|---|---|
| `#file` manual attachment | Always works; precise control | Manual step every time; easy to forget |
| Subsystem map in main instructions | Self-documenting; Copilot can guide users | Indirect — Copilot still needs file attached to use the context |
| Per-subsystem README as instruction fragment | Excellent quality when attached; also good human docs | Requires maintaining separate docs per subsystem |
| Putting everything in the main instructions file | Simple | Bloats token budget; unrelated context pollutes all interactions |

For most teams, the best approach is a combination: a lean main instructions file (< 4,000 characters) that captures universal rules, plus well-written per-subsystem READMEs that engineers attach with `#file` when doing focused work in a subsystem.
