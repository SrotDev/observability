#!/usr/bin/env bash
set -euo pipefail

# Simple alert poller that reads Prometheus alerts API and logs entries locally.
# Requirements: curl; jq (optional but recommended)

PROM_URL="${PROM_URL:-http://localhost:9090}"
LOG_FILE="${LOG_FILE:-alerts.log}"

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

echo "[$(timestamp)] Polling ${PROM_URL}/api/v1/alerts" >> "$LOG_FILE"

json=$(curl -s "${PROM_URL}/api/v1/alerts" || echo "")
if [ -z "$json" ]; then
  echo "[$(timestamp)] ERROR: No response from Prometheus" >> "$LOG_FILE"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  echo "$json" | jq -c '.data.alerts[]' | while read -r alert; do
    state=$(echo "$alert" | jq -r '.state')
    name=$(echo "$alert" | jq -r '.labels.alertname // .labels.alert // "unknown"')
    severity=$(echo "$alert" | jq -r '.labels.severity // "unknown"')
    summary=$(echo "$alert" | jq -r '.annotations.summary // ""')
    inst=$(echo "$alert" | jq -r '.labels.instance // ""')
    echo "[$(timestamp)] state=$state name=$name severity=$severity instance=$inst summary=\"$summary\"" >> "$LOG_FILE"
  done
else
  # Fallback (very naive): write raw JSON snippet
  echo "[$(timestamp)] WARN: jq not found; writing raw JSON" >> "$LOG_FILE"
  echo "$json" >> "$LOG_FILE"
fi

exit 0
