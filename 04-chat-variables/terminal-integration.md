# Terminal Integration: @terminal and Terminal Variables

GitHub Copilot has three ways to read your terminal: the `@terminal` participant, the `#terminalLastCommand` variable, and the `#terminalSelection` variable. Together they let you ask Copilot about build errors, failed commands, and cryptic log output without leaving the editor or copying text.

---

## Understanding the Difference

| Variable | What It Reads | When to Use |
|---|---|---|
| `@terminal` | Summarized context from the active terminal session | High-level questions: "what went wrong?", "what should I run next?" |
| `#terminalLastCommand` | The last command you ran + its complete output | Specific questions about the most recent command |
| `#terminalSelection` | Text you have selected in the terminal | Questions about a specific part of a long log |

**Critical note:** All three are **read-only**. Copilot can see your terminal; it cannot type into it or run commands. When Copilot suggests a fix command, you must run it yourself.

---

## Pattern 1: Debugging a Failed Command

**Scenario:** You ran a command and it failed. You want to know why.

```
@terminal why did the last command fail?
```

**What Copilot does:** Reads the terminal session context, identifies the command that ran, reads the error output, and explains what went wrong — usually with a specific explanation and a suggested fix command.

**Example scenario:**
```bash
# You ran:
npm install

# Terminal shows:
npm ERR! code ERESOLVE
npm ERR! ERESOLVE unable to resolve dependency tree
npm ERR!
npm ERR! While resolving: my-app@1.0.0
npm ERR! Found: react@18.2.0
npm ERR! node_modules/react
npm ERR!   react@"^18.0.0" from the root project
npm ERR!
npm ERR! Could not resolve dependency:
npm ERR! peer react@"^17.0.0" from some-legacy-package@2.1.0

# You ask:
@terminal why did the last command fail?
```

**Copilot's response** will explain the React peer dependency conflict and suggest concrete options: upgrade the legacy package, use `--legacy-peer-deps`, or pin React to 17.

---

## Pattern 2: Explaining a Stack Trace

**Scenario:** Your test suite failed and printed a multi-line stack trace. You want it explained.

```
@terminal #terminalLastCommand explain this stack trace. What is the root cause and which file should I look at first?
```

**Why use both `@terminal` and `#terminalLastCommand`:** `@terminal` activates the terminal-aware agent; `#terminalLastCommand` attaches the exact output. Using both ensures Copilot has both the contextual awareness and the raw text.

**Example scenario:**
```bash
# You ran:
npm test

# Output includes:
  ● UserService › createUser › should reject duplicate email

    TypeError: Cannot read properties of undefined (reading 'findOne')

      at UserService.createUser (src/services/user-service.js:23:28)
      at Object.<anonymous> (tests/user-service.test.js:41:33)
```

```
@terminal #terminalLastCommand the test is failing with a TypeError. What is undefined at line 23 in user-service.js?
```

**Copilot** will explain that `this.userRepository` is `undefined`, which means the dependency was not injected — either the constructor was not called with the repo argument, or the mock was not set up correctly in the test.

---

## Pattern 3: Getting Next Steps After a Failure

**Scenario:** A build or deployment failed and you want to know what to investigate or run next.

```
@terminal the tests are failing. What should I run to get more details about which tests failed and why?
```

**Copilot** might respond with: "Run `npm test -- --verbose --no-coverage` to see the full test names without the coverage pass. If you want a specific test file, run `npm test -- tests/user-service.test.js`."

**Variation — after a TypeScript compile error:**
```
@terminal TypeScript compilation failed. What's the fastest way to see all the type errors at once, sorted by file?
```

**Copilot:** "Run `npx tsc --noEmit 2>&1 | head -50` to see the first 50 type errors without producing output files."

**Variation — after a Docker build failure:**
```
@terminal the Docker build failed. Where in the Dockerfile should I look and what does this layer caching error mean?
```

---

## Pattern 4: Selective Error Explanation with #terminalSelection

**Scenario:** Your terminal has 200 lines of output. One specific 10-line section has the relevant error. You do not want to ask Copilot to read all 200 lines.

