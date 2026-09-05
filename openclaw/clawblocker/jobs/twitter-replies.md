# Twitter Reply Triage Job

**Frequency:** Every 6 hours, at :17 past
**Agent:** jtechsh
**Timeout:** 180s

## Overview

Reviews recent mentions and surfaces the top 5 worth replying to, based on relevance, engagement potential, and urgency.

## Execution Flow

### 1. Read State

```bash
cat ./openclaw/clawblocker/state/twitter-replies.json
```

### 2. Fetch Recent Mentions

```bash
gog twitter mentions --count 100 --json > /tmp/jtechsh-twitter-replies-mentions.json
```

### 3. Filter Already Processed

Remove tweets already in `reportedTweetIds` or `resolvedTweetIds` from state.

### 4. Score and Rank

Score each remaining mention:

- **Direct question about Triger.sh** → high priority
- **Bug report** → high priority
- **Feature request** → medium priority
- **General mention / retweet** → low priority
- **Spam / irrelevant** → skip

### 5. Select Top 5

Pick the 5 highest-scoring mentions that haven't been reported yet.

### 6. Write Audit Log

```bash
cat >> ./openclaw/clawblocker/audit/twitter-replies/$(date +%Y-%m-%d).md << EOF
## Pass @ $(date -u +%H:%M) UTC

- Reported: @user1 (direct question about config)
- Reported: @user2 (bug report: shell crashes on cd)
- Reported: @user3 (feature request: plugin support)
- Reported: @user4 (general mention, high engagement)
- Reported: @user5 (documentation improvement suggestion)
EOF
```

### 7. Update State (MANDATORY)

```bash
cat > ./openclaw/clawblocker/state/twitter-replies.json << EOF
{
  "reportedTweetIds": ["111", "222", "333", "444", "555"],
  "resolvedTweetIds": ["..."]
}
EOF
```

### 8. Emit Digest

Only AFTER audit log and state writes are confirmed, emit digest with:

- **Top 5 mentions** — with scores and suggested reply angles
- **Skipped** — count of filtered/spam mentions

## gogcli Command Reference

| Operation | Command |
|-----------|---------|
| Get mentions | `gog twitter mentions --count N --json` |
| Get tweet | `gog twitter tweet TWEET_ID --json` |
| Get user | `gog twitter user USER_ID --json` |
