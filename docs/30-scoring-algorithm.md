# Scoring Algorithm

## Overview

Two layers:

1. **Per-prediction score `S_i`.** A continuous value between roughly 0 and 3 that captures how impressive a single correct prediction was.
2. **Aggregate leaderboard score.** A Wilson-confidence-bounded accuracy rate that ranks predictors fairly across volume differences.

## Per-Prediction Score Formula

```
S_i = [ W_D * D_i + W_F * F_i ] * T(t_i) * CL_i
```

| Symbol | Meaning | Range |
|---|---|---|
| W_D | Destination weight | 0.75 (fixed) |
| W_F | Fee weight | 0.25 (fixed) |
| D_i | Destination accuracy | 0 or 1 |
| F_i | Fee accuracy | 0 to 1 |
| T(t_i) | Temporal bonus | 1.0 to 3.0 |
| CL_i | Consensus lag multiplier | 0 to 1 (dormant in MVP) |

### Destination Score D_i

Binary:
- `D_i = 1.0` if the predicted destination club exactly matches the actual destination
- `D_i = 0.0` otherwise

A loan move counts as a match if the predicted club hosts the loan, even if the parent club differs. A loan-to-buy move counts as a match for the host club.

### Fee Score F_i

Logarithmic falloff to prevent negative scores on wild misses:

```
F_i = max(0.0, 1.0 - ln(1.0 + |Fee_predicted - Fee_actual| / Fee_actual))
```

**Undisclosed fee fallback.** If `fee_was_undisclosed = true` and no estimate is published within 14 days:
- Set `W_F = 0`, `W_D = 1.0` for that prediction only
- The formula simplifies to `S_i = D_i * T(t_i) * CL_i`

**No fee predicted.** If the predictor did not state a fee, F_i = 0.50 (neutral). They cannot achieve a perfect score but are not penalized for omission.

### Temporal Bonus T(t_i)

Logistic curve. Rewards earlier predictions.

```
T(t_i) = 1.0 + L / (1.0 + e^(-α * (t_i - t_0)))
```

Where:
- `t_i` = days between prediction and official announcement
- `L = 2.0` (max bonus cap)
- `α = 0.08` (curve steepness)
- `t_0 = 15` (inflection at 15 days)

Sample values:

| Days early | T(t_i) |
|---|---|
| 0 (same day as announcement) | 1.23 |
| 7 | 1.46 |
| 15 (inflection) | 2.00 |
| 30 | 2.54 |
| 60 | 2.91 |
| 90+ | 2.98 (approaches asymptote) |

### Consensus Lag CL_i (Dormant in MVP)

```
CL_i = e^(-β * Δτ_i)
```

Where `Δτ_i` is hours between the earliest documented Tier 1 prediction of this transfer and the predictor's tweet, `β = 0.05`.

**Dormant in MVP because:**
- Tiers are derived from data after 6 months (see ADR 0005)
- No hardcoded Tier 1 list at launch

Until tiers are derived, `CL_i = 1.0` for all predictions. The formula collapses to `S_i = [W_D*D_i + W_F*F_i] * T(t_i)`.

## Aggregate Leaderboard Score

Per-prediction scores ranked in isolation reward spray-and-pray. An account posting 200 predictions and hitting 5 gets credit for those 5 with no penalty for the 195 misses.

Two corrections:

### Step 1: Raw Accuracy

```
raw_accuracy = sum(S_i for resolved_state='correct') / total_resolved
```

Where `total_resolved` = correct + incorrect + mitigated + deleted_by_author.

Deleted predictions count against the predictor. This is the practical replacement for the "Transparency Rating" in the strategy doc.

### Step 2: Wilson Lower Bound

Apply a Wilson score confidence interval at 95% on the raw accuracy. Use the lower bound for ranking. SQL implementation:

```sql
CREATE OR REPLACE FUNCTION wilson_lower(p NUMERIC, n INT)
RETURNS NUMERIC AS $$
DECLARE
    z CONSTANT NUMERIC := 1.96; -- 95% confidence
    denom NUMERIC;
    center NUMERIC;
    margin NUMERIC;
BEGIN
    IF n = 0 THEN RETURN 0; END IF;
    denom := 1 + (z * z / n);
    center := p + (z * z / (2 * n));
    margin := z * sqrt((p * (1 - p) / n) + (z * z / (4 * n * n)));
    RETURN (center - margin) / denom;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
```

### Step 3: Minimum Resolution Threshold

