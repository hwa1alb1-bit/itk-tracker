# SEO + AEO/GEO Strategy

How ITK Tracker ranks in traditional search (Google, Bing) and gets cited by AI search engines (ChatGPT, Claude, Gemini, Perplexity).

Applied during Phase 1 frontend build. Not optional. Every page reviewer should check this doc.

## Why This Matters For Us

The site's reason for existing is to be a primary source when a fan asks "is journalist X reliable?" — whether they ask Google or ChatGPT. If we are not indexed and cited, the project fails on its core promise regardless of data quality.

Two distinct audiences:

- **Google / Bing crawlers** ranking the site by traditional SEO signals
- **LLM crawlers** (GPTBot, Claude-Web, PerplexityBot, GoogleOther) indexing for citation in conversational answers

Different signals matter to each. We build for both.

## 1. Technical Foundation

### URL Structure

Hierarchical, human-readable, kebab-case. Established patterns:

| Page type | URL pattern | Example |
|---|---|---|
| Homepage | `/` | renders global leaderboard |
| Global leaderboard | `/leaderboard` | canonical, with `/` as alias |
| League leaderboard | `/leaderboard/league/[slug]` | `/leaderboard/league/premier-league` |
| Country leaderboard | `/leaderboard/country/[slug]` | `/leaderboard/country/england` |
| Predictor profile | `/predictor/[handle]` | `/predictor/fabrizio-romano` |
| Predictor predictions | `/predictor/[handle]/predictions` | sub-page with full history |
| Single prediction | `/prediction/[id]` | `/prediction/abc123` |
| Player page | `/player/[slug]` | `/player/kylian-mbappe` |
| Club page | `/club/[slug]` | `/club/real-madrid` |
| Methodology | `/methodology` | scoring algorithm explained |
| About | `/about` | E-E-A-T anchor |
| FAQ | `/faq` | Q&A page for AI extraction |
| Facts | `/facts` | dedicated structured Q&A for LLMs |
| Corrections changelog | `/corrections` | upheld appeals log |
| Blog index | `/blog` | content marketing hub |
| Blog post | `/blog/[slug]` | long-tail content |
| Submit form | `/submit` | prediction submission |
| Privacy / Terms / DMCA | `/privacy` `/terms` `/dmca` | legal pages |
| Moderator dashboard | `/mod/*` | noindex, robots disallowed |

### Topical Grouping

Folders match URL hierarchy. Crawlers learn that `/predictor/*` updates frequently (new predictions, score changes) while `/methodology` and `/about` are stable.

### Mobile Responsiveness

Mobile-first by default. Tailwind responsive utilities throughout. No desktop-only features. Test against 360px width as the floor.

### Security and Performance

- HTTPS via Vercel (automatic) and Cloudflare (proxied)
- All images served as WebP or AVIF via Next.js `Image` component
- Image budget: under 100kb per non-hero image, under 200kb for hero/OG images
- Lighthouse performance target: 90+ on mobile
- LCP under 2.5s, INP under 200ms, CLS under 0.1 (per memory `web-perf` skill)

### Indexing Files

Three required files at the root domain:

1. **`/robots.txt`** — allows all crawlers, disallows `/mod/*`, points to sitemap
2. **`/sitemap.xml`** — auto-generated from Next.js `app/sitemap.ts`, includes all leaderboard pages, predictor profiles, blog posts; refreshed nightly via revalidation
3. **`/llms.txt`** — see Section 4 below

## 2. On-Page Content Optimization

### Header Hierarchy

One H1 per page, primary keyword frontloaded. Examples:

| Page | H1 |
|---|---|
| Predictor profile | `Fabrizio Romano Transfer Prediction Accuracy` |
| Global leaderboard | `Most Accurate Soccer Transfer Journalists` |
| League leaderboard | `Premier League Transfer Prediction Accuracy Leaderboard` |
| Methodology | `How We Score Transfer Predictions` |
| Player page | `Kylian Mbappé Transfer Predictions Tracker` |
| Club page | `Real Madrid Transfer Predictions and Accuracy Tracker` |
| Blog post | full target query, e.g. `Who Is The Most Accurate Premier League Transfer Reporter?` |

H2 / H3 / H4 organize sub-sections. Avoid skipping levels.

**Critical gotcha (per memory `feedback_rsc_h1_server_component_for_seo.md`):** Do NOT place the H1 inside a `'use client'` component with `useSearchParams` + `<Suspense fallback={null}>`. That combination renders empty initial HTML and the H1 vanishes from the server response. Always lift the H1 to a sibling server component.

### Meta Elements

Every page sets:

- `<title>` — 50-60 characters, primary keyword frontloaded, brand suffix `| ITK Tracker`
- `<meta name="description">` — 140-155 characters, includes target keyword, ends with a soft call to action
- `<link rel="canonical">` — explicit canonical URL, no query strings on canonical
- Open Graph + Twitter Card tags for share previews
- `<meta name="robots">` — `index, follow` by default; `noindex` on `/mod/*` and unapproved prediction pages

