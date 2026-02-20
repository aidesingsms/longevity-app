-- AIDESING Longevity App - Create Missing Tables Only
-- Safe to run - only creates tables that don't exist

-- ============================================
-- USERS TABLE (skip if exists)
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
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
        
        ALTER TABLE users ENABLE ROW LEVEL SECURITY;
        CREATE POLICY user_isolation ON users FOR ALL USING (auth.uid() = id);
        
        RAISE NOTICE 'Created users table';
    ELSE
        RAISE NOTICE 'Users table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- BIOMARKER ANALYSIS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'biomarker_analyses') THEN
        CREATE TABLE biomarker_analyses (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            analysis_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            biological_age INTEGER,
            chronological_age INTEGER,
            health_score INTEGER,
            body_fat_percentage DECIMAL(5,2),
            muscle_mass_kg DECIMAL(5,2),
            hydration_level DECIMAL(5,2),
            skin_age INTEGER,
            skin_health_score INTEGER,
            wrinkle_score INTEGER,
            pigmentation_score INTEGER,
            tongue_color VARCHAR(50),
            tongue_coating VARCHAR(50),
            tongue_moisture VARCHAR(50),
            tongue_health_score INTEGER,
            nail_health_score INTEGER,
            circulation_score INTEGER,
            ai_insights JSONB,
            recommendations JSONB,
            body_photo_url TEXT,
            face_photo_url TEXT,
            tongue_photo_url TEXT,
            hand_photo_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        CREATE INDEX idx_biomarker_analyses_user_date ON biomarker_analyses(user_id, analysis_date DESC);
        ALTER TABLE biomarker_analyses ENABLE ROW LEVEL SECURITY;
        CREATE POLICY biomarker_isolation ON biomarker_analyses FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created biomarker_analyses table';
    ELSE
        RAISE NOTICE 'biomarker_analyses table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- WEARABLE CONNECTIONS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'wearable_connections') THEN
        CREATE TABLE wearable_connections (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            provider VARCHAR(50) NOT NULL,
            provider_user_id VARCHAR(255),
            access_token TEXT,
            refresh_token TEXT,
            token_expires_at TIMESTAMP WITH TIME ZONE,
            is_connected BOOLEAN DEFAULT FALSE,
            last_sync_at TIMESTAMP WITH TIME ZONE,
            sync_frequency_minutes INTEGER DEFAULT 60,
            permissions_granted JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(user_id, provider)
        );
        
        ALTER TABLE wearable_connections ENABLE ROW LEVEL SECURITY;
        CREATE POLICY wearable_isolation ON wearable_connections FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created wearable_connections table';
    ELSE
        RAISE NOTICE 'wearable_connections table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- DAILY HEALTH METRICS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'daily_health_metrics') THEN
        CREATE TABLE daily_health_metrics (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            date DATE NOT NULL,
            steps INTEGER,
            calories_burned INTEGER,
            active_minutes INTEGER,
            stand_hours INTEGER,
            distance_km DECIMAL(6,2),
            resting_heart_rate INTEGER,
            avg_heart_rate INTEGER,
            max_heart_rate INTEGER,
            hrv_ms DECIMAL(6,2),
            sleep_duration_minutes INTEGER,
            deep_sleep_minutes INTEGER,
            rem_sleep_minutes INTEGER,
            light_sleep_minutes INTEGER,
            sleep_score INTEGER,
            sleep_efficiency DECIMAL(5,2),
            spo2_avg DECIMAL(5,2),
            spo2_min DECIMAL(5,2),
            respiratory_rate DECIMAL(4,1),
            body_temp_avg DECIMAL(4,1),
            wrist_temp_avg DECIMAL(4,1),
            glucose_avg DECIMAL(5,2),
            glucose_min DECIMAL(5,2),
            glucose_max DECIMAL(5,2),
            bp_systolic_avg INTEGER,
            bp_diastolic_avg INTEGER,
            activity_score INTEGER,
            recovery_score INTEGER,
            sleep_score_computed INTEGER,
            overall_score INTEGER,
            sources JSONB,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            UNIQUE(user_id, date)
        );
        
        CREATE INDEX idx_daily_metrics_user_date ON daily_health_metrics(user_id, date DESC);
        ALTER TABLE daily_health_metrics ENABLE ROW LEVEL SECURITY;
        CREATE POLICY daily_metrics_isolation ON daily_health_metrics FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created daily_health_metrics table';
    ELSE
        RAISE NOTICE 'daily_health_metrics table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- HOURLY METRICS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'hourly_health_metrics') THEN
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
        
        CREATE INDEX idx_hourly_metrics_user_timestamp ON hourly_health_metrics(user_id, timestamp DESC);
        ALTER TABLE hourly_health_metrics ENABLE ROW LEVEL SECURITY;
        CREATE POLICY hourly_metrics_isolation ON hourly_health_metrics FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created hourly_health_metrics table';
    ELSE
        RAISE NOTICE 'hourly_health_metrics table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- SUPPLEMENTS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'supplements') THEN
        CREATE TABLE supplements (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            name VARCHAR(100) NOT NULL,
            dosage VARCHAR(50),
            frequency VARCHAR(50),
            time_of_day TIME[],
            category VARCHAR(50),
            purpose TEXT,
            start_date DATE,
            end_date DATE,
            is_active BOOLEAN DEFAULT TRUE,
            notes TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE supplements ENABLE ROW LEVEL SECURITY;
        CREATE POLICY supplement_isolation ON supplements FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created supplements table';
    ELSE
        RAISE NOTICE 'supplements table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- SUPPLEMENT LOGS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'supplement_logs') THEN
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
        
        CREATE INDEX idx_supplement_logs_user_date ON supplement_logs(user_id, taken_at DESC);
        ALTER TABLE supplement_logs ENABLE ROW LEVEL SECURITY;
        CREATE POLICY supplement_log_isolation ON supplement_logs FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created supplement_logs table';
    ELSE
        RAISE NOTICE 'supplement_logs table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- DIGITAL TWINS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'digital_twins') THEN
        CREATE TABLE digital_twins (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            model_url TEXT,
            texture_url TEXT,
            chest_cm DECIMAL(5,2),
            waist_cm DECIMAL(5,2),
            hips_cm DECIMAL(5,2),
            arms_cm DECIMAL(5,2),
            thighs_cm DECIMAL(5,2),
            heart_health INTEGER DEFAULT 100,
            lung_health INTEGER DEFAULT 100,
            liver_health INTEGER DEFAULT 100,
            kidney_health INTEGER DEFAULT 100,
            brain_health INTEGER DEFAULT 100,
            gut_health INTEGER DEFAULT 100,
            show_organs BOOLEAN DEFAULT TRUE,
            show_circulation BOOLEAN DEFAULT TRUE,
            show_nervous_system BOOLEAN DEFAULT FALSE,
            last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE digital_twins ENABLE ROW LEVEL SECURITY;
        CREATE POLICY twin_isolation ON digital_twins FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created digital_twins table';
    ELSE
        RAISE NOTICE 'digital_twins table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- AI INSIGHTS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ai_insights') THEN
        CREATE TABLE ai_insights (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            insight_type VARCHAR(50),
            title VARCHAR(200),
            description TEXT,
            severity VARCHAR(20),
            confidence_score DECIMAL(3,2),
            related_metrics JSONB,
            recommendations JSONB,
            is_read BOOLEAN DEFAULT FALSE,
            is_dismissed BOOLEAN DEFAULT FALSE,
            user_feedback VARCHAR(20),
            generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            valid_until TIMESTAMP WITH TIME ZONE
        );
        
        CREATE INDEX idx_ai_insights_user_unread ON ai_insights(user_id, is_read) WHERE is_read = FALSE;
        ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
        CREATE POLICY insight_isolation ON ai_insights FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created ai_insights table';
    ELSE
        RAISE NOTICE 'ai_insights table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- HEALTH GOALS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'health_goals') THEN
        CREATE TABLE health_goals (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            goal_type VARCHAR(50),
            target_value DECIMAL(10,2),
            current_value DECIMAL(10,2),
            unit VARCHAR(20),
            start_date DATE,
            target_date DATE,
            status VARCHAR(20) DEFAULT 'active',
            progress_percentage INTEGER DEFAULT 0,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE health_goals ENABLE ROW LEVEL SECURITY;
        CREATE POLICY goal_isolation ON health_goals FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created health_goals table';
    ELSE
        RAISE NOTICE 'health_goals table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- LAB RESULTS TABLE
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'lab_results') THEN
        CREATE TABLE lab_results (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES users(id) ON DELETE CASCADE,
            test_date DATE,
            lab_name VARCHAR(100),
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
            results_json JSONB,
            report_url TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        ALTER TABLE lab_results ENABLE ROW LEVEL SECURITY;
        CREATE POLICY lab_isolation ON lab_results FOR ALL USING (auth.uid() = user_id);
        
        RAISE NOTICE 'Created lab_results table';
    ELSE
        RAISE NOTICE 'lab_results table already exists - skipping';
    END IF;
END $$;

-- ============================================
-- FUNCTIONS
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'update_updated_at_column') THEN
        CREATE OR REPLACE FUNCTION update_updated_at_column()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ language 'plpgsql';
        
        RAISE NOTICE 'Created update_updated_at_column function';
    ELSE
        RAISE NOTICE 'update_updated_at_column function already exists - skipping';
    END IF;
END $$;

-- Create triggers for updated_at
DO $$
BEGIN
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
        IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_users_updated_at') THEN
            CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
                FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'wearable_connections') THEN
        IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_wearable_connections_updated_at') THEN
            CREATE TRIGGER update_wearable_connections_updated_at BEFORE UPDATE ON wearable_connections
                FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'daily_health_metrics') THEN
        IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_daily_metrics_updated_at') THEN
            CREATE TRIGGER update_daily_metrics_updated_at BEFORE UPDATE ON daily_health_metrics
                FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        END IF;
    END IF;
    
    IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'health_goals') THEN
        IF NOT EXISTS (SELECT FROM pg_trigger WHERE tgname = 'update_health_goals_updated_at') THEN
            CREATE TRIGGER update_health_goals_updated_at BEFORE UPDATE ON health_goals
                FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
        END IF;
    END IF;
