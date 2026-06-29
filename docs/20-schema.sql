-- ITK Tracker: PostgreSQL Schema for Supabase
-- Target: PostgreSQL 15 (Supabase default)
-- Verification: psql -f docs/20-schema.sql against a fresh local Postgres

-- ============================================================================
-- ENUMS
-- ============================================================================

CREATE TYPE prediction_state AS ENUM (
    'pending',           -- Awaiting moderator review or transfer resolution
    'correct',           -- Player joined the predicted club within reasonable window
    'incorrect',         -- Player joined a different club, or transfer fell through
    'mitigated',         -- Partial match (e.g. predicted club correct, fee wildly off)
    'deleted_by_author', -- Original tweet no longer publicly accessible
    'unverifiable'       -- Cannot determine outcome after 180-day grace
);

-- ============================================================================
-- PREDICTORS (Journalists and ITK accounts)
-- ============================================================================

CREATE TABLE predictors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    x_user_id VARCHAR(30) UNIQUE NOT NULL,
    x_username VARCHAR(15) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    bio TEXT,
    avatar_url VARCHAR(500),
    profile_url VARCHAR(500),
    other_socials JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT
);

CREATE INDEX idx_predictors_username ON predictors(x_username);
CREATE INDEX idx_predictors_active ON predictors(is_active) WHERE is_active = true;

-- ============================================================================
-- CLUBS
-- ============================================================================

CREATE TABLE clubs (
    id SERIAL PRIMARY KEY,
    club_name VARCHAR(100) NOT NULL,
    short_name VARCHAR(50),
    league_name VARCHAR(100) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    x_handle VARCHAR(15),
    UNIQUE (club_name, country_name)
);

CREATE INDEX idx_clubs_league ON clubs(league_name);
CREATE INDEX idx_clubs_country ON clubs(country_name);

-- ============================================================================
-- PLAYERS
-- ============================================================================

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    player_name VARCHAR(150) NOT NULL,
    nationality VARCHAR(50),
    date_of_birth DATE,
    position VARCHAR(30),
    market_value_eur BIGINT,
    wikipedia_url VARCHAR(500)
);

CREATE INDEX idx_players_name ON players USING gin (to_tsvector('simple', player_name));

-- ============================================================================
-- PREDICTIONS (Core transactional table)
-- ============================================================================

CREATE TABLE predictions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    predictor_id UUID REFERENCES predictors(id) ON DELETE CASCADE NOT NULL,
    player_id INT REFERENCES players(id) NOT NULL,
    destination_club_id INT REFERENCES clubs(id) NOT NULL,
    predicted_fee_eur BIGINT,
    tweet_id VARCHAR(30) UNIQUE NOT NULL,
    tweet_url VARCHAR(500) NOT NULL,
    tweet_text VARCHAR(2000) NOT NULL,
    predicted_at TIMESTAMP WITH TIME ZONE NOT NULL,

    -- Archival snapshots
    wayback_url VARCHAR(500),
    archive_today_url VARCHAR(500),

    -- Submission metadata
    submitted_by_user_id UUID,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    moderator_reviewed_by UUID,
    moderator_reviewed_at TIMESTAMP WITH TIME ZONE,
    is_approved BOOLEAN DEFAULT false,

    -- Resolution
    resolved_state prediction_state DEFAULT 'pending',
    resolved_at TIMESTAMP WITH TIME ZONE,
    actual_destination_club_id INT REFERENCES clubs(id),
    actual_fee_eur BIGINT,
    fee_was_undisclosed BOOLEAN DEFAULT false,
    proof_url VARCHAR(500),

    -- Computed score (recalculated on resolution)
    score_destination NUMERIC(4,3),
    score_fee NUMERIC(4,3),
    score_temporal NUMERIC(4,3),
    score_consensus_lag NUMERIC(4,3),
    score_final NUMERIC(6,3),

    -- Deletion audit
    last_deletion_check_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_predictions_predictor ON predictions(predictor_id);
CREATE INDEX idx_predictions_state ON predictions(resolved_state);
CREATE INDEX idx_predictions_approved ON predictions(is_approved) WHERE is_approved = true;
CREATE INDEX idx_predictions_predicted_at ON predictions(predicted_at DESC);
CREATE INDEX idx_predictions_pending_deletion_check ON predictions(last_deletion_check_at)
    WHERE resolved_state = 'pending';

