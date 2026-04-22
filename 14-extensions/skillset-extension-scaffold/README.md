# Skillset Extension Scaffold

This scaffold gives you a working GitHub Copilot skillset extension in about 30 minutes. You will end up with a real extension that Copilot can invoke, running locally via ngrok and ready to deploy to production.

A skillset extension is the simplest kind of Copilot Extension: you define skills in a YAML manifest, back each skill with an HTTP endpoint, and GitHub handles all the conversational plumbing. You never manage conversation history or stream responses.

---

## What You Need

| Requirement | Version / Notes |
|---|---|
| Node.js | 18 or higher |
| npm | Comes with Node.js |
| A GitHub account | Must have Copilot access (Individual, Business, or Enterprise) |
| ngrok | For exposing localhost during development |
| A text editor | VS Code recommended |

Install ngrok if you do not have it:

```bash
# macOS
brew install ngrok

# or via npm (works everywhere)
npm install -g ngrok

# Verify
ngrok version
```

---

## Directory Structure

```
skillset-extension-scaffold/
├── index.js                 # Express server — your skill endpoints live here
├── skillset-definition.yaml # Declares the skills Copilot knows about
├── package.json             # Node dependencies
└── README.md                # This file
```

The two key files are `index.js` (the runtime) and `skillset-definition.yaml` (the contract). Copilot reads the YAML to know what skills exist and what parameters they accept. When a user invokes a skill, Copilot POSTs to the corresponding endpoint in `index.js`.

---

## Step 1: Install Dependencies

```bash
cd 14-extensions/skillset-extension-scaffold
npm install
```

This installs Express and the other small dependencies declared in `package.json`.

---

## Step 2: Register a GitHub App

Your extension lives inside a GitHub App. Every Copilot Extension must be a GitHub App.

1. Go to **github.com → Settings → Developer settings → GitHub Apps → New GitHub App**

2. Fill in the fields:

   | Field | Value |
   |---|---|
   | GitHub App name | `my-code-reviewer` (must be globally unique) |
   | Homepage URL | `https://github.com/your-username/your-repo` |
   | Webhook URL | Leave blank for now — you'll fill this in after starting ngrok |
   | Webhook secret | Generate a random string, save it |

3. Under **Permissions & events → Repository permissions**, add:
   - **Contents**: Read-only (so the extension can read code when needed)

4. Under **Copilot** (scroll down in permissions):
   - Enable **Copilot Chat**

5. Click **Create GitHub App**

6. On the app's settings page, scroll down and click **Generate a private key**. Save the downloaded `.pem` file — you'll need it to verify incoming requests.

7. Note down your **App ID** and **Client ID** from the top of the settings page.

---

## Step 3: Configure Environment Variables

Create a `.env` file in the scaffold directory (never commit this file):

```bash
# .env
GITHUB_APP_ID=123456
GITHUB_CLIENT_ID=Iv1.abc123def456
GITHUB_PRIVATE_KEY_PATH=./private-key.pem
WEBHOOK_SECRET=your_random_webhook_secret
PORT=3000
```

Copy your downloaded `.pem` file into the scaffold directory as `private-key.pem`.

---

## Step 4: Start the Server

```bash
node index.js
```

You should see:

```
Skillset extension server running on port 3000
Health check available at http://localhost:3000/health
```

Test the health endpoint:

```bash
curl http://localhost:3000/health
# {"status":"ok","timestamp":"...","skills":["code-review","explain-error"]}
```

---

## Step 5: Expose Localhost with ngrok

Open a new terminal window and run:

```bash
ngrok http 3000
```

ngrok will print output like:

```
Forwarding   https://a1b2c3d4.ngrok.io -> http://localhost:3000
```

Copy the `https://...ngrok.io` URL. This is your public endpoint.

---

## Step 6: Connect ngrok URL to Your GitHub App

1. Go back to your GitHub App settings page
2. In the **Webhook URL** field, enter: `https://a1b2c3d4.ngrok.io/events`
3. Click **Save changes**

Now configure the skillset definition URL:

