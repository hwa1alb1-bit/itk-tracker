# Legal and Methodology

**This document is a working operational guide. It is not legal advice. Consult a US attorney before launch.**

## Jurisdiction

United States. Hank is US-based. The service is hosted on US infrastructure (Vercel, Supabase US regions). US first-amendment protections and Section 230 of the CDA apply.

The system intentionally avoids touching EU-resident data subjects beyond what is unavoidable for a public website. No tracking pixels, no EU-only features, no targeted advertising. GDPR exposure is minimal.

## What We Are Doing

The service:

1. Catalogs public statements made by journalists on public X accounts about soccer transfer predictions
2. Records whether the predicted transfer occurred as predicted by cross-referencing public sources (Wikipedia, BBC, ESPN, official club announcements)
3. Computes a numerical score per prediction based on a published algorithm
4. Aggregates scores into a per-account accuracy ranking
5. Publishes the rankings, individual prediction records, and methodology

## US Public-Figure Standard

Most tracked journalists (Romano, Ornstein, etc.) are public figures for purposes of soccer journalism. Under *New York Times v. Sullivan* and progeny, statements about public figures concerning their public conduct are protected unless made with "actual malice" (knowing falsity or reckless disregard for truth).

The service publishes:

- Verified public statements made by the journalist (the predictions themselves)
- Verified public outcomes from authoritative sources (official transfers)
- Numerical scores computed by a published, transparent algorithm

Reporting accurate facts about public figures' public statements is the strongest possible defamation defense.

## Aspiring or Less-Known Journalists

Accounts that are not public figures get included only after:

1. Moderator approval (Phase 1)
2. Voluntary opt-in via Supabase Auth + X OAuth (Phase 2)

Less-public accounts can request removal at any time via the appeals process. If removed, their historical records are deleted within 7 days.

## Public Evidence Only

Strict policy: every tracked prediction must be a public tweet on a public account. Verification sources must be publicly accessible URLs.

Off-limits:

- Direct messages, even leaked
- Anonymous sources or "people familiar with the matter" without a documented public statement
- Audio or video clips not officially published
- Discord, Telegram, or other private channels

## Methodology Page (Public)

The website will publish a methodology page at `/methodology` covering:

- The scoring algorithm in plain language with worked examples
- The source list used for resolution (Wikipedia, BBC, ESPN, official club announcements)
- The Wilson confidence interval and minimum-resolution threshold
- The deletion policy (deleted tweets count against the predictor as `incorrect`, with neutral framing)
- The appeals process

## Appeals Process

Every prediction record displays a "Challenge this scoring" link. Clicking opens a form:

- Appellant email (required)
- Appellant X handle (optional but recommended for verification)
- Reason for appeal (free text)
- Evidence URLs (array of public links supporting the appeal)

Submissions land in the `appeals` table. Hank (or a mod) reviews within 14 days. Possible outcomes:

1. **Upheld:** the scoring or resolution was wrong. Correction applied. Public changelog entry posted.
2. **Rejected:** the scoring stands. Email response with reasoning.
3. **Removal request:** if the appellant is the predictor and they meet the "less-known journalist" criteria, their account and all predictions can be removed within 7 days.

Public changelog at `/corrections` lists every upheld appeal with date, prediction ID, and the change made.

## Deletion Tracking: Framing

The strategy doc proposed a public "Transparency Rating: 36% of predictions deleted" headline metric. This is reframed in the public-facing site to reduce inflammatory positioning.

**On profile pages:**

> "12 of this account's tracked predictions are no longer publicly accessible. These count toward the resolved-prediction total. See methodology for details."

No standalone "transparency rating" percentage. The deletion impact is already encoded in the accuracy score via the denominator. The footnote exists for context, not as a callout metric.

## DMCA and Takedowns

A designated DMCA agent gets registered with the US Copyright Office (~$6 fee, one-time). Email and physical address published on the site. Takedown requests are processed per standard DMCA procedure.

In practice, journalist-driven takedowns of factual reporting are not DMCA-eligible (no copyrighted material in our reporting). DMCA exists primarily for the tweet text quotation; if a journalist demands removal of a verbatim tweet quote, we comply within 24 hours but retain the metadata (link, timestamp, scoring outcome).

## X Terms of Service

The strategy doc proposed self-hosted screenshots of tweets. This is dropped from the MVP because:

1. X has aggressively pursued litigation against screenshot archives (e.g., Bright Data case)
2. Wayback Machine and archive.today already serve this purpose with established legal precedent
3. Self-hosted storage is a Supabase cost we avoid

The MVP stores tweet text in the database (within fair-use quotation limits for factual reporting) and links to Wayback for the canonical archived version.

## Transfermarkt Terms of Service

The strategy doc proposed automated Transfermarkt scraping for actual fee verification. This violates Transfermarkt ToS. The MVP does manual lookups by human moderators viewing Transfermarkt as any normal user would. No automated scraping.

## Privacy Policy Highlights

Required at `/privacy`:

- What we collect (submission form: tweet URL, IP for rate-limiting, optional email for appeals)
- What we do not collect (no behavioral tracking, no ad SDKs, no third-party analytics initially)
- Retention: appeal emails retained 2 years, then purged
- Right to access / delete: email the DMCA agent address

## Terms of Service Highlights

Required at `/terms`:

- The service is provided as-is, no warranty
- Scoring is one signal among many; not financial advice, not legal advice
- Predictors retain rights to their own tweets; we only quote and link
- Appeals process available; arbitration clause for disputes

## Pre-Launch Legal Checklist

- [ ] Methodology page drafted and reviewed
- [ ] Privacy Policy drafted and reviewed
- [ ] Terms of Service drafted and reviewed
- [ ] DMCA agent registered with US Copyright Office
- [ ] Appeals process tested end-to-end with a friendly test case
- [ ] Cloudflare Email Routing (inbound) configured for `appeals@`, `dmca@`, `corrections@` forwarding to `oneoddbob@gmail.com`
- [ ] Cloudflare Email Sending (outbound) provisioned for `noreply@prizm.app` transactional replies
- [ ] Gmail "Send mail as" alias configured so manual appeal responses show `appeals@prizm.app` as sender
- [ ] DKIM / SPF / DMARC verified via Cloudflare DNS automation
- [ ] Optional: pro-bono review by a US attorney familiar with publishing law
