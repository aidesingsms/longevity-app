# Supabase Setup Checklist for AIDESING Longevity

## ✅ Project Created
**URL:** https://lbqaeoqzflldiwtxlecd.supabase.co

## ⬜ Next Steps

### 1. Get Your Anon Key
1. Go to: https://supabase.com/dashboard/project/lbqaeoqzflldiwtxlecd/settings/api
2. Copy **Project API keys** → `anon public`
3. Looks like: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 2. Run Database Schema
1. Go to: https://supabase.com/dashboard/project/lbqaeoqzflldiwtxlecd/sql
2. Click "New Query"
3. Copy entire contents of `supabase/schema.sql`
4. Paste and click "Run"

### 3. Update Config File
Once you have the anon key, update:
```javascript
// web-demo/supabase-config.js
const SUPABASE_CONFIG = {
    url: 'https://lbqaeoqzflldiwtxlecd.supabase.co',
    anonKey: 'YOUR_REAL_ANON_KEY_HERE'
};
```

### 4. Test Connection
Open unified-dashboard.html and check browser console:
- ✅ "Connected to Supabase" = Success
- ⚠️ "Using LocalStorage fallback" = Check config

## 🔑 Security Note
Never commit the real anon key to public repos if it has sensitive permissions.
For this demo project, the anon key is safe to use in frontend code.
