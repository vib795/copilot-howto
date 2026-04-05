# Copilot Usage Audit Logs

GitHub's audit log records significant actions taken by organisation members and administrators. For Copilot, the audit log captures seat assignment changes, policy changes, and (in enterprise tiers) Chat interaction events. This guide covers what gets logged, how to access and filter the log, how to export it, and how to use it for compliance.

---

## Table of Contents

1. [What Gets Logged](#what-gets-logged)
2. [What Is Not Logged](#what-is-not-logged)
3. [How to Access the Audit Log](#how-to-access-the-audit-log)
4. [Filtering the Audit Log](#filtering-the-audit-log)
5. [Key Copilot Audit Log Events](#key-copilot-audit-log-events)
6. [Exporting the Audit Log](#exporting-the-audit-log)
7. [Streaming to a SIEM](#streaming-to-a-siem)
8. [Querying via the REST API](#querying-via-the-rest-api)
9. [Compliance Use Cases](#compliance-use-cases)

---

## What Gets Logged

The following Copilot-related activities are captured in the GitHub audit log:

| Category | Specific Events |
|---|---|
| Seat management | Assigning a Copilot seat to a user |
| Seat management | Revoking a Copilot seat from a user |
| Seat management | User joining/leaving an org and seat status changing |
| Policy changes | Changing the "public code suggestions" policy |
| Policy changes | Enabling or disabling Copilot Chat |
| Policy changes | Enabling or disabling Copilot in the CLI |
| Policy changes | Enabling or disabling Copilot Extensions |
| Policy changes | Changing content exclusion rules |
| Feature settings | Enabling or disabling Copilot on GitHub.com |
| Chat interactions | Copilot Chat prompts and responses (Enterprise tier, if enabled) |
| Feedback | User thumbs up/down on a Copilot suggestion (if telemetry is enabled) |
| Authentication | Copilot OAuth app authorisation events |

---

## What Is Not Logged

Understanding the limits of audit logging is important for compliance planning:

- **Inline suggestion content**: The actual code that Copilot suggested and whether it was accepted or rejected is **not** in the audit log by default. Suggestion acceptance rate data is available in Copilot usage metrics (`/orgs/{org}/copilot/usage`), but that data is aggregate and not user-attributable in the standard audit log.
- **Exact Chat prompts and responses**: For Copilot Business (not Enterprise), Chat interaction content is not logged in the audit log. For Copilot Enterprise, this can be enabled but is subject to privacy and legal review.
- **What code the user wrote after accepting a suggestion**: Once a suggestion is accepted, it becomes the developer's code. There is no mechanism to track which lines of committed code originated from a Copilot suggestion.

---

## How to Access the Audit Log

### Organisation Audit Log (Organisation Admin)

1. Navigate to your organisation: `https://github.com/organizations/YOUR-ORG`
2. Click **Settings**
3. In the left sidebar, click **Audit log** (under "Archives")
4. The audit log UI shows a searchable, filterable timeline of events

### Enterprise Audit Log (Enterprise Admin)

1. Navigate to your enterprise: `https://github.com/enterprises/YOUR-ENTERPRISE`
2. Click **Settings**
3. In the left sidebar, click **Audit log**
4. The enterprise audit log aggregates events from all organisations in the enterprise

---

## Filtering the Audit Log

### Using the Search Bar

The audit log search bar accepts a free-text query or a structured filter. To filter for Copilot-related events:

```
action:copilot
```

This returns all events whose action begins with `copilot.`.

To filter to a specific user:

```
action:copilot actor:username
```

To filter to a date range:

```
action:copilot created:2025-01-01..2025-12-31
```

To filter to a specific event type:

```
action:copilot.cfb_setting_change
```

### Combining Filters

```
action:copilot.seat_assignment_change actor:admin-username created:>=2025-06-01
```

---

## Key Copilot Audit Log Events

The following are the most commonly referenced Copilot audit log event types:

| Event | Description |
|---|---|
| `copilot.cfb_setting_change` | A Copilot for Business setting was changed (policy change). The `setting` field indicates which policy. |
| `copilot.seat_assignment_change` | A Copilot seat was assigned or unassigned. The `user` field is the affected user. |
| `copilot.seat_cancelled` | A Copilot seat assignment was cancelled (user removed or subscription change). |
| `copilot.seat_created` | A Copilot seat was newly created for a user. |
| `copilot.content_exclusion_created` | A content exclusion rule was added. |
| `copilot.content_exclusion_deleted` | A content exclusion rule was removed. |
| `copilot.content_exclusion_updated` | A content exclusion rule was modified. |
| `copilot.enterprise_settings_changed` | An enterprise-level Copilot setting was changed. |
| `copilot.chat_message` | A Copilot Chat interaction (Enterprise tier, if logging is enabled). |

### Example: Seat Assignment Change Event

```json
{
  "action": "copilot.seat_assignment_change",
  "actor": "admin-alice",
  "user": "developer-bob",
  "org": "acme-corp",
  "created_at": "2025-03-15T14:32:00Z",
  "seat_type": "copilot_for_business",
  "previous_state": "inactive",
  "new_state": "active"
}
```

### Example: Policy Change Event

```json
{
  "action": "copilot.cfb_setting_change",
  "actor": "admin-alice",
  "org": "acme-corp",
  "created_at": "2025-03-15T14:35:00Z",
  "setting": "public_code_suggestions",
  "previous_value": "allowed",
  "new_value": "blocked"
}
```

---

## Exporting the Audit Log

### CSV Export (Web UI)

1. Navigate to the audit log (organisation or enterprise)
2. Apply filters to narrow the date range and event type (exporting without filters on a large org can produce very large files)
3. Click **Export** → **Export as CSV**
4. A `.csv` file is generated and downloaded

The CSV export is suitable for one-time compliance reports and sharing with auditors. It is not suitable for ongoing automated monitoring (use the REST API or streaming for that).

### Export via the REST API

```bash
# Export all Copilot events for the last 30 days as JSON:
gh api \
  --paginate \
  "/orgs/YOUR-ORG/audit-log?phrase=action:copilot&per_page=100&after=$(date -d '30 days ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -v-30d +%Y-%m-%dT%H:%M:%SZ)" \
  > copilot-audit-$(date +%Y%m%d).json
```

The above uses the `gh` CLI which handles authentication automatically. Replace `YOUR-ORG` with your organisation slug.

---

## Streaming to a SIEM

For ongoing compliance monitoring, GitHub supports streaming audit log events in real-time to external SIEM platforms. This is available for GitHub Enterprise Cloud.

### Supported Streaming Destinations

| Destination | Protocol |
|---|---|
| Amazon S3 | Webhook / S3 direct |
| Azure Blob Storage | Azure Event Hubs |
| Google Cloud Storage | Pub/Sub |
| Splunk | Splunk HEC (HTTP Event Collector) |
| Datadog | Datadog Logs API |
| Generic HTTPS endpoint | Webhook |

### Configuring Audit Log Streaming

1. Navigate to `https://github.com/enterprises/YOUR-ENTERPRISE/settings/audit-log`
2. Click **Audit log streaming**
3. Click **Configure**
4. Select your streaming destination and follow the configuration wizard

**Note**: Audit log streaming requires Copilot Enterprise (or GitHub Enterprise Cloud). It is not available for Copilot Business.

### What Gets Streamed

Once configured, all audit log events (not just Copilot events) are streamed to the destination. Apply SIEM-side filtering to focus on `action:copilot.*` events.

### Example: Splunk Search for Copilot Seat Changes (after streaming)

```spl
index=github_audit action="copilot.seat_assignment_change"
| table _time, actor, user, org, previous_state, new_state
| sort -_time
```

---

## Querying via the REST API

The GitHub REST API provides programmatic access to the audit log. This is useful for automated compliance checks, dashboards, and scheduled reports.

### Authentication

You need a personal access token (PAT) or GitHub App token with the `read:audit_log` scope (or `manage_billing:copilot` for usage-related endpoints).

```bash
# Set your token:
export GH_TOKEN="ghp_your_token_here"
```

### List Copilot Events (Organisation)

```bash
# Using gh CLI:
gh api "/orgs/YOUR-ORG/audit-log?phrase=action:copilot&per_page=100" \
  --paginate \
  --jq '.[] | {action, actor, user: .user, created_at, setting, new_value}'
```

```bash
# Using curl directly:
curl -s \
  -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/orgs/YOUR-ORG/audit-log?phrase=action%3Acopilot&per_page=100" \
  | jq '.[] | {action, actor, user, created_at}'
```

### List Copilot Events (Enterprise)

```bash
gh api "/enterprises/YOUR-ENTERPRISE/audit-log?phrase=action:copilot&per_page=100" \
  --paginate \
  --jq '.[]'
```

### Get Copilot Seat Usage Metrics

The audit log records *events*. For ongoing *usage metrics* (active users, acceptance rates), use the dedicated usage API:

```bash
# Monthly active Copilot users and suggestion statistics:
gh api "/orgs/YOUR-ORG/copilot/usage" \
  --jq '.[] | {date, total_suggestions_count, total_acceptances_count, total_lines_suggested, total_lines_accepted, total_active_users}'
```

```bash
# Per-language breakdown:
gh api "/orgs/YOUR-ORG/copilot/usage" \
  --jq '.[] | .breakdown[] | {day: .date, language, suggestions: .suggestions_count, acceptances: .acceptances_count}'
```

---

## Compliance Use Cases

### Use Case 1: Demonstrating Seat Governance to Auditors

**Requirement**: Auditors want to confirm that only authorised employees have Copilot access and that access is removed when employees leave.

**Approach**:
1. Export the `copilot.seat_assignment_change` events for the audit period
2. Cross-reference with your HR offboarding records to show seat removal on or before the last day of employment
3. Show that seat assignments match your approved access list

**Query:**
```bash
gh api "/orgs/YOUR-ORG/audit-log?phrase=action:copilot.seat_assignment_change&per_page=100" \
  --paginate \
  --jq '.[] | select(.new_state == "active") | {actor, user, created_at}'
```

### Use Case 2: Proving Policy Compliance

**Requirement**: Auditors want to confirm that the "block public code suggestions" policy was enabled throughout the audit period.

**Approach**:
1. Query for `copilot.cfb_setting_change` events where `setting == "public_code_suggestions"`
2. Confirm the policy was set to `blocked` at the start of the audit period
3. Confirm there are no events showing a change to `allowed` during the audit period

**Query:**
```bash
gh api "/orgs/YOUR-ORG/audit-log?phrase=action:copilot.cfb_setting_change&per_page=100" \
  --paginate \
  --jq '.[] | select(.setting == "public_code_suggestions") | {actor, previous_value, new_value, created_at}'
```

### Use Case 3: Auditing Content Exclusion Changes

**Requirement**: Security team needs to know if anyone has modified the content exclusion rules (which could expose sensitive files to Copilot context).

**Approach**: Monitor for `copilot.content_exclusion_created`, `copilot.content_exclusion_deleted`, and `copilot.content_exclusion_updated` events.

**Query:**
```bash
gh api "/orgs/YOUR-ORG/audit-log?phrase=action:copilot.content_exclusion&per_page=100" \
  --paginate \
  --jq '.[] | {action, actor, created_at, details}'
```

Set up an alert in your SIEM to trigger whenever this query returns new results. Any unexpected change to content exclusion rules should be investigated.

### Use Case 4: Generating a Monthly Copilot Usage Report

```bash
#!/bin/bash
# monthly-copilot-report.sh

ORG="YOUR-ORG"
OUTPUT="copilot-report-$(date +%Y-%m).txt"

echo "GitHub Copilot Usage Report - $(date +%B %Y)" > "$OUTPUT"
echo "Organisation: $ORG" >> "$OUTPUT"
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$OUTPUT"
echo "" >> "$OUTPUT"

echo "=== Seat Usage ===" >> "$OUTPUT"
gh api "/orgs/$ORG/copilot/billing" \
  --jq '"Total seats: \(.seat_breakdown.total)\nActive this cycle: \(.seat_breakdown.active_this_cycle)\nAdded this cycle: \(.seat_breakdown.added_this_cycle)"' \
  >> "$OUTPUT"

echo "" >> "$OUTPUT"
echo "=== Suggestion Metrics (Last 28 Days) ===" >> "$OUTPUT"
gh api "/orgs/$ORG/copilot/usage" \
  --jq '.[] | "\(.day): \(.total_suggestions_count) suggestions, \(.total_acceptances_count) accepted (\(if .total_suggestions_count > 0 then ((.total_acceptances_count / .total_suggestions_count * 100) | round) else 0 end)% acceptance rate)"' \
  >> "$OUTPUT"

echo "Report written to $OUTPUT"
```
