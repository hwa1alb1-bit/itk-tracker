# ITK Tracker

A public-facing accountability system for soccer transfer journalism. Tracks the prediction accuracy of "In The Know" (ITK) accounts on X, ranks them on a leaderboard, and exposes profile pages with verified historical calls.

## Status

**Phase 0: Planning.** This repository contains specifications, architecture decisions, and design notes only. No code yet.

## Why This Exists

The soccer transfer market is driven by real-time social-media reporting from journalists, aggregators, and anonymous ITK accounts. The ecosystem has no accountability layer. Predictors delete incorrect claims, post vague unfalsifiable hints, and copy verified information from elite sources while claiming original insight. This project measures and publishes who is actually accurate over time.

## How It Works

1. **Submission.** A user submits a prediction tweet via the website form (Phase 1) or browser extension (Phase 2). MVP does not use the X summon-bot model because the X API costs are out of scope at $0/month.
2. **Archival.** The tweet is immediately snapshotted to the Wayback Machine and archive.today to prevent "receipt wiping" via deletion.
3. **Moderator review.** A small mod team approves submissions into the tracking database.
4. **Resolution.** When the transfer concludes, moderators record the actual destination, fee, and a link to the official club announcement.
5. **Scoring.** A multi-criteria algorithm scores each prediction on destination accuracy, fee accuracy, prediction timing, and (eventually) consensus lag.
6. **Leaderboard.** Accounts are ranked by a Wilson-confidence-bounded accuracy score, scoped by global, league, and country views.

## Repo Map

- `docs/00-vision.md` — Problem, audience, success metrics
- `docs/10-architecture.md` — System diagram, services, deploy targets
- `docs/20-schema.sql` — PostgreSQL DDL for Supabase
- `docs/20-schema-notes.md` — Field-by-field rationale
- `docs/30-scoring-algorithm.md` — Formula, Wilson interval, worked examples
- `docs/40-ingestion-pipeline.md` — Submission flow + Make.com scenarios
- `docs/50-legal-methodology.md` — US posture, public-figure standard, appeals process
- `docs/60-roadmap.md` — Phased budget unlocks
- `docs/70-nomination-governance.md` — How accounts get on and off the tracker
- `docs/80-seo-aeo-strategy.md` — SEO + AEO/GEO requirements applied at Phase 1 build time
- `docs/adrs/` — Architecture Decision Records
- `open-questions.md` — Unresolved decisions

## Constraints

- Budget: $0/month. Free tiers only.
- Jurisdiction: United States. Public-figure standard, public evidence only.
- Stack: Cloudflare DNS, Vercel hobby frontend, Supabase free Postgres, Make.com free workflow engine.

## Contributing

Phase 0 is doc-only. Open an issue or PR against any spec doc. Do not write code yet.

## License

MIT. See `LICENSE`.
