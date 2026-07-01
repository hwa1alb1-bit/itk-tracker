# Sub-Phase 1A: Foundation

**Status:** Complete (with 3 non-blocking deferrals)
**Started:** 2026-06-29
**Completed:** 2026-07-01
**Path:** B (document-as-we-go)

Records what got built during 1A, what's deferred, and what remains open. Not a blueprint — a running log of actual provisioning outcomes.

## Goal

End 1A with a live, green-deploying Next.js site at `https://prizmview.app`, all external integrations wired end-to-end (GitHub → Vercel → CDN → DNS → Supabase → Cloudflare email), with a holding-page splash and SEO foundation in place. No user-facing features. All feature work happens in 1B onward.

## Exit Criteria

- [x] Supabase project provisioned with full schema applied
- [x] Next.js 16 App Router repo pushed to GitHub, builds green on Vercel
- [x] SEO scaffolding present: `robots.txt`, `sitemap.xml`, `llms.txt`, page metadata
- [x] AI crawler allow-list explicit in `robots.txt`
- [x] Cloudflare zone verified accessible for `prizmview.app` (zone tag `c7e14db3f6ea89f22659e754c0e32238`)
- [x] DNS: `prizmview.app` (A record) + `www.prizmview.app` (CNAME) pointed at Vercel
- [x] Vercel env vars set: Supabase URL/anon/service role, site URL (redeploy `dpl_B3iHaoNcrXiusk61egjTcWjaZKo7`)
- [x] Cloudflare Email Routing rules active: `appeals@`, `dmca@`, `corrections@` → `oneoddbob@gmail.com`
- [ ] **DEFERRED:** Cloudflare Email Sending — endpoint returns 404 in beta. Revisit via dashboard or use Resend fallback when Phase 1D/1E needs outbound
- [ ] **DEFERRED to Phase 1E:** Gmail "Send mail as" alias for `appeals@prizmview.app`
- [ ] **DEFERRED to Phase 1G (pre-launch):** DMCA agent registered with US Copyright Office ($6 filing)
- [x] SSL certificate active on both `https://prizmview.app` (308 → www) and `https://www.prizmview.app`

## Live Verification (2026-07-01)

- `https://www.prizmview.app` returns 200 OK with `<h1>Most Accurate Soccer Transfer Journalists</h1>`
- `https://prizmview.app` returns 308 to `https://www.prizmview.app/`
- HSTS header present, `Server: Vercel`, edge region iad1
- Latest production deployment `dpl_B3iHaoNcrXiusk61egjTcWjaZKo7` (redeploy after env vars set)

## What Got Built

### Supabase

- **Project:** `ITK-Tracker` (`gxbiedwhsvteirhisxai`)
- **Organization:** `oneoddbob@gmail.com's Org` (`pvevhaammisjfxbqrzxt`)
- **Region:** `us-east-1`
- **Postgres:** 17.6.1.127
- **URL:** `https://gxbiedwhsvteirhisxai.supabase.co`
- **Publishable keys:** legacy anon (JWT) + modern `sb_publishable_zYE_QMO2stSq_Om6AGRRjg_ysUU9lbd`
- **Migration applied:** `initial_schema` via Supabase MCP `apply_migration`. Includes all tables (`predictors`, `clubs`, `players`, `predictions`, `sheets_sync_queue`, `appeals`), the `prediction_state` enum, `predictor_stats` materialized view, indexes, and RLS policies from `docs/20-schema.sql`.

### GitHub

