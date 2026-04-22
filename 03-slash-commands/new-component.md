# `/new` — Practical Examples

The `/new` command scaffolds net-new code from a description. It is distinct from other commands because it creates files or code blocks that do not yet exist, rather than modifying existing code. The quality of the output is directly proportional to the specificity of your description.

---

## Example 1: Scaffold a React Component

**Scenario:** You need a reusable card component for displaying user profile information. You want it to follow your project's conventions: TypeScript, functional components, named exports, no default exports.

**Prompt:**
```
/new
Create a React functional component called UserProfileCard.
Requirements:
- TypeScript with strict types
- Named export (not default export)
- Props: user (object with id: string, name: string, email: string, avatarUrl: string, role: 'admin' | 'editor' | 'viewer')
- Renders: avatar image, name, email, and a role badge
- The role badge should have different background colors per role:
  admin = red, editor = blue, viewer = gray
- Accepts an optional onClick prop that receives the user id
- Accepts an optional className prop for custom styling
- Use Tailwind CSS utility classes
- No inline styles
File location: src/components/UserProfileCard/UserProfileCard.tsx
Also create: src/components/UserProfileCard/index.ts (barrel export)
```

**Generated output (typical):**
```tsx
// src/components/UserProfileCard/UserProfileCard.tsx

import React from 'react';

type UserRole = 'admin' | 'editor' | 'viewer';

interface User {
  id: string;
  name: string;
  email: string;
  avatarUrl: string;
  role: UserRole;
}

interface UserProfileCardProps {
  user: User;
  onClick?: (userId: string) => void;
  className?: string;
}

const ROLE_BADGE_STYLES: Record<UserRole, string> = {
  admin: 'bg-red-100 text-red-700',
  editor: 'bg-blue-100 text-blue-700',
  viewer: 'bg-gray-100 text-gray-700',
};

export function UserProfileCard({ user, onClick, className = '' }: UserProfileCardProps) {
  return (
    <div
      className={`flex items-center gap-4 rounded-lg border border-gray-200 p-4 ${
        onClick ? 'cursor-pointer hover:bg-gray-50' : ''
      } ${className}`}
      onClick={() => onClick?.(user.id)}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
    >
      <img
        src={user.avatarUrl}
        alt={`${user.name}'s avatar`}
        className="h-12 w-12 rounded-full object-cover"
      />
      <div className="flex flex-col">
        <span className="font-semibold text-gray-900">{user.name}</span>
        <span className="text-sm text-gray-500">{user.email}</span>
        <span className={`mt-1 inline-block rounded-full px-2 py-0.5 text-xs font-medium ${ROLE_BADGE_STYLES[user.role]}`}>
          {user.role}
        </span>
      </div>
    </div>
  );
}
```

**Immediately after:** Combine with `/tests` to generate tests for this new component (see [chaining-commands.md](./chaining-commands.md)).

---

## Example 2: Scaffold an Express API Endpoint

**Scenario:** You need a new REST endpoint to create an order. You want Copilot to generate the route handler, request validation, and error handling.

**Prompt:**
```
/new
Create an Express route handler for POST /api/v1/orders.
Requirements:
- TypeScript
- Uses express-validator for input validation
- Request body shape: { customerId: string, items: Array<{ productId: string, quantity: number }>, shippingAddressId: string }
- Validation rules:
  - customerId: required, non-empty string
  - items: required, non-empty array; each item must have productId (non-empty string) and quantity (integer, min 1)
  - shippingAddressId: required, non-empty string
- If validation fails: return 422 with a structured error body { errors: ValidationError[] }
- On success: call OrderService.create(dto) and return 201 with the created order
- Handle OrderService throwing a CustomerNotFoundError as a 404
- Handle OrderService throwing any other error as a 500
- Use async/await, not .then()
File: src/api/routes/orders.route.ts
```

**Generated output includes:**
- Import statements for Express, express-validator, and the OrderService
- A `router.post('/api/v1/orders', [...validationMiddleware], asyncHandler(createOrder))` pattern
- The handler function with full try/catch and typed error handling
- Clean separation between validation middleware and handler logic

---

## Example 3: Scaffold a Python Class from a Spec

**Scenario:** You need a data access object for a `products` table in PostgreSQL, using asyncpg.

**Prompt:**
```
/new
Create a Python class called ProductRepository for the products table in PostgreSQL.
Use asyncpg for database access. The class should be instantiated with an asyncpg connection pool.

