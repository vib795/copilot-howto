/**
 * GitHub Copilot Agent Extension — Minimal Working Server
 *
 * This server implements a "Code Quality Agent" — a Copilot agent extension
 * that reviews code, explains errors, and answers code quality questions
 * using a custom system prompt and full conversation context.
 *
 * Key differences from a skillset extension:
 *   - Receives the FULL messages array (entire conversation history)
 *   - Must stream the response using Server-Sent Events (SSE)
 *   - Manages its own system prompt and persona
 *   - Can handle open-ended questions, not just named skill invocations
 *
 * SSE streaming format (required by Copilot Extensions):
 *   data: {"type":"text","text":"chunk of text"}\n\n
 *   data: [DONE]\n\n
 *
 * To run:
 *   npm install && node index.js
 *
 * To test locally:
 *   curl -X POST http://localhost:3000/agent \
 *     -H "Content-Type: application/json" \
 *     -d '{"messages":[{"role":"user","content":"review this: const x = eval(userInput)"}]}'
 */

'use strict';

const express = require('express');
const crypto = require('crypto');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// ---------------------------------------------------------------------------
// System prompt for the Code Quality Agent
//
// This is injected as the first message in every conversation. It defines
// the agent's persona, capabilities, and response style. Keeping it focused
// produces more consistent, useful responses.
// ---------------------------------------------------------------------------
const SYSTEM_PROMPT = `You are the Code Quality Agent, an expert software engineer assistant
integrated into GitHub Copilot. You specialize in:

- **Security review**: Identifying vulnerabilities (SQL injection, XSS, insecure deserialization,
  hardcoded secrets, improper authentication, eval usage, prototype pollution)
- **Performance analysis**: Spotting N+1 queries, sequential awaits, regex recompilation,
  memory leaks, unnecessary re-renders, and algorithmic inefficiencies
- **Code style and maintainability**: Flagging var usage, missing error handling, overly
  complex functions, poor naming, missing documentation
- **Error diagnosis**: Explaining stack traces, runtime errors, and build failures in
  plain language with concrete fix steps

Behavior guidelines:
- Be direct and specific. Name the exact line or pattern that has the issue.
- For every issue, provide a concrete fix with a code snippet.
- Use Markdown formatting: headers for sections, code blocks for examples, bold for key terms.
- Severity levels: Critical (exploitable vulnerability or data loss), High (likely bug),
  Medium (performance or maintainability concern), Low (style suggestion).
- If no issues are found, say so clearly and explain why the code looks good.
- Keep responses focused. Do not pad with unnecessary filler.`;

// ---------------------------------------------------------------------------
// Request logging
// ---------------------------------------------------------------------------
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

// ---------------------------------------------------------------------------
// Signature verification
//
// GitHub signs incoming agent requests with HMAC-SHA256. We verify this to
// ensure only genuine requests from GitHub reach the agent.
// ---------------------------------------------------------------------------
function verifySignature(req, res, next) {
  const secret = process.env.WEBHOOK_SECRET;
  if (!secret) {
    console.warn('WEBHOOK_SECRET not set — skipping verification (dev only)');
    return next();
  }

  const signature = req.headers['x-hub-signature-256'];
  if (!signature) {
    return res.status(401).json({ error: 'Missing x-hub-signature-256 header' });
  }

  const expected = 'sha256=' + crypto
    .createHmac('sha256', secret)
    .update(JSON.stringify(req.body))
    .digest('hex');

  try {
    const a = Buffer.from(signature);
    const b = Buffer.from(expected);
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      return res.status(401).json({ error: 'Signature mismatch' });
    }
  } catch {
    return res.status(401).json({ error: 'Signature verification error' });
  }

  next();
}

// ---------------------------------------------------------------------------
// SSE helpers
//
// These functions write properly formatted SSE events to the response stream.
// The Copilot Extensions protocol expects:
//   data: <JSON object>\n\n
// The blank line after each event is required by the SSE specification.
// ---------------------------------------------------------------------------

