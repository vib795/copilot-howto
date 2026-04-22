# Using the Copilot Coding Agent in GitHub Actions

The Copilot coding agent is an autonomous AI agent that can read a GitHub issue, understand the task, write code, run tests, and open a pull request — all without a developer writing a single line of code.

This document covers how to trigger and configure the Copilot coding agent, what it can and cannot do, and how to integrate it into your team's workflow.

---

## What the Copilot Coding Agent Is

The Copilot coding agent is not a chat assistant. It is an **autonomous coding agent** that:

1. Reads a GitHub issue (title, body, and comments)
2. Explores the repository to understand the codebase
3. Writes a plan
4. Implements the changes (creates/edits files)
5. Runs tests and fixes failures
6. Opens a pull request with the changes for human review

The agent runs in a GitHub Actions runner — a fresh, isolated environment — with access to your repository. It does not have access to external services unless you explicitly configure it.

The key distinction from Copilot Chat: **it takes action**, not just advice.

---

## How to Trigger the Copilot Coding Agent

### Method 1: `@copilot` in an Issue Comment

The most common trigger is mentioning `@copilot` in a comment on a GitHub issue:

```
@copilot Please implement this feature. Focus on the `src/api/users.ts` file.
The acceptance criteria are in the issue description.
```

When GitHub detects this mention, it dispatches the coding agent workflow automatically.

**What happens next:**
1. GitHub adds a "thinking" reaction to your comment
2. The agent workflow starts (visible in the Actions tab)
3. The agent explores the repo, writes the code, and opens a PR
4. GitHub notifies you when the PR is ready (usually 3–10 minutes)

### Method 2: Workflow Dispatch (Manual Trigger)

You can manually trigger the agent from the GitHub Actions UI or via the API:

```yaml
# In your workflow file
on:
  workflow_dispatch:
    inputs:
      issue_number:
        description: 'Issue number to implement'
        required: true
        type: number
```

Then trigger it:
```bash
gh workflow run copilot-agent.yml -f issue_number=42
```

### Method 3: Automated Triggers

You can configure the agent to run automatically based on labels or events:

```yaml
on:
  issues:
    types: [labeled]

jobs:
  run-agent:
    if: github.event.label.name == 'copilot-implement'
    runs-on: ubuntu-latest
    steps:
      - uses: github/copilot-coding-agent@v1
        with:
          issue-number: ${{ github.event.issue.number }}
```

Adding the `copilot-implement` label to an issue triggers the agent.

---

## The Agent Workflow

Here is a minimal working workflow file for the Copilot coding agent:

```yaml
# .github/workflows/copilot-agent.yml
name: Copilot Coding Agent

on:
  issue_comment:
    types: [created]

permissions:
  contents: write        # Create branches and commits
  pull-requests: write   # Open pull requests
  issues: write          # Add reactions and comments to issues

jobs:
  copilot-agent:
    # Only run when @copilot is mentioned in an issue comment (not a PR comment)
    if: |
      github.event.issue.pull_request == null &&
      contains(github.event.comment.body, '@copilot')
    runs-on: ubuntu-latest

    steps:
      - name: Run Copilot coding agent
        uses: github/copilot-coding-agent@v1
        with:
          # The issue number to implement
          issue-number: ${{ github.event.issue.number }}

          # GitHub token with sufficient permissions
          github-token: ${{ secrets.GITHUB_TOKEN }}

          # Optional: restrict which paths the agent can modify
          # allowed-paths: |
          #   src/
          #   tests/
          #   docs/

          # Optional: paths the agent must not touch
          # denied-paths: |
          #   .github/
          #   infrastructure/
          #   secrets/
```

---

## Use Cases

### Implementing Small Features from Well-Written Issues

The agent works best when the issue is specific and contains:
- A clear description of what to build
- Acceptance criteria (ideally as a checklist)
- Pointers to relevant files if the codebase is large

