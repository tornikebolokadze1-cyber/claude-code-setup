#!/bin/bash
# Backup Cleanup Script
# Usage: bash ~/.claude/scripts/cleanup-backups.sh [days]
# Removes backup files older than N days (default: 7)

BACKUP_DIR="$HOME/.claude/file-backups"
DAYS=${1:-7}

if [ ! -d "$BACKUP_DIR" ]; then
  echo "No backup directory found. Nothing to clean."
  exit 0
fi

# Count before cleanup
TOTAL_BEFORE=$(find "$BACKUP_DIR" -name "*.bak" -type f 2>/dev/null | wc -l | tr -d ' ')
SIZE_BEFORE=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)

echo "=== Backup Cleanup ==="
echo "Directory: $BACKUP_DIR"
echo "Current: $TOTAL_BEFORE files ($SIZE_BEFORE)"
echo "Removing files older than $DAYS days..."
echo ""

# Remove old .bak files
DELETED=0
while IFS= read -r file; do
  rm "$file" 2>/dev/null && DELETED=$((DELETED + 1))
done < <(find "$BACKUP_DIR" -name "*.bak" -type f -mtime +$DAYS 2>/dev/null)

# Remove empty date directories
find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null

# Count after cleanup
TOTAL_AFTER=$(find "$BACKUP_DIR" -name "*.bak" -type f 2>/dev/null | wc -l | tr -d ' ')
SIZE_AFTER=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)

echo "Deleted: $DELETED files"
echo "Remaining: $TOTAL_AFTER files ($SIZE_AFTER)"

# Also clean old audit logs (older than 30 days)
AUDIT_DIR="$HOME/.claude/audit-logs"
if [ -d "$AUDIT_DIR" ]; then
  AUDIT_DELETED=0
  while IFS= read -r file; do
    rm "$file" 2>/dev/null && AUDIT_DELETED=$((AUDIT_DELETED + 1))
  done < <(find "$AUDIT_DIR" -name "*.log" -type f -mtime +30 2>/dev/null)
  if [ "$AUDIT_DELETED" -gt 0 ]; then
    echo ""
    echo "Also cleaned $AUDIT_DELETED old audit logs (30+ days)"
  fi
fi

echo ""
echo "Done."
