/**
 * GitHub Copilot Skillset Extension — Minimal Working Server
 *
 * This Express server implements a Copilot skillset extension with two skills:
 *   - /code-review: Reviews code for quality, security, and performance issues
 *   - /explain-error: Explains an error message and provides fix suggestions
 *
 * Copilot Extensions protocol (skillset):
 *   1. GitHub POSTs to your skill endpoint with { messages, skill, parameters }
 *   2. Your endpoint processes the request
 *   3. You return { type: "text", text: "your response" }
 *   4. Copilot renders the text in the chat panel
 *
 * To run locally:
 *   npm install && node index.js
 *
 * To expose via ngrok:
 *   ngrok http 3000
 */

'use strict';

const express = require('express');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Parse JSON bodies — required for all Copilot Extension requests
app.use(express.json());

// ---------------------------------------------------------------------------
// Request logging middleware (helpful during development)
// ---------------------------------------------------------------------------
app.use((req, res, next) => {
  const ts = new Date().toISOString();
  console.log(`[${ts}] ${req.method} ${req.path}`);
  next();
});

// ---------------------------------------------------------------------------
// Signature verification middleware
//
// GitHub signs every request with a webhook secret using HMAC-SHA256.
// We must reject requests that fail verification to prevent spoofed calls.
// In production, apply this to all routes. Here we apply it selectively.
// ---------------------------------------------------------------------------
function verifyWebhookSignature(req, res, next) {
  const secret = process.env.WEBHOOK_SECRET;

  // Skip verification in local development if no secret is configured
  if (!secret) {
    console.warn('WEBHOOK_SECRET not set — skipping signature verification (dev only)');
    return next();
  }

  const signature = req.headers['x-hub-signature-256'];
  if (!signature) {
    return res.status(401).json({ error: 'Missing signature header' });
  }

  // Compute expected signature from the raw body
  const rawBody = JSON.stringify(req.body);
  const expected = 'sha256=' + crypto
    .createHmac('sha256', secret)
    .update(rawBody)
    .digest('hex');

  // Use timingSafeEqual to prevent timing attacks
  const sigBuffer = Buffer.from(signature);
  const expectedBuffer = Buffer.from(expected);

  if (sigBuffer.length !== expectedBuffer.length ||
      !crypto.timingSafeEqual(sigBuffer, expectedBuffer)) {
    return res.status(401).json({ error: 'Invalid signature' });
  }

  next();
}

// ---------------------------------------------------------------------------
// Helper: Build a Copilot skillset response
//
// The Copilot Extensions skillset response format expects a JSON object with
// a "type" field and a "text" field. The text is rendered as Markdown.
// ---------------------------------------------------------------------------
function buildTextResponse(text) {
  return {
    type: 'text',
    text: text,
  };
}

// ---------------------------------------------------------------------------
// Helper: Extract skill parameters from the incoming Copilot request
//
// Copilot sends parameters as a flat object in req.body.parameters.
// The structure mirrors what you defined in skillset-definition.yaml.
// ---------------------------------------------------------------------------
function getParam(body, name, defaultValue = '') {
  if (body.parameters && body.parameters[name] !== undefined) {
    return body.parameters[name];
  }
  // Also check the last user message for inline parameters
  if (body.messages && body.messages.length > 0) {
    const lastMessage = body.messages[body.messages.length - 1];
    if (lastMessage.content) {
      return lastMessage.content;
    }
  }
  return defaultValue;
}

