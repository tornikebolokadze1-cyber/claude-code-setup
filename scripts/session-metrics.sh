#!/bin/bash
# Session Metrics Viewer
# Usage: bash ~/.claude/scripts/session-metrics.sh [days]
# Shows session counts and patterns from JSONL metrics

METRICS_DIR="$HOME/.claude/metrics"
DAYS=${1:-7}

echo "=== Claude Code Session Metrics (last $DAYS days) ==="
echo ""

if [ ! -d "$METRICS_DIR" ]; then
  echo "No metrics found. Sessions are tracked automatically."
  exit 0
fi

# Count sessions per day
echo "Sessions per day:"
for file in "$METRICS_DIR"/sessions-*.jsonl; do
  [ -f "$file" ] || continue
  MONTH=$(basename "$file" | sed 's/sessions-//;s/.jsonl//')
  COUNT=$(wc -l < "$file" | tr -d ' ')
  echo "  $MONTH: $COUNT sessions"
done

echo ""

# Show recent sessions
echo "Recent sessions:"
LATEST=$(ls -t "$METRICS_DIR"/sessions-*.jsonl 2>/dev/null | head -1)
if [ -n "$LATEST" ]; then
  tail -5 "$LATEST" | while read -r line; do
    TS=$(echo "$line" | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
    CWD=$(echo "$line" | grep -o '"cwd":"[^"]*"' | cut -d'"' -f4)
    DIR=$(basename "$CWD" 2>/dev/null || echo "$CWD")
    echo "  $TS — $DIR"
  done
fi

echo ""

# Show governance events if any
GOV_DIR="$HOME/.claude/audit-logs"
if [ -d "$GOV_DIR" ]; then
  GOV_COUNT=$(cat "$GOV_DIR"/governance-*.log 2>/dev/null | wc -l | tr -d ' ')
  if [ "$GOV_COUNT" -gt 0 ]; then
    echo "Governance alerts: $GOV_COUNT total"
    echo "Recent:"
    cat "$GOV_DIR"/governance-*.log 2>/dev/null | tail -3 | while read -r line; do
      echo "  $line"
    done
  fi
fi
