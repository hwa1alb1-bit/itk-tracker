# Roadmap

Phased delivery aligned with budget unlocks. No hard dates. Each phase ends when its exit criteria are met.

## Phase 0: Planning Repo (current)

**Goal:** Lock the architecture, schema, and scoring algorithm on paper before writing code.

**Deliverables:**

- This repository, fully populated with specs and ADRs
- All open questions logged in `open-questions.md`
- Domain conflict resolved (apex vs subdomain vs alternate)
- Initial seed list of 20-30 ITK accounts identified

**Exit criteria:**

- Every doc has substantive content
- Hank has read every doc end-to-end
- No structural blockers remain

**Estimated effort:** 1-2 weeks part-time.

## Phase 1: Website MVP

**Goal:** Public leaderboard and profile pages, manual submission, moderator queue.

**Deliverables:**

- Frontend deployed to Vercel hobby on the chosen domain
- Supabase free Postgres provisioned with the schema from `20-schema.sql`
- Make.com scenarios configured (submission post-processing + daily maintenance)
- 20-30 seed predictors added with at least 5 historical predictions each (backfilled by Hank)
- Public methodology, privacy, and terms pages live
- Appeals form functional, tested end-to-end

**Exit criteria:**

- Leaderboard page loads under 1 second from CDN cache
- A community member can submit a prediction via the form and see it appear after moderator approval
- A predictor can submit an appeal and receive a response within 14 days
- 30 days of operation without DMCA or defamation contact

**Estimated effort:** 4-6 weeks part-time.

**Cost:** $0/month if everything fits in free tiers. Domain cost is sunk (already owned).

## Phase 2: Browser Extension + Voting

**Goal:** Reduce submission friction. Re-introduce community voting for nominations.

**Deliverables:**

- Chrome + Firefox extension shipped to respective stores
- "Track this prediction" button injected on every X tweet
- Supabase Auth via X OAuth for voter accounts
- 50-upvote nomination threshold from voters with 6-month-old X accounts + 50+ followers
- Voting fraud detection (basic: same-IP cluster analysis, account age sanity checks)

**Exit criteria:**

- 100 active extension installs
- Submission rate via extension exceeds submission rate via form
- Zero successful Sybil attacks on nominations (manual review of every promotion in first 90 days)

**Estimated effort:** 2-4 weeks part-time after Phase 1 ships.

**Cost:** Still $0/month.

## Phase 3: X Bot + Sportmonks Integration

**Goal:** Full automation. Bot summons replace manual form. Automated transfer verification.

**Prerequisites:**

- Sustained traffic indicating Phase 2 product-market fit
- Budget of ~$300/month available (X Basic $200, Sportmonks $40, headroom)
- Either donation revenue, sponsorship, or out-of-pocket commitment from Hank

**Deliverables:**

- X Basic API access provisioned on `@ITKTracker` account
- Mentions polling worker deployed (Cloudflare Worker free tier)
- Redis dedup cache (Upstash free tier or Cloudflare KV)
- Sportmonks Transfer Rumours API integrated for automated ground truth
- Webhook-driven resolution (player officially moves → automatic scoring)

**Exit criteria:**

- 200+ summons per month sustained
- 80%+ of resolutions are automated (moderator only intervenes on edge cases)
- Plain-text confirmation reply system working without URL-link cost overruns

**Estimated effort:** 3-4 weeks part-time after Phase 2.

**Cost:** ~$300/month.

## Phase 4: Tier Derivation and Consensus Lag

**Goal:** Activate the consensus lag penalty once enough data exists.

**Prerequisites:**

- 6+ months of resolved predictions across 50+ active predictors
- At least 200 resolved predictions in the dataset

**Deliverables:**

- Tier 1, Tier 2, unrated classifications derived from observed data
- Consensus lag penalty `CL_i = e^(-0.05 * Δτ_i)` activated in scoring
- Quarterly tier re-evaluation cron job
- Public methodology page updated to explain tier derivation

**Cost:** No new infrastructure.

## Phase 5: Scale and Sustainability

**Goal:** Operate without Hank's personal subsidy.

**Possible paths:**

- Patreon or Ko-fi donation page
- Embed-as-a-widget for content sites (free tier with attribution, paid tier without)
- Sponsorship deals with non-betting brands (newsletters, soccer media)
- League partnerships (extremely unlikely but possible)

**Anti-goals:**

- Betting integration (introduces a different legal regime, taints the public-trust positioning)
- Pay-to-rank or pay-to-remove features (destroys credibility)
- Selling user data (no data of any value exists; not a business model)

## Out-of-Scope (Won't Build)

- Predictive ML model forecasting future transfers
- Real-time push notifications to fans
- Mobile native apps (responsive web is sufficient)
- Multi-sport expansion (NFL, NBA, cricket transfers) until soccer version is stable

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Free Supabase tier exhausted | Medium (transfer windows) | Service degradation | Upgrade to Pro ($25/mo) before Phase 2 ships |
| Vercel hobby bandwidth cap | Low | Site slowdown | Cloudflare cache TTL increased on hot pages |
| Make.com ops quota | Low | Glue scenarios fail | Pay for $9/mo Core tier if it happens twice |
| Defamation challenge from a journalist | Low-Medium | Legal cost, possible takedown | Public-figure defense, appeals process, methodology transparency |
| X bans the bot account in Phase 3 | Medium | Phase 3 stalls | Stay strictly within official API ToS; have fallback browser-extension path |
| Hank loses interest | Personal | Project mothballs | All-in-one repo + docs makes pickup-able by someone else |
