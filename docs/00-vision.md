# Vision

## Problem

Soccer transfer journalism on X is a high-volume, low-accountability information market. Predictors operate without consequences for being wrong:

- Incorrect predictions are quietly deleted, leaving only the hits visible.
- Vague language ("close to," "advanced talks," "monitoring") is unfalsifiable.
- Aggregator accounts copy verified breaks from elite sources minutes later, claiming original insight.
- Fans cannot distinguish reliable journalists from clickbait without doing manual research per account.

Fan communities have built informal "transfer reliability guides" on Reddit (r/Chelsea, r/Gunners, r/Barca, r/FCInterMilan) but these are subjective, episodic, and not interlinked across fanbases.

## Audience

Three primary user groups:

1. **Soccer fans** wanting to vet a tweet before believing or sharing it. Needs: leaderboard scoped by team or league, quick profile lookups, mobile-friendly UI.
2. **Aspiring journalists** wanting a track record they can point to. Needs: profile page with verifiable history, embeddable scorecard, accuracy stats over time.
3. **Established journalists** wanting differentiation from aggregators. Needs: opt-in inclusion, appeals process for misclassified resolutions, transparent methodology.

## Success Metrics

Phase 1 (Website MVP):

- 30 seeded accounts with at least 10 resolved predictions each within 6 months of launch
- Leaderboard page loads under 1 second from CDN cache
- Zero successful defamation or DMCA challenges

Phase 2 (Browser extension):

- 100 active extension installs
- Submission friction down by 50% measured as time from tweet view to confirmed submission

Phase 3 (X bot + Sportmonks):

- 200+ summons per month sustained
- Automated ground truth verification on 80%+ of predictions
- Self-sustaining via donations or sponsorship covering ~$300/month infrastructure

## Non-Goals

- Predicting transfers (this is a measurement tool, not a forecasting service).
- Real-time betting odds (not a gambling product).
- Private DM tracking or anonymous sourcing (public evidence only).
- Replacing established outlets (this is a layer on top of journalism, not a replacement).

## Guiding Principles

1. **Public evidence only.** Every tracked prediction must be a public statement on a public account.
2. **Transparent methodology.** The scoring algorithm, source list, and verification rules are published.
3. **Appeals are real.** Any predictor can challenge a scored resolution. Documented response window.
4. **Data over intuition.** Tiers, weights, and thresholds get adjusted based on observed accuracy distributions, not vibes.
5. **Minimum-viable-cost.** Run on free tiers until the data proves the project deserves paid infrastructure.
