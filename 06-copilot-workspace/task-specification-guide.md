# Writing Effective Task Specifications for Copilot Workspace

The task specification is the single most important factor in the quality of Workspace output. A vague specification produces a vague plan and mediocre code. A precise specification with acceptance criteria and file references produces a plan you can approve with confidence.

This guide covers what makes a specification effective, provides a reusable template, and walks through good vs. bad examples for three common scenarios.

---

## What Makes a Good Task Specification

### 1. It Describes the Goal, Not Just the Symptom

Bad: "The login is broken."
Good: "The login endpoint returns 500 when the username contains a special character. Fix the input sanitization in `src/auth/LoginService.ts`."

The goal includes enough context that Workspace can identify the right files and the right solution without guessing.

### 2. It Names Affected Files (If Known)

Workspace can find relevant files on its own, but naming them saves time and produces more accurate plans:

Bad: "Add validation to the registration form."
Good: "Add email format validation to `src/components/RegistrationForm.tsx`. Use the existing `validateEmail` function from `src/utils/validators.ts`."

### 3. It Includes Acceptance Criteria

Acceptance criteria are the most powerful part of a task specification. They give Workspace a checklist to implement against and give you a way to verify the output:

```
Acceptance criteria:
- [ ] Email validation fires on blur (not on every keypress)
- [ ] Error message: "Please enter a valid email address"
- [ ] Error clears when the user fixes the input
- [ ] Form still submits if the field is empty (email is optional)
- [ ] Add unit test for each acceptance criterion
```

### 4. It States Constraints Explicitly

Tell Workspace what not to do:
- "Do not change the database schema — this is a frontend-only change."
- "Do not rewrite the existing tests — only add new ones."
- "Do not change the public API surface of this module."

### 5. It References Existing Patterns

Workspace learns from your codebase, but explicitly pointing to a reference implementation dramatically improves consistency:

"Follow the same pattern as `src/services/ProductService.ts` — it already handles the error cases correctly."

---

## Template Structure

Use this template when writing or editing a Workspace task specification:

```
## Background

[1-3 sentences explaining the current state and why this change is needed.
Include relevant context like: which users are affected, why this matters,
what the current behavior is.]

## Goal

[1-2 sentences describing the desired outcome. Focus on the result, not
the implementation steps.]

## Acceptance Criteria

- [ ] [Specific, testable criterion 1]
- [ ] [Specific, testable criterion 2]
- [ ] [Tests added for the above]

## Files to Change

(Optional — include if you know which files are involved)

- `path/to/primary/file.ts` — [what needs to change]
- `path/to/test/file.test.ts` — [what tests to add]
- `path/to/route/file.ts` — [how to register the new functionality]

## Reference Implementation

(Optional — point to an existing file that uses the pattern you want)

See `path/to/similar/file.ts` for the pattern to follow.

## Do Not Touch

(Optional — prevents unintended changes)

- `src/legacy/` — legacy code, do not refactor
- `docs/` — documentation will be updated separately
- Database schema — this change is application-layer only
```

---

## Good vs. Bad Examples

### Scenario 1: Feature Addition

**BAD specification:**

```
Add a dark mode toggle to the settings page.
```

Problems:
- No acceptance criteria
- No file references
- "Settings page" could mean many things in a large app
- Doesn't specify where the preference should be stored
- Doesn't specify whether this is a global or per-user setting

**GOOD specification:**

```
## Background

Users have requested a dark mode option. We store user preferences in the
`user_preferences` table (column already exists: `display_theme VARCHAR`).

## Goal

Add a dark/light mode toggle to the Settings page. The selected theme should
persist across sessions.

## Acceptance Criteria

- [ ] The Settings page (`src/pages/Settings.tsx`) shows a toggle: "Dark mode"
- [ ] Toggle reads the current value from `UserPreferencesService.getTheme()`
- [ ] Toggling saves the new value via `UserPreferencesService.setTheme(theme)`
- [ ] The app's root CSS class updates immediately (no page reload required)
- [ ] Uses the existing `Toggle` component from `src/components/ui/Toggle.tsx`
- [ ] Add test: toggling dark mode calls setTheme('dark')
- [ ] Add test: toggling back calls setTheme('light')

## Files to Change

- `src/pages/Settings.tsx` — add dark mode toggle UI
- `src/services/UserPreferencesService.ts` — add getTheme/setTheme methods
- `src/App.tsx` — apply theme class based on preference on load

## Reference Implementation

See how `src/services/NotificationPreferencesService.ts` reads and writes
preferences for the same user_preferences table.

## Do Not Touch

- `src/styles/` — CSS variables are already set up for dark mode
- Database schema — the `display_theme` column already exists
```

---

### Scenario 2: Bug Fix

**BAD specification:**

```
The export to CSV is not working correctly.
```

