# VS Code Timeline: Lightweight Checkpoints for Workspace Changes

When using Copilot Workspace (or making any risky changes), you sometimes want to recover a previous state of a file without using git. VS Code's Timeline panel provides file-level local history that is saved automatically — no git commit required.

---

## What VS Code Timeline Is

The **Timeline** panel in VS Code shows a per-file history of changes, including:

- **Every save**: each time you press Cmd+S / Ctrl+S, VS Code records a snapshot
- **Git operations**: commits, checkouts, and merges appear as timeline entries
- **Editor operations**: some changes are captured even before you save (VS Code's local history feature)

This is **not git**. The timeline entries are stored in VS Code's local storage on your machine (not in the repository). They persist across sessions but are machine-local — other developers cannot access your timeline entries.

---

## How to Access the Timeline

### Method 1: Explorer Panel

1. Open the **Explorer** panel (Cmd+Shift+E / Ctrl+Shift+E)
2. Click on any file to select it
3. At the bottom of the Explorer panel, expand the **Timeline** section

### Method 2: Right-Click a File

1. Right-click any file in the Explorer
2. Select **"Open Timeline"**
3. The Timeline panel opens at the bottom of the VS Code window

### Method 3: View Menu

1. **View → Open View...**
2. Type "Timeline" and select it

### Method 4: Command Palette

```
Cmd+Shift+P (Mac) / Ctrl+Shift+P (Windows/Linux)
> Timeline: Focus
```

---

## What the Timeline Shows

Each entry in the timeline shows:
- A timestamp (relative: "2 minutes ago", "yesterday", or absolute on hover)
- The event type: "Saved", "Git Commit", "Git Checkout", etc.
- For git entries: the commit message

Timeline entries are color-coded:
- **Blue dots**: local saves (VS Code local history)
- **Orange dots**: git operations

---

## How to Restore from the Timeline

### View a Previous State

1. Click any timeline entry
2. A diff view opens: **left side = timeline entry**, **right side = current file**
3. Review what changed between the two states

### Restore a Previous State

To restore a file to a specific timeline entry:

1. Click the timeline entry you want to restore to
2. In the diff editor that opens, click the **"Revert File"** button (the circular arrow icon in the editor toolbar)
3. The file is restored to that state
4. Save the file (Cmd+S / Ctrl+S) to confirm

Alternatively, right-click the timeline entry and select **"Restore Contents"**.

### Copy Specific Lines from a Previous State

You don't have to restore the entire file. In the diff view:
1. Select the lines you want from the left side (the old version)
2. Copy them (Cmd+C)
3. Close the diff view
4. Paste them into the current file where needed

---

## Timeline vs. Claude Code Checkpoints

Understanding the difference helps you choose the right tool:

| Feature | VS Code Timeline | Claude Code Checkpoints (`/rewind`) |
|---------|-----------------|-------------------------------------|
| Scope | Single file | Entire session (all files + conversation) |
| Trigger | Every save, automatically | Manually created or at task boundaries |
| Granularity | Fine (every save) | Coarse (session checkpoints) |
| Multi-file restore | No — must restore each file individually | Yes — reverts all session changes at once |
| Conversation rewind | No | Yes — returns to previous conversation state |
| Available in Copilot Workspace | No (browser-based) | N/A (Claude Code only) |
| Machine-local | Yes | Yes (local session) |
| Persists across sessions | Yes (VS Code local history) | No (session-scoped) |
| Team-visible | No | No |

**The key limitation:** VS Code Timeline is **file-level only**. If you refactored 10 files and want to "go back to before I started," you must restore each file individually from the timeline. This is tedious for large changes.

For that reason, the recommended approach is to use **git branches** as session-level checkpoints before starting risky work.

---

## Recommended Workflow for Safe Experimentation

### Before Starting a Risky Change

Create a git checkpoint branch:

```bash
# Create a branch at the current state
git checkout -b checkpoint/pre-refactor-$(date +%Y%m%d-%H%M)

# Push it to the remote (so it is not lost if your machine dies)
git push -u origin checkpoint/pre-refactor-$(date +%Y%m%d-%H%M)

# Return to your working branch
git checkout my-feature-branch
```

This takes 10 seconds and gives you a hard restore point.

### During the Change

VS Code Timeline handles the fine-grained within-session recovery automatically. Every save is a restore point for that file.

### If Something Goes Wrong at the File Level

Use VS Code Timeline to recover an individual file:
1. Open the file in Explorer
2. Click the Timeline entry from before the bad change
3. Restore the file contents

### If Something Goes Wrong at the Session Level

Use git to restore everything:

```bash
# Option 1: Reset to the checkpoint branch (destructive — discards all local changes)
git fetch origin
git checkout my-feature-branch
git reset --hard origin/checkpoint/pre-refactor-20240115-1430

# Option 2: Use git stash to save current (broken) state and return to checkpoint
git stash push -m "broken-attempt-$(date +%Y%m%d)"
git reset --hard origin/checkpoint/pre-refactor-20240115-1430

# Option 3: Simply check out the checkpoint branch and try again
git checkout checkpoint/pre-refactor-20240115-1430
git checkout -b my-feature-branch-v2
```

---

## Git-Based Checkpoint Patterns

These patterns complement VS Code Timeline for larger changes:

### Pattern 1: `git stash` Before a Risky Change

```bash
# Save all current changes to the stash
git stash push -m "WIP: before trying the new approach"

# Make your experimental changes...
# If the experiment works:
git add .
git commit -m "feat: implement new approach"
git stash drop  # Remove the stash (no longer needed)

# If the experiment fails:
git checkout .              # Discard the experimental changes
git stash pop               # Restore the WIP state
```

`git stash` is useful for short experiments. For longer-running work, a branch is safer.

### Pattern 2: WIP Commits

Make frequent "WIP" commits during risky work, even if they are not ready to push:

```bash
# Safe point A
git add .
git commit -m "WIP: safe point before refactoring the service layer"

# ... make changes ...

# Safe point B
git add .
git commit -m "WIP: service layer refactored, tests not updated yet"

# If things go wrong after safe point B:
git reset --hard HEAD~1     # Go back to safe point A

# Once the work is done:
git rebase -i HEAD~3        # Squash the WIP commits into one clean commit
```

### Pattern 3: Branch-Per-Attempt

When you are uncertain how to approach a problem and want to try two strategies:

```bash
# Create two branches from the same starting point
git checkout -b approach-a
# ... implement approach A ...

git checkout main             # Or whatever your base branch is
git checkout -b approach-b
# ... implement approach B ...

# Compare the two approaches:
git diff approach-a...approach-b

# Keep the better one and delete the other:
git branch -d approach-a
```

---

## Configuring VS Code Local History

You can control how much history VS Code keeps:

In your VS Code settings (`settings.json` or via the Settings UI):

```json
{
  // Maximum number of timeline entries per file (default: 50)
  "workbench.localHistory.maxFileEntries": 100,

  // Maximum size of a file stored in local history in KB (default: 256 KB)
  "workbench.localHistory.maxFileSize": 512,

  // How many days to keep local history entries (default: 30 days)
  "workbench.localHistory.expire": 60,

  // Glob patterns to exclude from local history (e.g., lock files, binaries)
  "workbench.localHistory.exclude": {
    "**/node_modules/**": true,
    "**/*.lock": true,
    "**/__pycache__/**": true
  }
}
```

To access these settings:
1. Cmd+Shift+P → "Preferences: Open User Settings (JSON)"
2. Add the above keys to your `settings.json`

---

## Summary

VS Code Timeline is most useful for:
- Quickly recovering a single file that you accidentally broke
- Reviewing what a file looked like before a specific save or git operation
- No-hassle, automatic per-save history that requires no setup

It is **not a replacement** for git-based checkpoints when you are making multi-file changes or running a Copilot Workspace session. For those scenarios, create a git checkpoint branch before starting and rely on `git reset` or `git stash` for full-session recovery.

The combination of VS Code Timeline (fine-grained, per-file) + git branches (coarse-grained, all-files) gives you comprehensive coverage for safe experimentation.
