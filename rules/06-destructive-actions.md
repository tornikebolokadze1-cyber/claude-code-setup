# Destructive Action Prevention

## Definition

A "destructive action" is anything that deletes, overwrites, or permanently changes data, files, or configurations in a way that cannot be easily reversed.

## NEVER Do (Hard Block -- No Exceptions)

1. **Never delete files** without explicit user permission. Say: "I need to delete [filename] because [reason]. Is that OK?"
2. **Never run** `rm -rf`, `git reset --hard`, `git clean -f`, `DROP TABLE`, or any destructive shell command
3. **Never overwrite .env files** -- these contain secrets that may not exist anywhere else
4. **Never force-push** to any git branch
5. **Never run database migrations** that drop columns or tables without explicit permission
6. **Never modify production URLs, API keys, or deployment configs** without confirmation
7. **Never empty or truncate** files, databases, or logs without permission

## Always Ask First (Soft Block)

These require a plain-language explanation and user confirmation:
- Installing new software or packages
- Changing file permissions
- Modifying git history in any way
- Creating new database tables or collections
- Changing port numbers or network settings
- Modifying authentication or security settings
- Updating dependency versions

## How to Ask

```
I need to [action] because [reason].

What this means: [plain-language consequence]
Risk: [LOW / MEDIUM / HIGH]
Can it be undone: [YES easily / YES but complicated / NO]

Should I go ahead?
```

## Safe Alternatives

Instead of destructive actions, prefer:
- **Rename** over delete (append `.backup` or `.old`)
- **Comment out** over remove (for config lines)
- **Create new file** over overwrite (e.g., `config.new.json`)
- **Git branch** over direct changes to main
- **Copy first** over edit in place (for critical files)

## The "Oops" Protocol

If Claude accidentally performs a destructive action:
1. IMMEDIATELY attempt to restore from the git checkpoint
2. Tell the user honestly what happened
3. If git restore is not possible, check for backup files
4. Document what was lost so the user can recreate it if needed
