#!/usr/bin/env bash
# send-block-digest.sh — Parse audit logs and send daily block digest email
# Adapted for gogcli (gog command)

set -euo pipefail

# Configuration
AUDIT_DIR="${AUDIT_DIR:-$HOME/.openclaw/workspace-jtechsh/audit/twitter}"
STATE_FILE="${STATE_FILE:-$HOME/.openclaw/workspace-jtechsh-digest/state.json}"
GOG_ACCOUNT="${GOG_ACCOUNT:-}"
TO_EMAIL="${TO_EMAIL:-$GOG_ACCOUNT}"
GOG_BIN="${GOG_BIN:-gog}"

# Ensure required tools are available
command -v "$GOG_BIN" >/dev/null 2>&1 || { echo "Error: $GOG_BIN not found"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "Error: python3 not found"; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "Error: jq not found"; exit 1; }

# Create temp directory for working files
WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

BODY_FILE="$WORK_DIR/body.txt"
META_FILE="$WORK_DIR/meta.json"

# Read state
if [[ ! -f "$STATE_FILE" ]]; then
    echo "Error: State file not found: $STATE_FILE"
    exit 1
fi

LAST_SENT_AT=$(jq -r '.lastSentAt // "1970-01-01T00:00:00Z"' "$STATE_FILE")

# Parse audit logs with Python
python3 << 'PYTHON_SCRIPT'
import os
import re
import json
from datetime import datetime
from pathlib import Path

audit_dir = os.environ.get('AUDIT_DIR', '')
last_sent_at = os.environ.get('LAST_SENT_AT', '1970-01-01T00:00:00Z')
body_file = os.environ.get('BODY_FILE', '')
meta_file = os.environ.get('META_FILE', '')

# Parse last_sent_at
try:
    window_start = datetime.fromisoformat(last_sent_at.replace('Z', '+00:00'))
except:
    window_start = datetime.min

# Patterns for parsing audit lines
patterns = [
    # Pipe-separated format
    re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\s*\|\s*block\s*\|\s*@(\w+)\s*\|\s*(https?://\S+)\s*\|\s*(.+?)(?:\s*\|\s*transport:.*)?$'),
    # Em-dash format
    re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\s*—\s*block\s*—\s*@(\w+)\s*—\s*(https?://\S+)\s*—\s*(.+)$'),
    # Compact format
    re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z)\s+block\s+@(\w+)\s+(https?://\S+)\s+(.+)$')
]

blocks = []
seen_handles = set()

# Scan all audit files
audit_path = Path(audit_dir)
if audit_path.exists():
    for md_file in sorted(audit_path.glob('*.md')):
        try:
            with open(md_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    for pattern in patterns:
                        match = pattern.match(line)
                        if match:
                            timestamp_str, handle, url, reasons = match.groups()
                            try:
                                timestamp = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                                if timestamp > window_start and handle not in seen_handles:
                                    blocks.append({
                                        'handle': handle,
                                        'url': url,
                                        'reasons': reasons.strip(),
                                        'timestamp': timestamp_str
                                    })
                                    seen_handles.add(handle)
                            except:
                                pass
                            break
        except Exception as e:
            print(f"Warning: Error reading {md_file}: {e}", file=__import__('sys').stderr)

# Generate email body
now = datetime.utcnow()
subject = f"Daily X Block Digest - {now.strftime('%Y-%m-%d')} ({len(blocks)})"

with open(body_file, 'w') as f:
    f.write(f"Daily X Block Digest\n")
    f.write(f"Generated: {now.strftime('%Y-%m-%d %H:%M UTC')}\n")
    f.write(f"Window: {last_sent_at} → {now.strftime('%Y-%m-%dT%H:%M:%SZ')}\n\n")
    
    if not blocks:
        f.write("No new blocks since last digest.\n")
    else:
        f.write(f"Total new blocks: {len(blocks)}\n\n")
        for block in blocks:
            f.write(f"@{block['handle']}\n")
            f.write(f"  URL: {block['url']}\n")
            f.write(f"  Reason: {block['reasons']}\n")
            f.write(f"  Time: {block['timestamp']}\n\n")

# Write metadata
with open(meta_file, 'w') as f:
    json.dump({
        'subject': subject,
        'count': len(blocks),
        'window_start': last_sent_at,
        'window_end': now.strftime('%Y-%m-%dT%H:%M:%SZ')
    }, f, indent=2)

print(f"Parsed {len(blocks)} blocks from audit logs")
PYTHON_SCRIPT

# Read metadata
SUBJECT=$(jq -r '.subject' "$META_FILE")
COUNT=$(jq -r '.count' "$META_FILE")

# Send email via gogcli
echo "Sending block digest: $SUBJECT"
"$GOG_BIN" gmail send \
    ${GOG_ACCOUNT:+--account "$GOG_ACCOUNT"} \
    --to "$TO_EMAIL" \
    --subject "$SUBJECT" \
    --body-file "$BODY_FILE" \
    --json >/dev/null

# Update state
NEW_STATE=$(jq -n \
    --arg lastSentAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg lastSubject "$SUBJECT" \
    --argjson lastCount "$COUNT" \
    '{
        lastSentAt: $lastSentAt,
        lastSubject: $lastSubject,
        lastCount: $lastCount
    }')

echo "$NEW_STATE" > "$STATE_FILE"

echo "sent block digest: subject=$SUBJECT count=$COUNT"