/**
 * Set up the response headers for an SSE stream.
 * Must be called before writing any data.
 */
function initSSEStream(res) {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  // Disable response buffering in nginx/reverse proxies
  res.setHeader('X-Accel-Buffering', 'no');
  // Flush headers immediately so the client knows the stream has started
  res.flushHeaders();
}

/**
 * Write a text chunk to the SSE stream.
 * @param {import('express').Response} res
 * @param {string} text - The text chunk to stream
 */
function writeTextChunk(res, text) {
  const event = JSON.stringify({ type: 'text', text });
  res.write(`data: ${event}\n\n`);
}

/**
 * Write the [DONE] sentinel and close the stream.
 * This MUST be called to signal the end of the response.
 * @param {import('express').Response} res
 */
function closeStream(res) {
  res.write('data: [DONE]\n\n');
  res.end();
}

/**
 * Write an error event and close the stream.
 * The error will be rendered in the Copilot Chat UI as a message.
 */
function streamError(res, message) {
  writeTextChunk(res, `**Error:** ${message}`);
  closeStream(res);
}

// ---------------------------------------------------------------------------
// Core agent logic
//
// In production you would forward the messages to an LLM (OpenAI, Claude, etc.)
// and pipe the streamed response back to Copilot. This implementation uses
// a rule-based analyzer to stay self-contained and runnable without API keys.
//
// See the README for how to replace this with real LLM calls.
// ---------------------------------------------------------------------------

/**
 * Analyze the user's latest message and generate a review response.
 * Returns an array of text chunks to stream, simulating a streaming LLM.
 */
function generateAgentResponse(messages) {
  // Extract the last user message
  const userMessages = messages.filter(m => m.role === 'user');
  if (userMessages.length === 0) {
    return ['I did not receive a message. Please describe what you would like me to review.'];
  }

  const lastUserMessage = userMessages[userMessages.length - 1].content;
  const chunks = [];

  // Detect intent from the message
  const isCodeBlock = /```|function |const |class |def |import |package /.test(lastUserMessage);
  const isErrorMessage = /error:|exception:|traceback|stack trace|at [A-Za-z].*:\d+/i.test(lastUserMessage);
  const isQuestion = /\?$|how do|what is|why does|explain|help me/.test(lastUserMessage.toLowerCase());

  if (isErrorMessage) {
    chunks.push(...generateErrorExplanation(lastUserMessage));
  } else if (isCodeBlock) {
    chunks.push(...generateCodeReview(lastUserMessage));
  } else if (isQuestion) {
    chunks.push(...generateGeneralAnswer(lastUserMessage));
  } else {
    // Treat as code if it looks like code, otherwise give a general response
    if (lastUserMessage.length > 50) {
      chunks.push(...generateCodeReview(lastUserMessage));
    } else {
      chunks.push(
        'I can help you with:\n\n',
        '- **Code review**: Paste your code (or attach with `#file`) and I\'ll check for security, performance, and style issues\n',
        '- **Error diagnosis**: Paste a stack trace or error message and I\'ll explain what went wrong\n',
        '- **Code quality questions**: Ask me about best practices, patterns, or specific concerns\n\n',
        'What would you like me to look at?'
      );
    }
  }

  return chunks;
}

