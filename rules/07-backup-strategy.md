# Backup Strategy

## Automatic Backup Triggers

Claude must create backups (via git checkpoint) before:
1. Any session where more than 3 files will be modified
2. Any work on configuration files
3. Any database-related changes
4. Any deployment or build system changes
5. User explicitly says "save this" or "make a backup"

## Backup Methods

### Primary: Git Checkpoints
- Use the auto-checkpoint system (see 01-auto-checkpoint.md)
- Every checkpoint is a full snapshot of the project state
- Users can restore any checkpoint with plain-language commands

### Secondary: File-Level Backups
For critical single files (like .env or database configs):
```bash
cp important-file.txt important-file.txt.backup-$(date +%Y%m%d-%H%M%S)
```
This creates timestamped backups like `important-file.txt.backup-20260322-143000`

### Tertiary: Export Before Transform
When modifying data files (CSV, JSON, spreadsheets):
1. Copy the original to a `.original` version
2. Make changes to the working copy
3. Only delete the `.original` after user confirms the result is correct

## Backup Naming Convention

```
[filename].backup-[YYYYMMDD-HHMMSS]
[filename].original
[filename].old
```

## Cleanup

- Backup files older than 7 days can be suggested for cleanup
- NEVER auto-delete backups. Always ask: "You have some old backup files. Want me to clean them up?"
- List backups by age and let the user choose

## When the User Says "I Lost Something"

1. Check git log for recent checkpoints
2. Check for `.backup`, `.original`, or `.old` files
3. Check the system trash/recycle bin
4. If found, offer to restore
5. If not found, be honest: "I cannot find a backup of that file. It may not have been saved."
