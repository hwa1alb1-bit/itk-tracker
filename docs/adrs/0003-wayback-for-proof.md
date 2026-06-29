# ADR 0003: Wayback Machine and archive.today for Tweet Archival

**Status:** Accepted (2026-06-29)
**Owner:** Hank

## Context

ITK accounts routinely delete incorrect predictions to manipulate their accuracy record ("receipt wiping"). Any tracking system needs an immutable archive of the prediction tweet to prevent post-hoc revisionism.

The original strategy doc proposed self-hosted screenshots:

> When a user summons the bot, the system performs an immediate read of the parent tweet, saving the full text, author, timestamp, and screenshot to Supabase Storage.

This approach has three problems:

1. **Legal exposure.** X has aggressively pursued cases against screenshot archives (e.g., Bright Data). Self-hosting tweet screenshots is the exact behavior they target.
2. **Cost.** Headless browser rendering for screenshots requires either a paid service (Browserless, ScreenshotOne ~$10+/mo) or self-hosted Puppeteer (Vercel function timeouts, Cloudflare Worker memory limits).
3. **Storage.** Even at small file sizes, 1000 screenshots eats into Supabase's 1GB Storage free tier.

## Decision

Drop self-hosted screenshots. On every prediction submission, POST the tweet URL to two free public archival services:

1. **Internet Archive (Wayback Machine):** POST to `https://web.archive.org/save/{tweet_url}`. Returns a snapshot URL.
2. **archive.today:** POST to `https://archive.today/?url={tweet_url}`. Returns a snapshot URL.

Both snapshot URLs are written to the `predictions` row (`wayback_url`, `archive_today_url` columns).

Wayback and archive.today have well-established legal standing as public-interest archives. X has not pursued them. They handle their own rendering, storage, and uptime.

## Consequences

**Positive:**

- Zero storage cost
- Zero rendering cost
- Legal defensibility (established archival precedent)
- Two independent archives = redundancy
- Both archives are publicly accessible — appellants and skeptics can verify our screenshots independently

**Negative:**

- Wayback occasionally fails to capture (rate limits, transient outages)
- archive.today sometimes captures slowly or imperfectly
- We don't control the archive; if both services purge the snapshot somehow, we lose proof. Vanishingly unlikely.
- Snapshot rendering is whatever the service produces; we cannot annotate or highlight

## Failure Modes and Mitigations

| Failure | Mitigation |
|---|---|
| Wayback 429 rate limit | Make.com retry with exponential backoff |
| Both services fail on same tweet | Store the raw tweet text + author + timestamp in DB as fallback proof |
| Tweet deleted before archival completes | Daily deletion audit catches this; prediction marked `deleted_by_author` with whatever metadata we captured |
| User submits an archived URL (already a Wayback snapshot) | Detect Wayback URL pattern, skip re-archiving, use the original URL directly |

## Database Implications

The `predictions` schema has:

- `tweet_url VARCHAR(500)` — the original X URL
- `tweet_text VARCHAR(2000)` — copy of the tweet text (fair-use quotation for factual reporting)
- `wayback_url VARCHAR(500)` — Wayback snapshot URL
- `archive_today_url VARCHAR(500)` — archive.today snapshot URL

The `proof_url` column is reserved for the resolution proof (link to official club announcement), not the prediction archive.

## Alternatives Considered

1. **Screenshot via headless browser service.** Browserless free tier exists but is highly rate-limited. ScreenshotOne, ApiFlash, etc. all have free tiers but lock screenshots into their proprietary CDNs. Rejected on cost-at-scale and legal exposure.
2. **Manual screenshots by moderators.** Workflow disaster. Rejected.
3. **Wayback only (no archive.today).** Single point of failure. archive.today adds resilience at zero marginal cost. Rejected as a one-archive approach.
4. **Trust the X API for proof.** X cache TTLs are short and the API returns 404 on deleted tweets. Not durable. Rejected (also doesn't apply since we have no paid X API in MVP).
