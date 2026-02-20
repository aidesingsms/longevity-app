// Supabase Configuration for AIDESING Longevity App
// Fallback to localStorage if Supabase fails

const SUPABASE_CONFIG = {
    url: 'https://lbqaeoqzflldiwtxlecd.supabase.co',
    anonKey: 'sb_publishable_HfK2VZMmAglXlZm9dCKz_g_nOwI3RSH',
    timezone: 'America/New_York'
};

// Initialize database connection
let longevityDB = null;
let useLocalStorage = false;

function initializeDatabase() {
    try {
        longevityDB = new LongevityDatabase(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
        console.log('✅ Connected to Supabase');
        return longevityDB;
    } catch (error) {
        console.warn('⚠️ Supabase connection failed, using localStorage fallback');
        useLocalStorage = true;
        longevityDB = new LocalStorageDB();
        return longevityDB;
    }
}

// LocalStorage fallback for when Supabase fails
class LocalStorageDB {
    constructor() {
        this.prefix = 'longevity_';
        console.log('📦 Using LocalStorage fallback');
    }
    
    // User operations
    async createUser(userData) {
        const users = JSON.parse(localStorage.getItem(`${this.prefix}users`) || '[]');
        
        // Check if email already exists
        if (users.find(u => u.email === userData.email)) {
            throw new Error('Email already registered');
        }
        
        const newUser = {
            id: 'user_' + Date.now(),
            ...userData,
            created_at: new Date().toISOString()
        };
        
        users.push(newUser);
        localStorage.setItem(`${this.prefix}users`, JSON.stringify(users));
        
        // Create digital twin
        await this.updateDigitalTwin(newUser.id, {
            user_id: newUser.id,
            heart_health: 95,
            lung_health: 90,
            liver_health: 85,
            kidney_health: 88,
            brain_health: 92,
            gut_health: 80
        });
        
        // Create welcome insight
        await this.createInsight({
            user_id: newUser.id,
            insight_type: 'general',
            title: 'Welcome to AIDESING Longevity!',
            description: 'Your account has been created successfully. Start by connecting your wearables and uploading your first biomarker photos.',
            severity: 'positive',
            generated_at: new Date().toISOString()
        });
        
        return [newUser];
    }
    
    async getUser(userId) {
        const users = JSON.parse(localStorage.getItem(`${this.prefix}users`) || '[]');
        return users.find(u => u.id === userId);
    }
    
    async findUserByEmail(email) {
        const users = JSON.parse(localStorage.getItem(`${this.prefix}users`) || '[]');
        return users.find(u => u.email === email);
    }
    
    async updateUser(userId, updates) {
        const users = JSON.parse(localStorage.getItem(`${this.prefix}users`) || '[]');
        const index = users.findIndex(u => u.id === userId);
        if (index !== -1) {
            users[index] = { ...users[index], ...updates, updated_at: new Date().toISOString() };
            localStorage.setItem(`${this.prefix}users`, JSON.stringify(users));
            return users[index];
        }
        return null;
    }
    
    // Biomarker operations
    async saveBiomarkerAnalysis(data) {
        const key = `${this.prefix}biomarker_${data.user_id}`;
        const analyses = JSON.parse(localStorage.getItem(key) || '[]');
        analyses.push({ ...data, id: Date.now().toString() });
        localStorage.setItem(key, JSON.stringify(analyses));
        return data;
    }
    
    async getLatestBiomarkerAnalysis(userId) {
        const key = `${this.prefix}biomarker_${userId}`;
        const analyses = JSON.parse(localStorage.getItem(key) || '[]');
        return analyses.sort((a, b) => new Date(b.analysis_date) - new Date(a.analysis_date))[0] || null;
    }
    
    // Daily metrics
    async saveDailyMetrics(data) {
        const key = `${this.prefix}metrics_${data.user_id}_${data.date}`;
        localStorage.setItem(key, JSON.stringify(data));
        return data;
    }
    
    async getDailyMetrics(userId, startDate, endDate) {
        const metrics = [];
        const start = new Date(startDate);
        const end = new Date(endDate);
        
        for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
            const dateStr = d.toISOString().split('T')[0];
            const key = `${this.prefix}metrics_${userId}_${dateStr}`;
            const data = localStorage.getItem(key);
            if (data) {
                metrics.push(JSON.parse(data));
            }
        }
        
        return metrics;
    }
    
    async getLatestDailyMetrics(userId) {
        const today = new Date().toISOString().split('T')[0];
        const key = `${this.prefix}metrics_${userId}_${today}`;
        const data = localStorage.getItem(key);
        return data ? JSON.parse(data) : null;
    }
    
    // Wearable connections
    async getWearableConnections(userId) {
        const key = `${this.prefix}wearables_${userId}`;
        return JSON.parse(localStorage.getItem(key) || '[]');
    }
    
    async connectWearable(data) {
        const key = `${this.prefix}wearables_${data.user_id}`;
        const connections = JSON.parse(localStorage.getItem(key) || '[]');
        const filtered = connections.filter(w => w.provider !== data.provider);
        filtered.push({ ...data, is_connected: true });
        localStorage.setItem(key, JSON.stringify(filtered));
        return data;
    }
    
    // AI Insights
    async getInsights(userId, unreadOnly = false) {
        const key = `${this.prefix}insights_${userId}`;
        const insights = JSON.parse(localStorage.getItem(key) || '[]');
        return unreadOnly ? insights.filter(i => !i.is_read) : insights;
    }
    
    async createInsight(data) {
        const key = `${this.prefix}insights_${data.user_id}`;
        const insights = JSON.parse(localStorage.getItem(key) || '[]');
        insights.push({ ...data, id: Date.now().toString(), is_read: false });
        localStorage.setItem(key, JSON.stringify(insights));
        return data;
    }
    
    async markInsightRead(insightId) {
        // Find in all user insights
        for (let i = 0; i < localStorage.length; i++) {
            const key = localStorage.key(i);
            if (key && key.startsWith(`${this.prefix}insights_`)) {
                const insights = JSON.parse(localStorage.getItem(key) || '[]');
                const insight = insights.find(ins => ins.id === insightId);
                if (insight) {
                    insight.is_read = true;
                    localStorage.setItem(key, JSON.stringify(insights));
                    return insight;
                }
            }
        }
        return null;
    }
    
    // Digital Twin
    async getDigitalTwin(userId) {
        const key = `${this.prefix}twin_${userId}`;
        const data = localStorage.getItem(key);
        return data ? JSON.parse(data) : this.getDefaultTwin();
    }
    
    async updateDigitalTwin(userId, data) {
        const key = `${this.prefix}twin_${userId}`;
        const existing = await this.getDigitalTwin(userId);
        const updated = { ...existing, ...data, last_updated: new Date().toISOString() };
        localStorage.setItem(key, JSON.stringify(updated));
        return updated;
    }
    
    getDefaultTwin() {
        return {
            heart_health: 95,
            lung_health: 90,
            liver_health: 85,
            kidney_health: 88,
            brain_health: 92,
            gut_health: 80
        };
    }
    
    // Aggregated queries
    async getWeeklySummary(userId) {
        const endDate = new Date().toISOString().split('T')[0];
        const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        const metrics = await this.getDailyMetrics(userId, startDate, endDate);
        
        if (metrics.length === 0) return null;
        
        const avg = arr => arr.reduce((a, b) => a + b, 0) / arr.length;
        
        return {
            week_start: startDate,
            avg_steps: Math.round(avg(metrics.map(m => m.steps).filter(Boolean)) || 0),
            avg_sleep_minutes: Math.round(avg(metrics.map(m => m.sleep_duration_minutes).filter(Boolean)) || 0),
            avg_resting_hr: Math.round(avg(metrics.map(m => m.resting_heart_rate).filter(Boolean)) || 0),
            avg_hrv: Math.round(avg(metrics.map(m => m.hrv_ms).filter(Boolean)) || 0),
            days_logged: metrics.length
        };
    }
    
    async getHealthScoreHistory(userId, days = 30) {
        const endDate = new Date().toISOString().split('T')[0];
        const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        const metrics = await this.getDailyMetrics(userId, startDate, endDate);
        
        return metrics.map(m => ({
            date: m.date,
            health_score: m.overall_score || 70,
            activity_score: m.activity_score || 70,
            sleep_score: m.sleep_score_computed || 70,
            recovery_score: m.recovery_score || 70
        })).reverse();
    }
}

// Supabase Database Client (original)
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
    
    async findUserByEmail(email) {
        const results = await this.request(`/users?email=eq.${encodeURIComponent(email)}`);
        return results[0];
    }

    async updateUser(userId, updates) {
        return this.request(`/users?id=eq.${userId}`, {
            method: 'PATCH',
            body: JSON.stringify(updates)
        });
    }

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

    async getWearableConnections(userId) {
        return this.request(`/wearable_connections?user_id=eq.${userId}`);
    }

    async connectWearable(data) {
        return this.request('/wearable_connections', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

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
