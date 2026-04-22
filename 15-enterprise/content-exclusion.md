# Copilot Content Exclusion

Content exclusion prevents specific files and directories from being sent to the Copilot API as context. When a file is excluded, its content cannot influence suggestions — Copilot behaves as if those files do not exist when generating completions for other files, and suggestions do not appear when the excluded file itself is open in the editor.

---

## Table of Contents

1. [What Content Exclusion Does](#what-content-exclusion-does)
2. [What It Does Not Do](#what-it-does-not-do)
3. [Two Levels of Exclusion](#two-levels-of-exclusion)
4. [Pattern Syntax](#pattern-syntax)
5. [What to Exclude](#what-to-exclude)
6. [Example Patterns with Explanations](#example-patterns-with-explanations)
7. [Repository-Level Configuration](#repository-level-configuration)
8. [Organisation-Level Configuration](#organisation-level-configuration)
9. [Verifying That Exclusion Is Working](#verifying-that-exclusion-is-working)
10. [Important Behaviour Notes](#important-behaviour-notes)

---

## What Content Exclusion Does

When a file is covered by a content exclusion rule:

1. **The file is not sent to Copilot as context.** If the file is open in a neighboring tab, Copilot does not include snippets from it when generating completions in other files.

2. **Suggestions are suppressed in the excluded file.** If a developer opens an excluded file and tries to use Copilot (inline suggestions, inline chat, Chat with the file as context), Copilot does not generate suggestions. The ghost text does not appear.

3. **The file cannot be referenced via `#file` in Chat.** If a developer tries to attach an excluded file using `#file:path/to/excluded` in Copilot Chat, the attachment is blocked.

---

## What It Does Not Do

Content exclusion is **not a DLP (Data Loss Prevention) tool**. It is specifically about preventing files from being used as AI context. It does not:

- Prevent developers from reading, copying, or pasting content from excluded files manually
- Prevent secrets from being committed to the repository
- Encrypt or redact file content
- Prevent Copilot Chat from discussing a topic that happens to be covered in an excluded file (if the developer pastes the content directly into the Chat)
- Apply retroactively to data that was sent to Copilot before the exclusion rule was configured

For broader secret scanning and DLP, use GitHub Secret Scanning, GitHub Advanced Security, and your organisation's existing DLP tools.

---

## Two Levels of Exclusion

### Repository-Level Exclusion

Configured within the repository itself. Repository admins can set exclusion rules that apply to all Copilot users accessing that repository.

**Two mechanisms:**

**Mechanism A — Repository settings (recommended):**
In the GitHub web UI, navigate to the repository → **Settings → Copilot → Excluded files**. Add glob patterns directly in the settings UI.

**Mechanism B — `.github/copilot-instructions.md` path exclusions (for instructions only):**
Note: `.github/copilot-instructions.md` is for custom instructions, not exclusions. Do not confuse this file with exclusion configuration.

### Organisation-Level Exclusion

Configured by an organisation admin and applies to all repositories in the organisation, regardless of each repository's own settings. Organisation-level rules are *additive* — they are applied on top of any repository-level rules, not instead of them.

Organisation admins configure this at:
**github.com/organizations/YOUR-ORG/settings/copilot** → **Content exclusion**

---

## Pattern Syntax

Content exclusion uses **glob pattern syntax**, identical to `.gitignore`. Key rules:

| Pattern | Matches |
|---|---|
| `*.env` | Any file ending in `.env` in any directory |
| `.env` | The file named `.env` in the root of the repository |
| `secrets/` | The directory named `secrets/` and all its contents |
| `**/secrets/**` | Any directory named `secrets/` at any depth |
| `src/**/*.generated.ts` | Any `.generated.ts` file anywhere under `src/` |
| `vendor/` | The `vendor/` directory and all its contents |
| `!important.ts` | Negate a pattern — exclude everything except `important.ts` |
| `**/*.pem` | All `.pem` files at any depth |
| `config/database.yml` | Exactly this file at this path |

**Glob anchoring:**
- Patterns without a leading `/` match at any level in the repository.
- Patterns starting with `/` are anchored to the repository root.
- Patterns ending with `/` match directories and all their contents.

---

## What to Exclude

The following categories are strong candidates for exclusion in most organisations:

### Secrets and Credentials

```
**/.env
**/.env.*
**/secrets/**
**/credentials/**
**/*.pem
**/*.key
**/*.p12
**/*.pfx
**/id_rsa
**/id_ed25519
**/.ssh/**
```

### Configuration Files with Sensitive Values

```
config/database.yml
config/production.yml
**/application-prod.properties
**/application-staging.properties
**/appsettings.Production.json
```

### Generated and Vendor Code

Excluding generated and vendor code keeps Copilot's context focused on your first-party code, which typically produces better suggestions:

```
vendor/
node_modules/
**/*.pb.go
**/*.generated.cs
**/__generated__/**
**/*.min.js
**/dist/**
**/build/**
```

### Files Containing PII or Regulated Data

For organisations in regulated industries, exclude files that may contain sample or fixture data derived from real regulated data:

```
tests/fixtures/
tests/testdata/
**/*_test_data.*
**/sample_patients.*
**/anonymised_transactions.*
```

### Binary and Large Files

Binary files are not useful as Copilot context and may cause unnecessary overhead:

```
**/*.sqlite
**/*.db
**/*.lock
**/*.wasm
**/*.bin
```

---

## Example Patterns with Explanations

```
# Exclude all .env files at any depth in the repository.
# Covers .env, .env.local, .env.production, .env.staging, etc.
**/.env*

# Exclude the entire secrets/ directory wherever it appears.
# Useful for repos that store encrypted secrets files in a secrets/ folder.
**/secrets/

# Exclude all PEM certificates and private keys.
# These should never be committed, but if they are, Copilot won't use them.
**/*.pem
**/*.key

# Exclude configuration files that are environment-specific and may contain
# real database passwords, API keys, or connection strings.
config/production.rb
config/secrets.yml
.env.production

# Exclude the vendor/ directory entirely.
# Third-party code is not useful as Copilot context for your own codebase.
vendor/

# Exclude generated gRPC/protobuf files.
# These are auto-generated and Copilot's suggestions for them add no value.
**/*.pb.go
**/*.pb.ts
**/*_grpc.pb.go

# Exclude test fixture files that may contain sensitive or PII-like data.
tests/fixtures/
spec/fixtures/

# Exclude database dumps and seed files.
**/*.sql.gz
db/seeds/production/

# Exclude Terraform state files, which may contain sensitive output values.
**/*.tfstate
**/*.tfstate.backup
.terraform/
```

---

## Repository-Level Configuration

### Via GitHub Web UI (Recommended)

1. Navigate to the repository on GitHub.com
2. Click **Settings** (requires repository admin permissions)
3. In the left sidebar, click **Copilot** under the "Code and automation" section
4. Under **Excluded files**, enter your glob patterns (one per line)
5. Click **Save**

Changes take effect immediately for new Copilot requests. There is no need to restart IDEs, though users who have the excluded files open may need to close and reopen them for the exclusion to apply to the current editor session.

### Checking the Current Repository Configuration

```bash
# Via GitHub CLI (gh):
gh api /repos/YOUR-ORG/YOUR-REPO/copilot/content_exclusion
```

---

## Organisation-Level Configuration

Organisation admins configure content exclusion at the organisation level from:

**github.com/organizations/YOUR-ORG/settings/copilot → Content exclusion**

### Scope of Organisation-Level Exclusions

Organisation-level exclusions can be scoped to:
- **All repositories in the organisation** — applies to every repository
- **Specific repositories** — applies only to the named repositories

### Adding Organisation-Level Exclusions

1. Navigate to **github.com/organizations/YOUR-ORG/settings/copilot**
2. Click **Content exclusion**
3. Click **Add exclusion rule**
4. Choose the repository scope (all repositories or specific repositories)
5. Enter the glob patterns
6. Click **Save**

### Via the REST API

```bash
# List current org-level exclusions:
gh api /orgs/YOUR-ORG/copilot/content_exclusion

# Add an exclusion (replace with your actual payload):
gh api --method PUT /orgs/YOUR-ORG/copilot/content_exclusion \
  -f 'repositories[0][name]=*' \
  -f 'repositories[0][excluded_files][0]=**/.env*'
```

---

## Verifying That Exclusion Is Working

After configuring an exclusion rule, verify it is working as expected:

### Method 1: Open an Excluded File and Attempt Completion

1. Open an excluded file (e.g., `.env`) in VS Code or another supported IDE
2. Place your cursor in the file and type something
3. Wait for Copilot to respond

**Expected behaviour**: No ghost text appears. The Copilot status bar icon may show a tooltip like "Copilot is disabled for this file" or "Content excluded."

### Method 2: Check the Copilot Status in the Editor

In VS Code, click the Copilot icon in the status bar when an excluded file is open. It should indicate that Copilot is not providing suggestions for this file.

### Method 3: Test Context Isolation

1. Open both an excluded file (e.g., a file containing a secret constant `MY_API_KEY = "sk-..."`) and a non-excluded file in the same editor
2. In the non-excluded file, try to get Copilot to suggest the value of `MY_API_KEY`

**Expected behaviour**: Copilot does not suggest the secret value. The excluded file is not part of the context.

**Important caveat**: This test only confirms that the current editor session is using the exclusion. It does not guarantee that historical data from before the exclusion was configured is not available to the model.

---

## Important Behaviour Notes

### Exclusion Is Not Retroactive

If a file was open in an editor tab and used as Copilot context before an exclusion rule was added, there is no way to "un-send" that context. Exclusion prevents future use, not past use.

### Exclusion Does Not Block the Developer from Using the File

Developers can still open, read, and edit excluded files. The only effect is that Copilot will not use those files as AI context and will not generate suggestions while they are the active editor file.

### Exclusion Applies to Context, Not to Topics

If a developer copies a secret from an excluded file and pastes it into a Copilot Chat prompt, Copilot will process it as part of that Chat request. Content exclusion prevents automatic context injection; it does not prevent a developer from manually providing excluded content.

### IDE Support

Content exclusion is honoured by:
- VS Code (with the GitHub Copilot extension)
- JetBrains IDEs (with the GitHub Copilot plugin)
- Visual Studio

Content exclusion may not be enforced consistently in community plugins (Neovim's `copilot.vim`, `copilot.lua`) at this time. Verify behaviour with your specific plugin version.

### Propagation Delay

After adding or changing an exclusion rule, there may be a propagation delay of up to a few minutes before all developer clients pick up the new rules. Clients refresh their exclusion rules periodically or when they re-authenticate.
