# Auto-Checkpoint System

## When Claude MUST Auto-Commit (No User Permission Needed)

1. **Before any multi-file change** (3+ files about to be modified)
2. **Before touching configuration files** (package.json, tsconfig, .env, docker-compose, etc.)
3. **After completing a working feature** that the user requested
4. **Before any refactoring operation**
5. **Before installing or removing dependencies**
6. **Before modifying database schemas or migrations**
7. **At the end of every session** if there are uncommitted changes

## When Claude SHOULD Auto-Commit (Recommended)

- After every 2 successful file edits
- After fixing a bug that was verified working
- Before switching to a different task/feature
- After any CSS/styling change that looks correct

## Commit Message Format

Checkpoints use a specific format so they are easy to find and understand:

```
CHECKPOINT: [plain-language description]

What was done: [1-2 sentences a non-coder can understand]
Files changed: [list of filenames only, no paths]
Status: [WORKING | IN-PROGRESS | EXPERIMENTAL]
```

Examples:
- `CHECKPOINT: Added the contact form to the homepage — Status: WORKING`
- `CHECKPOINT: Before changing the navigation menu — Status: IN-PROGRESS`
- `CHECKPOINT: Saving before updating the login system — Status: WORKING`

## Restore from Checkpoint

When a user says any of these, Claude must restore:
- "Undo the last change"
- "Go back to when it was working"
- "Restore the last save"
- "That broke things, go back"
- "Revert" or "undo"

### Restore Procedure
1. Run `git log --oneline -20` to find recent checkpoints
2. Present the user with plain-language options:
   ```
   I found these save points:
   1. "Added the contact form" (2 minutes ago) - was WORKING
   2. "Before changing navigation" (15 minutes ago) - was WORKING
   3. "Updated the homepage banner" (1 hour ago) - was WORKING
   Which one should I go back to?
   ```
3. After user picks, run `git checkout <hash> -- .` to restore files
4. Immediately verify the app still works
5. Create a new checkpoint: `CHECKPOINT: Restored to "[description]"`

## Maximum Files Before Mandatory Checkpoint

- **3 files changed** = checkpoint REQUIRED before continuing
- **5 files changed** = checkpoint REQUIRED + summarize changes to user
- **10+ files changed** = STOP, checkpoint, summarize, ask permission to continue

## Implementation

Before making changes, Claude must mentally check:
1. How many files will this touch?
2. Is there a checkpoint of the current working state?
3. If not, create one NOW before proceeding.

Auto-commit command pattern:
```bash
git add -A && git commit -m "$(cat <<'EOF'
CHECKPOINT: [description]

What was done: [plain language]
Files changed: [list]
Status: [WORKING|IN-PROGRESS|EXPERIMENTAL]

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```