- **Repo:** [`hwa1alb1-bit/itk-tracker`](https://github.com/hwa1alb1-bit/itk-tracker) — public
- **Default branch:** `main`
- **Latest commit before 1A code:** `08aeb3a` (docs-only)
- **Scaffold commit:** `c2422e7` — Next.js 16 App Router foundation

### Next.js Scaffold

- **Framework:** Next.js 16.2.9 with Turbopack
- **React:** 19
- **TypeScript:** strict, `moduleResolution: bundler`
- **Styling:** Tailwind CSS 4 via `@tailwindcss/postcss`
- **Supabase client:** `@supabase/ssr` 0.7.0 + `@supabase/supabase-js` 2.58.0
- **Testing:** `vitest` 3 (installed, no tests yet)
- **Files created:**
  - `package.json`, `tsconfig.json`, `next.config.ts`, `postcss.config.mjs`
  - `app/layout.tsx`, `app/page.tsx`, `app/globals.css`
  - `app/robots.ts`, `app/sitemap.ts`
  - `public/llms.txt`
  - `lib/supabase/client.ts`, `lib/supabase/server.ts`
  - `.env.example`
- **Verified locally:** `npm install` (30s, 102 packages) + `npm run build` both clean. Four static routes generated: `/`, `/_not-found`, `/robots.txt`, `/sitemap.xml`.

### Vercel

- **Team:** `PLKNoko's projects` (`team_uZERsB7RBuE8AlDoUPRlw5zz`) — Hobby tier
- **Project:** `itk-tracker` (`prj_ci9uQSxZFQHlRwRimNHzjjDtOStx`)
- **Latest production deploy:** `dpl_8evtYHscJxhwBFgFLuNLXY6zXoG7` — `READY`
- **Current preview URL:** `itk-tracker-lyhz8sp7e-plknokos-projects.vercel.app`
- **Auto-deploy:** on every push to `main`

### SEO Foundation (per `docs/80-seo-aeo-strategy.md`)

- `robots.ts` explicitly allows GPTBot, ClaudeBot, Claude-Web, PerplexityBot, GoogleOther, Google-Extended, CCBot, and default `*`. Disallows `/mod/`. Sitemap pointer set to `https://prizmview.app/sitemap.xml`.
- `sitemap.ts` stub currently lists only the homepage. Will expand as pages ship in 1B/1C.
- `public/llms.txt` includes the AEO manifesto stub with brand positioning, key facts, and archival guarantees.
- `app/layout.tsx` sets `metadataBase`, title template, and default description at the root layout level.
- `app/page.tsx` sets an SEO-optimized H1 (`Most Accurate Soccer Transfer Journalists`) frontloading the target keyword.

## What's Deferred to Later Sub-Phases

- Any real DB queries (belongs in 1B/1C when the leaderboard and profile pages ship)
- Supabase Auth setup with moderator role claim (belongs in 1C when the mod dashboard is built)
- Make.com scenario creation (belongs in 1D when submissions start flowing)
- Backfilling seed predictors, clubs, players, and predictions (belongs in 1F)
- All real content pages: methodology, about, FAQ, facts, privacy, terms, DMCA, corrections (belongs in 1B)

## Open Blockers

### Cloudflare Zone Access

Wrangler CLI is authenticated as `hwa1.alb1@gmail.com` (account `06194d230f5a7d371ad30a1d984e0868`), a different email than `oneoddbob@gmail.com`. Need to confirm which Cloudflare account owns the `prizmview.app` zone before DNS records or Email Routing rules can be added.

Options once confirmed:
- If `hwa1.alb1@gmail.com` owns it, wrangler is ready
- If a different account owns it, either `wrangler logout && wrangler login` to switch, or manage DNS/Email through the dashboard directly

### Vercel Env Vars

Not blocking the build (the Supabase client is imported but not invoked on the holding page). Must be set before 1B leaderboard queries land:

- `NEXT_PUBLIC_SUPABASE_URL=https://gxbiedwhsvteirhisxai.supabase.co`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY=<legacy JWT anon key from Supabase MCP>`
- `SUPABASE_SERVICE_ROLE_KEY=<from Supabase dashboard — not exposed via MCP by design>`
- `NEXT_PUBLIC_SITE_URL=https://prizmview.app`

## Design Deviations From Original Plan

None significant. The scaffold matches the strategy in `docs/10-architecture.md` and `docs/80-seo-aeo-strategy.md`.

One micro-choice: `metadataBase` in `app/layout.tsx` reads `NEXT_PUBLIC_SITE_URL` with a `https://prizmview.app` fallback. Prevents SSR crashes if the env var isn't set locally.

## Verification

Manual verification steps for the finished 1A phase:

1. `curl -I https://prizmview.app` returns 200 with valid SSL
2. `curl https://prizmview.app/robots.txt` returns the AI-crawler allow-list
3. `curl https://prizmview.app/sitemap.xml` returns valid XML with the homepage entry
4. `curl https://prizmview.app/llms.txt` returns the AEO manifesto
5. Test email to `appeals@prizmview.app` from an external inbox arrives in `oneoddbob@gmail.com`
6. Vercel dashboard shows all four env vars marked with green checkmarks across Production/Preview/Development
7. Lighthouse score on `https://prizmview.app` mobile ≥90 across all four categories (Performance, Accessibility, Best Practices, SEO)

## Next Sub-Phase

**1C Mod Dashboard** is the next planned sub-phase per the phase order locked in on 2026-06-29 (`1A → 1C → 1F partial → 1B → 1D → 1E → 1F rest → 1G`). Rationale: seeding data through a UI beats seeding via raw SQL at any scale beyond a handful of rows.

Design doc for 1C to be written when 1A blockers are cleared.
