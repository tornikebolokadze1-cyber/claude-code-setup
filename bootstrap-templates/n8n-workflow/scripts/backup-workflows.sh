#!/usr/bin/env bash
#
# backup-workflows.sh — Back up all workflows from an n8n instance.
#
# Usage:
#   ./scripts/backup-workflows.sh [backup-directory]
#
#   Default backup directory: ./backups/<date>/
#
# Requires: N8N_INSTANCE_URL and N8N_API_KEY environment variables.

set -euo pipefail

# --- Configuration -----------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load .env if it exists
if [[ -f "$PROJECT_DIR/.env" ]]; then
  set -a
  source "$PROJECT_DIR/.env"
  set +a
fi

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="${1:-${BACKUP_DIR:-$PROJECT_DIR/backups}/$TIMESTAMP}"

# --- Validation ---------------------------------------------------------------

if [[ -z "${N8N_INSTANCE_URL:-}" ]]; then
  echo "Error: N8N_INSTANCE_URL is not set." >&2
  exit 1
fi

if [[ -z "${N8N_API_KEY:-}" ]]; then
  echo "Error: N8N_API_KEY is not set." >&2
  exit 1
fi

# --- Backup -------------------------------------------------------------------

API_BASE="${N8N_INSTANCE_URL}/api/v1"

echo "Fetching workflow list from ${N8N_INSTANCE_URL}..."

# Get all workflows (handle pagination)
ALL_WORKFLOWS="[]"
CURSOR=""
HAS_MORE=true

while [[ "$HAS_MORE" == "true" ]]; do
  URL="${API_BASE}/workflows?limit=100"
  if [[ -n "$CURSOR" ]]; then
    URL="${URL}&cursor=${CURSOR}"
  fi

  RESPONSE=$(curl -s \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "$URL")

  # Extract workflows from this page
  PAGE_DATA=$(echo "$RESPONSE" | jq -r '.data // []')
  ALL_WORKFLOWS=$(echo "$ALL_WORKFLOWS $PAGE_DATA" | jq -s 'add')

  # Check for next page
  CURSOR=$(echo "$RESPONSE" | jq -r '.nextCursor // empty')
  if [[ -z "$CURSOR" ]]; then
    HAS_MORE=false
  fi
done

WORKFLOW_COUNT=$(echo "$ALL_WORKFLOWS" | jq 'length')
echo "Found $WORKFLOW_COUNT workflow(s)."

if [[ "$WORKFLOW_COUNT" -eq 0 ]]; then
  echo "No workflows to back up."
  exit 0
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Download each workflow
echo "Backing up to: $BACKUP_DIR"
SAVED=0

for ID in $(echo "$ALL_WORKFLOWS" | jq -r '.[].id'); do
  WORKFLOW=$(curl -s \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    "${API_BASE}/workflows/${ID}")

  NAME=$(echo "$WORKFLOW" | jq -r '.name // "unnamed"')
  # Sanitize name for filename
  SAFE_NAME=$(echo "$NAME" | tr -cs '[:alnum:]-_ ' '-' | sed 's/^-//;s/-$//')
  FILENAME="${ID}_${SAFE_NAME}.json"

  echo "$WORKFLOW" | jq '.' > "$BACKUP_DIR/$FILENAME"
  echo "  Saved: $FILENAME"
  SAVED=$((SAVED + 1))
done

echo ""
echo "Backup complete: $SAVED workflow(s) saved to $BACKUP_DIR"

# Create a manifest
echo "$ALL_WORKFLOWS" | jq '[.[] | {id, name, active, updatedAt}]' \
  > "$BACKUP_DIR/_manifest.json"
echo "Manifest written to $BACKUP_DIR/_manifest.json"
