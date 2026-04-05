# Copilot Extensions on the GitHub Marketplace

The GitHub Marketplace lists Copilot-compatible extensions from verified publishers. This guide helps you find, evaluate, and use the most useful ones.

---

## How to Find Extensions

### On GitHub Marketplace

The most direct path:

```
https://github.com/marketplace?type=apps&copilot_app=true
```

You can filter by category (Code quality, Monitoring, Documentation, etc.) and sort by most installed.

### In VS Code

1. Open Copilot Chat (`Ctrl+Shift+I` / `Cmd+Shift+I`)
2. Type `@` in the chat input
3. Click **Browse extensions** at the bottom of the dropdown
4. This opens the Marketplace pre-filtered to Copilot-compatible apps

### On github.com/copilot

1. Open the Copilot Chat panel
2. Click the extension icon in the panel header
3. This shows installed extensions and a link to discover more

---

## Recommended Extensions by Category

### Code Quality

#### GitHub (Built-in)
**Publisher:** GitHub (first-party, verified)
**What it does:** The built-in `@github` participant gives Copilot access to your GitHub data — issues, pull requests, repositories, and code search. It does not require separate installation; it is available to all Copilot users.

**How to invoke:**
```
@github what open issues are assigned to me?
@github summarize PR #142
@github find all files that import the UserService class
```

**Sample prompt:**
```
@github I'm about to merge PR #67. Are there any open issues that this PR might close based on its description?
```

---

#### Sentry
**Publisher:** Sentry (verified)
**What it does:** Brings Sentry error tracking data into Copilot Chat. You can ask about recent errors, get full stack traces, and ask Copilot to help fix issues — all without leaving your editor.

**How to invoke:**
```
@sentry what errors spiked in the last hour on production?
@sentry show me the full details of PYTHON-ABC123
```

**Sample prompt:**
```
@sentry the error FRONTEND-4521 is blocking our release. Show me the full stack trace and the affected users count.
```

