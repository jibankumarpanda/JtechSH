# JtechSH Email Triage Job

**Frequency:** Every 3 hours, at :05 past
**Agent:** jtechsh
**Model:** gpt-5.4 with low thinking
**Timeout:** 300s

## Overview

This job scans your Gmail inbox, archives junk mail, and surfaces real mail that needs attention. It follows strict rules to never archive security-related or human email automatically.

## Execution Flow

### 1. Read Rules and State

```bash
# Read JtechSH rules
cat ./jtechsh/EMAILRULES.md

# Read current state
cat ./state/email.json
```

### 2. Scan Inbox (4 Parallel Searches)

```bash
# Unread emails
gog gmail search 'in:inbox is:unread' --json > /tmp/jtechsh-email-unread.json

# Recent emails (last 3 days)
gog gmail search 'in:inbox newer_than:3d' --json > /tmp/jtechsh-email-recent.json

# Security-related emails
gog gmail search 'in:inbox (security OR vulnerability OR GHSA OR CVE OR incident OR breach)' --json > /tmp/jtechsh-email-security.json

# GitHub notifications
gog gmail search 'in:inbox from:notifications@github.com' --json > /tmp/jtechsh-email-github.json
```

### 3. Compact JSON for AI Model

```bash
# Compact each result set to reduce context size
jq '{result_count: .resultCount, threads: [.threads[] | {threadId, date, from, subject, messageCount, labels}]}' /tmp/jtechsh-email-unread.json > /tmp/jtechsh-email-unread-compact.json
jq '{result_count: .resultCount, threads: [.threads[] | {threadId, date, from, subject, messageCount, labels}]}' /tmp/jtechsh-email-recent.json > /tmp/jtechsh-email-recent-compact.json
jq '{result_count: .resultCount, threads: [.threads[] | {threadId, date, from, subject, messageCount, labels}]}' /tmp/jtechsh-email-security.json > /tmp/jtechsh-email-security-compact.json
jq '{result_count: .resultCount, threads: [.threads[] | {threadId, date, from, subject, messageCount, labels}]}' /tmp/jtechsh-email-github.json > /tmp/jtechsh-email-github-compact.json
```

### 4. Re-check Previously Reported Noise

```bash
# Check if any previously reported noise is still in INBOX
# If it matches Rule 1 (machine auto-reply) or Rule 2 (unknown tasking) exactly → archive first
```

### 5. Classify Each Thread

Classify each thread by category:

- **Security / incident / abuse** → KEEP, never archive
- **Time-bound ops** → KEEP (billing, deadline, etc.)
- **Real human, needs reply** → KEEP
- **GitHub direct action** → KEEP if actionable
- **Newsletter / broadcast** → archive CANDIDATE only
- **Auto-reply / machine noise** → Rule 1 exact match → AUTO-ARCHIVE
- **Unknown low-context tasking** → Rule 2 exact match → AUTO-ARCHIVE

### 6. Archive Auto-Archive Candidates

For each auto-archive candidate:

```bash
# Fetch full thread to confirm it still matches the rule
gog gmail thread get THREAD_ID --json

# Archive thread (remove INBOX label)
gog gmail thread modify THREAD_ID --remove INBOX --json

# Verify archive succeeded by re-reading thread
gog gmail thread get THREAD_ID --json | jq '.labels | contains(["INBOX"])'
```

**Important:** If verification fails, record FAIL in audit and do NOT count as archived.

### 7. Write Audit Log

```bash
# Write audit log for today
cat >> ./audit/email/$(date +%Y-%m-%d).md << EOF
## Pass @ $(date -u +%H:%M) UTC

- Archived: thread_abc (Rule 1: QQ auto-reply machine noise)
- Archived: thread_def (Rule 2: one-line unknown tasking, no context)
- Urgent: thread_ghi — billing failure, renewal due 2026-01-20
- Reply: thread_jkl — customer bug report from known user
- GitHub: thread_mno — review requested on openclaw/openclaw#123
- Noise seen: 12 newsletters (count only)
EOF
```

### 8. Update State (MANDATORY)

```bash
# Update state file with current run information
cat > ./state/email.json << EOF
{
  "lastRunAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "jtechshVersion": 1,
  "reportedActionableThreadIds": ["thread_ghi", "thread_jkl", "thread_mno"],
  "reportedNoiseThreadIds": ["thread_xyz"],
  "archivedThreadIds": ["thread_abc", "thread_def"]
}
EOF
```

**Important:** Run fails if state is not updated.

### 9. Emit Digest

Only AFTER both audit log and state writes are confirmed, emit digest with sections:

- **Urgent now** — items requiring immediate attention
- **Reply queue** — items needing a reply
- **GitHub/action** — GitHub notifications requiring action
- **Noise seen** — count only for newsletters/auto-replies
- **Suggested cleanup** — items that could be archived in future runs

## gogcli Command Reference

| Operation | Command |
|-----------|---------|
| Search inbox | `gog gmail search 'QUERY' --json` |
| Get message | `gog gmail get MESSAGE_ID --json` |
| Get thread | `gog gmail thread get THREAD_ID --json` |
| Archive thread | `gog gmail thread modify THREAD_ID --remove INBOX --json` |
| Send email | `gog gmail send --to TO --subject "..." --body-file FILE --json` |

## State File Schema

```json
{
  "lastRunAt": "2026-01-15T09:05:00Z",
  "jtechshVersion": 1,
  "reportedActionableThreadIds": ["thread_abc", "..."],
  "reportedNoiseThreadIds": ["thread_xyz", "..."],
  "archivedThreadIds": ["thread_def", "..."]
}
```

- `jtechshVersion`: always `1`
- All arrays capped to 4000

## Audit Log Format

```markdown
## Pass @ 09:05 UTC

- Archived: thread_abc (Rule 1: QQ auto-reply machine noise)
- Archived: thread_def (Rule 2: one-line unknown tasking, no context)
- Urgent: thread_ghi — billing failure, renewal due 2026-01-20
- Reply: thread_jkl — customer bug report from known user
- GitHub: thread_mno — review requested on openclaw/openclaw#123
- Noise seen: 12 newsletters (count only)
```

## Security Rules

1. **Security-classified email is NEVER auto-archived**
2. **Human email is NEVER auto-archived unless explicitly allowed by a rule**
3. **Unknown messages are observed, not acted on**
4. **Every mutating action produces an audit record**
5. **If archive verification fails, record FAIL and leave for next run**