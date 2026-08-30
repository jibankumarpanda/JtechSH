# Conference Triage

How we do conference triage for jiban.

## Source of Truth

- Use `gog` first.
- Gmail = invitation / acceptance truth.
- Google Sheets = working tracker.
- Calendar = fit / conflict check only.
- Do not trust calendar for exact event dates unless the invite itself confirms them.

## Main Sheet

- Sheet: `Invitations`
- Keep explicit statuses:
  - `Needs response`
  - `Active thread`
  - `Scheduled / active`
  - `Confirmed / active`
- Keep visual buckets:
  - `@ Upcoming`
  - `⭐ CALENDARED`
  - `🟢 CONFIRMED`
  - `🟡 MAYBE`

## Basic Workflow

1. Read the tracker.
2. Read the Gmail thread.
3. Answer:
   - what is the event
   - exact date
   - exact location
   - what they want
   - did Peter say yes / no / maybe
   - does calendar fit
4. Update the sheet immediately.
5. If accepted, update/add calendar.
6. If publicly confirmed and worth listing, add to `~/Projects/speaking`.

## Gmail Rules

- Prefer thread reads over single-message reads when status is unclear.
- Look for explicit outbound replies from Jiban:
  - `from:(pandajiban331@gmail.com)`
- Distinguish:
  - explicit yes
  - explicit no
  - interest only
  - logistics imply yes
- Ticket / invoice / attendee welcome mail counts as confirmed even without a manual reply.

## Calendar Rules

- Search both `primary` and `Travel`.
- Reuse placeholders; do not create duplicates.
- Accepted events:
  - mark active/busy
  - note ticket / confirmation source in description
- Tentative events:
  - title with `Maybe`
  - keep free

## Sheet Rules

- Put `jiban is going.` in notes once that is true.
- Keep notes short, factual, dated.
- If dates are fuzzy, say so explicitly.
- Top block should contain future green conference rows, sorted by date.
- Do not mix podcasts into the top conference block.

## Speaking Repo

- Repo: `~/Projects/speaking`
- Only add conferences Peter is actually doing.
- Use official names and links where possible.
- Prefer the official event page over a newsletter link.

## Handy Commands

```bash
gog --account pandajiban331@gmail.com search --all --max 20 'SaaStock OR tedai-vienna-speakers@ted.com' --plain
gog --account pandajiban331@gmail.com gmail thread get <thread-id> --plain
gog --account pandajiban331@gmail.com sheets get <sheet-id> 'Invitations!A1:Q120' --plain
gog --account pandajiban331@gmail.com sheets update <sheet-id> 'Invitations!O8:O8' --values-json '[[\"jiban is going.\"]]'
gog --account pandajiban331@gmail.com calendar events --all --from 2026-10-10 --to 2026-10-16 --plain
gog --account pandajiban331@gmail.com calendar update <calendar-id> <event-id> --summary 'AI Engineer Europe 2026' --transparency busy
```

## Decision Heuristics

- High signal beats large attendance.
- Invite-only founder / researcher rooms are usually highest value.
- Exact fit matters:
  - cluster near existing travel = good
  - back-to-back intercontinental hops = bad
- If exact dates are missing, do not force a yes/no. Mark `undecided` and ask for details.
