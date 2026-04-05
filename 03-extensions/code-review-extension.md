# Code Review Extension: Complete Worked Example

This document walks through building a production-ready code review Copilot Extension — a direct analogue to the classic "code-review skill" pattern, now as an installable extension that any GitHub Copilot user can invoke with `@code-reviewer`.

---

## What the Extension Does

The code review extension performs a comprehensive review across four dimensions:

| Dimension | What It Checks |
|---|---|
| **Security** | SQL injection, eval usage, hardcoded secrets, insecure authentication, XSS vectors, prototype pollution |
| **Performance** | Sequential awaits, N+1 queries, regex recompilation, memory leaks, unnecessary object spread in hot paths |
| **Style** | `var` usage, overly long functions, missing error handling, poor naming, magic numbers |
| **Test coverage** | Missing test files, untested edge cases, missing null checks that tests should catch |

Each finding includes a severity level (Critical / High / Medium / Low), a plain-language explanation, and a concrete code fix.

---

## Architecture

This extension is built as a **skillset extension** with a single `/review` skill endpoint.

```mermaid
graph TD
    U["User in Copilot Chat<br/>@code-reviewer /review"] -->|POST| GH["GitHub Copilot<br/>Extension Router"]
    GH -->|POST /review<br/>{ code, focus }| APP["Express Server<br/>/review endpoint"]
    APP -->|Analyze| CHECKLIST["Review Checklist Engine<br/>(rule-based + optional LLM)"]
    CHECKLIST -->|findings| FORMATTER["Markdown Report Builder"]
    FORMATTER -->|{ type: 'text', text: '...' }| GH
    GH -->|Rendered Markdown| U

    style U fill:#e8f4f8
    style GH fill:#f0e8f8
    style APP fill:#f8f4e8
    style CHECKLIST fill:#e8f8e8
```

**Why skillset and not agent?** Code review is a stateless, single-shot operation. The user provides code, we return a review. There is no multi-turn reasoning needed. Skillset extensions are simpler to build, host, and debug for this use case.

---

## The Review Checklist

The checklist is embedded directly in the extension's logic, not in a config file. This keeps it versioned with the code and makes it easy to add new rules.

```javascript
const REVIEW_RULES = [
  // -------------------------------------------------------------------------
  // SECURITY RULES
  // -------------------------------------------------------------------------
  {
    id: 'SEC-001',
    severity: 'critical',
    category: 'Security',
    name: 'SQL injection via string concatenation',
    detect: (code) => /SELECT|INSERT|UPDATE|DELETE/.test(code) &&
                      (/\+\s*(id|name|input|param|req\.|user)/.test(code) ||
                       /`.*\$\{.*\}.*`/.test(code)),
    message: 'SQL query built with string concatenation or template literals.',
    fix: `Use parameterized queries:
\`\`\`javascript
// Vulnerable:
const q = "SELECT * FROM users WHERE id = " + userId;

// Safe:
const q = "SELECT * FROM users WHERE id = $1";
await db.query(q, [userId]);
\`\`\``,
  },
  {
    id: 'SEC-002',
    severity: 'critical',
    category: 'Security',
    name: 'eval() usage',
    detect: (code) => /\beval\s*\(/.test(code),
    message: '`eval()` executes arbitrary code. Any path that allows user input to reach `eval()` is a Remote Code Execution (RCE) vulnerability.',
    fix: 'Replace `eval()` with safe alternatives: `JSON.parse()` for JSON, a math library for expressions, or a sandboxed VM for dynamic code.',
  },
  {
    id: 'SEC-003',
    severity: 'high',
    category: 'Security',
    name: 'Hardcoded secret or API key',
    detect: (code) => /(api[_-]?key|secret|password|token)\s*[:=]\s*['"][A-Za-z0-9+/]{20,}['"]/i.test(code),
    message: 'A secret, API key, or password appears to be hardcoded in the source code.',
    fix: 'Move secrets to environment variables and load them at runtime:\n```javascript\nconst apiKey = process.env.MY_API_KEY;\n```\nNever commit `.env` files containing real secrets.',
  },
  {
    id: 'SEC-004',
    severity: 'high',
    category: 'Security',
    name: 'JWT decoded without verification',
    detect: (code) => /jwt\.decode\b/.test(code) && !/jwt\.verify\b/.test(code),
    message: '`jwt.decode()` does not verify the token signature. Anyone can craft a token that decodes to any payload.',
    fix: 'Use `jwt.verify(token, secret)` instead of `jwt.decode(token)`. Always verify before trusting the payload.',
  },
  {
    id: 'SEC-005',
    severity: 'medium',
    category: 'Security',
    name: 'Sensitive data in console.log',
    detect: (code) => /console\.log[^;]*(?:password|secret|token|key|credential)/i.test(code),
    message: 'Sensitive data (password, secret, token) is being logged to the console.',
    fix: 'Remove the log statement or redact the sensitive field before logging.',
  },

  // -------------------------------------------------------------------------
  // PERFORMANCE RULES
  // -------------------------------------------------------------------------
  {
    id: 'PERF-001',
    severity: 'medium',
    category: 'Performance',
    name: 'Sequential awaits — parallelization opportunity',
    detect: (code) => {
      const awaitLines = (code.match(/^\s*(?:const|let)\s+\w+\s*=\s*await\s+/gm) || []).length;
      return awaitLines >= 2;
    },
    message: 'Multiple `await` statements run sequentially. If the operations are independent, the total time equals the sum of all durations.',
    fix: `Parallelize independent operations:
\`\`\`javascript
// Sequential (slow):
const user = await getUser(id);
const orders = await getOrders(id);

// Parallel (fast):
const [user, orders] = await Promise.all([getUser(id), getOrders(id)]);
\`\`\``,
  },
  {
    id: 'PERF-002',
    severity: 'low',
    category: 'Performance',
    name: 'RegExp constructed inside a function body',
    detect: (code) => /(?:function|=>)\s*[\w\s]*\{[^}]*new RegExp\(/s.test(code),
    message: 'A `RegExp` is constructed inside a function. If the function is called frequently, the regex is recompiled on every call.',
    fix: 'Hoist the regex to module scope so it is compiled once:\n```javascript\nconst DATE_RE = /^\\d{4}-\\d{2}-\\d{2}$/; // compiled once\nfunction isValidDate(s) { return DATE_RE.test(s); }\n```',
  },
  {
    id: 'PERF-003',
    severity: 'low',
    category: 'Performance',
    name: 'Array.length accessed in loop condition',
    detect: (code) => /for\s*\([^;]+;\s*\w+\s*<\s*\w+\.length/.test(code),
    message: '`.length` is evaluated on every loop iteration. For large arrays, cache it in a variable.',
    fix: '```javascript\nconst len = items.length;\nfor (let i = 0; i < len; i++) { ... }\n// Or better:\nfor (const item of items) { ... }\n```',
  },

  // -------------------------------------------------------------------------
  // STYLE / QUALITY RULES
  // -------------------------------------------------------------------------
  {
    id: 'STYLE-001',
    severity: 'low',
    category: 'Style',
    name: 'var declarations',
    detect: (code) => /\bvar\s+\w+/.test(code),
    message: '`var` has function scope and hoisting semantics that cause subtle bugs. Modern JavaScript uses `const` and `let`.',
    fix: 'Replace `var` with `const` (for values that do not change) or `let` (for values that do).',
  },
  {
    id: 'STYLE-002',
    severity: 'medium',
    category: 'Style',
    name: 'Missing error handling in async function',
    detect: (code) => /async\s+function|async\s*\(/.test(code) && !/try\s*\{/.test(code),
    message: 'Async function has no `try/catch`. Rejected promises will cause unhandled rejections, crashing Node.js 15+ processes.',
    fix: '```javascript\nasync function fetchData() {\n  try {\n    const data = await api.get("/data");\n    return data;\n  } catch (err) {\n    logger.error("fetchData failed:", err);\n    throw err; // or return a default value\n  }\n}\n```',
  },
  {
    id: 'STYLE-003',
    severity: 'low',
    category: 'Style',
    name: 'Magic number',
    detect: (code) => /[^0-9a-zA-Z_](?:86400|3600|1000\s*\*\s*60|60\s*\*\s*60)[^0-9]/.test(code),
    message: 'A magic number representing a time value was found. Hard-to-read constants make code harder to maintain.',
    fix: '```javascript\nconst ONE_HOUR_MS = 60 * 60 * 1000;\nconst ONE_DAY_S = 86_400; // ES2021: numeric separator for readability\n```',
  },

  // -------------------------------------------------------------------------
  // TEST COVERAGE RULES (static signals only — no test runner needed)
  // -------------------------------------------------------------------------
  {
    id: 'TEST-001',
    severity: 'medium',
    category: 'Test Coverage',
    name: 'Function accepts user input with no validation',
    detect: (code) => /function\s+\w+\s*\([^)]*(?:input|data|body|params|req)\b/.test(code) &&
                      !/if\s*\(.*(?:typeof|instanceof|Array\.isArray|Number\.isNaN)/.test(code),
    message: 'Function accepts external input but has no input validation. Unexpected types or values may cause runtime errors.',
    fix: 'Add validation at the function entry point:\n```javascript\nfunction processItem(item) {\n  if (!item || typeof item !== "object") {\n    throw new TypeError(`Expected object, got ${typeof item}`);\n  }\n  // ... safe to proceed\n}\n```',
  },
];
```

---

## How to Invoke the Extension

### Basic Review

Paste code directly in the chat message:

```
@code-reviewer /review

async function getUserOrders(userId) {
  const user = await db.users.findOne(userId);
  const orders = await db.orders.find({ userId: userId });
  const invoices = await db.invoices.find({ userId: userId });
  return { user, orders, invoices };
}
```

### Review a File

Attach a file using the `#file` context variable:

```
@code-reviewer /review #file:src/services/payment.ts
```

### Focus on a Specific Concern

```
@code-reviewer /review focus=security

const query = `SELECT * FROM sessions WHERE token = '${req.cookies.sessionToken}'`;
const session = await db.execute(query);
```

---

## Sample Interaction Transcript

The following shows a realistic exchange between a developer and the extension.

---

**User:**
```
@code-reviewer /review

function loginUser(req, res) {
  const { username, password } = req.body;
  const query = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + password + "'";

  db.query(query, function(err, rows) {
    if (rows.length > 0) {
      var token = jwt.sign({ id: rows[0].id }, 'mysecretkey123');
      console.log('Token generated:', token, 'for user:', password);
      res.json({ token });
    } else {
      res.status(401).json({ error: 'Invalid credentials' });
    }
  });
}
```

---

**@code-reviewer:**

## Code Review

Found **4 issues** — including 2 critical security vulnerabilities.

---

### Critical: SQL injection via string concatenation (SEC-001)

The `username` and `password` fields from `req.body` are interpolated directly into the SQL string. An attacker can supply `' OR '1'='1` as the username to bypass authentication entirely.

**Fix:**
```javascript
const query = "SELECT * FROM users WHERE username = $1 AND password_hash = $2";
// Note: compare hashed passwords, not plaintext
await db.query(query, [username, hashedPassword]);
```

---

### Critical: Hardcoded JWT secret (SEC-003)

`'mysecretkey123'` is hardcoded as the JWT signing secret. Anyone who reads the source code (in version control, build logs, or error dumps) can forge tokens for any user ID.

**Fix:**
```javascript
// In .env:
// JWT_SECRET=<64-character random string>

// In code:
const token = jwt.sign({ id: userId }, process.env.JWT_SECRET, { expiresIn: '1h' });
```

Generate a strong secret: `node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`

---

### High: Password logged to console (SEC-005)

Line: `console.log('Token generated:', token, 'for user:', password)`

The plaintext password is being written to the application logs. Server logs are often stored unencrypted and accessible to ops teams, log aggregators, and potentially attackers.

**Fix:** Remove the log statement entirely. If you need to log authentication events, log only the username and timestamp — never the password or token.

---

### Medium: Passwords compared in plaintext (SEC-004 related)

The SQL query compares `password` directly. Passwords must never be stored or compared in plaintext.

**Fix:** Store passwords as hashes using `bcrypt` or `argon2`:
```javascript
const bcrypt = require('bcrypt');

// On registration:
const hash = await bcrypt.hash(plainPassword, 12);
await db.query("INSERT INTO users (username, password_hash) VALUES ($1, $2)", [username, hash]);

// On login:
const user = await db.query("SELECT * FROM users WHERE username = $1", [username]);
const valid = await bcrypt.compare(plainPassword, user.rows[0].password_hash);
```

---

*4 issues found | 2 critical, 1 high, 1 medium | Focus: all*

---

## How to Extend the Extension

### Adding a New Review Category

1. Add rules to the `REVIEW_RULES` array in `index.js`:

```javascript
{
  id: 'A11Y-001',
  severity: 'medium',
  category: 'Accessibility',
  name: 'onClick handler on non-interactive element',
  detect: (code) => /<div[^>]*onClick/.test(code),
  message: 'An `onClick` handler on a `<div>` is not keyboard accessible. Screen reader users and keyboard-only users cannot activate it.',
  fix: 'Replace with a `<button>` element which is focusable and keyboard-activatable by default.',
},
```

2. Update the skill description in `skillset-definition.yaml` to mention the new category
3. Optionally add it to the `focus` parameter's enum

### Integrating with a Linter

Instead of (or in addition to) the built-in rules, call ESLint programmatically and include its output in the review:

```javascript
const { ESLint } = require('eslint');

async function runESLint(code) {
  const eslint = new ESLint({
    useEslintrc: false,
    overrideConfig: {
      rules: {
        'no-eval': 'error',
        'no-var': 'warn',
        'eqeqeq': 'warn',
      },
    },
  });

  const results = await eslint.lintText(code, { filePath: 'review.js' });
  return results[0]?.messages || [];
}
```

Then merge the ESLint findings with the built-in checklist findings before building the Markdown report.

### Integrating an LLM for Deeper Analysis

For issues that are hard to detect with regex (e.g., "is this business logic correct?"), call an LLM:

```javascript
const OpenAI = require('openai');
const client = new OpenAI();

async function deepReview(code, ruleFindings) {
  const rulesSummary = ruleFindings.map(f => `- ${f.name}`).join('\n');

  const response = await client.chat.completions.create({
    model: 'gpt-4o',
    messages: [
      { role: 'system', content: 'You are a senior software engineer reviewing code for correctness and design.' },
      { role: 'user', content: `The automated checker found:\n${rulesSummary}\n\nHere is the full code:\n\`\`\`\n${code}\n\`\`\`\n\nProvide additional insights the automated checker may have missed.` },
    ],
  });

  return response.choices[0].message.content;
}
```