function generateCodeReview(code) {
  const findings = [];
  const chunks = [];

  // Security checks
  if (/eval\s*\(/.test(code)) {
    findings.push({
      severity: 'Critical',
      title: '`eval()` usage',
      detail: '`eval()` executes arbitrary strings as code. If any user-controlled data reaches this call, it is a remote code execution (RCE) vulnerability.',
      fix: '```javascript\n// Instead of eval(), use safer alternatives:\n// - JSON.parse() for JSON data\n// - Function() constructor with strong validation\n// - A dedicated expression parser library (e.g., mathjs for math)\n```',
    });
  }

  if (/SELECT.*\+|`SELECT.*\$\{/.test(code)) {
    findings.push({
      severity: 'Critical',
      title: 'SQL injection via string concatenation',
      detail: 'User input is being interpolated directly into a SQL string. This allows an attacker to modify the query structure.',
      fix: '```javascript\n// Use parameterized queries:\nconst result = await db.query(\n  "SELECT * FROM users WHERE id = $1",\n  [userId]  // passed separately, never concatenated\n);\n```',
    });
  }

  if (/const.*=.*require.*\n.*const.*=.*require.*\n.*const.*=.*require/.test(code) ||
      /await.*\n.*await.*\n.*await/.test(code)) {
    findings.push({
      severity: 'Medium',
      title: 'Sequential async operations can be parallelized',
      detail: 'Multiple independent `await` calls run one after another, each blocking on the previous. Total time = sum of all durations.',
      fix: '```javascript\n// If operations are independent, run in parallel:\nconst [user, orders, profile] = await Promise.all([\n  db.users.findOne({ id: userId }),\n  db.orders.find({ userId }),\n  db.profiles.findOne({ userId }),\n]);\n```',
    });
  }

  if (/var\s+/.test(code)) {
    findings.push({
      severity: 'Low',
      title: '`var` declarations',
      detail: '`var` has function scope and hoisting, which can cause unexpected behavior. Modern JavaScript uses `const` and `let`.',
      fix: 'Replace `var` with `const` (for values that do not change) or `let` (for values that do).',
    });
  }

  chunks.push('## Code Quality Review\n\n');

  if (findings.length === 0) {
    chunks.push('No significant issues found in the provided code.\n\n');
    chunks.push('The code appears clean for the patterns I check. For a deeper review, consider:\n');
    chunks.push('- Running a static analysis tool (ESLint with security plugins, SonarQube)\n');
    chunks.push('- Adding unit tests if none exist\n');
    chunks.push('- Reviewing error handling completeness\n');
  } else {
    chunks.push(`Found **${findings.length} issue(s)**:\n\n`);
    for (const f of findings) {
      chunks.push(`### ${f.severity}: ${f.title}\n\n`);
      chunks.push(`${f.detail}\n\n`);
      chunks.push(`**Fix:**\n${f.fix}\n\n`);
    }
  }

  return chunks;
}

function generateErrorExplanation(errorText) {
  const chunks = [];
  chunks.push('## Error Analysis\n\n');

  if (/cannot read propert/i.test(errorText)) {
    chunks.push('**Type:** Null/undefined property access\n\n');
    chunks.push('A property is being accessed on a value that is `null` or `undefined`. ');
    chunks.push('This typically means data was not loaded before it was used, or an API returned no result.\n\n');
    chunks.push('**Fix:**\n```javascript\n// Option 1: Optional chaining\nconst name = user?.profile?.name;\n\n');
    chunks.push('// Option 2: Guard clause\nif (!user) return null;\nconst name = user.profile.name;\n```\n');
  } else if (/econnrefused/i.test(errorText)) {
    chunks.push('**Type:** Network connection refused\n\n');
    chunks.push('The process tried to connect to a port where nothing is listening. ');
    chunks.push('The target service (database, cache, API) is not running or is on a different port.\n\n');
    chunks.push('**Checklist:**\n');
    chunks.push('- Is the service running? (`docker ps`, `ps aux | grep postgres`)\n');
    chunks.push('- Is the port correct in your connection string?\n');
    chunks.push('- In Docker Compose, are both services in the same network?\n');
  } else {
    chunks.push('The error text has been received. Here is a general debugging approach:\n\n');
    chunks.push('1. **Find the origin line** — look for the first stack frame that references your own code (not `node_modules`)\n');
    chunks.push('2. **Check the state** — add `console.log` immediately before that line to inspect all values\n');
    chunks.push('3. **Search the exact error text** in quotes on Stack Overflow\n');
    chunks.push('4. **Use the debugger** — run with `node --inspect index.js` and attach Chrome DevTools\n');
  }

  return chunks;
}

