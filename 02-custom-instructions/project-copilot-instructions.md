# Template: `.github/copilot-instructions.md`

This file is a production-ready template for a Node.js/TypeScript + PostgreSQL + React 18 project. Copy it to `.github/copilot-instructions.md` in your repository and customize it.

---

## The Template

Copy everything below the horizontal rule into your `.github/copilot-instructions.md` file.

---

```markdown
<!-- This file is auto-loaded by GitHub Copilot for all chat interactions in this repository. -->
<!-- Keep it under 8,000 characters to avoid consuming the context window budget. -->

# Acme Platform — Copilot Instructions

## Project Overview

This is **Acme Platform**, a B2B SaaS order management system serving ~200 enterprise customers.
Stack: Node.js 20 + TypeScript 5 (backend), React 18 + Vite (frontend), PostgreSQL 15 (database).
Team size: 8 engineers. Monorepo: `packages/api` (Express), `packages/web` (React), `packages/shared` (types/utils).

## Architecture

The project architecture is documented in `docs/architecture.md`.
When answering architecture questions, ask the user to attach it with `#file:docs/architecture.md`.

Key patterns:
- **API**: RESTful, versioned at `/api/v1/`. Controllers → Services → Repositories → PostgreSQL.
- **Frontend**: React 18 with React Query for server state, Zustand for client state, React Router v6.
- **Auth**: JWT (RS256) issued by the API, validated in Express middleware. 15-minute access tokens, 7-day refresh tokens.
- **Database**: Raw SQL via `pg` driver (no ORM). Migrations managed by `node-pg-migrate`. Schema in `packages/api/db/schema/`.

## Code Style

- TypeScript strict mode is enabled (`strict: true` in tsconfig). Never suppress type errors with `any` or `@ts-ignore`.
- Prettier with default config (no `.prettierrc` — uses defaults). 2-space indentation. 100-character max line length.
- ESLint with `eslint-config-airbnb-typescript`. Follow all rules unless a specific disable comment explains why.
- Trailing commas in multi-line structures (`"trailingComma": "all"` in Prettier).
- Single quotes for strings in TypeScript/JavaScript. Double quotes in JSON.
- Prefer `const` over `let`. Never use `var`.
- Use `async/await` over `.then()` chains.
- Prefer functional array methods (`map`, `filter`, `reduce`) over `for` loops when readability is equivalent.

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files (TypeScript) | kebab-case | `user-profile.service.ts` |
| Files (React components) | kebab-case | `user-profile-card.tsx` |
| TypeScript classes | PascalCase | `UserProfileService` |
| TypeScript interfaces/types | PascalCase | `UserProfile`, `CreateUserDTO` |
| Functions and variables | camelCase | `getUserById`, `isValidEmail` |
| Constants (module-level) | UPPER_SNAKE_CASE | `MAX_RETRY_ATTEMPTS` |
| React components | PascalCase, named export | `export function UserProfileCard()` |
| Database tables | snake_case | `user_profiles` |
| Database columns | snake_case | `created_at`, `user_id` |
| Environment variables | UPPER_SNAKE_CASE | `DATABASE_URL`, `JWT_SECRET` |

## Testing

- Framework: Jest + ts-jest for unit and integration tests. React Testing Library for component tests.
- Test file naming: `*.test.ts` / `*.test.tsx`, co-located with the source file.
  - Example: `user.service.test.ts` lives next to `user.service.ts`
- Structure: `describe` blocks for classes/modules, `it` blocks for individual cases.
- Minimum coverage: 80% branch coverage enforced by CI.
- Mocking: Use `jest.spyOn` for mocking methods. Use `jest.mock()` for mocking whole modules only when necessary.
- External services (database, HTTP calls, Redis) must always be mocked in unit tests.
- Integration tests in `packages/api/test/integration/` use a real test database (seeded by fixtures).

## Git and Pull Requests

