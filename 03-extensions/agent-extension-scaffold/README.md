# Agent Extension Scaffold

This scaffold shows you how to build a **Copilot agent extension**: a server that receives the full conversation context and streams back responses using Server-Sent Events (SSE). Agent extensions give you complete control over what the AI does with the user's message.

---

## Agent Extensions vs. Skillset Extensions

| Dimension | Skillset Extension | Agent Extension |
|---|---|---|
| Conversation management | GitHub manages it | You manage it |
| Response format | Return JSON | Stream SSE chunks |
| Multi-turn reasoning | Limited (one skill = one call) | Full — you decide when to stop |
| Calling external LLMs | Optional | Typical (you are the "brain") |
| System prompt | Set by GitHub/Copilot | You define it entirely |
| Streaming | Not required | Required |
| Complexity | Lower | Higher |
| Best for | Discrete tool calls | Complex reasoning, planning, research |

### When to Use an Agent Extension

Choose an agent extension when your use case requires:

- **Multi-turn conversations** where the response to message N depends on context from messages 1–(N-1)
- **Autonomous planning** — the agent needs to decide what steps to take before it can answer
- **Multiple downstream API calls** — e.g., search a codebase, query a database, call an LLM, then synthesize a response
- **Custom personas** — you want to inject a detailed system prompt that shapes the agent's behavior throughout the session
- **Long-running operations** that benefit from streaming partial results as they arrive

Choose a **skillset extension** instead when your use case is a simple, stateless function call: look up ticket X, lint this code, explain this error.

---

## How the Agent Extension API Works

### Incoming Request

When a user types `@my-agent hello` in Copilot Chat, GitHub sends a POST to your `/agent` endpoint with a body like this:

```json
{
  "messages": [
    {
      "role": "system",
      "content": "You are a helpful assistant integrated with GitHub Copilot."
    },
    {
      "role": "user",
      "content": "hello"
    }
  ],
  "agent": "my-agent",
  "model": "gpt-4o",
  "stream": true
}
```

The `messages` array follows the OpenAI Chat Completions format (system, user, assistant turns). Your server receives the full history — you own the context window from here.

### Outgoing Response (SSE Stream)

You must respond with `Content-Type: text/event-stream` and stream data in this format:

```
data: {"type":"text","text":"Hello"}

data: {"type":"text","text":", how can"}

data: {"type":"text","text":" I help you?"}

data: [DONE]

```

Each `data:` line is a JSON object. The `[DONE]` sentinel signals the end of the stream. GitHub reassembles the chunks and renders them as Markdown in the chat panel.

**Important formatting rules:**
- Each event must be on a single line starting with `data:` followed by a space
- There must be a blank line after each event (the SSE spec requires this)
- The final event must be `data: [DONE]`
- Do not close the connection before sending `[DONE]`

---

## Setting Up the GitHub App for Agent Mode

Agent extensions use the same GitHub App infrastructure as skillset extensions, but with different settings.

### 1. Create or Edit Your GitHub App

Go to **GitHub Settings → Developer Settings → GitHub Apps**.

In the **Copilot** section of your app's settings:
- Set **Agent type** to **Agent** (not Skillset)
- Set **Agent endpoint URL** to your server's `/agent` path

### 2. Required Permissions

Agent extensions typically need:
- **Copilot Chat**: Read & Write (required)
- **Contents**: Read-only (to read files from repos if needed)
- **Pull requests**: Read-only (if the agent discusses PRs)

### 3. Webhook Configuration

Unlike skillset extensions, agent extensions do not use webhooks for skill dispatch — GitHub POSTs directly to your `/agent` endpoint. However, you still need a webhook URL for installation events. Set it to `/events` on your server.

---

## Local Development Setup

### 1. Install Dependencies

```bash
cd 03-extensions/agent-extension-scaffold
npm install
```

### 2. Set Environment Variables

```bash
# .env
WEBHOOK_SECRET=your_webhook_secret
# Optional: if you want to forward to a real LLM
OPENAI_API_KEY=sk-...
# or
ANTHROPIC_API_KEY=sk-ant-...
PORT=3000
```

### 3. Start the Server

```bash
node index.js
```

### 4. Open an ngrok Tunnel

```bash
ngrok http 3000
```

### 5. Update GitHub App Settings

Set the **Agent endpoint URL** in your GitHub App's Copilot section to:
```
https://your-ngrok-url.ngrok.io/agent
```

### 6. Test in Copilot Chat

```
@code-quality-agent review this function for me:

async function fetchUserData(userId) {
  const user = await db.users.findOne({ id: userId });
  const orders = await db.orders.find({ userId: userId });
  const profile = await db.profiles.findOne({ userId: userId });
  return { user, orders, profile };
}
```

---

## Calling a Real LLM from Your Agent

The scaffold in `index.js` generates responses with a simple rule-based engine to keep it self-contained. In production, you would forward the `messages` array (with your system prompt prepended) to an LLM API:

### Using the OpenAI SDK

```javascript
const OpenAI = require('openai');
const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

async function streamFromOpenAI(messages, res) {
  const stream = await client.chat.completions.create({
    model: 'gpt-4o',
    messages,
    stream: true,
  });

  for await (const chunk of stream) {
    const text = chunk.choices[0]?.delta?.content || '';
    if (text) {
      res.write(`data: ${JSON.stringify({ type: 'text', text })}\n\n`);
    }
  }
  res.write('data: [DONE]\n\n');
  res.end();
}
```

### Using the Anthropic SDK

```javascript
const Anthropic = require('@anthropic-ai/sdk');
const client = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

async function streamFromClaude(systemPrompt, messages, res) {
  const stream = client.messages.stream({
    model: 'claude-opus-4-5',
    max_tokens: 4096,
    system: systemPrompt,
    messages: messages.filter(m => m.role !== 'system'),
  });

  stream.on('text', (text) => {
    res.write(`data: ${JSON.stringify({ type: 'text', text })}\n\n`);
  });

  await stream.finalMessage();
  res.write('data: [DONE]\n\n');
  res.end();
}
```

---

## Troubleshooting

**"Stream ended unexpectedly"**
- Make sure you send `data: [DONE]\n\n` before closing the connection
- Check that each SSE event line ends with `\n\n` (two newlines, not one)

**Responses appear all at once instead of streaming**
- Check that you call `res.flushHeaders()` immediately after setting the SSE headers
- Make sure your proxy (nginx, ngrok) is not buffering the response — add `X-Accel-Buffering: no`

**GitHub returns 401 on your agent endpoint**
- Verify the request signature using your webhook secret
- Check that the `x-hub-signature-256` header is present in the request

**Agent not appearing in `@` dropdown**
- Confirm the GitHub App is installed on your account
- Check that the Agent endpoint URL is set in the Copilot section (not just the Webhook URL)
