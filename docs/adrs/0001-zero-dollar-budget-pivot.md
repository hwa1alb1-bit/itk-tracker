# ADR 0001: Zero-Dollar Budget Pivot

**Status:** Accepted (2026-06-29)
**Owner:** Hank

## Context

The original strategy doc assumed a ~$500/month operating budget covering X Basic API ($200), Sportmonks ($40), third-party scraper APIs ($50+), Vercel Pro, and reserves. The summon-bot model where users tag the tracker account on a prediction tweet is the centerpiece of the original design.

Hank confirmed the actual operating budget is $0/month. Hobby project, free tiers only.

This invalidates several core assumptions of the strategy doc:

1. X paid API is out. Mentions polling at any useful frequency is gated behind Basic ($200) or PAYG (real costs per call). Free tier rate limits make summon polling unreliable.
2. Sportmonks is out. Lowest useful tier is ~$40/month.
3. Third-party X scraper APIs (TikHub, twitterapi.io) are also out. Cheapest is ~$0.001/request which still costs real money at any volume.

## Decision

Drop the X summon bot from the MVP entirely. Replace it with two alternative ingestion paths:

1. **Website submission form (MVP, Phase 1).** Users paste a tweet URL into a form. No X API required because the user already has the URL.
2. **Browser extension (Phase 2).** A "Track this prediction" button injected into the user's own X session. The browser is the client; no API costs.

The summon bot returns as Phase 3, gated on a ~$300/month budget unlock.

For automated ground truth (transfer resolution), replace Sportmonks with manual moderator verification using public sources (Wikipedia, BBC, ESPN, official club announcements). Sportmonks returns as Phase 3.

## Consequences

**Positive:**

- True $0/month operating cost for MVP
- Removes the most expensive line item (X API) from the critical path
- Forces a lean architecture that scales down to zero traffic gracefully
- Submission via form keeps the user's intent explicit (no accidental tracking)

**Negative:**

- Higher submission friction in Phase 1 (paste URL + fill metadata vs tag a bot)
- Moderator burden scales with submission volume. Hank's evenings cap throughput at ~10-30 submissions/day.
- Resolution is manual until Phase 3. Slow.
- The "auto-confirm reply to user" feature from the strategy doc is dropped. The submission form's success page replaces it.

**Mitigations:**

- Phase 2 browser extension closes most of the submission friction gap
- Make.com free tier handles the glue work (archival, sync, notifications) that would otherwise need Supabase Edge Functions
- Manual resolution is honestly fine for a hobby project tracking 30 accounts

## Alternatives Considered

1. **Wait for budget.** Don't ship anything until $300/month is committed. Rejected: the planning doc is already done and Phase 1 is buildable at $0. Stalling on budget delays validation.
2. **X free tier polling.** Free tier allows ~1500 reads/month. At any submission volume this dies in days. Rejected.
3. **Web scraping X.** Against ToS. Bot detection on X is aggressive. Rejected.
4. **RSS-based ingestion via Nitter mirrors.** Nitter is mostly dead. Surviving mirrors are intermittent. Rejected.
5. **Volunteer manual transcription.** Tried in fan communities (Reddit transfer guides). Doesn't scale. Rejected as a primary mechanism (but the moderator queue is essentially this, scoped down).

## References

- Original strategy doc (in conversation history)
- X API pricing 2026 (per source citations in strategy doc, requires independent verification)
- Make.com free tier limits (1,000 ops/month, 2 active scenarios)