Predictors with fewer than 10 resolved predictions in the rolling 365-day window do not appear on the public leaderboard. They get a profile page with their predictions visible but no ranking.

## Worked Examples

### Example A: 2-for-2 account vs 50-for-100 account

- Account A: 2 correct predictions, 0 incorrect. Per-prediction average S_i = 2.0. Raw accuracy = 2.0. n=2.
- Account B: 50 correct, 50 incorrect. Per-prediction average on hits = 1.8. Raw accuracy = (50 * 1.8) / 100 = 0.9. n=100.

Naive ranking by raw accuracy: A wins (2.0 vs 0.9).

Wilson lower bound at 95% confidence:
- A: wilson_lower(p=2.0, n=2) — note p>1 is unusual since S_i exceeds 1 due to T(t_i). Normalize by dividing raw_accuracy by max-observed-S to bound to [0,1] before Wilson, or apply Wilson to (correct/total) and multiply by mean S separately. **Decision: separate the two.**
  - hit_rate_A = 2/2 = 1.0, wilson_lower(1.0, 2) ≈ 0.342
  - hit_rate_B = 50/100 = 0.5, wilson_lower(0.5, 100) ≈ 0.404
- Mean S per correct prediction: A=2.0, B=1.8
- Final rank score: hit_rate_wilson * mean_S_correct
  - A: 0.342 * 2.0 = 0.684
  - B: 0.404 * 1.8 = 0.727

**Result: B ranks above A.** The high-volume account with proven consistency beats the 2-for-2 outlier. This is the desired behavior.

Furthermore, A is below the 10-prediction minimum so does not appear on the leaderboard at all in MVP.

### Example B: 90-day-early prediction vs 1-day-before prediction

Both correct, same destination, fee both unstated (F_i = 0.5).

Prediction 1: made 90 days before announcement.
- D_i = 1.0, F_i = 0.5, T(90) ≈ 2.98, CL = 1.0
- S_i = (0.75*1.0 + 0.25*0.5) * 2.98 * 1.0 = 0.875 * 2.98 = 2.61

Prediction 2: made 1 day before announcement.
- D_i = 1.0, F_i = 0.5, T(1) ≈ 1.28, CL = 1.0
- S_i = 0.875 * 1.28 = 1.12

Ratio: the 90-day-early prediction scores 2.33x the 1-day-before one. Encodes the strategy doc's "3 months > 1 day" requirement.

### Example C: Undisclosed fee

Player joins predicted club, fee officially undisclosed, no media estimate after 14 days.

- D_i = 1.0, fee_was_undisclosed = true
- W_F = 0, W_D = 1.0
- T(30) = 2.54, CL = 1.0
- S_i = 1.0 * 1.0 * 2.54 * 1.0 = 2.54

Compare with a fully-specified prediction at the same horizon:
- Hypothetical: predicted fee was perfectly accurate (F_i = 1.0)
- S_i = (0.75*1.0 + 0.25*1.0) * 2.54 = 2.54

Same score. The fee component is neutralized. The predictor is not punished for the league/club's lack of fee disclosure.

## Tier Derivation (Phase 3, After 6 Months of Data)

After 6 months of resolved predictions:

1. Sort all predictors by Wilson-bounded rank score
2. Top decile = Tier 1
3. Next 30% = Tier 2
4. Bottom 60% = unrated

When tiers exist, CL_i activates:

```
CL_i = e^(-0.05 * Δτ_i)
```

Where `Δτ_i` is hours between the earliest Tier 1 prediction of the same transfer and this predictor's tweet. An aggregator copying a Tier 1 break 24 hours later scores at e^(-1.2) ≈ 0.30, losing 70% of their per-prediction score.

Re-evaluate tier composition every 90 days to allow movement.

## Edge Cases

- **Multiple correct predictions of the same transfer by one account.** Only the earliest counts. Later restatements ignored.
- **Predictor predicts both clubs in a derby.** Treated as two predictions. If player joins one, predictor gets one correct, one incorrect. Hedge strategy is penalized via the denominator.
- **Transfer falls through (no move happens by deadline).** `resolved_state = 'incorrect'`. Predicting a phantom transfer is wrong.
- **Player extends with current club.** Any "leaving" prediction goes `incorrect`. Any "staying" prediction (if we track those at all) goes `correct`. MVP scope: leaving predictions only.
- **Loan + obligation to buy.** Counts as a permanent move for the host club. Matches predictions of "joining" that club.