**Install:** [github.com/marketplace/sentry](https://github.com/marketplace/sentry)

---

### Cloud and Infrastructure

#### Azure (Microsoft)
**Publisher:** Microsoft (verified)
**What it does:** Lets you ask questions about Azure resources, deployments, and documentation without leaving your editor. Useful for understanding Azure service limits, querying deployment status, and getting ARM/Bicep template help.

**How to invoke:**
```
@azure what Azure service should I use to host a containerized Node.js app?
@azure what's the connection string format for Azure Service Bus?
```

**Sample prompt:**
```
@azure I need to deploy a Node.js API that auto-scales under load, stores data in PostgreSQL, and has a Redis cache. What Azure services should I use and how do they connect?
```

**Install:** [github.com/marketplace/azure-for-github-copilot](https://github.com/marketplace/azure-for-github-copilot)

---

#### Datadog
**Publisher:** Datadog (verified)
**What it does:** Surfaces Datadog observability data — metrics, logs, APM traces, and monitors — in Copilot Chat. Connect a production incident to the code that caused it without switching context.

**How to invoke:**
```
@datadog what services have elevated error rates right now?
@datadog show me the slowest database queries over the last 24 hours
```

**Sample prompt:**
```
@datadog our checkout service latency spiked at 14:30 UTC. Show me the traces around that time and tell me which downstream service is the bottleneck.
```

**Install:** [github.com/marketplace/datadog-for-github-copilot](https://github.com/marketplace/datadog-for-github-copilot)

---

### Documentation

#### Mintlify
**Publisher:** Mintlify (verified)
**What it does:** Helps you write, update, and publish documentation. Can generate docstrings, API reference pages, and prose docs from your code. Integrates with Mintlify's hosted docs platform.

**How to invoke:**
```
@mintlify generate JSDoc for this function
@mintlify write an API reference section for this endpoint
```

**Sample prompt:**
```
@mintlify #file:src/api/payments.ts generate API reference documentation for all exported functions. Use our existing docs style with parameter tables and example responses.
```

**Install:** [github.com/marketplace/mintlify](https://github.com/marketplace/mintlify)

---

#### ReadMe
**Publisher:** ReadMe (verified)
**What it does:** Connects your Copilot session to your ReadMe API documentation portal. Query your API docs, check for discrepancies between docs and code, and update docs from within the IDE.

**How to invoke:**
```
@readme does our /users POST endpoint match the docs?
@readme what authentication methods does our API support according to the docs?
```

**Sample prompt:**
```
@readme #file:src/routes/users.ts compare this implementation against our published API docs. List any endpoints that exist in the code but are not in the docs.
```

**Install:** [github.com/marketplace/readme](https://github.com/marketplace/readme)

---

### Data and Search

#### Sourcegraph
**Publisher:** Sourcegraph (verified)
**What it does:** Cody-powered code search across all your repositories, not just the currently open one. Useful for finding how a pattern is used across a large monorepo or multiple repos that @workspace does not index.

**How to invoke:**
```
@sourcegraph find all usages of the PaymentGateway interface across all repos
@sourcegraph show me how we handle database migrations in other services
```

**Sample prompt:**
```
@sourcegraph search for all places we call sendEmail() across every repository. I need to audit them before we migrate to a new email provider.
```

**Install:** [github.com/marketplace/sourcegraph](https://github.com/marketplace/sourcegraph)

---

#### MongoDB
**Publisher:** MongoDB (verified)
**What it does:** Helps with MongoDB query construction, schema design, index optimization, and Atlas configuration. Can generate aggregation pipelines from natural language descriptions.

**How to invoke:**
```
@mongodb write an aggregation pipeline to count orders by status for the last 30 days
@mongodb what indexes should I add to this collection for this query pattern?
```

**Sample prompt:**
```
@mongodb I have a collection of orders with fields: userId, status, createdAt, total, items (array). I need to find the top 10 customers by total spend in the last 90 days, grouped by status. Write the aggregation pipeline.
```

**Install:** [github.com/marketplace/mongodb](https://github.com/marketplace/mongodb)

---

### Productivity

#### Jira (Atlassian)
**Publisher:** Atlassian (verified)
**What it does:** Surfaces Jira issue data in Copilot Chat. Ask about ticket status, acceptance criteria, and sprint progress without leaving the editor. Useful for staying aligned with product requirements while coding.

**How to invoke:**
```
@jira what's in the current sprint?
@jira show me the acceptance criteria for PROJ-1234
```

**Sample prompt:**
```
@jira I'm implementing PROJ-891. Show me the full acceptance criteria and any linked design tickets. I want to make sure my implementation covers everything before I open a PR.
```

**Install:** [github.com/marketplace/jira](https://github.com/marketplace/jira)

---

#### Linear
**Publisher:** Linear (verified)
**What it does:** Brings Linear issue tracking into Copilot Chat. Query issues, cycles, and project progress. Useful for teams that use Linear as their issue tracker.

**How to invoke:**
```
@linear what issues are in the current cycle?
@linear show me all bugs assigned to me
```

**Sample prompt:**
```
@linear I just fixed a bug with JWT refresh tokens. Search for any open issues related to authentication or token expiry that this fix might also resolve.
```

**Install:** [github.com/marketplace/linear](https://github.com/marketplace/linear)

---

## How to Evaluate an Extension Before Installing

Not all Marketplace extensions are equal. Before installing any extension, check these factors:

### Publisher Verification

Look for the **Verified** badge on the Marketplace listing. This means GitHub has confirmed the publisher's identity. Extensions from recognized companies (Microsoft, Atlassian, Datadog) carry lower risk than unverified individual publishers.

### Permissions Requested

Every extension declares what GitHub permissions it needs. Review these carefully on the installation page.

| Permission | What it means | Risk level |
|---|---|---|
| **Contents (read)** | Can read your repository files | Low — expected for code tools |
| **Issues (write)** | Can create and edit issues | Medium — verify you want this |
| **Pull requests (write)** | Can create and merge PRs | High — limit to extensions you trust |
| **Admin (org/repo)** | Administrative control | Very high — scrutinize carefully |
| **Email addresses** | Access your email | Medium — check the privacy policy |

Red flags:
- An extension requesting `admin` permissions with no obvious reason
- A new extension (< 100 installs) from an unverified publisher requesting broad permissions
- No privacy policy or terms of service linked from the Marketplace listing

### Source Code Transparency

Many extension publishers open-source their extension server. If the source is public, you can audit what the extension does with your code and conversation history. Check the Marketplace listing for a "Source code" or "GitHub repository" link.

### User Reviews and Install Count

Extensions with thousands of installs and recent positive reviews have more social proof. New extensions with zero reviews are not necessarily bad — but factor in the publisher's reputation.

---

## How to Uninstall an Extension

### From GitHub Settings

1. Go to **github.com → Settings → Applications → Installed GitHub Apps**
2. Find the extension you want to remove
3. Click **Configure**
4. Scroll to the bottom and click **Uninstall**
5. Confirm the uninstall

This immediately revokes the extension's access to your account and removes it from the Copilot `@` dropdown.

### Suspending Without Uninstalling

If you want to temporarily disable an extension without losing your configuration:

1. **github.com → Settings → Applications → Installed GitHub Apps**
2. Click **Configure** next to the extension
3. Under **Repository access**, change it to **No repositories** — this suspends the extension's access without uninstalling it
4. To re-enable, change repository access back to your desired repos

---

## Building Your Own Extension

If no Marketplace extension does exactly what you need, you can build your own. See:

- [Skillset Extension Scaffold](./skillset-extension-scaffold/README.md) — for tool-like extensions (discrete commands)
- [Agent Extension Scaffold](./agent-extension-scaffold/README.md) — for conversational agents
- [Code Review Extension Example](./code-review-extension.md) — complete worked example

Internal extensions (not listed on the Marketplace) can be installed directly via a GitHub App install link, making them practical for company-internal tools.
