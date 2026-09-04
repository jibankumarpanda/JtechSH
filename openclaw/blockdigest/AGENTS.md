# Block Digest Agent

Sends daily email summary of blocked Twitter/X accounts.

## Trigger

- Cron: `0 9 * * *` (daily at 9am Europe/London)
- Agent: `jtechsh-digest`

## What it does

1. Reads audit logs from `openclaw/clawblocker/audit/twitter/`
2. Parses block events since last digest
3. Compiles unique blocked handles with reasons
4. Sends digest email via `gog gmail send`
5. Updates `state.json` with last sent timestamp

## Dependencies

- `gog` (gogcli) for email sending
- `python3` for audit log parsing
- `jq` for JSON processing

## State

- `state.json` — tracks last digest sent timestamp and count
