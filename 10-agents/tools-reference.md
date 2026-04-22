# Agent Tools Reference

Every tool name you can put in an agent's `tools:` allowlist, grouped by category. Current as of April 2026.

Tool availability depends on:
1. What your Copilot subscription enables (agent mode must be on at the org level).
2. Which MCP servers are configured in `.vscode/mcp.json` — see [Module 11](../11-multi-model-mcp/README.md).
3. Which MCP profile is active — see [Module 11's mcp-profiles.md](../11-multi-model-mcp/mcp-profiles.md).

---

## Core tools (no MCP server needed)

These are built into Copilot's agent mode and work as long as agent mode is enabled.

### File I/O

| Tool | Effect | Use for |
|---|---|---|
| `read_file` | Read a file from the workspace | All agents need this |
| `write_file` | Create or overwrite a file | Implementers only — never reviewers/planners |
| `list_files` | List files in a directory | Exploration |

### Shell

| Tool | Effect | Use for |
|---|---|---|
| `run_terminal_command` | Execute a shell command | Tests, lint, build, smoke-checks |

Gotcha: `run_terminal_command` has full shell access unless constrained by policy hooks. See [Module 16's destructive-commands.sh](../16-governance/hooks/scripts/destructive-commands.sh) — wire it into `copilot-hooks.yml`.

### Chat / context

| Tool | Effect | Use for |
|---|---|---|
| `search_workspace` | Semantic search over the repo | Finding call sites, patterns |
| `get_symbol_info` | Inspect a function / class / type | Reading signatures without opening whole files |

---

## GitHub MCP server

Requires the `github` server in `.vscode/mcp.json` with `GITHUB_TOKEN` set in the environment.

### Read

| Tool | Effect |
|---|---|
| `github.get_issue` | Fetch an issue by number |
| `github.list_issues` | List issues with filters |
| `github.get_pull_request` | Fetch a PR by number |
| `github.list_pull_requests` | List PRs with filters |
| `github.list_pull_request_files` | List files changed in a PR |
| `github.get_pull_request_comments` | Fetch existing PR comments |
| `github.search_code` | Code search across a repo or org |
| `github.get_workflow_run` | Inspect a GitHub Actions run |
| `github.list_workflow_runs` | List recent runs |
| `github.get_commit` | Fetch a commit |

### Write (implementer only)

| Tool | Effect |
|---|---|
| `github.create_branch` | Create a branch |
| `github.create_commit` | Commit changes |
| `github.create_pull_request` | Open a PR |
| `github.add_pull_request_comment` | Post a PR comment |
| `github.add_pull_request_review` | Submit a review |
| `github.close_issue` | Close an issue |

### Risky

| Tool | Effect | Use with policy hook |
|---|---|---|
| `github.merge_pull_request` | Merge a PR | Yes — require explicit approval |
| `github.delete_branch` | Delete a branch | Yes — usually only after merge |
| `github.delete_repository` | Delete a repo | Never in a standard chain |

---

## Filesystem MCP server

Sandboxed file access outside the workspace.

| Tool | Effect |
|---|---|
| `filesystem.read` | Read a file at an absolute path |
| `filesystem.write` | Write a file at an absolute path |
| `filesystem.list` | List a directory |
| `filesystem.exists` | Check if a path exists |

Use sparingly — most work should be inside the workspace via `read_file` / `write_file`.

---

## Kubernetes MCP server

Requires the `kubernetes` server in `.vscode/mcp.json` with `KUBECONFIG` set.

### Read

| Tool | Effect |
|---|---|
| `kubernetes.list_pods` | List pods |
| `kubernetes.get_pod` | Get a pod's state |
| `kubernetes.get_logs` | Fetch logs |
| `kubernetes.describe_resource` | `kubectl describe <kind> <name>` |
| `kubernetes.get_events` | Recent events |
| `kubernetes.list_deployments` | Deployments |
| `kubernetes.list_services` | Services |
| `kubernetes.get_config_map` | Read a ConfigMap |

### Write (risky)

| Tool | Effect |
|---|---|
| `kubernetes.apply` | Apply a manifest |
| `kubernetes.rollout_restart` | Restart a Deployment |
| `kubernetes.scale_deployment` | Scale a Deployment |

### Destructive (pair with a policy hook)

| Tool | Effect |
|---|---|
| `kubernetes.delete_resource` | `kubectl delete` — dangerous in prod |

---

## Cloud provider MCP servers

Common providers have dedicated servers. Examples:

### AWS (`aws-docs` + `aws` servers)

| Tool | Effect |
|---|---|
| `aws_docs.search` | Search AWS documentation |
| `aws.describe_instance` | Inspect an EC2 instance |
| `aws.list_s3_objects` | List S3 objects |
| `aws.get_cloudwatch_logs` | Fetch CloudWatch logs |

Write tools for AWS are typically disabled — infra changes should go through Terraform, not Copilot.

### GCP / Azure

Same pattern — read-only reflection tools (`describe`, `list`, `get`) are safe; write tools should be disabled unless you have very narrow use cases.

---

## Database MCP servers

### Postgres

Point at a READ-REPLICA, not prod primary.

| Tool | Effect |
|---|---|
| `postgres.list_tables` | List tables |
| `postgres.describe_table` | Schema of a table |
| `postgres.query` | Run a SELECT |
| `postgres.explain` | `EXPLAIN` a query |

### MySQL / SQLite / Mongo

Similar pattern — `list`, `describe`, `query`. Write tools should be off for agent use.

---

## Web / search MCP servers

### Brave Search / DuckDuckGo / similar

| Tool | Effect |
|---|---|
| `brave.search` | Web search |
| `brave.fetch` | Fetch a URL's content |

Useful for agents that need to look up library docs or verify a third-party API format.

---

## Memory MCP server

Persists facts across sessions.

| Tool | Effect |
|---|---|
| `memory.store` | Save a fact |
| `memory.recall` | Retrieve facts matching a query |
| `memory.forget` | Delete a fact |

Use sparingly. Memory should reinforce durable facts (project conventions, team preferences), not transient state.

---

## Artifactory / Nexus / package registries

For agents that need to check package versions or build metadata.

| Tool | Effect |
|---|---|
| `artifactory.search` | Find a package |
| `artifactory.get_build_info` | Metadata for a build |

---

## Custom / org-internal MCP servers

Teams can build and register their own MCP servers (monitoring, internal APIs, ticketing). Each server exposes tools with its own namespace. Document them in your `.vscode/mcp.json` so teammates know what's available.

Pattern:

```yaml
tools:
  - acme.deploy_status         # custom tool
  - acme.trigger_rebuild
  - acme.list_incidents
```

---

## Allowlist patterns

### Plan / research agents (read-only)

```yaml
tools:
  - read_file
  - search_workspace
  - github.get_issue
  - github.get_pull_request
  - github.search_code
  - postgres.list_tables    # optional — only for schema-aware planning
```

### Implement agents (read + write + commands)

```yaml
tools:
  - read_file
  - write_file
  - run_terminal_command
  - github.search_code
  - github.create_commit
  - github.create_pull_request
```

### Review agents (read-only, enforced)

```yaml
tools:
  - read_file
  - github.list_pull_request_files
  - github.get_pull_request
  - github.search_code
```

### Ops / deploy agents (narrowly scoped, hook-gated)

```yaml
tools:
  - read_file
  - run_terminal_command         # for helm/kubectl/tf
  - kubernetes.list_pods
  - kubernetes.get_logs
  - kubernetes.rollout_restart
  # NOT included: kubernetes.delete_resource, kubernetes.apply
```

---

## Validation

`copilot-eval.yml` (from Module 16) validates that every tool in `tools:` exists in the registered MCP servers. Typos cause the eval to fail in CI rather than at runtime.

```bash
bash .github/eval/checks/tool-refs.sh
```
