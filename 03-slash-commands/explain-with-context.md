# `/explain` with Context — Practical Examples

The `/explain` command is most powerful when you give Copilot precise context about _what_ you are confused about and _which code_ you are asking about. Generic questions get generic answers. The examples below show how to attach different types of context to get explanations that are actually useful.

---

## Example 1: `/explain` on a Selected Function

**When to use this:** You have a single function open in the editor and want to understand it without leaving your current context. Select the entire function body, then open inline chat with `Ctrl+I` / `Cmd+I`.

**The function (selected in editor):**
```typescript
function mergeDeep<T extends Record<string, unknown>>(
  target: T,
  ...sources: Partial<T>[]
): T {
  if (!sources.length) return target;
  const source = sources.shift();
  if (isObject(target) && isObject(source)) {
    for (const key in source) {
      if (isObject(source[key])) {
        if (!target[key]) Object.assign(target, { [key]: {} });
        mergeDeep(target[key] as T, source[key] as Partial<T>);
      } else {
        Object.assign(target, { [key]: source[key] });
      }
    }
  }
  return mergeDeep(target, ...sources);
}
```

**Prompt in inline chat:**
```
/explain #selection
Walk me through how this recursive merge works. What happens if a key
exists in both target and source but source's value is not an object?
What is the risk with mutating `target` in place?
```

**What Copilot explains:**
- The recursion pattern: `sources.shift()` pops one source at a time, then recurses with the remaining sources
- The base case: when `sources` is empty, `target` is returned
- The mutation concern: `Object.assign(target, ...)` modifies `target` in place, which can cause bugs if the caller does not expect that
- The key conflict resolution: non-object values in `source` overwrite `target` values directly

**Tips for this pattern:**
- Select _only_ the function (not surrounding context) so Copilot focuses on it
- Ask about a specific concern (mutation, performance, edge cases) rather than "explain this" — you will get a much more targeted response
- If the function calls helpers (`isObject` here), mention them: "I see it calls `isObject` — I understand that part; focus on the recursive loop."

---

## Example 2: `/explain` on a Whole File

**When to use this:** You have just opened a file you've never seen before, or you're onboarding onto a codebase and need to understand an entire module at once.

**Prompt in Chat panel:**
```
/explain #file:src/infrastructure/database/query-builder.ts
Give me a high-level overview of what this module does, then explain
the QueryBuilder class in detail: its constructor, the methods it
exposes, and the order in which they are meant to be called.
```

**What this produces:**
Copilot reads the full file and generates a structured explanation that typically covers:
- Module purpose (e.g., "This is a fluent query builder for PostgreSQL using the `pg` driver directly, without an ORM")
- Class responsibility breakdown
- The intended method call order (e.g., `from()` → `where()` → `select()` → `build()`)
- Any internal state the class tracks

**Follow-up prompts that work well after a file explanation:**
```
How is error handling done in this file? Are there any cases where
a database error would be silently swallowed?
```

```
If I wanted to add support for JOIN clauses, where in this file
would I add that, and what interface would I follow?
```

**Tip:** When you attach a large file, be explicit about _which part_ you care most about. "Explain the whole file" on a 600-line file produces a wall of text. "Explain the `QueryBuilder` class — skip the helper functions at the top" produces something you can act on.

---

## Example 3: `/explain` with `@workspace` for Architecture Questions

**When to use this:** You want to understand how something works _across the codebase_, not just in one file. `@workspace` triggers Copilot to search the workspace index for relevant files, not just the current file.

**Prompt in Chat panel:**
```
/explain @workspace
How does a user's password get hashed and stored when they register?
Walk me through the entire chain: from the POST /api/v1/auth/register
endpoint, through any service layer, down to the database write.
```

**What this produces:**
Copilot traces the call chain across files, typically surfacing:
- The route handler (`src/routes/auth.ts`)
- The auth service (`src/services/auth.service.ts`)
- The password hashing utility (e.g., `bcrypt` usage in `src/utils/hash.ts`)
- The user repository (`src/repositories/user.repository.ts`)
- The database call

