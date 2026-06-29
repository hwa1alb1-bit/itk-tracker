# ADR 0004: Wilson Lower Bound for Aggregate Accuracy Scoring

**Status:** Accepted (2026-06-29)
**Owner:** Hank

## Context

The original strategy doc proposed a per-prediction score `S_i` and used it directly for ranking. This was the algorithm:

```
S_i = [W_D * D_i + W_F * F_i] * T(t_i) * CL_i
```

with `D_i` for destination accuracy, `F_i` for fee accuracy, `T(t_i)` for temporal bonus, `CL_i` for consensus lag.

The doc did not specify how `S_i` values aggregate to a leaderboard rank. The implication was sum or average.

This is gameable in two opposite ways:

**Spray-and-pray:** Account posts 200 predictions in a transfer window. Five hit. Per-prediction `S_i` for hits is fine. Sum across hits is competitive. The 195 misses are invisible to the score.

**Low-volume jackpot:** Account posts 2 predictions, both hit at high `T(t_i)` because they were posted weeks early. Per-prediction average is high. Account tops the leaderboard despite having a tiny sample size.

Both are credibility-destroying outcomes.

## Decision

Two-step aggregate score:

1. Compute hit rate as `correct / total_resolved`, where `total_resolved` includes correct, incorrect, mitigated, and `deleted_by_author`.
2. Apply Wilson score confidence interval at 95% confidence. Use the lower bound.
3. Multiply the Wilson lower bound by the mean `S_i` of correct predictions to get the final rank score.
4. Predictors with fewer than 10 resolved predictions in the rolling 365-day window do not appear on the leaderboard at all.

Wilson lower bound formula (95% confidence, z=1.96):

```
WL(p, n) = (p + z²/2n - z * sqrt((p(1-p) + z²/4n) / n)) / (1 + z²/n)
```

For low-volume accounts, the Wilson lower bound is pulled aggressively toward zero. For high-volume accounts with steady accuracy, the lower bound approaches the actual rate.

## Consequences

**Positive:**

- Spray-and-pray is penalized: the denominator grows faster than the numerator
- Low-volume accounts cannot top the leaderboard on a fluky 2-for-2 record
- Statistically principled: Wilson is the standard for ranking with confidence intervals (used in production by Reddit's "Best" comment sort)
- Deleted predictions count against the account, replacing the original "Transparency Rating" metric in a more defensible way

**Negative:**

- Less intuitive than "% correct". Methodology page must explain it clearly.
- A predictor who is genuinely accurate but only posts 2 predictions/year will sit below loud-but-decent volume players. This is a feature, not a bug, but expect complaints.
- The 10-resolution minimum delays new accounts' visibility on the leaderboard.

## Worked Example

Account A: 2 correct, 0 incorrect, mean S_i on correct = 2.0
- hit_rate = 1.0, n=2
- wilson_lower(1.0, 2) ≈ 0.342
- rank_score = 0.342 * 2.0 = 0.684

Account B: 50 correct, 50 incorrect, mean S_i on correct = 1.8
- hit_rate = 0.5, n=100
- wilson_lower(0.5, 100) ≈ 0.404
- rank_score = 0.404 * 1.8 = 0.727

B ranks above A even though A's raw hit rate is higher. Volume of proven accuracy beats outlier results.

## Implementation

A PostgreSQL function `wilson_lower(p NUMERIC, n INT) RETURNS NUMERIC` defined in the schema. Used in a SQL view that drives the leaderboard:

```sql
CREATE VIEW leaderboard AS
SELECT
    predictor_id,
    x_username,
    total_correct,
    total_resolved,
    sum_score_correct,
    (total_correct::numeric / NULLIF(total_resolved, 0)) AS raw_hit_rate,
    wilson_lower(total_correct::numeric / NULLIF(total_resolved, 0), total_resolved) AS wilson_hit_rate,
    sum_score_correct / NULLIF(total_correct, 0) AS mean_score_correct,
    wilson_lower(total_correct::numeric / NULLIF(total_resolved, 0), total_resolved) *
        (sum_score_correct / NULLIF(total_correct, 0)) AS rank_score
FROM predictor_stats
WHERE total_resolved >= 10
ORDER BY rank_score DESC NULLS LAST;
```

## Alternatives Considered

1. **Bayesian smoothing (Laplace prior).** Add fake "successes" and "failures" before computing rate. Simpler than Wilson but less statistically grounded. Rejected in favor of the better-known method.
2. **Bayesian beta-binomial credible intervals.** More flexible but adds parameters to tune (prior strength). Wilson is parameter-free. Rejected for complexity.
3. **Hard volume minimum + simple % correct.** Just require 50 resolved predictions and rank by hit rate. Rejected: bypasses the statistical-significance question entirely.
4. **Trust user judgment via dropdown filters (sort by hit rate, sort by volume, etc.).** Punts the problem to users. Rejected: the default sort is what most users see; it must be defensible.

## References

- Wilson, E. B. (1927). "Probable inference, the law of succession, and statistical inference."
- Evan Miller's "How Not To Sort By Average Rating" (2009) — popularized Wilson for product ranking.
