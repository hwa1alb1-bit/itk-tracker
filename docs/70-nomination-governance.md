# Nomination Governance

How accounts get on the tracker, how they get off, and how the system prevents abuse.

## Three Tiers of Tracked Accounts

### Tier A: Whitelisted (Phase 1 launch)

A seed set of 20-30 ITK accounts hand-picked by Hank at launch. These are well-known public-figure journalists where:

- Public-figure standard clearly applies
- Following them is part of the soccer-fan media diet
- Their inclusion is uncontroversial

Examples: Fabrizio Romano, David Ornstein, Florian Plettenberg, Nicolo Schira, Gianluca Di Marzio, Christian Falk, James Pearce.

Whitelisted accounts get full tracking from day one. Their predictions submitted via the form get fast-tracked through moderator approval (10-minute SLA).

### Tier B: Moderator-Approved (Phase 1, ongoing)

Anyone can submit a prediction tagging any X account. If the tagged account is not in the database, the moderator decides:

1. **Approve:** legitimate ITK journalist or aspiring one with verifiable public soccer-reporting history. Add to `predictors` table, mark `is_active=true`.
2. **Reject:** spam, parody, bot account, account with no relevant content. Reject the submission, do not add the account.
3. **Watch:** borderline case. Add to `predictors` table with `is_active=false` (tracked silently). After 5 verified predictions with ≥70% accuracy, flip to `is_active=true`.

Phase 1 throughput is moderator-limited. Hank reviews submissions in evenings. Expect 5-15 new accounts per month in this tier.

### Tier C: Community-Voted (Phase 2, after extension ships)

Phase 2 unlocks user voting via X OAuth login. The Tier B moderator path remains but adds a parallel community path:

1. User nominates an account via the extension or website
2. Other authenticated voters upvote within a 14-day window
3. Voters must have:
   - X account at least 6 months old
   - At least 50 followers (proxy for non-throwaway account)
   - At least one prior interaction with the site (vote, submission, etc.)
4. 50 upvotes within 14 days promotes the account from "nominated" to active tracking
5. Failure to hit 50 upvotes purges the nomination after 14 days

Voter anti-fraud:

- Same-IP cluster analysis (5+ votes from one /24 in 24 hours flags for review)
- Account age check at vote time, not at nomination time (prevents farming month-old accounts)
- Manual review of every "promoted" account in the first 90 days of Phase 2

### Tier D: Sandbox Probation (Phase 3+)

When a Phase 2 community-voted account is first promoted, it enters Sandbox for 90 days:

- Predictions are tracked and scored
- Profile page exists but is `noindex` for search engines
- Account does not appear on the public leaderboard
- After 90 days with ≥5 resolved predictions, account graduates to the full leaderboard

This protects the leaderboard's signal-to-noise ratio from new untested accounts.

## Removal and Deactivation

**Voluntary removal (opt-out).** Tier B/C accounts (not Tier A whitelisted public figures) can request removal at any time via the appeals form. Removal within 7 days. All historical predictions deleted.

**Tier A removal.** Public-figure journalists cannot remove their tracked predictions because those are public statements about public conduct (per US law). The appeals process is available for individual scoring corrections, not blanket removal. Exception: the journalist demonstrates harassment or doxxing originating from the tracker — in that case, Hank's call.

**Inactive account purge.** Accounts with no new predictions in 12 months get marked `is_active=false`. Profile remains accessible but does not appear on the live leaderboard. Predictions older than 365 days don't count toward the rolling accuracy score anyway.

**Banned accounts.** Tracker policy violations (impersonation, threats, doxxing through the appeals form) result in: (a) Tier C voter ban, or (b) Tier B/C predictor removal. Tier A bans are case-by-case.

## Anti-Sybil Defenses

**Phase 1 (moderator-only):** Sybil attacks not applicable. Only Hank decides who gets tracked.

**Phase 2 (community voting):** Multi-layer defense:

1. X OAuth identity verification (existing X account required)
2. Account age requirement (6 months)
3. Follower minimum (50)
4. IP cluster analysis
5. Vote rate-limiting (10 votes per user per day max)
6. Manual review of every promotion in first 90 days
7. Public abuse report channel (email + form)

**Detection signal:** sudden burst of upvotes for one account from accounts created within the past 7 days = automatic review hold.

## Whitelist Reviews

Quarterly. Hank (and any future mod team) reviews the Tier A list:

- Is any whitelisted account no longer relevant (e.g., quit journalism)? → Move to Tier B `is_active=false`
- Are any Tier B accounts now widely recognized public figures? → Promote to Tier A
- Has any account demonstrated egregious bad-faith (faked screenshots, plagiarized confirmed breaks)? → Remove or annotate

Outcomes logged in a public changelog at `/governance-log`.

## Initial Seed List (Working Draft)

To be finalized by Hank before Phase 1 launch. Working list (~25 candidates):

**Tier A (whitelisted at launch):**

1. Fabrizio Romano
2. David Ornstein
3. Florian Plettenberg
4. Nicolo Schira
5. Gianluca Di Marzio
6. Christian Falk
7. James Pearce (The Athletic)
8. Sam Lee (The Athletic)
9. Matt Law (Telegraph)
10. John Percy (Telegraph)
11. Sky Sports News (institutional)
12. BBC Sport (institutional)
13. ESPN FC (institutional)

**Tier B candidates (require review):**

14. CaughtOffside (aggregator, low credibility traditionally)
15. Indykaila News
16. Football Insider
17. The Mirror Football
18. Daily Mail Football
19. Sport Bible

The institutional accounts (Sky, BBC, ESPN) probably need separate handling since they aggregate multiple journalists' reporting. Decide before launch.

Hank picks the final list. The seed informs presentation only. The data eventually overwrites assumptions.
