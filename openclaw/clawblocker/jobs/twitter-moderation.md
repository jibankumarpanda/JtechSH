# Twitter Moderation Job

**Frequency:** Every 10 minutes
**Agent:** jtechsh
**Timeout:** 120s

## Overview

Scans recent mentions, blocks spam accounts (crypto bots, AI slop, scam links), keeps genuine interactions.

## Execution Flow

### 1. Read State

```bash
cat ./openclaw/clawblocker/state/twitter.json
```

### 2. Fetch Recent Mentions

```bash
gog twitter mentions --count 50 --json > /tmp/jtechsh-twitter-mentions.json
```

### 3. Classify Each Mention

Classify by category:

- **Crypto pump / token spam** → BLOCK
- **AI-generated slop / engagement bait** → BLOCK
- **Scam links / phishing** → BLOCK
- **Genuine bug report** → KEEP
- **Genuine question** → KEEP
- **Retweet / quote with no new content** → IGNORE

### 4. Block Spam Accounts

For each block candidate:

```bash
# Block account
gog twitter block USER_ID --json

# Verify block succeeded
gog twitter user USER_ID --json | jq '.blocking'
```

### 5. Write Audit Log

```bash
cat >> ./openclaw/clawblocker/audit/twitter/$(date +%Y-%m-%d).md << EOF
## Pass @ $(date -u +%H:%M) UTC

- $(date -u +%Y-%m-%dT%H:%M:%SZ) | block | @spambot1 | https://x.com/spambot1/status/123 | crypto pump spam
- $(date -u +%Y-%m-%dT%H:%M:%SZ) | keep  | @realdev | https://x.com/realdev/status/456 | genuine bug report
EOF
```

### 6. Update State (MANDATORY)

```bash
cat > ./openclaw/clawblocker/state/twitter.json << EOF
{
  "processedTweetIds": ["1234567890", "..."]
}
EOF
```

## gogcli Command Reference

| Operation | Command |
|-----------|---------|
| Get mentions | `gog twitter mentions --count N --json` |
| Get tweet | `gog twitter tweet TWEET_ID --json` |
| Block user | `gog twitter block USER_ID --json` |
| Get user | `gog twitter user USER_ID --json` |
