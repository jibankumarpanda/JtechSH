# Bird Twitter Moderation Skill

Warms the `birdclaw` mention cache and performs Twitter/X moderation.

## Prerequisites

- `birdclaw` CLI available at `$HOME/Projects/birdclaw`
- `bird` CLI available at `$HOME/Projects/bird/bird`
- Active X auth/cookies
- Node.js via `fnm`

## Execution

```bash
# Warm mention cache
fnm exec --using 25.8.1 pnpm cli --cache-warm

# Run moderation pass
fnm exec --using 25.8.1 pnpm cli --moderate
```

## What it does

1. Fetches recent mentions via `birdclaw`
2. Classifies each mention (spam, genuine, ignore)
3. Blocks spam accounts
4. Records block/mute actions to local SQLite
5. Returns moderation results for audit logging
