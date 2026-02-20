-- AIDESING Longevity App - Supabase Database Schema
-- PostgreSQL with Row Level Security (RLS)

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    location VARCHAR(100),
    timezone VARCHAR(50) DEFAULT 'America/New_York',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    subscription_tier VARCHAR(20) DEFAULT 'free'
);

-- ============================================
-- BIOMARKER ANALYSIS TABLE
-- ============================================
CREATE TABLE biomarker_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Overall scores
    biological_age INTEGER,
    chronological_age INTEGER,
    health_score INTEGER,
    
    -- Body analysis
    body_fat_percentage DECIMAL(5,2),
    muscle_mass_kg DECIMAL(5,2),
    hydration_level DECIMAL(5,2),
    
    -- Skin analysis (from face photo)
    skin_age INTEGER,
    skin_health_score INTEGER,
    wrinkle_score INTEGER,
    pigmentation_score INTEGER,
    
    -- Tongue analysis
    tongue_color VARCHAR(50),
    tongue_coating VARCHAR(50),
    tongue_moisture VARCHAR(50),
    tongue_health_score INTEGER,
    
    -- Hand analysis
    nail_health_score INTEGER,
    circulation_score INTEGER,
    
    -- AI insights
    ai_insights JSONB,
    recommendations JSONB,
    
    -- Photo references
    body_photo_url TEXT,
    face_photo_url TEXT,
    tongue_photo_url TEXT,
    hand_photo_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- WEARABLE CONNECTIONS TABLE
-- ============================================
CREATE TABLE wearable_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    provider VARCHAR(50) NOT NULL, -- 'apple_health', 'google_fit', 'oura', 'whoop', 'garmin'
    provider_user_id VARCHAR(255),
    access_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    
    is_connected BOOLEAN DEFAULT FALSE,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    sync_frequency_minutes INTEGER DEFAULT 60,
    
    -- Permissions granted
    permissions_granted JSONB,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, provider)
);

-- ============================================
-- DAILY HEALTH METRICS TABLE
-- ============================================
CREATE TABLE daily_health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    
    -- Activity
    steps INTEGER,
    calories_burned INTEGER,
    active_minutes INTEGER,
    stand_hours INTEGER,
    distance_km DECIMAL(6,2),
    
    -- Heart
    resting_heart_rate INTEGER,
    avg_heart_rate INTEGER,
    max_heart_rate INTEGER,
    hrv_ms DECIMAL(6,2),
    
    -- Sleep
    sleep_duration_minutes INTEGER,
    deep_sleep_minutes INTEGER,
    rem_sleep_minutes INTEGER,
    light_sleep_minutes INTEGER,
    sleep_score INTEGER,
    sleep_efficiency DECIMAL(5,2),
    
    -- Respiratory
    spo2_avg DECIMAL(5,2),
    spo2_min DECIMAL(5,2),
    respiratory_rate DECIMAL(4,1),
    
    -- Temperature
    body_temp_avg DECIMAL(4,1),
    wrist_temp_avg DECIMAL(4,1),
    
    -- Glucose (if CGM connected)
    glucose_avg DECIMAL(5,2),
    glucose_min DECIMAL(5,2),
    glucose_max DECIMAL(5,2),
    
    -- Blood Pressure (if wearable supports)
    bp_systolic_avg INTEGER,
    bp_diastolic_avg INTEGER,
    
    -- Computed scores
    activity_score INTEGER,
    recovery_score INTEGER,
    sleep_score_computed INTEGER,
    overall_score INTEGER,
    
    -- Source tracking
    sources JSONB, -- ['apple_health', 'oura', 'whoop']
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, date)
);

-- ============================================
-- HOURLY METRICS TABLE (for detailed charts)
-- ============================================
CREATE TABLE hourly_health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    
    heart_rate INTEGER,
    hrv_ms DECIMAL(6,2),
    spo2 DECIMAL(5,2),
    steps INTEGER,
    calories INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, timestamp)
);

