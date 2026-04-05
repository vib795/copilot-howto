# Configuring Copilot for Corporate Network Environments

GitHub Copilot communicates with cloud API endpoints over HTTPS. In corporate environments with proxies, firewalls, VPNs, or SSL inspection appliances, additional configuration is required for Copilot to function. This guide covers every aspect of network configuration.

---

## Table of Contents

1. [Copilot Endpoints That Must Be Reachable](#copilot-endpoints-that-must-be-reachable)
2. [Firewall Allowlist](#firewall-allowlist)
3. [HTTP/HTTPS Proxy Configuration](#httphttps-proxy-configuration)
4. [SSL Inspection and Custom CA Certificates](#ssl-inspection-and-custom-ca-certificates)
5. [VS Code Proxy Settings](#vs-code-proxy-settings)
6. [JetBrains Proxy Settings](#jetbrains-proxy-settings)
7. [Neovim / CLI Proxy Settings](#neovim--cli-proxy-settings)
8. [Testing Connectivity](#testing-connectivity)
9. [Common Issues and Solutions](#common-issues-and-solutions)

---

## Copilot Endpoints That Must Be Reachable

All of the following hostnames must be reachable over HTTPS (port 443) from developer workstations and CI/CD environments that use Copilot.

| Hostname | Purpose | Required? |
|---|---|---|
| `api.githubcopilot.com` | Copilot inline completion API and Chat API | **Required** |
| `copilot-proxy.githubusercontent.com` | Copilot proxy endpoint (used by some extensions) | **Required** |
| `api.github.com` | GitHub API (authentication, seat verification) | **Required** |
| `github.com` | GitHub OAuth and device authentication flows | **Required** |
| `objects.githubusercontent.com` | Node.js agent download (Neovim/JetBrains) | Required on first install |
| `vscode-cdn.net` | VS Code extension updates | Required for VS Code extension updates |
| `marketplace.visualstudio.com` | VS Code extension marketplace | Required for VS Code extension install |
| `plugins.jetbrains.com` | JetBrains plugin repository | Required for JetBrains plugin install |
| `telemetry.githubcopilot.com` | Copilot telemetry (acceptance rates, etc.) | Optional — can be blocked if required |

**Minimum allowlist** (required for Copilot to function after initial installation):
```
api.githubcopilot.com
copilot-proxy.githubusercontent.com
api.github.com
github.com
```

---

## Firewall Allowlist

Add the following rules to your network firewall or web proxy allowlist:

```
# GitHub Copilot API
ALLOW HTTPS api.githubcopilot.com:443
ALLOW HTTPS copilot-proxy.githubusercontent.com:443

# GitHub authentication and API
ALLOW HTTPS github.com:443
ALLOW HTTPS api.github.com:443

# GitHub raw content (for extension/agent downloads)
ALLOW HTTPS objects.githubusercontent.com:443
ALLOW HTTPS raw.githubusercontent.com:443

# VS Code extensions (if using VS Code)
ALLOW HTTPS marketplace.visualstudio.com:443
ALLOW HTTPS vscode-cdn.net:443
ALLOW HTTPS *.vscode.cdn.net:443

# JetBrains plugins (if using JetBrains IDEs)
ALLOW HTTPS plugins.jetbrains.com:443
ALLOW HTTPS download.jetbrains.com:443

# Telemetry (optional; safe to block)
# ALLOW HTTPS telemetry.githubcopilot.com:443
```

### IP Ranges

GitHub does not publish a static list of IP addresses for `api.githubcopilot.com`. If your firewall requires IP-based rules rather than FQDN-based rules, use FQDN-based rules with your firewall's DNS resolution capability, or contact GitHub support for the current IP ranges associated with Copilot endpoints.

For `api.github.com` and `github.com`, GitHub publishes IP ranges at:
`https://api.github.com/meta`

---

## HTTP/HTTPS Proxy Configuration

### Environment Variable (Recommended — Works for Most Tools)

Setting `HTTPS_PROXY` (and optionally `NO_PROXY`) as system environment variables is the simplest approach. Most Copilot IDE extensions, the GitHub CLI (`gh`), and Node.js all respect these standard variables.

**Linux / macOS — add to shell profile (`~/.zshrc`, `~/.bashrc`, etc.):**

```bash
export HTTPS_PROXY="https://proxy.corp.example.com:8080"
export HTTP_PROXY="http://proxy.corp.example.com:8080"
export NO_PROXY="localhost,127.0.0.1,.corp.example.com,*.internal"
```

**Windows — set as user environment variables:**

Open **System Properties → Advanced → Environment Variables** and add:
- Variable: `HTTPS_PROXY`, Value: `https://proxy.corp.example.com:8080`
- Variable: `NO_PROXY`, Value: `localhost,127.0.0.1,.corp.example.com`

### Proxy with Authentication

If your proxy requires a username and password:

```bash
export HTTPS_PROXY="https://username:password@proxy.corp.example.com:8080"
```

**Security note**: Storing proxy credentials in shell profiles is a security risk. Prefer using the Integrated Windows Authentication (NTLM/Kerberos) proxy setup or a secrets manager that injects the `HTTPS_PROXY` variable at shell startup.

### PAC (Proxy Auto-Configuration) Files

If your network uses a PAC file, individual tools may not automatically use it (it is primarily consumed by browsers). The recommended approach is to resolve the proxy URL from the PAC file for the Copilot hostnames and set `HTTPS_PROXY` to the resolved proxy URL explicitly.

---

## SSL Inspection and Custom CA Certificates

Many corporate networks use an SSL inspection appliance (a "man-in-the-middle" proxy) that re-signs TLS certificates with a corporate Certificate Authority (CA). This causes tools that pin or validate certificates strictly to reject the connection.

### Symptoms of SSL Inspection Problems

```
Error: unable to verify the first certificate
Error: CERT_UNTRUSTED
Error: self-signed certificate in certificate chain
Error: GitHub Copilot could not connect — SSL error
```

### Solution: Trust the Corporate CA Certificate

You must add your corporate CA certificate to the trust store used by each affected tool.

#### System Trust Store (macOS)

```bash
# Import the corporate CA certificate into the macOS Keychain:
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain /path/to/corporate-ca.crt
```

After importing to the system keychain, most tools that use the macOS system trust store (including VS Code via its bundled Node.js) will trust the certificate.

#### System Trust Store (Linux — Debian/Ubuntu)

```bash
sudo cp /path/to/corporate-ca.crt /usr/local/share/ca-certificates/corporate-ca.crt
sudo update-ca-certificates
```

#### System Trust Store (Linux — RHEL/CentOS/Fedora)

```bash
sudo cp /path/to/corporate-ca.crt /etc/pki/ca-trust/source/anchors/corporate-ca.crt
sudo update-ca-trust
```

#### System Trust Store (Windows)

```powershell
# Run in an elevated PowerShell session:
Import-Certificate -FilePath "C:\path\to\corporate-ca.crt" `
  -CertStoreLocation Cert:\LocalMachine\Root
```

#### Node.js Trust Store (Required for Copilot Agent in Neovim and JetBrains)

Node.js does not always use the system trust store. Set the `NODE_EXTRA_CA_CERTS` environment variable to point to the corporate CA file:

```bash
export NODE_EXTRA_CA_CERTS="/path/to/corporate-ca.crt"
```

Add this to your shell profile and restart the IDE.

#### VS Code — Disable SSL Strict Verification (Last Resort Only)

If you cannot trust the corporate CA certificate through the system store, you can disable strict SSL verification in VS Code. **This is a security risk and should only be used as a temporary measure:**

```json
// settings.json
{
  "http.proxyStrictSSL": false
}
```

---

## VS Code Proxy Settings

VS Code has built-in proxy configuration in `settings.json`:

```json
{
  // The proxy URL. Overrides system proxy settings for VS Code.
  "http.proxy": "https://proxy.corp.example.com:8080",

  // Whether to verify SSL certificates when going through the proxy.
  // Set to false only if the proxy uses SSL inspection with a corporate CA
  // that you cannot add to the trust store.
  "http.proxyStrictSSL": true,

  // If your proxy requires basic auth, you can set credentials here.
  // Prefer using the system credential manager instead.
  "http.proxyAuthorization": null,

  // Hosts that should bypass the proxy (same format as NO_PROXY env var):
  "http.noProxy": ["localhost", "127.0.0.1", "*.corp.example.com"]
}
```

### VS Code Proxy Priority

VS Code resolves the proxy in this order:
1. `http.proxy` in `settings.json` (highest priority)
2. `HTTPS_PROXY` / `HTTP_PROXY` environment variable
3. System proxy settings (macOS System Preferences, Windows Internet Options)
4. Direct connection (lowest priority)

---

## JetBrains Proxy Settings

### IDE-Level Proxy (Recommended)

1. Open **Settings → Appearance & Behaviour → System Settings → HTTP Proxy**
2. Select **Manual proxy configuration**
3. Enter the proxy hostname and port
4. If authentication is required, check **Proxy authentication** and enter credentials
5. Click **Check connection** to verify connectivity to `https://github.com`

### For the GitHub Copilot Plugin Specifically

The Copilot plugin uses the IDE's HTTP proxy settings. Once configured in the IDE settings above, Copilot API requests automatically route through the proxy.

### `JAVA_TOOL_OPTIONS` for JVM-Level Proxy

For environments where the IDE proxy settings are not picked up (rare, usually on Linux), set the JVM proxy via an environment variable:

```bash
export JAVA_TOOL_OPTIONS="-Dhttps.proxyHost=proxy.corp.example.com -Dhttps.proxyPort=8080 -Dhttps.nonProxyHosts=localhost|127.0.0.1|*.corp.example.com"
```

---

## Neovim / CLI Proxy Settings

### Environment Variables

The Neovim Copilot plugins (both `copilot.vim` and `copilot.lua`) communicate via a Node.js subprocess. Set proxy and CA certificate variables in your shell:

```bash
# In ~/.zshrc or ~/.bashrc:
export HTTPS_PROXY="https://proxy.corp.example.com:8080"
export NODE_EXTRA_CA_CERTS="/path/to/corporate-ca.crt"
```

These variables are inherited by the Neovim process and the Node.js subprocess it spawns.

### GitHub CLI (`gh`)

The `gh` CLI respects `HTTPS_PROXY` automatically. No additional configuration is needed if the environment variable is set.

---

## Testing Connectivity

Use these commands to verify that Copilot endpoints are reachable from a developer workstation before configuring the IDE.

### Basic HTTPS Connectivity Test

```bash
# Test the primary Copilot API endpoint:
curl -v --max-time 10 https://api.githubcopilot.com
# Expected response: HTTP 200 or HTTP 401 (Unauthorized)
# If Copilot is unreachable, you will see a connection error.

# Test the GitHub API:
curl -v --max-time 10 https://api.github.com
# Expected response: HTTP 200 with JSON

# Test through proxy explicitly:
curl -v --proxy https://proxy.corp.example.com:8080 --max-time 10 https://api.githubcopilot.com
```

### SSL Certificate Verification Test

```bash
# Verify that your CA certificates are trusted:
curl -v --max-time 10 https://api.githubcopilot.com 2>&1 | grep -E "SSL|certificate|verify"
# Look for: "SSL connection using TLSv1.3 / ..." (no errors)
# Problem signs: "SSL certificate problem", "unable to get local issuer certificate"
```

### Node.js Connectivity Test (for Neovim and JetBrains Agents)

```bash
# Test that Node.js can reach the Copilot API with your CA cert:
NODE_EXTRA_CA_CERTS=/path/to/corporate-ca.crt node -e "
const https = require('https');
https.get('https://api.githubcopilot.com', (res) => {
  console.log('Status:', res.statusCode);
}).on('error', (err) => {
  console.error('Error:', err.message);
});
"
# Expected: Status: 200 or Status: 401
```

---

## Common Issues and Solutions

### "GitHub Copilot could not connect to server"

| Possible Cause | Check | Solution |
|---|---|---|
| Proxy not configured | `curl https://api.githubcopilot.com` fails | Set `HTTPS_PROXY` or VS Code `http.proxy` |
| Firewall blocking Copilot endpoint | `curl` returns connection refused or timeout | Add `api.githubcopilot.com` to firewall allowlist |
| SSL inspection blocking TLS | `curl` returns SSL error | Add corporate CA cert to system trust store |
| VPN blocking non-corporate traffic | Works off VPN but not on | Ask network team to allowlist Copilot endpoints through VPN |

### "Self-Signed Certificate in Certificate Chain"

Your corporate proxy is performing SSL inspection. Solutions in order of preference:

1. **Add the corporate CA certificate to the system trust store** (see above) — affects all tools
2. **Set `NODE_EXTRA_CA_CERTS`** — affects Node.js-based tools (Neovim Copilot agent)
3. **Set `http.proxyStrictSSL: false` in VS Code** — VS Code only, security risk
4. **Set `NODE_TLS_REJECT_UNAUTHORIZED=0`** — affects all Node.js, serious security risk, do not use in production

### "Proxy Authentication Required" (407 Error)

Your proxy requires credentials. Solutions:

1. Include credentials in the proxy URL: `HTTPS_PROXY=https://user:pass@proxy:port`
2. Use Integrated Windows Authentication (NTLM) — JetBrains supports this natively; VS Code partially supports it via the system proxy
3. Use a PAC file that handles NTLM authentication

### Copilot Works from Terminal but Not from the IDE

The IDE may not be inheriting environment variables set in the shell. On macOS, environment variables set in `~/.zshrc` are not automatically available to GUI applications launched from the Dock.

**Solution for macOS**: Use `launchctl setenv` to set the environment variable for all GUI applications:

```bash
# Set HTTPS_PROXY for all GUI applications (survives reboot via launchd plist):
launchctl setenv HTTPS_PROXY "https://proxy.corp.example.com:8080"
launchctl setenv NODE_EXTRA_CA_CERTS "/path/to/corporate-ca.crt"

# Apply immediately without restart:
launchctl stop com.apple.Dock && launchctl start com.apple.Dock
```

Alternatively, configure the proxy in the IDE's own settings (VS Code `http.proxy`, JetBrains proxy settings) rather than relying on environment variables.
