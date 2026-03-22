#!/usr/bin/env bash
#
# deploy-workflow.sh — Deploy an n8n workflow JSON file to an n8n instance.
#
# Usage:
#   ./scripts/deploy-workflow.sh <workflow-file.json> [workflow-id]
#
#   If workflow-id is provided, the existing workflow is updated.
#   If omitted, a new workflow is created.
#
# Requires: N8N_INSTANCE_URL and N8N_API_KEY environment variables.
# Source your .env file or export them before running.

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

# --- Validation ---------------------------------------------------------------

if [[ -z "${N8N_INSTANCE_URL:-}" ]]; then
  echo "Error: N8N_INSTANCE_URL is not set." >&2
  echo "Export it or add it to .env" >&2
  exit 1
fi

if [[ -z "${N8N_API_KEY:-}" ]]; then
  echo "Error: N8N_API_KEY is not set." >&2
  echo "Export it or add it to .env" >&2
  exit 1
fi

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <workflow-file.json> [workflow-id]" >&2
  exit 1
fi

WORKFLOW_FILE="$1"
WORKFLOW_ID="${2:-}"

if [[ ! -f "$WORKFLOW_FILE" ]]; then
  echo "Error: File not found: $WORKFLOW_FILE" >&2
  exit 1
fi

# Validate JSON
if ! jq empty "$WORKFLOW_FILE" 2>/dev/null; then
  echo "Error: Invalid JSON in $WORKFLOW_FILE" >&2
  exit 1
fi

# --- Deploy -------------------------------------------------------------------

API_BASE="${N8N_INSTANCE_URL}/api/v1"

if [[ -n "$WORKFLOW_ID" ]]; then
  # Update existing workflow
  echo "Updating workflow $WORKFLOW_ID..."
  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X PUT \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    -H "Content-Type: application/json" \
    -d @"$WORKFLOW_FILE" \
    "${API_BASE}/workflows/${WORKFLOW_ID}")
else
  # Create new workflow
  echo "Creating new workflow..."
  RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST \
    -H "X-N8N-API-KEY: ${N8N_API_KEY}" \
    -H "Content-Type: application/json" \
    -d @"$WORKFLOW_FILE" \
    "${API_BASE}/workflows")
fi

# Parse response
HTTP_CODE=$(echo "$RESPONSE" | tail -1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [[ "$HTTP_CODE" =~ ^2 ]]; then
  WF_ID=$(echo "$BODY" | jq -r '.id // "unknown"')
  WF_NAME=$(echo "$BODY" | jq -r '.name // "unknown"')
  echo "Success! Workflow deployed."
  echo "  ID:   $WF_ID"
  echo "  Name: $WF_NAME"
  echo "  URL:  ${N8N_INSTANCE_URL}/workflow/${WF_ID}"
else
  echo "Error: API returned HTTP $HTTP_CODE" >&2
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY" >&2
  exit 1
fi