END $$;

-- ============================================
-- VIEWS
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_views WHERE viewname = 'weekly_health_summary') THEN
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
        
        RAISE NOTICE 'Created weekly_health_summary view';
    ELSE
        RAISE NOTICE 'weekly_health_summary view already exists - skipping';
    END IF;
END $$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_views WHERE viewname = 'monthly_health_trends') THEN
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
        
        RAISE NOTICE 'Created monthly_health_trends view';
    ELSE
        RAISE NOTICE 'monthly_health_trends view already exists - skipping';
    END IF;
END $$;

-- ============================================
-- HEALTH SCORE FUNCTION
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_proc WHERE proname = 'calculate_health_score') THEN
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
            SELECT 
                activity_score,
                sleep_score_computed,
                recovery_score
            INTO v_activity_score, v_sleep_score, v_heart_score
            FROM daily_health_metrics
            WHERE user_id = p_user_id AND date = p_date;
            
            v_overall_score := ROUND(
                (COALESCE(v_activity_score, 70) * 0.3) +
                (COALESCE(v_sleep_score, 70) * 0.3) +
                (COALESCE(v_heart_score, 70) * 0.4)
            );
            
            RETURN v_overall_score;
        END;
        $$ LANGUAGE plpgsql;
        
        RAISE NOTICE 'Created calculate_health_score function';
    ELSE
        RAISE NOTICE 'calculate_health_score function already exists - skipping';
    END IF;
END $$;

-- Done!
SELECT 'Schema setup complete!' as status;
