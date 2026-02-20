-- AIDESING Longevity App - Schema Verification Script
-- Run this to check if all required tables exist

-- Check if users table exists and has correct structure
SELECT 
    table_name,
    column_name,
    data_type
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public'
    AND table_name IN (
        'users',
        'biomarker_analyses', 
        'wearable_connections',
        'daily_health_metrics',
        'hourly_health_metrics',
        'supplements',
        'supplement_logs',
        'digital_twins',
        'ai_insights',
        'health_goals',
        'lab_results'
    )
ORDER BY 
    table_name, ordinal_position;

-- Check for existing RLS policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM 
    pg_policies
WHERE 
    schemaname = 'public'
ORDER BY 
    tablename, policyname;

-- Check for existing functions
SELECT 
    routine_name,
    routine_type,
    data_type AS return_type
FROM 
    information_schema.routines
WHERE 
    routine_schema = 'public'
    AND routine_type = 'FUNCTION'
ORDER BY 
    routine_name;

-- Check for existing views
SELECT 
    table_name,
    view_definition
FROM 
    information_schema.views
WHERE 
    table_schema = 'public'
ORDER BY 
    table_name;