- Commit message format: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`).
- All changes go through a PR. Direct pushes to `main` are not allowed.
- Minimum 1 approval required before merging.
- PRs must pass: lint, type check, unit tests, and integration tests in CI before merge.
- Branch naming: `feat/short-description`, `fix/short-description`, `chore/short-description`.

## API Design

- All API routes are versioned: `/api/v1/...`
- JSON request and response bodies everywhere. No form encoding.
- Use HTTP status codes semantically: 200 OK, 201 Created, 204 No Content, 400 Bad Request (validation), 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict, 422 Unprocessable Entity, 500 Internal Server Error.
- Error response shape: `{ "error": { "code": "ERROR_CODE", "message": "Human-readable message", "details": {} } }`
- All endpoints must be documented with OpenAPI annotations (`swagger-jsdoc` in `packages/api/src/docs/`).
- Pagination: `GET /resource` returns `{ data: T[], pagination: { page, pageSize, total, totalPages } }`.

## Database

- Raw SQL only. No ORM. Query helper is in `packages/api/src/db/query.ts`.
- Always use parameterized queries (`$1`, `$2`, ...). Never concatenate user input into SQL strings.
- Schema changes go through migrations in `packages/api/db/migrations/`. Never alter tables directly.
- Transactions: use `db.transaction(async (client) => { ... })` for operations that span multiple queries.
- Avoid N+1 queries. Use JOINs or batched queries for related data.

## Forbidden Patterns

- `any` type in TypeScript. Use `unknown` for truly unknown types, then narrow with type guards.
- `console.log` in production code. Use `logger.info()`, `logger.warn()`, `logger.error()` from `packages/shared/src/logger.ts`.
- Hardcoded credentials, API keys, connection strings, or secrets of any kind. Use environment variables.
- `@ts-ignore` or `@ts-nocheck`. Fix the type error properly.
- `document.write()` or `innerHTML` assignments (XSS risk). Use DOM methods or React.
- Synchronous file I/O (`readFileSync`, `writeFileSync`) in request handlers.
- Class components in React. Use functional components only.
- Default exports for React components or service classes. Use named exports.

## Common Commands

| Task | Command |
|---|---|
| Start dev server (API) | `cd packages/api && npm run dev` |
| Start dev server (Web) | `cd packages/web && npm run dev` |
| Run all tests | `npm test` (root — runs all packages) |
| Run tests for one package | `cd packages/api && npm test` |
| Run tests with coverage | `npm run test:coverage` |
| Type check | `npm run typecheck` |
| Lint | `npm run lint` |
| Format | `npm run format` |
| Build | `npm run build` |
| Run database migrations | `cd packages/api && npm run db:migrate` |
| Rollback last migration | `cd packages/api && npm run db:rollback` |
| Seed test database | `cd packages/api && npm run db:seed:test` |
```

---

## Notes on Using This Template

### Keeping It Under 8,000 Characters

The template above is approximately 4,500 characters — well within the recommended limit. As you customize it for your project, be mindful of length. Use these techniques to stay concise:

- Use bullet points and tables instead of prose paragraphs
- Do not explain "why" in the instructions (that goes in your project docs, not here)
- Remove sections that are already enforced automatically (e.g., if Prettier is configured in the repo, you do not need to repeat formatting rules here unless they are not captured by Prettier defaults)
- Prune sections that do not apply to your stack

### Verifying the Instructions Are Loaded

After saving the file, open Copilot Chat and ask a question that your instructions should answer:

```
What naming convention do we use for database columns?
```

If Copilot answers correctly (snake_case, per the template), the file is being loaded. If it answers generically ("it depends on your project"), the file may not be in the right location or may have a syntax issue.

### The Architecture Note

The template references `docs/architecture.md` and instructs Copilot to tell the user to attach it manually. This is intentional — you should not embed your entire architecture document inside `copilot-instructions.md` (it would blow the token budget). Instead, keep it as a separate file and attach it with `#file:docs/architecture.md` when asking architecture questions.

### Updating Instructions as the Project Evolves

Review and update `.github/copilot-instructions.md` when:
- The team adopts a new testing framework or library
- Naming conventions change
- New forbidden patterns are discovered
- The project's architecture evolves significantly

Treat it like any other configuration file: keep it version-controlled, review changes in PRs, and update it when the underlying standards change.
