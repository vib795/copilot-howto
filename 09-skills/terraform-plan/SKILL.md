---
name: terraform-plan
description: >
  Use when the user wants to plan, apply, or change infrastructure with
  Terraform or OpenTofu. Triggers on: tofu plan, terraform plan, tofu apply,
  terraform apply, tf state, "change the infrastructure", "update the
  Terraform", "add a resource", "import existing resource", "drift", "state
  lock", "workspace".
owner: "@org/platform-team"
classification: internal
---

# Terraform / OpenTofu Plan and Apply — Runbook

This project uses OpenTofu (`tofu`). If the user says "terraform," the commands are interchangeable. The runbook treats `apply` as the dangerous step and `plan` as the safe one.

## Golden rules

1. **Plan before every apply.** No exceptions.
2. **Read the plan.** Every line. A plan showing unexpected `destroy` is a stop sign.
3. **Never apply against the wrong workspace.** Confirm the workspace every time.
4. **Never edit state by hand.** Use `tofu state mv`, `tofu state rm`, `tofu import`.
5. **Commit code first, then apply.** Not the other way around. State drift is hard to reason about when code lags.

## Pre-flight

```bash
tofu version                           # confirm version
tofu workspace show                    # confirm workspace (dev / staging / prod)
git status                             # no uncommitted local changes
git pull --ff-only                     # latest main / release branch
tofu init -upgrade                     # ensure provider versions are current
tofu fmt -check -recursive             # code is formatted
tofu validate                          # syntactically valid
```

If any of these fail, stop.

## Plan

```bash
tofu plan -out=plan.tfplan -var-file=vars/<env>.tfvars
```

Read the output:

- `+` create — new resource
- `-` destroy — resource being deleted
- `~` update in-place — existing resource being modified
- `-/+` destroy and recreate — downtime risk

**Red flags:**
- Unexpected `destroy` of a stateful resource (RDS, S3, PVC, disk)
- `destroy and recreate` on a resource with data
- Changes you didn't intend to make (someone else's drift)
- Provider or backend changes you didn't author

If anything is surprising: STOP. Don't apply until understood.

## Apply

Once plan is reviewed and saved:

```bash
tofu apply plan.tfplan
```

Always apply the saved plan file — never `tofu apply` without a plan file for production.

If the apply fails:

- Read the error message in full
- Do NOT retry immediately without understanding why
- Provider errors (AWS/GCP/Azure) often point to quota, IAM, or conflicts
- For "state lock held" → someone else is applying or a previous apply crashed. See below.

## State lock held

If you see `Error acquiring the state lock`, do NOT force-unlock unless you're sure no one is applying:

```bash
# Identify who holds the lock
tofu force-unlock -dry-run <lock-id>

# Confirm with the person or team listed. Then:
tofu force-unlock <lock-id>
```

A force-unlock during a real apply can corrupt state. Double-check.

## State operations

### Rename a resource (no destroy/recreate)

```bash
tofu state mv <old_address> <new_address>
```

Example: renaming `aws_instance.web` to `aws_instance.web_server` without destroying.

### Import an existing resource

```bash
tofu import <resource_address> <cloud_id>
```

Then run `tofu plan` — expect no changes if the config matches the imported resource.

### Remove from state (without destroying in cloud)

```bash
tofu state rm <resource_address>
```

Use when a resource was deleted out-of-band and you want Terraform to stop tracking it.

## Drift detection

```bash
tofu plan -refresh-only
```

Shows what has changed in the cloud but not in state. Useful when you suspect someone clicked in the console.

## Workspaces

```bash
tofu workspace list
tofu workspace select <name>
tofu workspace new <name>
```

In this project, workspaces map 1:1 to environments. Never apply in the wrong workspace.

## Destructive operations — block list

Do NOT run these without explicit user confirmation AND a change record:

- `tofu destroy` — kills everything in the workspace
- `tofu state rm` on a production database
- Any `terraform apply` that destroys a resource in prod that stores data
- Any change to a backend configuration (migrating state)

If the user requests one of these, respond with:

```
Destructive operation detected: <operation>
Before I proceed, please confirm:
1. Change record: <ticket>
2. Backup taken: <evidence>
3. Off-hours window: <scheduled>
4. Rollback plan: <one sentence>
```

## Rollback

Terraform has no "undo." Rollback means applying the previous code:

```bash
git checkout <previous-commit>
tofu init
tofu plan -out=rollback.tfplan
tofu apply rollback.tfplan
```

For state-specific rollback, use `tofu state replace-provider` or restore from backend snapshot (S3 versioning for the state bucket).

## Common errors

| Error | Cause | Fix |
|---|---|---|
| `Error: Error acquiring the state lock` | Another run in progress or crashed | Identify holder; force-unlock only if safe |
| `Error: no valid credential sources` | AWS/GCP auth missing | `aws sso login`, `gcloud auth application-default login`, or set env vars |
| `Error: Provider configuration not present` | Resource imported without matching provider config | Add provider block or `-provider=` flag to import |
| `Error: no such file or directory: terraform.tfstate` | Backend misconfigured or workspace wrong | `tofu init`; verify workspace |
| `BucketAlreadyOwnedByYou` | Re-creating a resource Terraform thinks it's creating | Import instead of creating |
| `InvalidParameterValue: ... cannot be modified` | Provider wants to update an immutable field | Code change requires `destroy/create` — review impact |

## Escalation

- Production apply that fails mid-way → page the platform on-call; do not attempt to fix blindly.
- State corruption → involve the platform team; restore from backend snapshot.
- Apply touches IAM / security groups / VPC / routing → require a second reviewer before applying.
