# Open Questions

Running log of unresolved decisions. Each entry has a status and a decision owner.

## Q1: Domain (RESOLVED 2026-06-29)

**Status:** Resolved.
**Decision:** `prizm.app` is dedicated to ITK Tracker. The Ops Dashboard plan for this domain is dropped.
**Action items:** Verify Hank has edit access to the `prizm.app` zone on Cloudflare before Phase 1. Update Ops Dashboard project memory to reflect cancellation of the domain plan (handled in `project_ops_dashboard.md`).

## Q2: Moderator pool

**Status:** Open. Affects Phase 1 throughput.
**Owner:** Hank.

Just Hank, or a small trusted volunteer team? Solo moderation caps submission throughput at whatever Hank can review in evenings. A team of 3 to 5 trusted users scales but introduces consistency risk.

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

## Q6: Anti-Sybil at $0

**Status:** Provisionally resolved. Revisit before Phase 2.
**Owner:** Hank.

MVP uses moderator approval for new account nominations. User voting returns in Phase 2 alongside the browser extension. Open question: what abuse threshold triggers a voter ban, and who reviews appeals?

## Q7: Make.com scenario consolidation

**Status:** Open. Affects ingestion pipeline design.
**Owner:** Hank (after first scenario build).

Free tier allows 2 active scenarios. Plan calls for consolidating Wayback + Sheets mirror into one scenario, and deletion audit + moderator notification into the other. Verify the consolidation does not break the 1,000 ops/month budget in practice during the first transfer window.

## Q8: Email infrastructure for appeals

**Status:** Open. Needed before Phase 1 ships.
**Owner:** Hank.

Appeals process requires a documented inbox. Options:

1. Cloudflare Email Routing forwards `appeals@prizm.app` to Hank's existing inbox. Free.
2. Resend or similar transactional email for outbound replies. Free tier likely sufficient.

Memory note `reference_resend_auto_configure.md` flags Resend Auto Configure as the fastest path for DKIM/SPF/DMARC setup.