**How to use it:**
1. In the terminal panel, click and drag to select just the error lines
2. In Copilot Chat, type your question with `#terminalSelection`:

```
#terminalSelection what does this error mean and how do I fix it?
```

**Why this is better than #terminalLastCommand for long outputs:** `#terminalLastCommand` attaches the complete command output, which might be thousands of lines for a long-running build. `#terminalSelection` lets you cherry-pick the relevant 5–20 lines, which saves tokens and focuses the answer.

**Example:** Select just these lines from a long Webpack output:

```
ERROR in ./src/components/Dashboard.tsx
Module build failed (from ./node_modules/babel-loader/lib/index.js):
SyntaxError: /src/components/Dashboard.tsx: Unexpected token (47:12)

  45 |   return (
  46 |     <div className="dashboard">
> 47 |       <h1>{ title </h1>
     |            ^
```

Then ask:
```
#terminalSelection this JSX is failing to compile. What's the syntax error?
```

**Copilot:** "The issue is on line 47: `{ title` is missing the closing `}` brace. It should be `{title}` or `{ title }`."

---

## Pattern 5: Test Failure Workflow

**Scenario:** You just made a change and want to test it, then ask Copilot to help fix any failures — all without leaving the editor.

**Step 1:** Run your tests in the integrated terminal:
```bash
npm test
```

**Step 2:** See failures. Ask Copilot for help:
```
@terminal #terminalLastCommand the tests are failing. Focus on the first failing test — what is the assertion that failed and why?
```

**Step 3:** Copilot explains the failure. You open the relevant file and make a fix.

**Step 4:** Run tests again. If they pass, you're done. If not, repeat.

**Full workflow prompt example:**
```
@terminal #terminalLastCommand the payment service tests are failing. The error says "Expected 200, received 402". I think the issue is with how the mock credit card numbers are validated. Is that consistent with what the stack trace shows?
```

This combines the terminal output context with your hypothesis, giving Copilot everything it needs to confirm or redirect your debugging.

---

## Pattern 6: Understanding Build Output

**Scenario:** Your production build succeeded but produced warnings you want to understand.

```bash
npm run build
# Output:
# WARNING in asset size limit: The following asset(s) exceed the recommended size limit (244 KiB).
# Assets:
#   vendor.js (892 KiB)
# WARNING in entrypoint size limit: The following entrypoint(s) combined asset size exceeds the recommended limit
```

Ask:
```
@terminal #terminalLastCommand the build succeeded but there are size limit warnings. How serious are these and what should I do to fix them?
```

**Copilot** will explain what the warning means (browser performance implications), and suggest concrete steps: code splitting, lazy loading, analyzing the bundle with `webpack-bundle-analyzer`.

---

## Pattern 7: Interpreting Shell Error Codes

**Scenario:** A CI command failed with an exit code but minimal output.

```bash
./scripts/deploy.sh
# Exit code: 1
# No output
```

Ask:
```
@terminal the deploy script exited with code 1 but no output. How do I get more information about what it did?
```

**Copilot:** "Add `set -x` to the top of the shell script to enable tracing (prints each command as it runs). Alternatively, run `bash -x ./scripts/deploy.sh` to trace without modifying the file."

---

## Limitations to Be Aware Of

**@terminal reads the active terminal only.** If you have multiple terminal tabs, Copilot reads whichever is currently focused. If you want to ask about output from a different tab, click that tab first, then ask.

**Long outputs may be truncated.** For commands that produce thousands of lines (e.g., a full build log), `#terminalLastCommand` may only capture the most recent portion. Use `#terminalSelection` to highlight just the relevant section.

**Copilot cannot run commands.** It suggests; you execute. There is no way for Copilot to automatically run a suggested fix command. This is intentional — it keeps you in control.

**Copilot does not have context about previous sessions.** If you restart VS Code, the terminal history @terminal sees is reset. Each session starts fresh.

**Terminal content is not part of the chat history.** If you start a new chat window, @terminal will not know about the error you were discussing in the previous window.