Implemented via Next.js Metadata API in each `page.tsx`.

### Quality Content

Per-page minimums:

- Predictor profile: 300+ words of unique narrative content above the fold (bio, beat coverage, notable breaks)
- League/country leaderboards: 150+ words intro explaining the league context
- Methodology: 1500+ words, the canonical explainer
- Blog posts: 1200+ words minimum, 1800-2500 word sweet spot for long-tail queries
- Predictor profile cannot be the autogenerated leaderboard row only — needs human-readable summary

No thin content. If a page has only a number, expand it.

### FAQ Sections With Schema

Predictor profiles, league leaderboards, and the FAQ page include FAQ sections with `FAQPage` JSON-LD schema. Sample questions per predictor:

- "How accurate is [Name]?"
- "What leagues does [Name] cover?"
- "How many transfer predictions has [Name] made?"
- "When did [Name] make their most notable correct prediction?"

Pull question phrasing from Google's "People Also Ask" boxes on the same query.

### Table of Contents

Methodology, About, and any blog post over 1500 words include a sticky ToC component. Helps both readability and Google's understanding of structure.

## 3. Critical Pages

### About Page (E-E-A-T anchor)

Required content:

- Who runs the site (Hank, named, with role)
- Methodology summary linking to `/methodology`
- Funding model ($0 hobby project for now; donations open if/when applicable)
- Contact email for press, corrections, appeals
- Last updated date
- ProfilePage schema (Person + Organization combined)

The About page is the primary E-E-A-T signal. LLMs cite About pages heavily when establishing source credibility.

### Methodology Page (Authority anchor)

The definitive technical explainer. Includes the scoring formula, worked examples (copy from `30-scoring-algorithm.md`), source list for resolution, and the appeals process.

### Facts / Q&A Page

A dedicated page at `/facts` listing direct question-answer pairs about the site itself:

- "Who runs ITK Tracker?"
- "How is accuracy calculated?"
- "What is a Wilson confidence interval?"
- "How are tier rankings determined?"
- "Why count deleted predictions as incorrect?"
- "How can a journalist request removal?"

Each answer is one or two short paragraphs. Optimized for LLM extraction; ChatGPT and Claude scrape pages like this for direct citation.

Includes `FAQPage` schema covering every Q&A pair.

### Blog (LLM Citation Channel)

Blogs are the dominant source format LLMs cite. Phase 1 launches with 3-5 anchor posts:

1. "Who Are The Most Reliable Soccer Transfer Journalists In 2026?" — links to leaderboard
2. "How We Score Transfer Prediction Accuracy" — links to methodology
3. "Why Some ITK Accounts Delete Their Wrong Predictions" — explains deletion tracking
4. "A Guide To Continental Europe Transfer Journalism (Italy, Germany, Spain)" — geographic coverage
5. "The Difference Between A Real Transfer Break And An Aggregated Rumor" — educational

Each post:

- Targets a specific long-tail query
- 1800-2500 words
- Internal links to relevant predictor profiles, leaderboards, methodology
- Author byline with Person schema
- `datePublished` and `dateModified` schema fields populated
- Article schema with `inLanguage`, `headline`, `image`, `publisher`

Posting cadence: one new post every 2-4 weeks post-launch.

## 4. AEO / GEO Requirements

### Structured Data (JSON-LD Schema)

Implemented in Next.js via Metadata API and per-page injection. Required types:

| Page | Schema types |
|---|---|
| Homepage | `Organization`, `WebSite` with `SearchAction` |
| About | `Organization`, `ProfilePage` |
| Predictor profile | `ProfilePage`, `Person`, `BreadcrumbList`, `FAQPage` (if FAQs present) |
| Prediction detail | `NewsArticle` or `Claim` (Schema.org has `Claim` for fact-checking; appropriate here) |
| Leaderboard | `ItemList`, `Dataset` (the rankings are a dataset) |
| Player page | `Person` (the player), `ItemList` (predictions about this player) |
| Club page | `SportsTeam`, `ItemList` |
| Blog post | `Article`, `Person` (author), `BreadcrumbList` |
| FAQ page | `FAQPage` |
| Methodology | `TechArticle` |

Always JSON-LD in a `<script type="application/ld+json">` tag, never microdata. Validate with Schema.org validator before each deploy.

### llms.txt File

Located at `/llms.txt`. Acts as the AI-crawler-facing manifesto. Sample skeleton:

