// Supabase Configuration for AIDESING Longevity App
// Active connection to live database
// Timezone: America/New_York (Tampa, Florida)

const SUPABASE_CONFIG = {
    url: 'https://lbqaeoqzflldiwtxlecd.supabase.co',
    anonKey: 'sb_publishable_HfK2VZMmAglXlZm9dCKz_g_nOwI3RSH',
    timezone: 'America/New_York' // Tampa, Florida timezone
};

// Initialize database connection
let longevityDB = null;

function initializeDatabase() {
    longevityDB = new LongevityDatabase(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
    console.log('✅ Connected to Supabase');
    return longevityDB;
}

// Longevity Database Client
class LongevityDatabase {
    constructor(supabaseUrl, supabaseKey) {
        this.baseUrl = `${supabaseUrl}/rest/v1`;
        this.headers = {
            'apikey': supabaseKey,
            'Authorization': `Bearer ${supabaseKey}`,
            'Content-Type': 'application/json'
        };
    }

    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const response = await fetch(url, {
            ...options,
            headers: { ...this.headers, ...options.headers }
        });
        
        if (!response.ok) {
            const error = await response.text();
            throw new Error(error);
        }
        return response.json();
    }

    // User operations
    async createUser(userData) {
        return this.request('/users', {
            method: 'POST',
            body: JSON.stringify(userData)
        });
    }

    async getUser(userId) {
        const results = await this.request(`/users?id=eq.${userId}`);
        return results[0];
    }

    // Biomarker operations
    async saveBiomarkerAnalysis(data) {
        return this.request('/biomarker_analyses', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getLatestBiomarkerAnalysis(userId) {
        const results = await this.request(`/biomarker_analyses?user_id=eq.${userId}&order=analysis_date.desc&limit=1`);
        return results[0];
    }

    // Daily metrics
    async saveDailyMetrics(data) {
        return this.request('/daily_health_metrics', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getDailyMetrics(userId, startDate, endDate) {
        return this.request(`/daily_health_metrics?user_id=eq.${userId}&date=gte.${startDate}&date=lte.${endDate}&order=date.desc`);
    }

    async getLatestDailyMetrics(userId) {
        const today = new Date().toISOString().split('T')[0];
        const results = await this.request(`/daily_health_metrics?user_id=eq.${userId}&date=eq.${today}`);
        return results[0];
    }

    // Wearable connections
    async getWearableConnections(userId) {
        return this.request(`/wearable_connections?user_id=eq.${userId}`);
    }

    async connectWearable(data) {
        return this.request('/wearable_connections', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    // AI Insights
    async getInsights(userId, unreadOnly = false) {
        let url = `/ai_insights?user_id=eq.${userId}&order=generated_at.desc`;
        if (unreadOnly) url += '&is_read=eq.false';
        return this.request(url);
    }

    async createInsight(data) {
        return this.request('/ai_insights', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async markInsightRead(insightId) {
        return this.request(`/ai_insights?id=eq.${insightId}`, {
            method: 'PATCH',
            body: JSON.stringify({ is_read: true })
        });
    }

    // Digital Twin
    async getDigitalTwin(userId) {
        const results = await this.request(`/digital_twins?user_id=eq.${userId}`);
        return results[0];
    }

    async updateDigitalTwin(userId, data) {
        return this.request(`/digital_twins?user_id=eq.${userId}`, {
            method: 'PATCH',
            body: JSON.stringify({ ...data, last_updated: new Date().toISOString() })
        });
    }

    // Aggregated data
    async getWeeklySummary(userId) {
        const results = await this.request(`/weekly_health_summary?user_id=eq.${userId}&limit=1`);
        return results[0];
    }

    async getHealthScoreHistory(userId, days = 30) {
        const endDate = new Date().toISOString().split('T')[0];
        const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        return this.request(`/daily_health_metrics?user_id=eq.${userId}&date=gte.${startDate}&date=lte.${endDate}&order=date.asc`);
    }
}

// Initialize on load
document.addEventListener('DOMContentLoaded', () => {
    initializeDatabase();
});