**Good issue for the agent:**
```
## Add email validation to the user registration form

**Current behavior:** The registration form accepts any string in the email field.

**Expected behavior:** The email field should validate the format on blur and
show an error message if invalid.

**Acceptance criteria:**
- [ ] Email field validates on blur (when the user leaves the field)
- [ ] Shows "Please enter a valid email address" for invalid formats
- [ ] Clears the error when the user corrects the email
- [ ] Does not prevent form submission for a split second (debounce if needed)

**Relevant files:**
- `src/components/RegistrationForm.tsx`
- `src/utils/validators.ts` (add the email validator here)
- `tests/components/RegistrationForm.test.tsx`
```

### Fixing Failing Tests

The agent can look at a failing test, understand the failure, and fix either the test or the implementation:

```
@copilot The tests in `tests/api/users.test.ts` have been failing since the
last merge. The failure message is:

  TypeError: Cannot read property 'id' of undefined
  at UserService.getUser (src/services/UserService.ts:45)

Please investigate and fix the root cause. Do not change the test assertions
unless the test itself is wrong.
```

### Generating Boilerplate

The agent can generate boilerplate that follows your project's patterns:

```
@copilot Please add a new `ProductsController` that follows the same pattern
as `UsersController` in `src/controllers/UsersController.ts`. It should have
GET /products, GET /products/:id, POST /products, PUT /products/:id, and
DELETE /products/:id endpoints. Add the corresponding service and tests.
```

---

## Limitations

### Works Best With Small, Well-Scoped Tasks

The agent struggles with:

- **Large refactors** that touch 20+ files — it may make inconsistent changes or miss some files
- **Architecture decisions** — it will implement what you describe, not necessarily what is optimal
- **Cross-repository changes** — it can only modify one repository per run
- **External service configuration** — it cannot set up databases, cloud resources, or third-party services

### The Agent Needs Good Context

If your issue says "fix the bug," the agent will struggle. If it says "fix the NullPointerException on line 45 of UserService.java when userId is null," it will likely succeed.

### Test Availability Matters

The agent runs your test suite to verify its changes. If your tests are:
- Missing (no test coverage) — the agent cannot verify its work
- Flaky — the agent may spend time chasing non-existent failures
- Very slow (>10 min) — the agent run may time out

### It May Need Review

The agent's output should always be reviewed by a human before merging. It is a first draft, not a finished product. Common things to check:
- Does the implementation match the intent, not just the literal issue text?
- Are there edge cases the agent missed?
- Is the code style consistent with the rest of the codebase?

---

## Configuring Path Restrictions

You can control which parts of the codebase the agent is allowed to touch:

```yaml
- uses: github/copilot-coding-agent@v1
  with:
    issue-number: ${{ github.event.issue.number }}

    # The agent may only modify files in these directories
    allowed-paths: |
      src/features/
      tests/features/

    # Even within allowed paths, never touch these
    denied-paths: |
      src/features/payments/  # Too sensitive for automated changes
      src/features/auth/
```

Path restrictions are enforced by the action — the agent cannot commit changes outside the allowed paths even if it tries.

---

## Review Workflow

The Copilot coding agent always creates a pull request for human review. It never merges directly to the default branch.

**Recommended review workflow:**

1. Agent opens a PR with a descriptive title and summary
2. Automated CI runs on the PR (tests, lint, format checks)
3. A human reviews the diff — focus on correctness and edge cases
4. If changes are needed, you can either:
   - Comment on the PR with `@copilot please also handle the case where X`
   - Edit the files directly and push additional commits
5. Once satisfied, approve and merge normally

The agent will re-trigger if you comment `@copilot` on the PR with additional instructions.

---

## Enabling the Coding Agent in Your Organization

1. **Enable Copilot coding agent** in your organization settings:
   - Organization Settings → Copilot → Policies → Coding agent: Enabled

2. **Ensure the workflow exists** in your repository (`.github/workflows/copilot-agent.yml`)

3. **Set required permissions** on the repository:
   - Settings → Actions → General → Workflow permissions → Read and write permissions

4. **Test with a low-stakes issue** before relying on it for important work

---

## Further Reading

- [Copilot coding agent documentation](https://docs.github.com/en/copilot/using-github-copilot/using-copilot-coding-agent)
- [Writing effective issues for the coding agent](https://docs.github.com/en/copilot/using-github-copilot/writing-issues-for-copilot)
- [Copilot in GitHub Actions](https://docs.github.com/en/copilot/using-github-copilot/copilot-in-github-actions)
