# Configuring Copilot Access with SAML/OIDC SSO

When a GitHub organisation enforces SAML SSO (or OIDC with GitHub Enterprise Cloud), Copilot access is tied to the SSO session. Developers must explicitly authorise Copilot under their SSO-enforced organisation, and the token expiry behaviour changes. This guide covers the complete SSO + Copilot setup.

---

## Table of Contents

1. [How SSO Affects Copilot](#how-sso-affects-copilot)
2. [SAML SSO: What Changes for Developers](#saml-sso-what-changes-for-developers)
3. [How to Authorise the Copilot OAuth App Under SAML](#how-to-authorise-the-copilot-oauth-app-under-saml)
4. [OIDC (GitHub Enterprise Cloud)](#oidc-github-enterprise-cloud)
5. [Troubleshooting](#troubleshooting)
6. [Administrator: Verifying SSO Enforcement Does Not Break Copilot](#administrator-verifying-sso-enforcement-does-not-break-copilot)

---

## How SSO Affects Copilot

GitHub Copilot access is granted through **GitHub organisation membership**. SAML SSO is a feature that governs *who is allowed to remain a member of a GitHub organisation*: if a user's SSO session expires (or they are de-provisioned in the identity provider), GitHub revokes their organisation membership and thus their Copilot access.

The chain of dependencies:

```
Identity Provider (Okta / Azure AD / Google Workspace / etc.)
         │
         │  SAML assertion / OIDC token
         ▼
GitHub.com organisation (SSO enforced)
         │
         │  Org membership + Copilot seat assignment
         ▼
GitHub Copilot API access
         │
         │  OAuth app token
         ▼
Developer's IDE (VS Code, JetBrains, etc.)
```

**Key insight**: When your org enables SAML SSO, developers need a *SSO-authorised OAuth token* for Copilot. The regular GitHub OAuth token that Copilot obtains during IDE authentication is not automatically SSO-authorised — it must be explicitly granted access to the SSO-enforcing organisation.

---

## SAML SSO: What Changes for Developers

### Before SSO Enforcement

Without SSO, a developer authenticates Copilot once (via the device code flow in their IDE) and the resulting OAuth token works indefinitely (until revoked). The token grants Copilot API access based on seat assignment.

### After SSO Enforcement

With SAML SSO enforced on an organisation:

1. The developer's existing Copilot OAuth token may lose access to the SSO-enforced org
2. Copilot suggestions stop working, or the developer sees an error message
3. The developer must **authorise the Copilot OAuth app** under their SSO settings

This is a one-time action (per org per device), not something developers need to do every time they use Copilot. Once the OAuth app is authorised for SSO, it works until the token is revoked or the user is deprovisioned.

---

## How to Authorise the Copilot OAuth App Under SAML

### Step-by-Step for Developers

1. Navigate to [github.com/settings/applications](https://github.com/settings/applications)
2. Click the **Authorized OAuth Apps** tab
3. Find **"GitHub Copilot Plugin"** (or **"GitHub Copilot"**) in the list
4. Click on it to open the details page
5. Under **"Organisation access"**, find your SSO-enforcing organisation
6. Click **Grant** next to the organisation name
7. If prompted, complete the SAML SSO authentication with your identity provider (sign in to Okta / Azure AD / etc.)
8. Return to the app details page — the organisation should now show a green checkmark

After granting access, Copilot in your IDE should resume working within a few seconds (the IDE's extension periodically re-checks token validity).

### Alternative Path: Via the Organisation's SSO Page

1. Navigate to `https://github.com/orgs/YOUR-ORG/sso` (replace `YOUR-ORG` with the org slug)
2. If prompted, complete the SAML login
3. Once authenticated to the org via SSO, GitHub OAuth apps that you have previously authorised are automatically granted SSO access for that session

### For PATs (Personal Access Tokens) Used in CI/CD

If you have automated scripts or CI/CD pipelines that use a PAT to interact with the Copilot API:

1. Navigate to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click the PAT you want to authorise
3. Click **Configure SSO** → **Authorize** next to the org name
4. Complete the SAML authentication flow

Fine-grained PATs (the newer token type) do not currently require SSO authorisation in the same way — they are scoped to specific repositories and respect org membership directly.

---

## OIDC (GitHub Enterprise Cloud)

GitHub Enterprise Cloud supports OIDC-based SSO as an alternative to SAML. OIDC provides tighter integration between your identity provider session and GitHub access, with an important difference:

### OIDC Token Expiry Behaviour

With OIDC configured:
- When a user's session in the identity provider expires (e.g., end of workday, SSO timeout), GitHub automatically expires the user's OAuth token
- Copilot stops working as soon as the IdP session ends
- The developer must re-authenticate with the IdP to resume Copilot access

This is more secure than SAML because access is tied to an active IdP session, but it requires developers to re-authenticate to their IdP more frequently (depending on your IdP's session lifetime configuration).

### Configuring OIDC Session Lifetime

Work with your identity provider admin to set an appropriate session lifetime:

| IdP | Session Lifetime Setting Location |
|---|---|
| Okta | Admin → Security → Session → Maximum Session Lifetime |
| Azure AD | Azure Portal → Azure AD → Properties → Session Lifetime Policies |
| Google Workspace | Admin Console → Security → Google Session Control |

A typical enterprise setting is 8–12 hours (one working day), which matches the average development session without requiring multiple re-authentications per day.

### Enabling OIDC on GitHub Enterprise Cloud

Enterprise admins enable OIDC at:
`github.com/enterprises/YOUR-ENTERPRISE/settings/security`
→ **Authentication security** → **OIDC single sign-on**

Follow GitHub's official OIDC SSO guide for your specific IdP. Once enabled, the OIDC configuration replaces (not supplements) SAML.

---

## Troubleshooting

### "This organisation requires SAML SSO"

**Symptom**: Copilot in the IDE shows an error like:
```
This organisation requires SAML SSO. To access this resource, you must use a SAML SSO-authorized OAuth token.
```

**Cause**: The Copilot OAuth app has not been authorised for the SSO-enforcing organisation.

**Solution**: Follow [How to Authorise the Copilot OAuth App Under SAML](#how-to-authorise-the-copilot-oauth-app-under-saml).

---

### Copilot Stopped Working After SSO Was Enabled on the Organisation

**Symptom**: Copilot was working fine. The org admin enabled SAML SSO. Copilot now shows errors or no suggestions.

**Cause**: Existing OAuth tokens are not automatically SSO-authorised when SSO is first enabled.

**Solution for developers**:
1. In VS Code: Click the Copilot icon → Sign Out → Sign in again → complete the device code flow
2. After signing in, follow the OAuth app authorisation steps above

**Solution for org admins** (proactive):
Before enabling SSO, communicate to all Copilot users that they will need to re-authorise the Copilot OAuth app. Consider sending a link to this guide along with the notice.

---

### Copilot Works for Some Users in the Org but Not Others

**Symptom**: Some org members' Copilot works fine, others see "SAML SSO" errors.

**Cause**: The users seeing errors have not completed the SAML SSO handshake for the organisation since SSO was enabled. They may have been added to the org before SSO enforcement.

**Solution**: Each affected user must visit `https://github.com/orgs/YOUR-ORG/sso` and complete the SSO authentication. Then they must authorise the Copilot OAuth app as described above.

---

### "Your session has expired" — Copilot Disconnects After a Few Hours (OIDC)

**Symptom**: Copilot works at the start of the day but disconnects after several hours.

**Cause**: OIDC is configured and the IdP session has expired.

**Solution**:
1. Immediate: Re-authenticate to your IdP (open Okta/Azure AD in a browser, re-sign in, then return to VS Code — Copilot should reconnect)
2. Longer-term: Work with your IdP admin to extend the session lifetime, or configure persistent sessions for developer workstations

**VS Code behaviour**: VS Code's Copilot extension detects the token expiry and shows a notification: "Your GitHub session has expired. Please sign in again." Click the notification and re-authenticate.

---

### Copilot Intermittently Fails with "401 Unauthorized"

**Symptom**: Copilot generally works but fails intermittently, returning to normal after a few minutes.

**Cause**: SAML SSO token refresh. When the SAML assertion expires (configured at the IdP, typically 1–8 hours), GitHub re-validates the SSO session. During this validation window, some requests may be temporarily rejected.

**Solution**: This is usually transient. If it occurs frequently, check the SAML assertion lifetime configured in your IdP. A longer assertion lifetime (4–8 hours) reduces the frequency of re-validation.

---

### Error in JetBrains: "GitHub requires SSO authorisation"

**Symptom**: JetBrains shows the error in a notification or in the Copilot tool window.

**Cause**: Same as the VS Code case — the OAuth token needs SSO authorisation.

**Solution**:
1. In JetBrains: **Tools → GitHub Copilot → Logout**
2. Re-authenticate: **Tools → GitHub Copilot → Login to GitHub** — complete the device code flow
3. During the new sign-in flow, complete the SAML SSO authorisation when GitHub prompts for it
4. If not prompted during sign-in, manually authorise via `github.com/settings/applications` as described above

---

## Administrator: Verifying SSO Enforcement Does Not Break Copilot

When enabling or changing SSO enforcement on an organisation, follow this checklist:

### Before Enabling SSO

- [ ] Notify all Copilot users that they will need to re-authorise Copilot after SSO is enabled. Include a link to the [OAuth app authorisation steps](#how-to-authorise-the-copilot-oauth-app-under-saml).
- [ ] Verify that all Copilot seat holders are provisioned in the identity provider and will receive a SAML assertion for the GitHub organisation.
- [ ] Test the SSO flow with one developer before rolling out to everyone.

### After Enabling SSO

- [ ] Ask each affected developer to visit `https://github.com/orgs/YOUR-ORG/sso` and complete the SAML login.
- [ ] Ask each developer to verify their Copilot OAuth app is authorised at `https://github.com/settings/applications`.
- [ ] Monitor the audit log for `copilot.seat_assignment_change` events that might indicate users losing and regaining access.

### Ongoing Maintenance

- [ ] When a new developer joins and is assigned a Copilot seat, include the SSO authorisation steps in their onboarding checklist.
- [ ] When a developer is offboarded in the IdP (Okta/Azure AD), their Copilot access is automatically revoked when their GitHub org membership ends via SCIM provisioning. Confirm your SCIM configuration deprovisioned the user from the GitHub org.
- [ ] Review the `copilot.seat_assignment_change` audit log events quarterly to confirm seat assignments match your active employee list.