function generateGeneralAnswer(question) {
  return [
    "That's a good question about code quality. ",
    "For the best analysis, please share the specific code or error you're asking about. ",
    "I can review code for security vulnerabilities, performance issues, and style problems, ",
    "and I can explain error messages and stack traces. ",
    "Paste the code directly in your next message or use `#file:path/to/file.ts` to attach a file."
  ];
}

// ---------------------------------------------------------------------------
// POST /agent
//
// The main agent endpoint. GitHub POSTs here when a user mentions your
// extension in Copilot Chat. We must:
//   1. Parse the incoming messages array
//   2. Prepend our system prompt
//   3. Generate a response (here: rule-based; in production: call an LLM)
//   4. Stream the response as SSE chunks
// ---------------------------------------------------------------------------
app.post('/agent', verifySignature, async (req, res) => {
  // Step 1: Set up the SSE stream immediately
  // This tells the client the response is coming and prevents timeout
  initSSEStream(res);

  try {
    const { messages } = req.body;

    if (!messages || !Array.isArray(messages)) {
      return streamError(res, 'Invalid request: messages array is required');
    }

    // Step 2: Prepend our system prompt to the conversation
    // (GitHub may have already included a system message; we prepend ours
    //  so our persona takes precedence)
    const fullMessages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...messages.filter(m => m.role !== 'system'), // keep user/assistant turns only
    ];

    console.log(`Agent received ${fullMessages.length} messages`);

    // Step 3: Generate the response
    // In this scaffold: rule-based. In production: replace with LLM call.
    // See README for OpenAI and Anthropic integration examples.
    const responseChunks = generateAgentResponse(fullMessages);

    // Step 4: Stream each chunk with a small simulated delay
    // In production with a real LLM, you pipe the stream directly.
    for (const chunk of responseChunks) {
      writeTextChunk(res, chunk);
      // Small delay to simulate streaming (remove when using a real LLM stream)
      await new Promise(resolve => setTimeout(resolve, 30));
    }

    // Step 5: Send the [DONE] sentinel to close the stream
    closeStream(res);

  } catch (err) {
    console.error('Error in /agent handler:', err);

    // If headers have been sent, we can only stream an error message
    if (res.headersSent) {
      streamError(res, 'An unexpected error occurred. Please try again.');
    } else {
      // Headers not yet sent — respond with a standard HTTP error
      res.status(500).json({ error: 'Internal server error' });
    }
  }
});

// ---------------------------------------------------------------------------
// POST /events
//
// GitHub App webhook handler for installation lifecycle events.
// ---------------------------------------------------------------------------
app.post('/events', verifySignature, (req, res) => {
  const event = req.headers['x-github-event'];
  console.log(`GitHub webhook event: ${event}`);

  if (event === 'installation') {
    console.log(`App ${req.body.action} by: ${req.body.installation?.account?.login}`);
  }

  res.status(200).json({ received: true });
});

// ---------------------------------------------------------------------------
// GET /health
// ---------------------------------------------------------------------------
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    type: 'agent-extension',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// ---------------------------------------------------------------------------
// Error and 404 handlers
// ---------------------------------------------------------------------------
app.use((req, res) => {
  res.status(404).json({ error: `Not found: ${req.method} ${req.path}` });
});

app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ error: 'Internal server error' });
});

// ---------------------------------------------------------------------------
// Start
// ---------------------------------------------------------------------------
app.listen(PORT, () => {
  console.log(`Agent extension server running on port ${PORT}`);
  console.log(`Agent endpoint: POST http://localhost:${PORT}/agent`);
  console.log(`Health check:   GET  http://localhost:${PORT}/health`);
});

module.exports = app;
