# ADR 0005: Data-Driven Tier Derivation, Not Hardcoded Tier 1

**Status:** Accepted (2026-06-29)
**Owner:** Hank

## Context

The original strategy doc included a "Consensus Lag Penalty":

> `CL_i = e^(-β * Δτ_i)` where `Δτ_i` is the time delta in hours between the earliest documented public prediction of this transfer by any verified Tier 1 source and the predictor's tweet.

The doc implied Tier 1 = a hardcoded list (Romano, Ornstein, etc.).

This has a chicken-and-egg problem:

1. We hardcode "Romano and Ornstein are Tier 1"
2. The consensus lag penalty fires against everyone else who posts the same prediction later
3. Other accounts cannot earn Tier 1 status because their lag penalty drags them down
4. The leaderboard ossifies around the hardcoded list

It also has a market-coverage problem. Hardcoding English-language Premier League journalists as the Tier 1 reference ignores:

- German press (Bild, Sky Deutschland) breaking Bundesliga moves first
- Brazilian press (Globo, UOL) breaking South American moves first
- Italian press (Di Marzio, Pedullà, Romeo Agresti) breaking Serie A moves first
- Local club beat reporters who often break their own team's moves before the international names

## Decision

No hardcoded Tier 1 list. The consensus lag penalty `CL_i` is dormant in MVP.

After 6 months of accumulated resolved predictions across 50+ active predictors, derive tiers from the data:

- **Tier 1:** top decile by Wilson-bounded rank score
- **Tier 2:** next 30%
- **Unrated:** bottom 60%

When tiers exist, activate `CL_i`:

```
CL_i = e^(-0.05 * Δτ_i)
```

Where `Δτ_i` is hours between the earliest documented Tier 1 prediction of this transfer and the predictor's tweet.

Re-derive tiers every 90 days to allow movement up and down.

Until the first derivation, `CL_i = 1.0` for every prediction.

## Consequences

**Positive:**

- No baked-in bias toward any region, language, or established outlet
- The leaderboard reflects observed accuracy, not assumed reputation
- Accounts can earn Tier 1 status through performance
- The system is defensible against "you're just promoting Romano" complaints

**Negative:**

- The consensus lag penalty is unavailable in the first 6+ months
- Until then, aggregators copying confirmed breaks score the same as the original reporter
- The data needs sufficient volume for the derivation to be meaningful. If we have only 50 resolved predictions after 6 months, tier statistics are noisy.

**Mitigations:**

- Per-prediction temporal bonus `T(t_i)` already heavily rewards early predictions. An aggregator posting 1 day before announcement gets `T ≈ 1.28` while an original break 30 days early gets `T ≈ 2.54`. The temporal layer alone provides significant signal during the dormant CL window.
- If data is insufficient at 6 months, postpone tier derivation. No bad data is better than bad data.

## Worked Example (After Derivation)

Assume after 6 months Tier 1 includes journalists J1 and J2.

Transfer scenario:
- J1 posts at T=0 hours: "Mbappé to Real Madrid, here we go!"
- Account A posts at T=2 hours, same prediction
- Account B posts at T=24 hours, same prediction

Consensus lag values:
- J1: Δτ = 0, CL = 1.0 (no penalty, they broke it)
- A: Δτ = 2, CL = e^(-0.1) ≈ 0.905 (small penalty)
- B: Δτ = 24, CL = e^(-1.2) ≈ 0.301 (large penalty, ~70% of score lost)

This incentivizes original breaking, penalizes copycats, and remains mathematically principled.

## Alternatives Considered

1. **Hardcode Tier 1 from the start.** Per critique above, ossifies the leaderboard. Rejected.
2. **Manual Tier 1 designation by Hank.** Reintroduces bias. Rejected.
3. **Permanent dormancy of `CL_i`.** Loses the signal against aggregators. Rejected as a permanent stance, but acceptable as the MVP default.
4. **Use a community-voted Tier 1 list.** Same Sybil/popularity problems as voting elsewhere. Rejected.

## Open Questions

- What if the derived Tier 1 is dominated by one outlet? (e.g., five Athletic journalists.) Acceptable if their accuracy genuinely justifies it. Worth annotating publicly.
- Should Tier 1 require a minimum prediction volume floor higher than the leaderboard threshold? Probably yes — proposed: 50 resolved predictions to qualify for Tier 1 consideration.
- How are journalist accounts vs institutional accounts (Sky Sports News, BBC Sport) handled? Probably treat institutional accounts as separate tier or exclude from the CL reference set since they re-publish individual journalists' work.

These get answered in a Phase 4 ADR when tier derivation actually goes live.
