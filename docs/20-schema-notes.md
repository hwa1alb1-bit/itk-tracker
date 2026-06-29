# Schema Notes

Field-by-field rationale for the schema in `20-schema.sql`. Read alongside the SQL.

## `predictors` table

**Why UUID for `id`?** Stable across migrations, opaque to URLs, no enumeration attacks if profile slugs use the ID directly. UUID v4 is fine (no need for time-ordered v7 at this scale).

**Why both `x_user_id` and `x_username`?** Usernames change. The numeric `x_user_id` is X's stable internal identifier and lets us survive renames without losing history.

**No `tier_rating` field.** Tiers are derived from the data after 6 months. Storing a static tier seeds bias. See ADR 0005.

**No `reliability_score` field.** Aggregate accuracy lives in the `predictor_stats` materialized view, recomputed on resolution. Avoids stale denormalized data.

**`other_socials JSONB`.** Bluesky, Mastodon, personal website, podcast feed. Schema-less because the set changes over time.

## `clubs` table

**Why `SERIAL` not UUID?** Clubs are public reference data. ~5,000 clubs in the major leagues globally. Sequential integers are fine and join faster.

**`UNIQUE (club_name, country_name)`.** Multiple clubs share names ("Athletic" in Spain vs Bilbao, "Manchester City" reused in Lower Hutt NZ). Disambiguate by country at minimum.

**`x_handle` is nullable.** Used for resolution proof verification ("search from:ChelseaFC for the announcement tweet"). Not all clubs have a verified X presence.

**No Sportmonks `id` mapping in MVP.** When budget unlocks Sportmonks, add a `sportmonks_id INT UNIQUE` column via migration. Don't pre-create it.

## `players` table

**GIN index on `player_name`.** Player names get searched constantly. tsvector GIN handles fuzzy partial matches well. "Saliba" matches "William Saliba" without needing a separate alias field.

**`market_value_eur BIGINT`.** Bigint because Mbappe-tier transfers can hit 200M+ EUR. Integer overflows above ~21 trillion which is fine forever.

**Wikipedia URL is nullable.** Used as a public-evidence source for player identity. Not required.

## `predictions` table

**`tweet_id` is unique and indexed.** Primary dedup constraint. If the same tweet is submitted twice, the second insert fails cleanly.

**`tweet_text VARCHAR(2000)`.** X premium allows 25,000-char tweets. We cap at 2000 to bound storage; truncate if necessary and rely on `wayback_url` for the canonical original.

**Both `wayback_url` and `archive_today_url`.** Belt and suspenders. Wayback occasionally fails to capture. archive.today occasionally rate-limits. Having both means at least one snapshot survives.

**`submitted_by_user_id` is nullable UUID.** Phase 1 has no public users so submissions come in via the form with no auth. Phase 2 user accounts get linked here. Bot-submitted predictions (Phase 3) leave this NULL.

**`moderator_reviewed_by` and `is_approved`.** Moderator queue gate. Approved predictions become publicly visible; unapproved sit in the queue.

**Resolution columns.** `actual_destination_club_id` and `actual_fee_eur` are nullable; populated when a moderator resolves the prediction. `fee_was_undisclosed BOOLEAN` is the trigger for the W_F=0 fallback in scoring.

**Score columns.** Per-component scores are stored so debugging is possible without recomputing. Recompute via a Postgres function on resolution.

**`last_deletion_check_at`.** Lets the daily audit skip predictions already checked recently. Avoids redundant HEAD requests.

## `predictor_stats` materialized view

**Why materialized?** Leaderboard queries hit this on every page load. Computing it live from `predictions` on every request would exhaust the Supabase free tier within a few hundred page views.

**Refresh trigger.** `REFRESH MATERIALIZED VIEW CONCURRENTLY predictor_stats` on every resolution event. The CONCURRENTLY flag requires the unique index already declared.

**What's NOT in the view: Wilson lower bound.** Computed in the frontend or via a dedicated SQL function (`wilson_lower(correct, total)`). Kept out of the view so the formula can change without DDL.

## `sheets_sync_queue` table

**Why a queue, not direct write?** Critique 1 in the strategy doc. Google Sheets API rate-limits and breaks if columns change. Async queue with retry and backoff isolates DB writes from Sheets reliability.

**`operation` field.** insert / update / delete. Make.com scenario branches on this.

**`attempt_count` cap.** Set in Make.com scenario logic. After 5 failed attempts, flag the row, email Hank, do not retry until manual intervention.

## `appeals` table

**Why a dedicated table, not a comments field on predictions?** Appeals are first-class. Need their own lifecycle (pending / upheld / rejected), audit trail, and outbound communication. Comments would muddle moderator notes with public dispute history.

**`appellant_email`.** Required for response. Stored hashed or as-is depending on Supabase Auth integration. For MVP, store plaintext but restrict read access via RLS to mod role only.

**`evidence_urls TEXT[]`.** Array because most appeals will cite multiple sources (their tweet, club announcement, BBC article).

## Row Level Security

- Public users get SELECT on approved/active rows only
- Moderators get full access via JWT claim
- Appeals INSERT is public (anyone with email) but SELECT is mod-only

Set up the moderator role in Supabase Auth via custom claims. Hank's account claims `role: moderator` at JWT issuance.
