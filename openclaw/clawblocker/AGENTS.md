# ClawBlocker Agent

Handles Twitter/X mention moderation, reply triage, and email triage.

## Jobs

| Job | Cron | Timezone | Description |
|-----|------|----------|-------------|
| Twitter Moderation | `*/10 * * * *` | UTC | Blocks spam, crypto bots, AI slop |
| Twitter Replies | `17 */6 * * *` | Europe/London | Surfaces top 5 mentions worth replying to |
| Email Triage | `5 */3 * * *` | Europe/London | Scans inbox, archives junk, surfaces real mail |

## Directory Structure

```
clawblocker/
├── AGENTS.md           ← this file
├── jobs/
│   ├── email-triage.md
│   ├── twitter-moderation.md
│   └── twitter-replies.md
├── skills/             ← agent skill definitions
└── state/              ← runtime state JSON files
```

## Security Rules

1. Security-classified email is NEVER auto-archived
2. Human email is NEVER auto-archived unless explicitly allowed by a rule
3. Unknown messages are observed, not acted on
4. Every mutating action produces an audit record
5. If archive verification fails, record FAIL and leave for next run
