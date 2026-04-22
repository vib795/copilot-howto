---
mode: ask
model: claude-opus-4-5
description: "Threat model + OWASP-style audit of the attached code or service"
---

# Security Scan

Perform a thorough security audit. Use `#changes` for a diff-scoped review, `#file:<path>` for a specific file, or `@workspace` for a service-wide audit.

## 1. Threat model (brief)

- **Assets**: what is being protected (data, tokens, capability)?
- **Actors**: who can interact with this code? (anonymous user, authenticated user, admin, internal service)
- **Trust boundaries**: where does untrusted data cross into trusted code paths?
- **In-scope / out-of-scope**: explicitly name what you will and will not review.

## 2. Findings (OWASP-aligned)

Go through each relevant OWASP Top 10 category. For each, state either "not applicable" with a one-line reason, or list findings.

- **A01 Broken Access Control** — missing authz, IDOR, privilege escalation
- **A02 Cryptographic Failures** — weak algorithms, bad RNG, hardcoded keys, plaintext secrets
- **A03 Injection** — SQL, NoSQL, OS command, LDAP, template, prompt injection
- **A04 Insecure Design** — missing rate limits, unbounded expansion, no defence in depth
- **A05 Security Misconfiguration** — default creds, verbose errors, CORS wildcards, open S3
- **A06 Vulnerable and Outdated Components** — unpinned deps, known CVEs
- **A07 Identification and Authentication Failures** — weak session, no lockout, credential stuffing
- **A08 Software and Data Integrity Failures** — unsigned updates, CI without provenance
- **A09 Security Logging and Monitoring Failures** — missing audit logs, no alerts on suspicious events
- **A10 Server-Side Request Forgery** — user-controlled URLs, unsanitised redirects

Also scan for:

- **Secret hygiene** — `AKIA...`, `ghp_...`, private keys, `.env` values in code
- **Prompt injection / jailbreak** — for AI-facing surfaces
- **Deserialisation** — pickle, Java serialisation, YAML unsafe load
- **SSRF / XXE / XXE-adjacent** — XML, SVG, webhooks, PDF generators
- **Race conditions and TOCTOU** — check-then-use on filesystem or auth tokens

## 3. Finding format

```
[severity] <category>  file:line
What: <one sentence>
Impact: <what an attacker achieves>
Proof: <minimal proof-of-concept, exactly the attack input needed>
Fix: <the correct defence, with a code block>
Reference: <OWASP / CWE / CVE link if applicable>
```

Severity: `critical`, `high`, `medium`, `low`, `info`.

## 4. Summary

```
Critical: N  High: N  Medium: N  Low: N  Info: N
Blocking issues: <names or "none">
Recommended next action: <one sentence>
```

## Constraints

- Do **not** suggest rolling your own crypto. If a primitive is missing, point to the language's standard library.
- Do **not** mark something as "low risk" without a reason. If you're not sure, say so.
- No findings that rely on "an attacker who already has shell access" — that's post-compromise, not the scope of an application audit.
- If a finding is conditional on config you can't see (e.g., whether CSRF tokens are enabled), state the assumption explicitly.