-- ============================================
-- SUPPLEMENT TRACKING TABLE
-- ============================================
CREATE TABLE supplements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    name VARCHAR(100) NOT NULL,
    dosage VARCHAR(50),
    frequency VARCHAR(50), -- 'daily', 'twice_daily', 'weekly'
    time_of_day TIME[], -- array of times
    
    category VARCHAR(50), -- 'longevity', 'vitamin', 'mineral', 'herb', 'other'
    purpose TEXT,
    
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- SUPPLEMENT LOG TABLE
-- ============================================
CREATE TABLE supplement_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    supplement_id UUID REFERENCES supplements(id) ON DELETE CASCADE,
    
    taken_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    dosage_taken VARCHAR(50),
    skipped BOOLEAN DEFAULT FALSE,
    notes TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- DIGITAL TWIN CONFIGURATION TABLE
-- ============================================
CREATE TABLE digital_twins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- 3D Model settings
    model_url TEXT,
    texture_url TEXT,
    
    -- Body measurements
    chest_cm DECIMAL(5,2),
    waist_cm DECIMAL(5,2),
    hips_cm DECIMAL(5,2),
    arms_cm DECIMAL(5,2),
    thighs_cm DECIMAL(5,2),
    
    -- Organ health scores (0-100)
    heart_health INTEGER DEFAULT 100,
    lung_health INTEGER DEFAULT 100,
    liver_health INTEGER DEFAULT 100,
    kidney_health INTEGER DEFAULT 100,
    brain_health INTEGER DEFAULT 100,
    gut_health INTEGER DEFAULT 100,
    
    -- Visualization settings
    show_organs BOOLEAN DEFAULT TRUE,
    show_circulation BOOLEAN DEFAULT TRUE,
    show_nervous_system BOOLEAN DEFAULT FALSE,
    
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- AI INSIGHTS TABLE
-- ============================================
CREATE TABLE ai_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    insight_type VARCHAR(50), -- 'sleep', 'heart', 'activity', 'biomarker', 'general'
    title VARCHAR(200),
    description TEXT,
    
    severity VARCHAR(20), -- 'info', 'positive', 'warning', 'alert'
    confidence_score DECIMAL(3,2), -- 0.00 to 1.00
    
    -- Related data
    related_metrics JSONB, -- { 'metric': 'hrv', 'value': 65, 'trend': 'up' }
    recommendations JSONB,
    
    -- User interaction
    is_read BOOLEAN DEFAULT FALSE,
    is_dismissed BOOLEAN DEFAULT FALSE,
    user_feedback VARCHAR(20), -- 'helpful', 'not_helpful', 'action_taken'
    
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    valid_until TIMESTAMP WITH TIME ZONE
);

-- ============================================
-- HEALTH GOALS TABLE
-- ============================================
CREATE TABLE health_goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    goal_type VARCHAR(50), -- 'steps', 'sleep', 'hrv', 'weight', 'biological_age'
    target_value DECIMAL(10,2),
    current_value DECIMAL(10,2),
    unit VARCHAR(20),
    
    start_date DATE,
    target_date DATE,
    
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'achieved', 'abandoned'
    progress_percentage INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- LAB RESULTS TABLE
-- ============================================
CREATE TABLE lab_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    test_date DATE,
    lab_name VARCHAR(100),
    
    -- Common biomarkers
    total_cholesterol DECIMAL(6,2),
    hdl_cholesterol DECIMAL(6,2),
    ldl_cholesterol DECIMAL(6,2),
    triglycerides DECIMAL(6,2),
    
    glucose_fasting DECIMAL(5,2),
    hba1c DECIMAL(4,2),
    insulin DECIMAL(6,2),
    
    crp DECIMAL(5,2),
    homocysteine DECIMAL(5,2),
    
    testosterone_total DECIMAL(6,2),
    testosterone_free DECIMAL(6,2),
    
    vitamin_d DECIMAL(5,2),
    vitamin_b12 DECIMAL(6,2),
    
    -- Raw data
    results_json JSONB,
    report_url TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_biomarker_analyses_user_date ON biomarker_analyses(user_id, analysis_date DESC);
