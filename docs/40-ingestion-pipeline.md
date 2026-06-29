# Ingestion Pipeline

## Phase 1: Website Submission Form

```
[User visits website]
        ↓
[Clicks "Submit a prediction"]
        ↓
[Pastes X tweet URL + selects player/club from autocomplete + optional fee + prediction date (auto-pulled from tweet)]
        ↓
[Frontend validates URL format]
        ↓
[Supabase RPC: insert into predictions, is_approved=false, resolved_state='pending']
        ↓
[Database webhook fires to Make.com Scenario A]
        ↓
[Make.com:
   1. POST tweet URL to web.archive.org/save/
   2. POST tweet URL to archive.today
   3. UPDATE predictions row with wayback_url, archive_today_url
   4. Append row to Google Sheet "ITK Audit Log"]
        ↓
[Database webhook also fires to Make.com Scenario B branch: moderator notification]
        ↓
[Make.com sends Hank a Telegram/email: "New submission #abc123 in moderator queue"]
        ↓
[Hank opens moderator dashboard at prizmview.app/mod]
        ↓
[Reviews tweet, confirms player and club match, sets is_approved=true]
        ↓
[Public leaderboard CDN cache invalidates within 60 seconds]
```

### Form Fields

Required:
- Tweet URL (validated against `https://x.com/.+/status/\d+` regex)
- Player (autocomplete against `players` table, with "add new player" fallback)
- Predicted destination club (autocomplete against `clubs` table)

Optional:
- Predicted fee in EUR
- Predictor X handle (auto-extracted from URL; user can correct if it's a quote-tweet)

Auto-populated server-side:
- `predicted_at` from tweet metadata
- `tweet_text` from tweet content
- `tweet_id` parsed from URL
- `predictor_id` resolved from X handle against `predictors` table

### Anti-Abuse for the Form

- Cloudflare Turnstile on submit
- Per-IP rate limit: 5 submissions per hour (Cloudflare WAF rule)
- Duplicate `tweet_id` returns "already tracked" success message instead of error

### Player and Club Autocomplete

If the submitted player or club is not in the database:
- Frontend offers "Suggest new player" form
- New player suggestions go to a `pending_entities` queue
- Moderator approves or rejects new entity additions during their review

Seed the `clubs` table with the top 5 leagues (EPL, La Liga, Serie A, Bundesliga, Ligue 1) plus MLS, Eredivisie, Primeira Liga, and the major South American leagues at launch. ~200 clubs covers 90%+ of submissions.

## Phase 2: Browser Extension

Same flow, but eliminates the "find the tweet URL and paste it" friction.

### How It Works

1. User installs the extension (Chrome + Firefox)
2. User browses X normally
3. Each tweet on the user's feed gets a "Track this prediction" button injected via content script
4. Click opens an inline modal: player + club + fee fields, prepopulated where possible from the tweet text
5. Submit POSTs to the same `predictions` endpoint as the website form

### Why Not Just Scrape the Tweet API?

We have no X API budget. The extension runs in the user's authenticated browser session. X cannot rate-limit it differently than normal browsing.

### Distribution

- Chrome Web Store: free developer registration. ~1-week review.
- Firefox Add-ons: free, faster review.
- Manifest V3.

### Permissions

- `https://x.com/*` (content script injection)
- `https://prizmview.app/*` (API calls)
- No other host permissions, no broad storage permissions

## Phase 3: X Summon Bot

Returns when monthly budget supports X Basic ($200/mo). Architecture per the original strategy doc:

```
[User tags @ITKTracker on a prediction tweet]
        ↓
[Bot polls mentions endpoint every 60s]
        ↓
[For each new mention:
   1. Check Redis dedup cache for parent tweet_id (24h TTL)
   2. If new: extract parent tweet metadata via official API
   3. Insert into predictions table
   4. Post plain-text confirmation reply (no URLs to avoid $0.20/post penalty)
   5. Cache parent tweet_id in Redis]
```

Plain-text confirmation reply template (no URLs, no $0.20 penalty):

```
Tracked in our system under Record ID {prediction_id_short}. Search your username on our tracking website to view your profile and historical calls.
```

## Resolution Path (All Phases)

```
[Moderator monitors public sources:
   - Wikipedia transfer pages
   - BBC Sport
   - ESPN
   - Official club X accounts
   - Official club press releases]
        ↓
[When a tracked player officially moves]
        ↓
[Moderator opens predictions filtered by player_id]
        ↓
[For each matching prediction:
   - Set actual_destination_club_id
   - Set actual_fee_eur OR fee_was_undisclosed
   - Set proof_url (link to official announcement)
   - Set resolved_state to correct/incorrect/mitigated
   - Set resolved_at = NOW()]
        ↓
[Database trigger recomputes score columns]
        ↓
[REFRESH MATERIALIZED VIEW CONCURRENTLY predictor_stats]
        ↓
[Vercel revalidates leaderboard and predictor profile pages]
```

## Deletion Audit (Make.com Scenario B, Daily)

```
[Trigger: Schedule, 02:00 UTC daily]
        ↓
[HTTP GET Supabase: SELECT id, tweet_url FROM predictions
   WHERE resolved_state='pending' AND (last_deletion_check_at IS NULL OR last_deletion_check_at < NOW() - INTERVAL '7 days')
   LIMIT 100]
        ↓
[For each row, HTTP HEAD against tweet_url
   (batched as a single HTTP Iterator module to keep ops cost low)]
        ↓
[For each 404 or 403 response:
   UPDATE predictions SET resolved_state='deleted_by_author', last_deletion_check_at=NOW()]
        ↓
[For each 200 response:
   UPDATE predictions SET last_deletion_check_at=NOW()]
```

Operation cost: ~3 ops per scenario run regardless of how many tweets get checked (Iterator counts as one op). Daily = ~90 ops/month.

## Make.com Scenario Consolidation

Free tier allows only 2 active scenarios. The four logical scenarios collapse into two:

**Scenario 1: "Submission post-processing"**
- Trigger: Supabase webhook on `predictions` insert
- Path A: Archive to Wayback + archive.today, update row with snapshot URLs
- Path B: Send moderator notification to Hank
- Path C: Append to Google Sheets audit log

**Scenario 2: "Daily maintenance"**
- Trigger: Schedule, 02:00 UTC daily
- Step A: Deletion audit (HEAD requests against pending tweet URLs)
- Step B: Sheets sync queue retry (process rows with sync_status='failed' and attempt_count<5)

Total estimated ops/month: ~600. Headroom remains for transfer-window bursts.