Problems:
- "Not working" is vague — is it crashing? Producing wrong data? Timing out?
- No reproduction steps
- No expected vs. actual behavior

**GOOD specification:**

```
## Background

The "Export to CSV" button on the Orders page produces a CSV where the
`order_date` column contains UTC timestamps (e.g., "2024-01-15T08:30:00Z")
instead of the user's local date (e.g., "2024-01-15"). This was reported by
users in non-UTC time zones who see dates that are off by one day.

## Goal

Fix the date formatting in the CSV export so that `order_date` is formatted
as `YYYY-MM-DD` in the user's local timezone, not UTC.

## Acceptance Criteria

- [ ] CSV `order_date` column shows `YYYY-MM-DD` format (not ISO 8601)
- [ ] The date reflects the user's browser timezone (use `Intl.DateTimeFormat`)
- [ ] Other date columns (if any) are not changed
- [ ] Add test: order on 2024-01-15 at 23:30 UTC, user in UTC-5, exports as "2024-01-15"

## Files to Change

- `src/utils/csvExport.ts` — the `formatDate` function at line ~45 is the problem
- `tests/utils/csvExport.test.ts` — add the timezone test case

## Do Not Touch

- The display of dates in the Orders table (separate component, separate fix)
- Any other export formats (PDF export has its own date handling)
```

---

### Scenario 3: Refactoring

**BAD specification:**

```
Refactor the authentication code to be cleaner.
```

Problems:
- "Cleaner" is subjective — Workspace will guess what you mean
- No scope definition — could touch dozens of files
- No acceptance criteria for "done"
- High risk of breaking working code

**GOOD specification:**

```
## Background

The `AuthController` (src/controllers/AuthController.ts) currently handles
both business logic and HTTP request/response formatting. This violates the
single responsibility principle and makes the controller hard to test.

## Goal

Extract the business logic from AuthController into a new `AuthService` class,
leaving the controller responsible only for parsing requests and formatting
responses.

## Acceptance Criteria

- [ ] `src/services/AuthService.ts` is created with methods:
      `login(email, password)`, `logout(token)`, `refreshToken(token)`
- [ ] `AuthController` delegates to `AuthService` — no business logic remains
      in the controller itself
- [ ] All existing tests continue to pass without modification
- [ ] Add unit tests for `AuthService` that mock the database directly
- [ ] The public API (routes, request/response shapes) does not change

## Files to Change

- `src/controllers/AuthController.ts` — remove business logic, delegate to service
- `src/services/AuthService.ts` — create this file with extracted logic
- `src/routes/auth.routes.ts` — no functional change, but update imports if needed
- `tests/services/AuthService.test.ts` — new test file

## Reference Implementation

See `src/services/UserService.ts` for the service pattern to follow.
See `src/controllers/UserController.ts` for what a "thin controller" looks like.

## Do Not Touch

- `src/middleware/` — authentication middleware is separate and not changing
- Database models — no schema changes
- Any file outside `src/controllers/`, `src/services/`, `src/routes/`
```

---

## How Workspace Uses the Specification to Generate Its Plan

When Workspace reads your task specification, it:

1. **Scans the named files** first — if you named files, those become the starting points for the plan
2. **Searches for related files** using symbol search (function names, imports, exports)
3. **Reads the acceptance criteria** to determine how many plan steps are needed
4. **Checks for referenced patterns** (your "Reference Implementation") and models the generated code after them
5. **Respects "Do Not Touch"** by excluding those paths from the plan

This means:
- The more files you name, the more targeted the plan
- The more specific the acceptance criteria, the more complete the implementation
- A reference implementation dramatically improves code style consistency

---

## Iterating on a Plan

If the generated plan is not quite right, you have three options before approving it:

### Option 1: Edit the Task Specification

This is the highest-leverage option. If the plan is going in the wrong direction, rewrite the specification rather than trying to fix the plan step by step.

Click "Edit task" in the Workspace UI, update the spec, and click "Regenerate plan."

### Option 2: Edit Individual Plan Steps

For minor adjustments, click on a plan step to edit its description:

- "Also update the test for the 404 case" → adds a test for an edge case
- "Do not change the error message text" → prevents unwanted string changes
- "Use `zod` for validation, not manual if-statements" → steers implementation

### Option 3: Delete Plan Steps

If Workspace included a step you don't want (e.g., it wants to update a migration file but you want to do that manually), delete that step. Workspace will implement all remaining steps without it.

---

## Quick Reference Checklist

Before opening a Workspace session, verify your task specification answers:

- [ ] What is the current behavior? (background)
- [ ] What is the desired behavior? (goal)
- [ ] How will we know it is done? (acceptance criteria)
- [ ] Which files need to change? (files to change)
- [ ] What pattern should the code follow? (reference implementation)
- [ ] What should not change? (do not touch)

A specification that answers all six questions will produce a plan you can approve with minimal editing and an implementation you can ship with minimal rework.
