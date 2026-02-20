-- AIDESING Longevity - Core Tables Only
-- Compatible with older PostgreSQL versions

-- 1. USERS
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. BIOMARKER ANALYSES
CREATE TABLE IF NOT EXISTS biomarker_analyses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    biological_age INTEGER,
    chronological_age INTEGER,
    health_score INTEGER,
    ai_insights JSONB,
    recommendations JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_biomarker_user_date ON biomarker_analyses(user_id, analysis_date DESC);

-- 3. WEARABLE CONNECTIONS
CREATE TABLE IF NOT EXISTS wearable_connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    provider VARCHAR(50) NOT NULL,
    is_connected BOOLEAN DEFAULT FALSE,
    last_sync_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, provider)
);

-- 4. DAILY HEALTH METRICS
CREATE TABLE IF NOT EXISTS daily_health_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    steps INTEGER,
    calories_burned INTEGER,
    resting_heart_rate INTEGER,
    hrv_ms DECIMAL(6,2),
    sleep_duration_minutes INTEGER,
    sleep_score INTEGER,
    overall_score INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_metrics_user_date ON daily_health_metrics(user_id, date DESC);

-- 5. AI INSIGHTS
CREATE TABLE IF NOT EXISTS ai_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    insight_type VARCHAR(50),
    title VARCHAR(200),
    description TEXT,
    severity VARCHAR(20),
    is_read BOOLEAN DEFAULT FALSE,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_insights_user_unread ON ai_insights(user_id, is_read) WHERE is_read = FALSE;

-- 6. DIGITAL TWINS
CREATE TABLE IF NOT EXISTS digital_twins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    heart_health INTEGER DEFAULT 100,
    lung_health INTEGER DEFAULT 100,
    liver_health INTEGER DEFAULT 100,
    kidney_health INTEGER DEFAULT 100,
    brain_health INTEGER DEFAULT 100,
    gut_health INTEGER DEFAULT 100,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE biomarker_analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE wearable_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_health_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE digital_twins ENABLE ROW LEVEL SECURITY;

-- Views
CREATE OR REPLACE VIEW weekly_summary AS
SELECT 
    user_id,
    DATE_TRUNC('week', date) as week_start,
    AVG(steps) as avg_steps,
    AVG(sleep_duration_minutes) as avg_sleep,
    AVG(overall_score) as avg_score
FROM daily_health_metrics
GROUP BY user_id, DATE_TRUNC('week', date);

SELECT 'Core schema created successfully!' as result;
