-- Longevity App Database Schema
-- Supabase PostgreSQL

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    date_of_birth DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User measurements (biometrics)
CREATE TABLE IF NOT EXISTS public.measurements (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Basic measurements
    weight_kg DECIMAL(5,2),
    height_cm DECIMAL(5,2),
    waist_cm DECIMAL(5,2),
    hip_cm DECIMAL(5,2),
    
    -- Calculated fields
    bmi DECIMAL(4,2) GENERATED ALWAYS AS (
        weight_kg / ((height_cm/100) * (height_cm/100))
    ) STORED,
    waist_hip_ratio DECIMAL(3,2) GENERATED ALWAYS AS (
        CASE WHEN hip_cm > 0 THEN waist_cm / hip_cm ELSE NULL END
    ) STORED,
    
    -- Photo reference
    photo_url TEXT,
    
    -- Timestamp
    measured_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Lifestyle questionnaire responses
CREATE TABLE IF NOT EXISTS public.lifestyle_assessments (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Exercise (0-4 scale)
    exercise_frequency INTEGER CHECK (exercise_frequency BETWEEN 0 AND 4),
    exercise_intensity INTEGER CHECK (exercise_intensity BETWEEN 0 AND 3),
    
    -- Sleep
    sleep_hours DECIMAL(3,1),
    sleep_quality INTEGER CHECK (sleep_quality BETWEEN 1 AND 5),
    sleep_consistency INTEGER CHECK (sleep_consistency BETWEEN 1 AND 5),
    
    -- Stress
    stress_level INTEGER CHECK (stress_level BETWEEN 1 AND 5),
    stress_management INTEGER CHECK (stress_management BETWEEN 1 AND 5),
    
    -- Nutrition
    diet_quality INTEGER CHECK (diet_quality BETWEEN 1 AND 5),
    processed_food_intake INTEGER CHECK (processed_food_intake BETWEEN 0 AND 4),
    vegetable_intake INTEGER CHECK (vegetable_intake BETWEEN 0 AND 4),
    
    -- Habits
    smoking_status INTEGER CHECK (smoking_status BETWEEN 0 AND 3),
    alcohol_intake INTEGER CHECK (alcohol_intake BETWEEN 0 AND 4),
    
    -- Mental
    social_connections INTEGER CHECK (social_connections BETWEEN 1 AND 5),
    purpose_in_life INTEGER CHECK (purpose_in_life BETWEEN 1 AND 5),
    
    assessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Biological age calculations
CREATE TABLE IF NOT EXISTS public.biological_age_results (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    measurement_id UUID REFERENCES public.measurements(id) ON DELETE CASCADE,
    
    -- Results
    chronological_age INTEGER NOT NULL,
    biological_age DECIMAL(5,2) NOT NULL,
    age_difference DECIMAL(5,2) GENERATED ALWAYS AS (
        biological_age - chronological_age
    ) STORED,
    
    -- Scores (0-100)
    longevity_score INTEGER CHECK (longevity_score BETWEEN 0 AND 100),
    aging_velocity DECIMAL(4,2),
    
    -- Component scores
    metabolic_score INTEGER CHECK (metabolic_score BETWEEN 0 AND 100),
    cardiovascular_score INTEGER CHECK (cardiovascular_score BETWEEN 0 AND 100),
    lifestyle_score INTEGER CHECK (lifestyle_score BETWEEN 0 AND 100),
    
    -- Algorithm version
    algorithm_version TEXT DEFAULT '1.0',
    
    calculated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Personalized routines
CREATE TABLE IF NOT EXISTS public.routines (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    -- Routine type
    routine_type TEXT CHECK (routine_type IN ('sleep', 'nutrition', 'exercise', 'stress', 'supplements')),
    
    -- Content
    title TEXT NOT NULL,
    description TEXT,
    recommendations JSONB, -- Flexible structure for recommendations
    
    -- Schedule
    frequency TEXT, -- daily, weekly, etc.
    time_of_day TIME,
    duration_minutes INTEGER,
    
    -- Tracking
    is_active BOOLEAN DEFAULT true,
    completed_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Routine completion tracking
CREATE TABLE IF NOT EXISTS public.routine_completions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    routine_id UUID REFERENCES public.routines(id) ON DELETE CASCADE NOT NULL,
    
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    mood_score INTEGER CHECK (mood_score BETWEEN 1 AND 5)
);

-- Progress photos
CREATE TABLE IF NOT EXISTS public.progress_photos (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    
    photo_url TEXT NOT NULL,
    photo_type TEXT CHECK (photo_type IN ('front', 'side', 'back')),
    
    -- Analysis results
    posture_score INTEGER CHECK (posture_score BETWEEN 0 AND 100),
    body_composition_estimate JSONB,
    
    taken_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_measurements_user_id ON public.measurements(user_id);
CREATE INDEX idx_measurements_measured_at ON public.measurements(measured_at);
CREATE INDEX idx_bio_age_user_id ON public.biological_age_results(user_id);
CREATE INDEX idx_bio_age_calculated_at ON public.biological_age_results(calculated_at);
CREATE INDEX idx_routines_user_id ON public.routines(user_id);
CREATE INDEX idx_routines_type ON public.routines(routine_type);

-- Row Level Security (RLS) policies
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lifestyle_assessments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.biological_age_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_completions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.progress_photos ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own measurements" ON public.measurements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own measurements" ON public.measurements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own bio age results" ON public.biological_age_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view own routines" ON public.routines
    FOR SELECT USING (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_routines_updated_at BEFORE UPDATE ON public.routines
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
