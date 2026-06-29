# ITK Tracker

Planning + spec repo for a soccer transfer prediction accountability site. Phase 0 is doc-only. No code yet.

## Skill Defaults (Not Optional)

Three skills are mandatory for this project. Invoke the relevant skill via the Skill tool before starting any work in the matching category.

| Task type | Skill to invoke | Trigger words |
|---|---|---|
| Development work (writing code, adding features, refactoring) | `tdd` | "build", "implement", "add", "refactor", "feature" |
| Bugs and errors (failing tests, runtime errors, broken behavior) | `diagnosing-bugs` | "broken", "failing", "error", "diagnose", "debug" |
| UI / UX work (frontend design, visual polish, accessibility) | `impeccable` | "design", "polish", "layout", "visual", "UI", "UX" |

Rules of engagement:

1. Invoke the matching skill before writing any code or making non-trivial design decisions.
2. If a task spans categories, invoke the process skill first (`tdd` or `diagnosing-bugs`), then the domain skill (`impeccable`).
3. User-typed slash commands `/tdd`, `/diagnosing-bugs`, `/impeccable` invoke the same skills.

## Status

Phase 0: planning only. Specs live in `docs/`. ADRs in `docs/adrs/`. Unresolved decisions in `open-questions.md`. Re-read the plan file (in `~/.claude/plans/`) for context on strategic pivots from the original strategy doc.

## Project Conventions

- $0/month operating budget until Phase 3
- Free tiers only: Cloudflare DNS, Vercel hobby, Supabase free Postgres, Make.com free workflow engine, GitHub free
- Public evidence only. US jurisdiction. Public-figure legal posture with appeals process
- Domain: `prizm.app` (dedicated to this project; the Ops Dashboard plan for this domain is dropped)
- Frontend stack: Next.js (App Router, RSC) + TypeScript strict + Tailwind + shadcn/ui + `@supabase/ssr`
- GitHub repo: `github.com/hwa1alb1-bit/itk-tracker` (public)
- All secrets in env vars, never hardcoded
- GitHub identity for personal repos: handle `hwa1alb1-bit`, commit email `oneoddbob@gmail.com`

## Phase 1 Build Requirements

Before writing any frontend code in Phase 1:

- Read [docs/80-seo-aeo-strategy.md](docs/80-seo-aeo-strategy.md) end-to-end.
- Every new page must pass the build checklist in Section 9 of that doc before merging.
- SEO and AEO/GEO are not retrofit. They are first-class concerns applied at template design time.

## What Not To Do

- Do not write code in Phase 0. The deliverable is specs.
- Do not propose Sportmonks, third-party scraper APIs, or X paid API solutions in Phase 1 designs (see ADR 0001).
- Do not propose self-hosted tweet screenshots (see ADR 0003).
- Do not propose hardcoded Tier 1 lists in the scoring algorithm (see ADR 0005).
- Do not propose "Transparency Rating" as a headline metric (see ADR 0006).