-- ============================================================================
-- AGGREGATED PREDICTOR STATS (Materialized view, refreshed on resolution)
-- ============================================================================

CREATE MATERIALIZED VIEW predictor_stats AS
SELECT
    p.id AS predictor_id,
    p.x_username,
    COUNT(*) FILTER (WHERE pr.is_approved AND pr.resolved_state != 'pending') AS total_resolved,
    COUNT(*) FILTER (WHERE pr.resolved_state = 'correct') AS total_correct,
    COUNT(*) FILTER (WHERE pr.resolved_state = 'incorrect') AS total_incorrect,
    COUNT(*) FILTER (WHERE pr.resolved_state = 'deleted_by_author') AS total_deleted,
    COALESCE(SUM(pr.score_final) FILTER (WHERE pr.resolved_state = 'correct'), 0) AS sum_score_correct,
    CASE
        WHEN COUNT(*) FILTER (WHERE pr.is_approved AND pr.resolved_state != 'pending') = 0 THEN 0
        ELSE COALESCE(SUM(pr.score_final) FILTER (WHERE pr.resolved_state = 'correct'), 0)
             / COUNT(*) FILTER (WHERE pr.is_approved AND pr.resolved_state != 'pending')::numeric
    END AS raw_accuracy_score
FROM predictors p
LEFT JOIN predictions pr ON pr.predictor_id = p.id
WHERE p.is_active = true
GROUP BY p.id, p.x_username;

CREATE UNIQUE INDEX idx_predictor_stats_id ON predictor_stats(predictor_id);

-- ============================================================================
-- GOOGLE SHEETS SYNC QUEUE (Async outbound mirror)
-- ============================================================================

CREATE TABLE sheets_sync_queue (
    id BIGSERIAL PRIMARY KEY,
    prediction_id UUID REFERENCES predictions(id) ON DELETE CASCADE,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
    sync_status VARCHAR(20) DEFAULT 'pending' CHECK (sync_status IN ('pending', 'synced', 'failed')),
    last_attempt_at TIMESTAMP WITH TIME ZONE,
    attempt_count INT DEFAULT 0,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sheets_queue_pending ON sheets_sync_queue(sync_status, created_at)
    WHERE sync_status = 'pending';

-- ============================================================================
-- APPEALS
-- ============================================================================

CREATE TABLE appeals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    prediction_id UUID REFERENCES predictions(id) ON DELETE CASCADE NOT NULL,
    appellant_email VARCHAR(255) NOT NULL,
    appellant_x_handle VARCHAR(15),
    appeal_reason TEXT NOT NULL,
    evidence_urls TEXT[],
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'upheld', 'rejected')),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID,
    resolution_notes TEXT
);

CREATE INDEX idx_appeals_status ON appeals(status);
CREATE INDEX idx_appeals_prediction ON appeals(prediction_id);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE predictors ENABLE ROW LEVEL SECURITY;
ALTER TABLE clubs ENABLE ROW LEVEL SECURITY;
ALTER TABLE players ENABLE ROW LEVEL SECURITY;
ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE appeals ENABLE ROW LEVEL SECURITY;
ALTER TABLE sheets_sync_queue ENABLE ROW LEVEL SECURITY;

-- Public read on approved predictions and active predictors
CREATE POLICY "Public read approved predictions" ON predictions
    FOR SELECT USING (is_approved = true);

CREATE POLICY "Public read active predictors" ON predictors
    FOR SELECT USING (is_active = true);

CREATE POLICY "Public read clubs" ON clubs FOR SELECT USING (true);
CREATE POLICY "Public read players" ON players FOR SELECT USING (true);

-- Moderator write requires authenticated role with moderator claim
-- (Set up via Supabase Auth custom claims; placeholder policy below)
CREATE POLICY "Moderator write predictions" ON predictions
    FOR ALL USING (auth.jwt() ->> 'role' = 'moderator');

CREATE POLICY "Moderator write predictors" ON predictors
    FOR ALL USING (auth.jwt() ->> 'role' = 'moderator');

CREATE POLICY "Moderator read appeals" ON appeals
    FOR SELECT USING (auth.jwt() ->> 'role' = 'moderator');

-- Public can submit appeals (insert only)
CREATE POLICY "Public submit appeals" ON appeals
    FOR INSERT WITH CHECK (true);
