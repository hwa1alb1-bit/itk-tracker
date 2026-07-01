# Open Questions

Running log of unresolved decisions. Each entry has a status and a decision owner.

## Q1: Domain (RESOLVED 2026-06-29)

**Status:** Resolved.
**Decision:** `prizmview.app` is dedicated to ITK Tracker. The Ops Dashboard plan for this domain is dropped.
**Action items:** Verify Hank has edit access to the `prizmview.app` zone on Cloudflare before Phase 1. Update Ops Dashboard project memory to reflect cancellation of the domain plan (handled in `project_ops_dashboard.md`).

## Q2: Moderator pool (RESOLVED 2026-06-29)

**Status:** Resolved.
**Decision:** Solo moderation by Hank for Phase 1. No volunteer team.

Implications baked into the design:

- Submission queue throughput capped at Hank's evening review capacity (estimated 10-30 per day)
- No moderator-consistency risk because there is only one decision-maker
- Vacation handling: a public banner pattern at the top of the site reads "Reviews paused until [date]" when Hank flags an away period via an env var or a single-row DB toggle
- Phase 2 voting reduces per-decision moderator burden by promoting accounts through the community rather than per-submission review
- A second moderator can be added later by adding a row to `predictors`-adjacent moderator table; the schema already supports `moderator_reviewed_by UUID` without per-mod RLS changes

## Q3: Initial seed list (RESOLVED 2026-06-29)

**Status:** Resolved on size and selection criteria.
**Decision:** Approximately 25 accounts. Selection ranked by X follower count and observed engagement on transfer reporting (a popularity-weighted proxy). Final ranked list lives in `docs/70-nomination-governance.md`. Hank can prune or add before Phase 1 launch.

## Q4: Frontend stack (RESOLVED 2026-06-29)

**Status:** Resolved.
**Decision:** Next.js (App Router, RSC). Picked at Claude's discretion per Hank's delegation.

Rationale:
- Largest ecosystem and best Supabase integration (Supabase docs are Next-first)
- Server components handle SEO-friendly leaderboard pages without client-side JS hydration cost
- Vercel-native deploy with zero config
- Memory note `feedback_rsc_h1_server_component_for_seo.md` documents the known SEO gotcha (H1 inside `'use client'` + `useSearchParams` + `<Suspense fallback={null}>` renders empty initial HTML); pattern to avoid is documented

Stack details:
- Next.js 16+ on App Router
- TypeScript strict mode
- Tailwind CSS for styling
- `@supabase/ssr` for Supabase Auth + queries
- shadcn/ui components (memory note `reference_shadcn_base_ui.md`: shadcn@latest uses Base UI, no `asChild` prop, use styled Link or render prop)

## Q5: Repo visibility (RESOLVED 2026-06-29)

**Status:** Resolved.
**Decision:** Public from day one. Push to `github.com/hwa1alb1-bit/itk-tracker` as public.

## Q6: Anti-Sybil at $0 (DEFERRED to Phase 2)

**Status:** Deferred.
**Decision:** Phase 1 has no public users and no voting surface. Sybil risk is zero in Phase 1.

Re-opens when Phase 2 design begins (browser extension + community voting). At that point, define:

- Vote rate limits per account per day
- Account-age minimum for voting eligibility
- IP cluster detection thresholds
- Vote-buying detection signals
- Voter-ban appeals process

## Q7: Make.com scenario consolidation (RECLASSIFIED as ops-monitoring task)

**Status:** Not a pre-launch decision. Operational verification post-launch.

The plan in [`docs/40-ingestion-pipeline.md`](docs/40-ingestion-pipeline.md) collapses four logical jobs into two Make.com scenarios using internal branching:

- Scenario 1: Wayback archival + archive.today + Google Sheets sync (parallel branches)
- Scenario 2: Daily deletion audit + moderator notifications (conditional routing)

Estimated ~600 ops/month within the 1,000 free-tier ceiling. The verification is whether real transfer-window traffic stays inside that ceiling.

Action after launch: check the Make.com ops dashboard at the end of every transfer window (January, summer). If usage projects above 80% of free tier two months in a row, either tighten branch logic or pay $9/mo for Make.com Core tier.

## Q8: Email infrastructure for appeals (RESOLVED 2026-06-29)

**Status:** Resolved. Cloudflare end-to-end.

**Decision:**

- **Inbound:** Cloudflare Email Routing forwards `appeals@prizmview.app`, `dmca@prizmview.app`, `corrections@prizmview.app` to Hank's existing inbox (`oneoddbob@gmail.com`). Free.
- **Outbound (transactional replies from the site):** Cloudflare Email Sending via Workers. Free tier. Sends from `noreply@prizmview.app` for automated confirmations.
- **Outbound (manual appeal responses):** Hank replies from Gmail with a "Send mail as" alias `appeals@prizmview.app` configured via SMTP. Cloudflare Email Routing supports outbound SMTP relay for verified domains.
- **DKIM / SPF / DMARC:** Managed via Cloudflare DNS automatically when Email Routing + Email Sending are enabled. No manual record entry needed.

Setup tasks (Phase 1 prep):

1. Verify Hank has edit access to the `prizmview.app` zone on Cloudflare
2. Enable Email Routing in the Cloudflare dashboard for `prizmview.app`
3. Add the three forwarding rules (appeals, dmca, corrections → oneoddbob@gmail.com)
4. Enable Email Sending and provision an API token for the Worker
5. In Gmail, configure "Send mail as" with the appeals@ alias
6. Test end-to-end: send to appeals@, confirm forwarding; reply from Gmail, confirm headers show appeals@prizmview.app as sender

The `cloudflare-email-service` skill in this Claude install covers the implementation details when Phase 1 build begins.