**Another useful `@workspace` pattern:**
```
/explain @workspace
What is the difference between how the app handles authentication
for web requests vs. API requests? Are there separate middleware paths?
```

**When `@workspace` gives poor results:**
- If your workspace is very large (hundreds of thousands of files), Copilot's workspace index may miss relevant files
- For large codebases, be more specific: instead of `@workspace`, attach the specific files you know are relevant with `#file`

---

## Example 4: `/explain` on Terminal Output

**When to use this:** You have a confusing error message, a failing test, or unexpected output in the terminal and you want help understanding what went wrong.

**First, reproduce the error in your terminal.** Then, in the Chat panel:

```
/explain @terminal
The test suite just failed. Can you explain what the error means and
which part of the stack trace I should focus on first?
```

**Example terminal output that this works well for:**

```
FAIL src/services/notification.service.test.ts
  ● NotificationService › sendEmailNotification › should retry on transient failure

    expect(received).toHaveBeenCalledTimes(expected)

    Expected number of calls: 3
    Received number of calls: 1

      at Object.<anonymous> (src/services/notification.service.test.ts:87:45)
```

**Copilot's explanation would cover:**
- The test expected the `sendEmail` mock to be called 3 times (retry logic), but it was only called once
- This means the retry mechanism is either not implemented or not being triggered
- The relevant line to inspect is line 87 of `notification.service.test.ts`

**Follow-up prompt after the explanation:**
```
/fix #file:src/services/notification.service.ts #file:src/services/notification.service.test.ts
Based on the test failure above, fix the retry logic in the service so
the test passes. The service should retry up to 3 times on a 429 or 503 response.
```

**When `@terminal` is not attached automatically:**
If Copilot does not pick up the terminal output automatically, copy the relevant error output and paste it directly into the chat with your `/explain` prompt.

---

## Example 5: Explaining a Regular Expression

**When to use this:** Regular expressions are notoriously hard to read. `/explain` with `#selection` is excellent for this.

**Selected code:**
```typescript
const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
```

**Prompt:**
```
/explain #selection
Break this regex down segment by segment. What email formats does it
accept and what does it reject? Does it comply with RFC 5322?
```

---

## Example 6: Explaining an Unfamiliar Pattern or Library

**When to use this:** You see an unfamiliar design pattern, decorator, or library API and want context about why the code is written the way it is.

**Selected code:**
```typescript
@Injectable()
export class OrderService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @Inject(CACHE_MANAGER)
    private readonly cacheManager: Cache,
  ) {}
}
```

**Prompt:**
```
/explain #selection
I'm new to NestJS. Explain what @Injectable, @InjectRepository, and
@Inject are doing here, and how the dependency injection system knows
what to pass to this constructor.
```

---

## Tips for Better Explanations

**1. Be specific about what confuses you.**

Instead of:
```
/explain #selection
```

Try:
```
/explain #selection
I understand what the function does at a high level. What I don't
understand is why it uses a WeakMap instead of a regular Map, and
what garbage collection behavior that changes.
```

**2. Tell Copilot your level of familiarity.**

```
/explain #file:src/core/event-bus.ts
I'm a backend developer who is unfamiliar with event-driven
architecture. Explain this event bus as if I haven't worked with
pub/sub before, then explain the specific implementation choices.
```

**3. Ask for comparisons.**

```
/explain #selection
How is this implementation different from a standard Promise chain?
What are the advantages of using async generators here?
```

**4. Ask "why" not just "what".**

```
/explain #selection
I can see what this code does. What I want to understand is why
the author chose this approach. What alternatives exist and what
tradeoffs does this design make?
```

**5. Break large explanations into parts.**

For a complex file, ask about one section at a time rather than the whole file. Context window limits can cause Copilot to rush through later sections of a large explanation.

---

## Inline Chat vs. Chat Panel for `/explain`

| Use Case | Recommended Surface |
|---|---|
| Quick "what does this do?" on a selected function | Inline chat (`Ctrl+I`) |
| Deep-dive on a whole file | Chat panel |
| Architecture questions across files | Chat panel with `@workspace` |
| Terminal error interpretation | Chat panel with `@terminal` |
| Multi-turn exploration with follow-ups | Chat panel |