// ---------------------------------------------------------------------------
// Core logic: Code review analysis
//
// In a real extension you might call an LLM API (OpenAI, Claude, etc.) here.
// For this scaffold, the analysis is rule-based to keep the example self-contained.
// ---------------------------------------------------------------------------
function analyzeCode(code, focusArea) {
  const issues = [];
  const suggestions = [];

  // Security checks
  if (focusArea === 'security' || focusArea === 'all') {
    if (/SELECT.*\+\s*(id|name|input|param|req\.)/.test(code) ||
        /`SELECT.*\$\{/.test(code)) {
      issues.push({
        severity: 'critical',
        category: 'Security',
        issue: 'SQL injection vulnerability detected',
        detail: 'String concatenation or template literals used in SQL queries. ' +
                'User input is being interpolated directly into the query string.',
        fix: 'Use parameterized queries or a query builder:\n' +
             '```javascript\n' +
             '// Instead of:\nconst query = "SELECT * FROM users WHERE id = " + id;\n\n' +
             '// Use:\nconst query = "SELECT * FROM users WHERE id = ?";\ndb.execute(query, [id]);\n' +
             '```',
      });
    }

    if (/eval\s*\(/.test(code)) {
      issues.push({
        severity: 'critical',
        category: 'Security',
        issue: '`eval()` detected',
        detail: '`eval()` executes arbitrary code and is a common attack vector for ' +
                'code injection. It also prevents V8 optimizations.',
        fix: 'Rewrite to avoid `eval()`. If you need dynamic code execution, ' +
             'consider `Function` constructor with strong input validation, or better yet, ' +
             'a declarative approach.',
      });
    }

    if (/console\.log.*password|console\.log.*secret|console\.log.*token/i.test(code)) {
      issues.push({
        severity: 'high',
        category: 'Security',
        issue: 'Sensitive data logged to console',
        detail: 'Passwords, secrets, or tokens should never be logged. ' +
                'Logs are often stored in plaintext and accessible to multiple parties.',
        fix: 'Remove or redact the logging statement.',
      });
    }

    if (!/try\s*\{/.test(code) && code.length > 100) {
      suggestions.push('Consider wrapping async operations in try/catch to prevent ' +
                       'unhandled promise rejections from leaking internal details to clients.');
    }
  }

  // Performance checks
  if (focusArea === 'performance' || focusArea === 'all') {
    if (/for\s*\(.*\).*\.length/.test(code)) {
      suggestions.push(
        '**Performance tip:** Cache `.length` outside the loop condition:\n' +
        '```javascript\nconst len = arr.length;\nfor (let i = 0; i < len; i++) { ... }\n```\n' +
        'Or better, use `for...of` or `Array.prototype.forEach`.'
      );
    }

    if (/await\s+\w+\(.*\)[\s\S]{0,20}await\s+\w+\(.*\)/m.test(code)) {
      suggestions.push(
        '**Performance tip:** Sequential `await` calls may be parallelizable. ' +
        'If the operations are independent, use `Promise.all()`:\n' +
        '```javascript\nconst [a, b] = await Promise.all([fetchA(), fetchB()]);\n```'
      );
    }

    if (/new RegExp\(/.test(code)) {
      suggestions.push(
        '**Performance tip:** If the `RegExp` is constructed with a constant pattern, ' +
        'use a regex literal instead. Regex literals are compiled once; `new RegExp()` ' +
        'recompiles on every call.'
      );
    }
  }

  // Style / quality checks
  if (focusArea === 'style' || focusArea === 'all') {
    if (/var\s+/.test(code)) {
      suggestions.push('Replace `var` with `const` or `let`. `var` has function scope ' +
                       'and hoisting behavior that leads to subtle bugs.');
    }

    if (!/\/\/|\/\*|\*\/|\/\*\*/.test(code) && code.split('\n').length > 10) {
      suggestions.push('The function has no comments or JSDoc. Consider adding a brief ' +
                       'description of what it does, its parameters, and return value.');
    }
  }

  return { issues, suggestions };
}

// ---------------------------------------------------------------------------
// POST /code-review
//
// Copilot skill: reviews code for quality, security, and performance issues.
//
// Expected parameters (from skillset-definition.yaml):
//   - code (required): the source code to review
//   - focus_area (optional): "security" | "performance" | "style" | "all"
// ---------------------------------------------------------------------------
app.post('/code-review', verifyWebhookSignature, (req, res) => {
  try {
    const code = getParam(req.body, 'code');
    const focusArea = getParam(req.body, 'focus_area', 'all');

    if (!code || code.trim().length === 0) {
      return res.json(buildTextResponse(
        'Please provide code to review. Example:\n\n' +
        '`@code-reviewer /code-review` and then paste your code in the message.'
      ));
    }

    const { issues, suggestions } = analyzeCode(code, focusArea.toLowerCase());

    // Build a Markdown-formatted review report
    const lines = [];

    lines.push(`## Code Review — Focus: ${focusArea}`);
    lines.push('');

    if (issues.length === 0 && suggestions.length === 0) {
      lines.push('No issues found. The code looks clean for the selected focus area.');
    } else {
      // Issues (things that should be fixed)
      if (issues.length > 0) {
        lines.push(`### Issues Found (${issues.length})`);
        lines.push('');
        for (const issue of issues) {
          const badge = issue.severity === 'critical' ? '🔴 Critical' : '🟠 High';
          lines.push(`#### ${badge} — ${issue.issue}`);
          lines.push(`**Category:** ${issue.category}`);
          lines.push('');
          lines.push(issue.detail);
          lines.push('');
          lines.push('**Suggested fix:**');
          lines.push(issue.fix);
          lines.push('');
        }
      }

      // Suggestions (improvements, not bugs)
      if (suggestions.length > 0) {
        lines.push(`### Suggestions (${suggestions.length})`);
        lines.push('');
        for (const suggestion of suggestions) {
          lines.push(`- ${suggestion}`);
          lines.push('');
        }
      }
    }

    lines.push('---');
    lines.push(`*Reviewed ${code.split('\n').length} lines | Focus: ${focusArea}*`);

    return res.json(buildTextResponse(lines.join('\n')));

  } catch (err) {
    console.error('Error in /code-review:', err);
    return res.status(500).json(buildTextResponse(
      'An error occurred while reviewing the code. Please try again.'
    ));
  }
});

// ---------------------------------------------------------------------------
// POST /explain-error
//
// Copilot skill: explains what an error message means and how to fix it.
//
// Expected parameters (from skillset-definition.yaml):
//   - error_message (required): the error text or stack trace
//   - language (optional): the programming language context
// ---------------------------------------------------------------------------
app.post('/explain-error', verifyWebhookSignature, (req, res) => {
  try {
    const errorMessage = getParam(req.body, 'error_message');
    const language = getParam(req.body, 'language', 'javascript');

    if (!errorMessage || errorMessage.trim().length === 0) {
      return res.json(buildTextResponse(
        'Please provide an error message to explain. Paste the error or stack trace directly.'
      ));
    }

    const explanation = explainError(errorMessage.trim(), language.toLowerCase());
    return res.json(buildTextResponse(explanation));

  } catch (err) {
    console.error('Error in /explain-error:', err);
    return res.status(500).json(buildTextResponse(
      'An error occurred while analyzing the error. Please try again.'
    ));
  }
});

// ---------------------------------------------------------------------------
// Core logic: Error explanation
// ---------------------------------------------------------------------------
function explainError(errorMessage, language) {
  const lines = [];
  lines.push('## Error Explanation');
  lines.push('');

  // Common JavaScript/Node.js errors
  const patterns = [
    {
      pattern: /cannot read propert(?:y|ies) of (undefined|null)/i,
      title: 'Null/Undefined Property Access',
      explanation: 'You are trying to access a property on a value that is `null` or `undefined`. ' +
                   'This usually means a variable was not initialized before use, an API call returned ' +
                   'no data, or an async operation completed before data was available.',
      fixes: [
        'Add a null check before accessing the property:\n```javascript\nif (user && user.name) { ... }\n```',
        'Use optional chaining (ES2020+):\n```javascript\nconst name = user?.profile?.name;\n```',
        'Ensure async data is loaded before rendering (check loading states)',
      ],
    },
    {
      pattern: /is not a function/i,
      title: 'Called a Non-Function Value',
      explanation: 'You are calling something with `()` that is not a function. Common causes: ' +
                   'a method name is misspelled, the wrong variable is being called, or a module ' +
                   'export is not a function (e.g., `module.exports = value` instead of `module.exports = fn`).',
      fixes: [
        'Check the spelling of the method/function name',
        'Log the value before calling it: `console.log(typeof myVar)` — it should print `"function"`',
        'Check that you are importing/requiring the right thing from the module',
      ],
    },
    {
      pattern: /enoent.*no such file or directory/i,
      title: 'File or Directory Not Found',
      explanation: 'The Node.js runtime tried to open a file or directory that does not exist ' +
                   'at the specified path. Paths in Node.js are relative to the current working ' +
                   'directory when the process was started, not the file that contains the code.',
      fixes: [
        'Check if the file actually exists at the given path',
        'Use `path.join(__dirname, "relative/path")` to build paths relative to the current file',
        'Print `process.cwd()` to see what directory Node considers "current"',
      ],
    },
    {
      pattern: /syntaxerror/i,
      title: 'Syntax Error',
      explanation: 'The JavaScript parser found code that violates the language grammar. ' +
                   'This prevents the entire file from loading. Common causes: missing closing ' +
                   'bracket or brace, unexpected comma, invalid import statement.',
      fixes: [
        'Look at the line number in the stack trace — the error is often one line above it',
        'Check for mismatched `{`, `}`, `[`, `]`, `(`, `)`',
        'Use a linter (ESLint) to catch syntax errors before runtime',
        'Paste the code into an online validator like jshint.com',
      ],
    },
    {
      pattern: /unhandledpromiserejection/i,
      title: 'Unhandled Promise Rejection',
      explanation: 'An async operation (Promise) rejected with an error, but there was no ' +
                   '`.catch()` or `try/catch` around the `await` to handle it. In Node.js 15+, ' +
                   'this crashes the process.',
      fixes: [
        'Wrap async code in try/catch:\n```javascript\ntry {\n  await riskyOperation();\n} catch (err) {\n  console.error(err);\n}\n```',
        'Add `.catch()` to all Promise chains',
        'Add a global handler during development:\n```javascript\nprocess.on("unhandledRejection", (err) => console.error(err));\n```',
      ],
    },
    {
      pattern: /connection refused|econnrefused/i,
      title: 'Connection Refused',
      explanation: 'Your code tried to open a network connection (TCP) to a port on a server, ' +
                   'but nothing was listening on that port. Common causes: the database or service ' +
                   'is not running, the port number is wrong, or you are connecting to the wrong host.',
      fixes: [
        'Check that the target service is running: `ps aux | grep postgres` or `docker ps`',
        'Verify the host and port in your connection string',
        'If using Docker Compose, make sure the service is in the same network and using the service name as hostname',
      ],
    },
  ];

  let matched = false;
  for (const { pattern, title, explanation, fixes } of patterns) {
    if (pattern.test(errorMessage)) {
      matched = true;
      lines.push(`### ${title}`);
      lines.push('');
      lines.push('**What this means:**');
      lines.push(explanation);
      lines.push('');
      lines.push('**How to fix it:**');
      for (const fix of fixes) {
        lines.push(`- ${fix}`);
      }
      lines.push('');
      break;
    }
  }

  if (!matched) {
    lines.push('### Error Analysis');
    lines.push('');
    lines.push('**Error received:**');
    lines.push('```');
    lines.push(errorMessage.split('\n').slice(0, 10).join('\n'));
    lines.push('```');
    lines.push('');
    lines.push('This error pattern was not matched by the built-in rules. ' +
               'Here are general debugging steps:');
    lines.push('');
    lines.push('1. Read the error message carefully — it usually names the file and line number');
    lines.push('2. Search the error text in quotes on Stack Overflow');
    lines.push('3. Check the project\'s issue tracker for known bugs');
    lines.push('4. Add `console.log` statements around the failing code to inspect state');
    lines.push('5. Run the code in a debugger (Node.js `--inspect` flag + Chrome DevTools)');
  }

  lines.push('---');
  lines.push(`*Language context: ${language}*`);

  return lines.join('\n');
}

// ---------------------------------------------------------------------------
// GET /skillset
//
// Serves the skillset definition YAML to GitHub so it knows what skills
// this extension provides. GitHub fetches this endpoint during installation
// and periodically to detect changes.
// ---------------------------------------------------------------------------
app.get('/skillset', (req, res) => {
  const yamlPath = path.join(__dirname, 'skillset-definition.yaml');
  if (!fs.existsSync(yamlPath)) {
    return res.status(404).send('Skillset definition not found');
  }
  res.setHeader('Content-Type', 'application/yaml');
  res.send(fs.readFileSync(yamlPath, 'utf8'));
});

// ---------------------------------------------------------------------------
// POST /events
//
// Receives GitHub App webhook events. For skillset extensions you typically
// only need to handle installation events to track which accounts have
// installed your extension. Other events are optional.
// ---------------------------------------------------------------------------
app.post('/events', verifyWebhookSignature, (req, res) => {
  const event = req.headers['x-github-event'];
  const payload = req.body;

  console.log(`Received GitHub event: ${event}`);

  if (event === 'installation') {
    const action = payload.action;
    const accountName = payload.installation?.account?.login;
    console.log(`Extension ${action} by: ${accountName}`);
  }

  // Always respond with 200 to acknowledge receipt
  res.status(200).json({ received: true });
});

// ---------------------------------------------------------------------------
// GET /health
//
// Health check endpoint. Used by deployment platforms (Railway, Render,
// Fly.io) to verify the server is running. Also useful for quick manual checks.
// ---------------------------------------------------------------------------
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    skills: ['code-review', 'explain-error'],
    version: '1.0.0',
  });
});

// ---------------------------------------------------------------------------
// 404 handler — catch any routes not explicitly defined above
// ---------------------------------------------------------------------------
app.use((req, res) => {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` });
});

// ---------------------------------------------------------------------------
// Global error handler — catch any unhandled synchronous errors in routes
// ---------------------------------------------------------------------------
app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ---------------------------------------------------------------------------
// Start the server
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`Skillset extension server running on port ${PORT}`);
  console.log(`Health check available at http://localhost:${PORT}/health`);
  console.log(`Skillset definition at http://localhost:${PORT}/skillset`);
});

module.exports = app; // Export for testing