CREATE INDEX idx_daily_metrics_user_date ON daily_health_metrics(user_id, date DESC);
CREATE INDEX idx_hourly_metrics_user_timestamp ON hourly_health_metrics(user_id, timestamp DESC);
CREATE INDEX idx_ai_insights_user_unread ON ai_insights(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX idx_supplement_logs_user_date ON supplement_logs(user_id, taken_at DESC);

-- ============================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================

-- Users can only see their own data
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE biomarker_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE wearable_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE hourly_health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplements ENABLE ROW LEVEL SECURITY;
ALTER TABLE supplement_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE digital_twins ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE health_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE lab_results ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own records
CREATE POLICY user_isolation ON users FOR ALL USING (auth.uid() = id);
CREATE POLICY biomarker_isolation ON biomarker_analyses FOR ALL USING (auth.uid() = user_id);
CREATE POLICY wearable_isolation ON wearable_connections FOR ALL USING (auth.uid() = user_id);
CREATE POLICY daily_metrics_isolation ON daily_health_metrics FOR ALL USING (auth.uid() = user_id);
CREATE POLICY hourly_metrics_isolation ON hourly_health_metrics FOR ALL USING (auth.uid() = user_id);
CREATE POLICY supplement_isolation ON supplements FOR ALL USING (auth.uid() = user_id);
CREATE POLICY supplement_log_isolation ON supplement_logs FOR ALL USING (auth.uid() = user_id);
CREATE POLICY twin_isolation ON digital_twins FOR ALL USING (auth.uid() = user_id);
CREATE POLICY insight_isolation ON ai_insights FOR ALL USING (auth.uid() = user_id);
CREATE POLICY goal_isolation ON health_goals FOR ALL USING (auth.uid() = user_id);
CREATE POLICY lab_isolation ON lab_results FOR ALL USING (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_wearable_connections_updated_at BEFORE UPDATE ON wearable_connections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_metrics_updated_at BEFORE UPDATE ON daily_health_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_health_goals_updated_at BEFORE UPDATE ON health_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate health score
CREATE OR REPLACE FUNCTION calculate_health_score(
    p_user_id UUID,
    p_date DATE
)
RETURNS INTEGER AS $$
DECLARE
    v_activity_score INTEGER;
    v_sleep_score INTEGER;
    v_heart_score INTEGER;
    v_overall_score INTEGER;
BEGIN
    -- Get daily metrics
    SELECT 
        activity_score,
        sleep_score_computed,
        recovery_score
    INTO v_activity_score, v_sleep_score, v_heart_score
    FROM daily_health_metrics
    WHERE user_id = p_user_id AND date = p_date;
    
    -- Calculate weighted overall score
    v_overall_score := ROUND(
        (COALESCE(v_activity_score, 70) * 0.3) +
        (COALESCE(v_sleep_score, 70) * 0.3) +
        (COALESCE(v_heart_score, 70) * 0.4)
    );
    
    RETURN v_overall_score;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VIEWS
-- ============================================

-- Weekly health summary view
CREATE VIEW weekly_health_summary AS
SELECT 
    user_id,
    DATE_TRUNC('week', date) as week_start,
    AVG(steps) as avg_steps,
    AVG(sleep_duration_minutes) as avg_sleep_minutes,
    AVG(resting_heart_rate) as avg_resting_hr,
    AVG(hrv_ms) as avg_hrv,
    AVG(overall_score) as avg_health_score,
    COUNT(DISTINCT date) as days_logged
FROM daily_health_metrics
GROUP BY user_id, DATE_TRUNC('week', date);

-- Monthly trends view
CREATE VIEW monthly_health_trends AS
SELECT 
    user_id,
    DATE_TRUNC('month', date) as month,
    AVG(steps) as avg_steps,
    AVG(sleep_score_computed) as avg_sleep_score,
    AVG(recovery_score) as avg_recovery_score,
    AVG(overall_score) as avg_overall_score
FROM daily_health_metrics
GROUP BY user_id, DATE_TRUNC('month', date);