Methods to implement:
- async find_by_id(product_id: int) -> Optional[Product]
- async find_all(limit: int = 50, offset: int = 0) -> list[Product]
- async find_by_category(category_id: int) -> list[Product]
- async create(dto: CreateProductDTO) -> Product
- async update(product_id: int, dto: UpdateProductDTO) -> Optional[Product]
- async delete(product_id: int) -> bool

Types:
- Product: dataclass with id: int, name: str, price_cents: int, category_id: int, created_at: datetime, updated_at: datetime
- CreateProductDTO: dataclass with name: str, price_cents: int, category_id: int
- UpdateProductDTO: dataclass with optional name, price_cents, category_id (all Optional)

Return None / False for find/update/delete when the row does not exist.
Raise ProductRepositoryError (a custom exception) on database errors.
File: src/repositories/product_repository.py
```

---

## Example 4: `/new` with Custom Instructions to Enforce Naming Conventions

**Scenario:** Your team has strict conventions that you cannot rely on Copilot to follow by default. Add them to `.github/copilot-instructions.md` so they apply automatically to every `/new` command.

**In `.github/copilot-instructions.md`:**
```markdown
## Code Generation Conventions

When generating new files:
- TypeScript files: kebab-case filenames (e.g., user-profile-card.tsx, not UserProfileCard.tsx)
- React components: functional, named exports only, no default exports
- Services: classes with constructor injection; no static methods
- All new TypeScript files must start with 'use strict'; not needed — just ensure strict: true is in tsconfig
- Test files: co-located with the source file (e.g., user.service.test.ts next to user.service.ts)
- Do not generate barrel index.ts files unless explicitly requested
```

With these instructions in place, when you type:
```
/new
Create a service class for sending SMS notifications using Twilio.
```

Copilot will automatically:
- Name the file `sms-notification.service.ts` (not `SmsNotificationService.ts`)
- Use a class with constructor injection (not a module with exported functions)
- Follow the project's other conventions without you having to repeat them

---

## Example 5: Combining `/new` with `/tests`

**Scenario:** You want to create a new utility module and immediately generate tests for it, without leaving the chat.

**Step 1: Scaffold the module.**
```
/new
Create a TypeScript module called slug-utils.ts in src/utils/.
Export the following functions:
- slugify(text: string): string — converts a string to a URL-friendly slug
  (lowercase, hyphens for spaces, removes non-alphanumeric characters except hyphens)
- truncateSlug(slug: string, maxLength: number): string — truncates a slug to maxLength
  characters, ensuring it does not end with a hyphen
- isValidSlug(slug: string): boolean — returns true if the string is a valid slug
  (lowercase alphanumeric and hyphens, no leading/trailing hyphens, no consecutive hyphens)
```

**Step 2: After accepting the generated code, generate tests in the same session.**
```
/tests #file:src/utils/slug-utils.ts
Generate Jest unit tests for all three functions in slug-utils.ts.
- slugify: test spaces, special characters, consecutive spaces, unicode, empty string
- truncateSlug: test exact maxLength, over maxLength ending in a hyphen, under maxLength
- isValidSlug: test valid slugs, leading/trailing hyphens, consecutive hyphens, uppercase letters, empty string
Use describe blocks per function and it() for each case.
```

**Why this workflow works well:** The Chat panel retains the context of the just-generated `slug-utils.ts`, so when you reference `#file:src/utils/slug-utils.ts` in the follow-up, Copilot has both the code it just wrote and the file content in context.

---

## Tips for Better `/new` Output

**1. Specify the exact file path.**
```
/new
... create the file at src/services/stripe/stripe-webhook.handler.ts
```
Without this, Copilot may suggest a generic filename or omit the path entirely.

**2. List every method you need.**
Copilot can infer reasonable methods from a description, but for a data access object or service class, explicit method names and signatures produce more accurate code.

**3. Describe the error handling behavior.**
```
/new
... when the upstream API returns a 429, throw RateLimitError with the retry-after header value.
When it returns a 5xx, throw UpstreamServiceError. For any other error, throw UnknownServiceError.
```

**4. Tell Copilot about existing patterns.**
```
/new ... Follow the same pattern as #file:src/services/email.service.ts
```
This is often the most effective instruction: point at an existing file and say "do it like this."

**5. Review the output as a diff, not a given.**
`/new` output is a starting point. Review it for:
- Missing null checks
- Over-permissive types (`any`, missing generics)
- Missing error handling branches
- Hardcoded values that should be configurable