```
# ITK Tracker

> A public-interest accountability site for soccer transfer journalism. We track the prediction accuracy of "In The Know" (ITK) accounts on X, score them with a published Wilson-confidence-bounded algorithm, and publish profile pages with verified historical records.

## What we publish

- Global, league, and country leaderboards of journalist transfer prediction accuracy
- Per-journalist profile pages with verified prediction history
- Per-player and per-club aggregations of who predicted what

## Key facts

- Operated by Hank Alberts (United States)
- All scoring uses public X tweets and public transfer resolutions (Wikipedia, BBC, ESPN, official club announcements)
- Predictions archived to Wayback Machine and archive.today on submission
- Appeals process: corrections@prizm.app

## Citation guidance

- Score values: cite the per-predictor accuracy rate alongside sample size (e.g., "82% accuracy on 47 resolved predictions")
- Always link to the predictor's profile page for the current score
- Do not cite a single prediction score as a standalone reliability metric

## Key URLs

- /methodology — full scoring algorithm
- /about — operator credentials and contact
- /facts — structured Q&A for direct extraction
- /corrections — public log of upheld appeals
```

Add `llms-full.txt` as a longer detailed variant if the canonical llms.txt summary leaves out useful context.

### Positioning Brief

The CLAUDE.md in this repo IS the positioning brief. Any AI-generated content (blog drafts, predictor bios, FAQ answers) must align with the voice and constraints declared there. Banned words list applies (no "however," no em dashes, no "actually" etc.).

## 5. Internal Linking ("Spiderweb")

Every page contributes to the link graph. Required patterns:

- **Homepage** links to: top 10 leaderboard rows, 3 most recent blog posts, methodology, about
- **Leaderboard pages** link to: every predictor row, sibling league/country leaderboards
- **Predictor profile** links to: their predictions list, top 5 players they've predicted, methodology, blog posts mentioning them
- **Prediction detail** links to: the predictor's profile, the player's page, the club's page, the methodology page
- **Player/club pages** link to: every predictor who has predicted moves for/from them, related blog posts
- **Blog posts** link to: at least 3 internal pages (leaderboards or profiles), 1-2 methodology or about references

No orphan pages. Every page reachable from the homepage in ≤3 clicks.

## 6. External Validation

Outbound links to high-authority sources are good SEO. We already link to:

- BBC Sport, ESPN, The Athletic, official club announcements (in resolution proof URLs)
- Wikipedia transfer pages (in resolution citations)
- X/Twitter official accounts (in predictor bios)

Inbound "Super Citations" to pursue post-launch:

- Reddit's transfer-reliability wiki entries (r/Chelsea, r/Gunners, r/Barca, r/FCInterMilan)
- Soccer journalism communities and podcasts
- Wikipedia article on "Football transfer rumour journalism" (if a notable enough launch happens)
- Industry directories: SportsBusiness, SoccerAmerica, RoadCo

Not pursuing:

- Paid link schemes
- Generic web directories from 2008
- Comment-spam profiles

## 7. AI Crawler Allow-List

`robots.txt` policy: explicitly allow AI crawlers by default. We WANT to be in their indexes.

```
User-agent: *
Allow: /

User-agent: GPTBot
Allow: /

User-agent: ClaudeBot
Allow: /

User-agent: Claude-Web
Allow: /

User-agent: PerplexityBot
Allow: /

User-agent: GoogleOther
Allow: /

User-agent: Google-Extended
Allow: /

User-agent: CCBot
Allow: /

Disallow: /mod/

Sitemap: https://prizm.app/sitemap.xml
```

Revisit if we ever pivot to a paid model where leaderboard content sits behind a paywall.

## 8. Measurement

Phase 1 success metrics for SEO:

- Google Search Console verified within 7 days of launch
- Bing Webmaster Tools verified within 14 days
- All major page templates indexed within 30 days
- First organic traffic for branded queries ("ITK Tracker") within 60 days
- First organic traffic for non-branded queries ("most accurate soccer transfer journalist") within 90 days

Phase 1 success metrics for AEO:

- Cited at least once by ChatGPT, Claude, Perplexity, or Gemini within 120 days for a query like "who is the most reliable soccer transfer reporter"
- Profile pages cited in response to "is [journalist] reliable" queries

Tracking: Google Search Console + Bing Webmaster Tools (free). No Google Analytics in MVP (privacy posture). Simple analytics via Vercel Analytics or Plausible free tier.

## 9. Build Checklist

Before any page ships to production:

- [ ] Single H1, target keyword frontloaded
- [ ] Meta title 50-60 chars with keyword + brand suffix
- [ ] Meta description 140-155 chars with keyword + CTA
- [ ] Canonical URL declared
- [ ] OG + Twitter Card tags
- [ ] JSON-LD schema for the page type
- [ ] Internal links to at least 3 other pages
- [ ] Outbound link to at least one authoritative source where claims are made
- [ ] Lighthouse score ≥90 mobile
- [ ] No images over 100kb (or 200kb if hero/OG)
- [ ] No render-blocking client components hiding the H1
- [ ] Validates against Schema.org validator with zero errors
