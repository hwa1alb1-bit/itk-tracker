# Architecture

## High-Level Diagram

```
                          ┌──────────────────────────┐
                          │ User Browser             │
                          │  - Website submission    │
                          │  - Browser extension P2  │
                          └────────────┬─────────────┘
                                       │ HTTPS
                          ┌────────────▼─────────────┐
                          │ Cloudflare (DNS + CDN)   │
                          │  prizmview.app or sub    │
                          └────────────┬─────────────┘
                                       │
                          ┌────────────▼─────────────┐
                          │ Vercel Hobby (Frontend)  │
                          │  Next.js / SvelteKit     │
                          │  - Public leaderboard    │
                          │  - Profile pages         │
                          │  - Submission form       │
                          │  - Moderator dashboard   │
                          └────────────┬─────────────┘
                                       │ Supabase JS client
                          ┌────────────▼─────────────┐
                          │ Supabase Free Postgres   │
                          │  - predictors            │
                          │  - players, clubs        │
                          │  - predictions           │
                          │  - sheets_sync_queue     │
                          │  - Row Level Security    │
                          │  - Database webhooks ────┼──┐
                          └──────────────────────────┘  │
                                                        │
                              ┌─────────────────────────▼──┐
                              │ Make.com (Free Tier)       │
                              │  Scenario A:               │
                              │   - Wayback POST           │
                              │   - archive.today POST     │
                              │   - Google Sheets append   │
                              │  Scenario B:               │
                              │   - Daily deletion audit   │
                              │   - Moderator notification │
                              └────────────────────────────┘
```

## Service Inventory

| Layer | Service | Tier | Purpose |
|---|---|---|---|
| DNS / CDN | Cloudflare | Free | Domain, edge caching, optional Email Routing |
| Frontend | Vercel | Hobby | Static + SSR rendering, edge functions |
| Database | Supabase | Free | PostgreSQL 500MB, Auth, Storage 1GB, Realtime |
| Workflow | Make.com | Free | 1,000 ops/month, 2 active scenarios |
| Archival | Internet Archive + archive.today | Free | Wayback snapshots of tweets |
| Email | Cloudflare Email Routing | Free | Appeals inbox forwarding |
| Source code | GitHub | Free | Repo hosting, Issues, Actions |

## Data Flow: Submission

1. User pastes tweet URL into website form
2. Frontend validates URL is a valid X status link
3. Frontend calls Supabase Edge Function (or RPC) to insert `predictions` row with `resolved_state = 'pending'`, `moderator_reviewed_by IS NULL`
4. Supabase webhook fires to Make.com Scenario A
5. Make.com POSTs the tweet URL to web.archive.org and archive.today, captures snapshot URLs, writes them back to the `predictions` row, appends a row to the Google Sheet
6. Make.com Scenario B fires in parallel, sends Hank a notification (Telegram or email) about the pending moderator review
7. Hank or a mod opens the moderator dashboard, reviews, approves or rejects
8. Approved predictions become visible on the public site after a CDN cache refresh

## Data Flow: Resolution

1. Moderator monitors transfers via Wikipedia, BBC Sport, official club pages
2. When a tracked player officially moves, moderator opens the relevant `predictions` row in the dashboard
3. Moderator records actual destination club ID, actual fee, link to official club announcement (proof URL), and sets `resolved_state` to `correct`, `incorrect`, or `mitigated`
4. Database trigger or scheduled job recomputes per-prediction score `S_i` and updates predictor's aggregate stats
5. CDN cache invalidates on the predictor profile and leaderboard

## Data Flow: Deletion Audit

1. Make.com Scenario B runs once daily
2. Queries Supabase for all `pending` predictions with no recorded deletion check in last 7 days
3. Performs HTTP HEAD against each tweet URL in a single batched HTTP module
4. For any URL returning 404 or 403, updates `resolved_state` to `deleted_by_author` and logs timestamp
5. Deleted predictions count against the predictor's aggregate accuracy (treated as incorrect for scoring)

## Security and Privacy

- Supabase Row Level Security: write access on `predictions` restricted to authenticated mods. Read access public for approved rows only.
- Authentication: Supabase Auth with email magic links for moderators. No public user accounts in MVP (Phase 2 adds limited user accounts for voting).
- PII: no real names beyond what is already public on X. No email addresses stored except moderator accounts.
- Secrets: stored in Vercel environment variables and Make.com connection credentials. Never committed to repo.

## Performance Targets

- Leaderboard page TTFB under 200ms (Cloudflare cached)
- Profile page TTFB under 500ms (Supabase query + Vercel SSR)
- Submission form to confirmation under 2 seconds
- Daily deletion audit completes in under 5 minutes

## Failure Modes

| Failure | Detection | Mitigation |
|---|---|---|
| Supabase free tier inactivity pause (7 days) | UptimeRobot ping fails | Cloudflare worker pings DB daily |
| Make.com ops quota exceeded | Scenario emails failure to Hank | Pause non-critical scenarios until reset |
| Vercel hobby bandwidth cap | Vercel email warning at 80% | Cloudflare cache TTL bumped to 24h |
| Wayback API rate limit | Scenario A 429 response | Make.com retry with backoff, fall through to archive.today only |
| Moderator out for a week | Submission queue grows | Public banner: "Reviews may be delayed" |