1. In your GitHub App settings, find the **Copilot** section
2. Under **Skillset definition URL**, enter: `https://a1b2c3d4.ngrok.io/skillset`
3. Save

GitHub will fetch `GET /skillset` from your server to read the YAML manifest. The `index.js` scaffold serves this automatically.

---

## Step 7: Install the Extension on Your Account

1. On your GitHub App's settings page, click **Install App** in the left sidebar
2. Choose your personal account (or an organization)
3. Click **Install**
4. Complete any OAuth prompts

---

## Step 8: Test in Copilot Chat

Open VS Code with GitHub Copilot installed. Open the Chat panel (`Ctrl+Shift+I`).

Type:

```
@my-code-reviewer /code-review focus_area=security

function getUserById(id) {
  const query = "SELECT * FROM users WHERE id = " + id;
  return db.execute(query);
}
```

Copilot will route your message to the `/code-review` endpoint on your local server and display the response in the chat panel.

Try the error explainer:

```
@my-code-reviewer /explain-error

TypeError: Cannot read properties of undefined (reading 'map')
  at processItems (app.js:42:23)
```

---

## Step 9: Upload the Skillset Definition

Instead of serving the YAML dynamically, you can also upload it directly in your GitHub App settings:

1. Go to your GitHub App → **Copilot** section
2. Click **Upload skillset definition**
3. Upload your `skillset-definition.yaml` file

This is simpler for production but means you need to re-upload whenever you change the skills.

---

## Deploying to Production

Once you're happy with local development, deploy to a permanent host and update your GitHub App's Webhook URL and skillset definition URL.

### Railway (Recommended for Simplicity)

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Initialize a new project in the scaffold directory
railway init

# Set environment variables
railway variables set GITHUB_APP_ID=123456
railway variables set GITHUB_CLIENT_ID=Iv1.abc123def456
railway variables set WEBHOOK_SECRET=your_secret
# Upload the private key content:
railway variables set GITHUB_PRIVATE_KEY="$(cat private-key.pem)"

# Deploy
railway up
```

Railway gives you a URL like `https://my-code-reviewer.up.railway.app`. Update your GitHub App settings with this URL.

### Render

1. Push your scaffold to a GitHub repo
2. Go to render.com → New → Web Service
3. Connect your repo
4. Set the start command: `node index.js`
5. Add environment variables in the Render dashboard
6. Deploy — Render gives you a `https://your-app.onrender.com` URL

### Fly.io

```bash
# Install flyctl
brew install flyctl   # macOS

# Launch (from the scaffold directory)
fly launch

# Set secrets
fly secrets set GITHUB_APP_ID=123456
fly secrets set WEBHOOK_SECRET=your_secret
fly secrets set GITHUB_PRIVATE_KEY="$(cat private-key.pem)"

# Deploy
fly deploy
```

---

## How Users Install Your Extension

Once your extension is deployed and your GitHub App is public:

1. Users go to `github.com/marketplace/apps/my-code-reviewer`
2. Click **Install** and choose their account or organization
3. Authorize the OAuth permissions
4. The extension appears in their Copilot Chat `@` dropdown

For private/internal extensions (e.g., within a company), you can share a direct install link without publishing to the Marketplace.

---

## Troubleshooting

**"Extension not found" when typing `@my-code-reviewer`**
- Make sure you've installed the GitHub App on your account (Step 7)
- Check that the App name matches exactly what you type after `@`

**"Failed to load skillset definition"**
- Confirm ngrok is running and the tunnel URL is correct
- Test directly: `curl https://your-ngrok-url.ngrok.io/skillset`
- Check that the YAML is valid: `node -e "require('js-yaml').load(require('fs').readFileSync('skillset-definition.yaml', 'utf8'))"`

**Requests not reaching your server**
- Check the ngrok web interface at `http://localhost:4040` — it shows all incoming requests
- Look at your server logs for incoming POST requests

**"Signature verification failed"**
- Double-check that `WEBHOOK_SECRET` in `.env` matches what you set in the GitHub App settings
