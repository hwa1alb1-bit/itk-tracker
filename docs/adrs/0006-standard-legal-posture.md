# ADR 0006: Standard Public-Figure Legal Posture

**Status:** Accepted (2026-06-29)
**Owner:** Hank

## Context

Publicly ranking named journalists by "reliability" sits adjacent to defamation. The strategy doc proposed an aggressive "Transparency Rating" callout naming and shaming accounts that delete predictions, with a stated "% of predictions deleted" headline metric.

Hank confirmed the desired posture: US jurisdiction, public evidence only, standard public-figure protections, appeals process. Not aggressive name-and-shame, not consent-only opt-in.

## Decision

Adopt a "standard" legal posture defined as:

1. **Public-figure standard applied to known journalists.** Romano, Ornstein, and similar are public figures for purposes of soccer journalism. Reporting factual data about their public statements is protected speech under *NYT v. Sullivan*.

2. **Public evidence only.** Every tracked prediction is a public X tweet on a public account. Every resolution sources from publicly accessible URLs (Wikipedia, BBC, ESPN, official club channels).

3. **Methodology transparency.** The scoring algorithm, source list, and verification rules are published on a dedicated methodology page.

4. **Appeals process.** Any predictor can challenge a scored resolution via a public form. Documented response window of 14 days. Upheld appeals are recorded in a public changelog.

5. **Reframe deletion tracking.** Drop the headline "Transparency Rating" metric. Show deletion counts in a footnote with neutral framing ("N predictions are no longer publicly accessible"). The score impact is already encoded in the denominator.

6. **Removal rights for less-known accounts.** Tier B/C predictors (not Tier A whitelisted public figures) can opt out and have records deleted within 7 days.

7. **DMCA designated agent registered.** $6 one-time fee. Email and physical address public.

## Consequences

**Positive:**

- Legally defensible against the most likely complaint (a journalist demands removal)
- Public methodology builds credibility with both fans and journalists
- Appeals process is a pressure valve and a content marketing asset ("see our corrections log")
- Avoids the worst-case "Transparency Rating" framing that invites bad-faith reactions

**Negative:**

- Less viral than aggressive name-and-shame ("X deleted 36% of their predictions!" is a hot tweet)
- Some predictors will still send legal threats even with strong defenses; cost of responding is non-zero even if we win
- The 14-day appeals window adds moderator workload during transfer windows

## What This Does Not Cover

- **EU-resident journalists.** GDPR may give them deletion rights even if they're public figures under US law. MVP scope is US legal exposure only. Phase 4+ revisit if EU growth happens.
- **UK journalists.** UK libel law is plaintiff-friendly. If a UK-based journalist files in UK courts, US protections may not apply. Mitigation: no UK-targeted features, no marketing in UK media, server geolocation US-only.
- **Doxxing or harassment originating from the site.** If a predictor demonstrates the site is being used to harass them, that's a separate operational concern. Hank's call case-by-case, with bias toward predictor protection.

## Pre-Launch Legal Checklist

Mirrored in `50-legal-methodology.md`:

- [ ] Methodology page drafted
- [ ] Privacy policy drafted
- [ ] Terms of service drafted
- [ ] DMCA agent registered with US Copyright Office
- [ ] Appeals form tested end-to-end
- [ ] Cloudflare Email Routing (inbound) configured for `appeals@`, `dmca@`, `corrections@`
- [ ] Cloudflare Email Sending (outbound) provisioned for transactional replies
- [ ] Optional: pro-bono review by US attorney

## Alternatives Considered

1. **Aggressive name-and-shame ("Transparency Rating: 36% deleted").** Higher engagement, much higher legal risk. Rejected.
2. **Consent-only opt-in tracking.** Drastically smaller dataset. Whitelisted journalists wouldn't bother opting in. Rejected.
3. **Defer the legal decision until after data is collected.** "Build first, ask forgiveness later." Risky for a public site. Rejected.
4. **Operate from offshore jurisdiction.** Cloudflare + Vercel + Supabase all have US presence regardless of where Hank lives. Doesn't actually buy anything. Rejected.

## References

- *New York Times Co. v. Sullivan*, 376 U.S. 254 (1964)
- *Gertz v. Robert Welch, Inc.*, 418 U.S. 323 (1974) — public figure standard
- Section 230 of the Communications Decency Act
- US Copyright Office DMCA Designated Agent registry
