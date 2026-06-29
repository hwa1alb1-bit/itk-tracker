# ADR 0002: Manual Ingestion via Submission Form for MVP

**Status:** Accepted (2026-06-29)
**Owner:** Hank
**Related:** ADR 0001

## Context

Following ADR 0001 (zero-dollar budget pivot), the summon bot is out of MVP scope. We need a Phase 1 ingestion mechanism that:

- Costs $0/month
- Captures structured metadata (predictor, player, club, fee, prediction date)
- Survives at low volume (10-30 submissions/day)
- Lets moderators validate before publication
- Provides a clear path to lower-friction methods in Phase 2

## Decision

Phase 1 uses a website submission form. The form takes:

- Tweet URL (required, validated against X URL pattern)
- Player (autocomplete from `players` table, with "add new" fallback)
- Predicted destination club (autocomplete from `clubs` table)
- Predicted fee in EUR (optional)
- Predictor X handle (auto-extracted from URL)

Submissions land in the `predictions` table with `is_approved=false`. A moderator reviews the queue and approves or rejects.

## Consequences

**Positive:**

- Highly explicit user intent. Submitters are committing to a specific prediction.
- Structured data at submission time. No NLP needed to extract player/club from tweet text.
- Moderator queue prevents spam and obvious mistakes from polluting the leaderboard.
- Same form code reused as the backend for the Phase 2 browser extension (extension just prefills the form fields).

**Negative:**

- Friction. Paste URL → autocomplete two entities → submit. Probably 60-90 seconds of effort per submission.
- Moderator throughput becomes the rate limiter. If Hank is on vacation, the queue grows.
- Easy to forget to submit a prediction right after seeing the tweet. Submission rates are likely lumpy.

## Form Anti-Abuse

- Cloudflare Turnstile to gate the submit endpoint
- Per-IP rate limit: 5 submissions/hour at the Cloudflare WAF layer
- Duplicate `tweet_id` returns a "already tracked" success instead of an error (prevents fishing for queue contents)

## Moderator Dashboard

A separate authenticated route `/mod` (Supabase Auth, mod role required):

- Pending submissions list, sorted by submission time
- For each: tweet embed (via X oEmbed), player/club confirmation, approve/reject buttons
- Bulk-approve for obvious whitelisted predictors
- Reject reason captured for the audit log

## Alternatives Considered

1. **Public no-moderation submission.** Skip the moderator queue, let submissions go live immediately. Rejected: spam and bad-faith submissions would destroy the data quality. Same reason Wikipedia has admins.
2. **Email-based submission.** Users email `submit@prizm.app` with a tweet URL. Rejected: harder to parse, no structured metadata, higher moderator burden.
3. **Discord bot in a community server.** Lower friction within Discord but limits reach to one community. Rejected as a primary mechanism but could supplement Phase 2.
4. **Twitter/X DM-based submission.** Doesn't avoid X API costs (DMs count as paid API). Rejected.
