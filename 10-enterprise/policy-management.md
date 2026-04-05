# Copilot Policy Management

Policies let organisation and enterprise admins control which Copilot features their members can use, and in some cases whether Copilot is available to members at all. This guide covers each policy, how to configure it, and recommended settings for regulated industries.

---

## Table of Contents

1. [What Policies Control](#what-policies-control)
2. [Key Policies](#key-policies)
3. [Policy Inheritance and Hierarchy](#policy-inheritance-and-hierarchy)
4. [How to Configure Policies](#how-to-configure-policies)
5. [Recommended Settings for Regulated Industries](#recommended-settings-for-regulated-industries)
6. [Checking Effective Policies via the API](#checking-effective-policies-via-the-api)

---

## What Policies Control

Copilot policies are administrative controls that determine:

- **Whether Copilot is enabled** for members of an organisation or enterprise
- **Which Copilot features** are available (CLI, Chat on GitHub.com, PR summaries, etc.)
- **Safety and compliance settings** (public code matching, telemetry, feedback collection)
- **Scope constraints** — what an organisation admin can and cannot configure relative to enterprise-level mandates

Policies operate at two levels:

| Level | Who Sets It | Scope |
|---|---|---|
| Enterprise | Enterprise admin | All orgs and all members within the enterprise |
| Organisation | Org admin | All members of the specific organisation |

When a policy is set at the enterprise level, org admins see it as either enforced (non-configurable) or as a permitted range within which they can operate.

---

## Key Policies

### Enable / Disable Copilot for Members

**What it does**: Enables or disables Copilot access for all members of the organisation. When disabled, no member can use Copilot regardless of their personal subscription status.

**Settings:**
- **Enabled for all members** — all current and future org members automatically have Copilot access
- **Enabled for selected members** — admins manually assign seats
- **Disabled** — Copilot is not available to anyone in the org

**Where to configure:**
`github.com/organizations/YOUR-ORG/settings/copilot/policies`

**Note for enterprise admins**: If Copilot is disabled at the enterprise level, org admins cannot enable it.

---

### Suggestions Matching Public Code (Duplication Filter)

**What it does**: Controls whether Copilot can suggest code that closely matches publicly available code on GitHub. When enabled (i.e., the filter is active), Copilot suppresses suggestions that match public code above a similarity threshold.

This is one of the most important policies for organisations concerned about open-source licence compliance. If a suggestion matches GPL-licensed public code and a developer accepts it, the organisation may inadvertently introduce licence-incompatible code.

**Settings:**
- **Allowed** (no filter) — Copilot may suggest code regardless of public code similarity
- **Blocked** (filter active) — Copilot suppresses suggestions with significant public code similarity

**Recommendation for regulated industries**: Set to **Blocked** to reduce licence compliance risk.

**Where to configure:**
`github.com/organizations/YOUR-ORG/settings/copilot/policies`
→ **Suggestions matching public code**

---

### Copilot in the CLI

**What it does**: Controls whether members can use `gh copilot explain` and `gh copilot suggest` — the GitHub CLI integration that lets users ask Copilot to explain or suggest shell commands.

Some organisations restrict this because it allows Copilot to generate executable shell commands, which may conflict with change management or security policies.

**Settings:**
- **Enabled** — Members can use `gh copilot explain` and `gh copilot suggest`
- **Disabled** — The CLI commands are blocked for org members

---

### Copilot Chat in IDEs

**What it does**: Controls whether org members can access the Copilot Chat panel in VS Code, JetBrains, and other supported IDEs.

Some organisations enable inline suggestions but wish to review and approve Chat separately, since Chat can answer arbitrary questions about the codebase and generate larger blocks of code.

**Settings:**
- **Enabled** — Members can use Copilot Chat in IDEs
- **Disabled** — The Chat panel is unavailable; only inline suggestions work

---

### Copilot on GitHub.com

**What it does**: Controls whether members can use Copilot-powered features on the GitHub web UI, including:
- AI-generated pull request summaries
- Issue assistance (Copilot helping triage and understand issues)
- Copilot in the GitHub mobile app

**Settings:**
- **Enabled** — All GitHub.com Copilot features are available to org members
- **No policy** — Members' individual settings apply
- **Disabled** — GitHub.com Copilot features are blocked for org members

---

### User Feedback for Product Improvement

**What it does**: Controls whether Copilot usage data (suggestion acceptance rates, thumbs up/down ratings, etc.) is shared with GitHub for product improvement purposes.

Under GitHub's data privacy policies for Copilot Business and Enterprise, prompt data is not used to train the base model by default. This policy controls whether aggregated telemetry (not prompts) is shared.

**Settings:**
- **Enabled** — Telemetry is shared with GitHub (supports model improvement)
- **Disabled** — No telemetry is shared with GitHub beyond what is required for service operation

---

### Copilot Extensions

**What it does**: Controls whether members can install and use Copilot Extensions — third-party agents that appear in Copilot Chat as `@extension-name`. Extensions can access external services (e.g., Jira, Sentry, Datadog) from within the Chat interface.

**Settings:**
- **Enabled for all extensions** — Members can install any Copilot Extension
- **Enabled for all extensions except those blocked** — Allows extensions by default; admins can block specific ones
- **Disabled** — No Copilot Extensions are available

**Recommendation**: Start with **Disabled** or **Enabled with review** until your security team has evaluated the data-sharing implications of each extension.

---

## Policy Inheritance and Hierarchy

The Copilot policy system follows a three-tier hierarchy. Higher-level settings restrict or mandate what lower levels can do.

### Possible States for Each Policy

Each policy at the organisation level can be in one of three states:

| State | Meaning |
|---|---|
| **Enforced by enterprise** | The enterprise admin has set a fixed value. Org admins cannot change it. |
| **No policy (default)** | The enterprise has not set a constraint. Org admin can configure freely. |
| **Org-configured** | The org admin has set a value, subject to enterprise constraints. |

### Example: Blocking Public Code Matching at Enterprise Level

```
Enterprise Admin sets "Suggestions matching public code" → Blocked

Result:
 └─ Org A: Policy is "Blocked (enforced by enterprise)" — org admin cannot change it
 └─ Org B: Policy is "Blocked (enforced by enterprise)" — org admin cannot change it
 └─ Org C: Policy is "Blocked (enforced by enterprise)" — org admin cannot change it

 All members across all orgs: Copilot will never suggest public-matching code.
```

### Example: Org Admin Restricts Chat

```
Enterprise Admin: No policy set for "Copilot Chat in IDEs"

Result:
 └─ Org A admin sets "Copilot Chat in IDEs" → Disabled
     └─ Org A members: Cannot use Copilot Chat. Cannot re-enable it.

 └─ Org B admin sets "Copilot Chat in IDEs" → Enabled
     └─ Org B members: Can use Copilot Chat normally.
```

---

## How to Configure Policies

### Organisation Policies

1. Navigate to `https://github.com/organizations/YOUR-ORG/settings/copilot`
2. Click **Policies** in the left sidebar
3. Review the list of policies. Those locked by the enterprise admin show a lock icon and cannot be changed.
4. For configurable policies, use the dropdown or toggle to set the desired value
5. Changes take effect immediately — no deploy or restart is required

### Enterprise Policies

1. Navigate to `https://github.com/enterprises/YOUR-ENTERPRISE/settings/copilot`
2. Click **Policies**
3. Set each policy to either:
   - **No policy** — org admins can configure this independently
   - A specific value (e.g., **Blocked**) — enforced across all orgs

---

## Recommended Settings for Regulated Industries

Different regulated industries have different primary concerns. The following tables provide starting-point recommendations; your compliance and legal teams should review and finalise the policy configuration for your specific regulatory context.

### Financial Services (e.g., SOC 2, PCI-DSS, ISO 27001)

| Policy | Recommended Setting | Rationale |
|---|---|---|
| Copilot inline suggestions | Enabled | Core productivity feature; low risk with content exclusion |
| Suggestions matching public code | **Blocked** | Reduces licence compliance and IP risk |
| Copilot Chat in IDEs | Enabled with review | Chat does not exfiltrate data; enable after security team sign-off |
| Copilot in the CLI | **Disabled** | Shell command generation conflicts with change management controls |
| Copilot on GitHub.com | Enabled | PR summaries are useful; evaluate based on data classification |
| Copilot Extensions | **Disabled** initially | Review each extension's data access before enabling |
| User feedback / telemetry | **Disabled** | Minimise data sharing with third parties per data classification policy |
| Content exclusion | Configure for secrets, config, and PII-adjacent files | Required for PCI-DSS scope files |

### Healthcare (e.g., HIPAA)

| Policy | Recommended Setting | Rationale |
|---|---|---|
| Copilot inline suggestions | Enabled | PHI should be excluded via content exclusion, not policy disable |
| Suggestions matching public code | Blocked | IP protection |
| Copilot Chat in IDEs | Enabled with BAA review | GitHub offers a BAA for applicable tiers; confirm with your legal team |
| Copilot in the CLI | Disabled | CLI commands may interact with production systems containing PHI |
| Copilot on GitHub.com | Evaluate per use case | Ensure no PHI-containing content appears in GitHub UI Copilot features |
| Copilot Extensions | Disabled | Third-party extensions are out of scope for your BAA |
| Content exclusion | **Critical** — exclude all test fixtures, seed data, and any files derived from PHI | Any PHI-adjacent data must be excluded |

### Government / Public Sector

| Policy | Recommended Setting | Rationale |
|---|---|---|
| Copilot inline suggestions | Enabled (after approval) | Subject to FedRAMP or equivalent authorisation |
| Suggestions matching public code | Blocked | |
| Copilot Chat in IDEs | Evaluate per data classification | May require sovereign or FedRAMP-compliant endpoint |
| Copilot in the CLI | Disabled | |
| Copilot on GitHub.com | Disabled or evaluate | Only on GitHub Enterprise Cloud GovCloud if required |
| User feedback / telemetry | **Disabled** | Government data must not leave approved boundaries |

**Note**: For US Federal use, check whether GitHub Copilot is included in your FedRAMP-authorised service agreement. As of early 2026, GitHub Enterprise Cloud has FedRAMP Moderate authorisation; verify which services and features are in scope.

---

## Checking Effective Policies via the API

The GitHub REST API provides an endpoint to check the effective Copilot policy settings for an organisation:

```bash
# Requires an admin token with the manage_billing:copilot scope
gh api /orgs/YOUR-ORG/copilot/billing

# Example response fields:
# {
#   "seat_management_setting": "assign_selected",
#   "public_code_suggestions": "block",
#   "copilot_chat": "enabled",
#   "ide_chat": "enabled",
#   "cli": "disabled",
#   "seat_breakdown": { "total": 50, "added_this_cycle": 3, "active_this_cycle": 47, ... }
# }
```

```bash
# List all seats and their assignment status:
gh api /orgs/YOUR-ORG/copilot/billing/seats \
  --paginate \
  --jq '.seats[] | {login: .assignee.login, created_at: .created_at, pending_cancellation_date: .pending_cancellation_date}'
```

Use these API calls to programmatically audit your policy configuration and generate compliance reports.
