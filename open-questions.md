# Open Questions

Running log of unresolved decisions. Each entry has a status and a decision owner.

## Q1: Domain conflict with Ops Dashboard

**Status:** Open. Blocking Phase 1.
**Owner:** Hank.

`prizmview.app` was previously planned as the deploy target for the personal Ops Dashboard (FastAPI + SQLite + APScheduler). Three options:

1. Repoint apex to ITK tracker. Cleanest URL.
2. Subdomain split. ITK at `itk.prizmview.app`, Ops at `ops.prizmview.app` or apex.
3. Different spare domain for ITK.

Need to verify `prizmview.app` is on a Cloudflare account Hank can edit (memory note `project_prizm_cloudflare_access_blocked.md` flags a separate zone as blocked).

## Q2: Moderator pool

**Status:** Open. Affects Phase 1 throughput.
**Owner:** Hank.

Just Hank, or a small trusted volunteer team? Solo moderation caps submission throughput at whatever Hank can review in evenings. A team of 3 to 5 trusted users scales but introduces consistency risk.

## Q3: Initial seed list

**Status:** Open. Needed before Phase 1 ships.
**Owner:** Hank.

Which 20 to 30 ITK accounts get tracked at launch? Candidates by reputation:

- Tier 1 candidates: Fabrizio Romano, David Ornstein, Florian Plettenberg, Nicolo Schira, Gianluca Di Marzio, Christian Falk
- Tier 2 candidates: James Pearce (Athletic Liverpool), Sam Lee, Matt Law, John Percy
- Aspiring / community-nominated: TBD

Hank picks the launch list. The seed list informs presentation only. It does not affect scoring (tiers are derived from data).

## Q4: Frontend stack

**Status:** Open. Decide before Phase 1 begins.
**Owner:** Hank.

Next.js, SvelteKit, or Astro. All free on Vercel hobby. Decision criteria:

- Next.js: largest ecosystem, best Supabase integration, RSC supports SEO-friendly leaderboard
- SvelteKit: smaller bundle, simpler mental model
- Astro: best for content-heavy static pages, ship-zero-JS by default

Per memory `feedback_rsc_h1_server_component_for_seo.md`, Next.js SEO requires careful server-vs-client component boundaries.

## Q5: Repo visibility

**Status:** Open. Decide before first push to GitHub.
**Owner:** Hank.

Public from day one (community contributions, transparency-by-design) or private until Phase 1 ships (avoid public commitment to half-baked specs)?

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

1. Cloudflare Email Routing forwards `appeals@prizmview.app` to Hank's existing inbox. Free.
2. Resend or similar transactional email for outbound replies. Free tier likely sufficient.

Memory note `reference_resend_auto_configure.md` flags Resend Auto Configure as the fastest path for DKIM/SPF/DMARC setup.
