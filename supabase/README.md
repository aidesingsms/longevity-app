# AIDESING Longevity App - Supabase Backend

## Setup Instructions

### 1. Create Supabase Project

1. Go to [https://supabase.com](https://supabase.com)
2. Sign up / Log in
3. Click "New Project"
4. Choose organization and project name: `aidesing-longevity`
5. Select region: `US East (N. Virginia)` (closest to Tampa, FL)
6. Choose password for database
7. Wait for project to be created (~2 minutes)

### 2. Get API Keys

Once project is created:

1. Go to Project Settings → API
2. Copy these values:
   - **Project URL**: `https://xxxxxxxxxxxx.supabase.co`
   - **anon/public key**: `eyJ...`

### 3. Run Database Schema

1. Go to SQL Editor in Supabase Dashboard
2. Create "New Query"
3. Copy contents of `schema.sql`
4. Run the query

### 4. Configure Web App

Create `supabase-config.js` in your web-demo folder:

```javascript
const SUPABASE_CONFIG = {
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key-here'
};
```

### 5. Enable Authentication (Optional)

For user authentication:

1. Go to Authentication → Settings
2. Enable Email provider
3. Configure Site URL: `https://aidesingsms.github.io/longevity-app/web-demo/`
4. Enable Confirm Email (recommended)

## Database Schema Overview

### Tables

| Table | Purpose | Records |
|-------|---------|---------|
| `users` | User accounts and profiles | 1 per user |
| `biomarker_analyses` | Multi-biomarker photo analysis results | Multiple per user |
| `wearable_connections` | Connected devices (Apple, Google, etc.) | 1 per provider per user |
| `daily_health_metrics` | Daily aggregated health data | 1 per day per user |
| `hourly_health_metrics` | Hourly detailed metrics | Multiple per day |
| `supplements` | User's supplement regimen | Multiple per user |
| `supplement_logs` | Daily supplement intake tracking | Multiple per user |
| `digital_twins` | 3D avatar configuration | 1 per user |
| `ai_insights` | Generated health insights | Multiple per user |
| `health_goals` | User health goals | Multiple per user |
| `lab_results` | Blood test and lab results | Multiple per user |

### Views

| View | Purpose |
|------|---------|
| `weekly_health_summary` | Aggregated weekly metrics |
| `monthly_health_trends` | Monthly trend analysis |

### Security

- **Row Level Security (RLS)** enabled on all tables
- Users can only access their own data
- API keys required for all requests

## API Usage Examples

### Initialize Client

```javascript
const db = new LongevityDatabase(
    'https://your-project.supabase.co',
    'your-anon-key'
);
```

### User Operations

```javascript
// Create user
const user = await db.createUser({
    email: 'jose@aidesing.com',
    password_hash: 'hashed_password',
    first_name: 'Jose',
    last_name: 'Osorio',
    date_of_birth: '1986-08-19',
    gender: 'male'
});

// Get user
const userData = await db.getUser('user-uuid');

// Update user
await db.updateUser('user-uuid', {
    weight_kg: 85,
    height_cm: 180
});
```

### Biomarker Analysis

```javascript
// Save analysis results
await db.saveBiomarkerAnalysis({
    user_id: 'user-uuid',
    biological_age: 38,
    chronological_age: 40,
    health_score: 84,
    body_fat_percentage: 18.5,
    skin_age: 36,
    ai_insights: {
        summary: 'Good metabolic health',
        recommendations: ['Increase sleep', 'Reduce stress']
    }
});

// Get latest analysis
const latest = await db.getLatestBiomarkerAnalysis('user-uuid');
```

### Wearable Data

```javascript
// Connect wearable
await db.connectWearable('user-uuid', 'apple_health', {
    access_token: 'token-here',
    permissions_granted: ['heart_rate', 'sleep', 'activity']
});

// Sync daily metrics
await db.syncWearableData('user-uuid', 'apple_health', {
    steps: 8432,
    calories: 450,
    activeMinutes: 45,
    restingHR: 72,
    hrv: 65,
    sleepMinutes: 443,
    sleepScore: 78
});

// Get metrics history
const metrics = await db.getDailyMetrics('user-uuid', '2024-01-01', '2024-01-31');
```

### Digital Twin

```javascript
// Create twin
await db.createDigitalTwin('user-uuid', {
    heart_health: 95,
    lung_health: 90,
    liver_health: 85,
    kidney_health: 88,
    brain_health: 92,
    gut_health: 80
});

// Update organ health
await db.updateDigitalTwin('user-uuid', {
    heart_health: 96,
    last_updated: new Date().toISOString()
});
```

### AI Insights

```javascript
// Create insight
await db.createInsight('user-uuid', {
    insight_type: 'sleep',
    title: 'Sleep Optimization Needed',
    description: 'Your deep sleep has decreased 15%...',
    severity: 'warning',
    confidence_score: 0.85,
    recommendations: ['Take magnesium', 'Consistent bedtime']
});

// Get unread insights
const insights = await db.getInsights('user-uuid', true);
```

## Free Tier Limits

Supabase free tier includes:

| Resource | Limit |
|----------|-------|
| Database | 500 MB |
| Bandwidth | 2 GB/month |
| API Requests | Unlimited (fair use) |
| Auth Users | Unlimited |
| Realtime | 200 concurrent |

Estimated capacity:
- ~10,000 users with daily metrics
- ~100,000 biomarker analyses
- ~1,000,000 daily metric records

## Next Steps

1. ✅ Create Supabase project
2. ✅ Run schema.sql
3. ✅ Add config to web app
4. ⬜ Implement authentication flow
5. ⬜ Add data sync from wearables
6. ⬜ Set up real-time subscriptions
7. ⬜ Add backup strategy

## Support

- Supabase Docs: https://supabase.com/docs
- PostgreSQL Docs: https://www.postgresql.org/docs/
- AIDESING Support: jose@aidesing.com
