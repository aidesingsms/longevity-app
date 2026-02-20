// Supabase Configuration for AIDESING Longevity App
// Replace with your actual Supabase credentials after setup

const SUPABASE_CONFIG = {
    // Your Supabase project URL
    url: 'https://your-project.supabase.co',
    
    // Your Supabase anon/public key
    anonKey: 'your-anon-key-here',
    
    // Optional: Service role key (only for server-side operations)
    // serviceKey: 'your-service-key-here'
};

// Database instance (initialized after config is set)
let longevityDB = null;

// Initialize database connection
function initializeDatabase() {
    if (SUPABASE_CONFIG.url.includes('your-project')) {
        console.warn('⚠️ Supabase not configured yet. Using localStorage fallback.');
        return new LocalStorageDB();
    }
    
    longevityDB = new LongevityDatabase(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);
    console.log('✅ Connected to Supabase');
    return longevityDB;
}

// LocalStorage fallback for demo/testing
class LocalStorageDB {
    constructor() {
        this.prefix = 'longevity_';
        console.log('📦 Using LocalStorage fallback');
    }
    
    // User operations
    async getUser(userId) {
        const data = localStorage.getItem(`${this.prefix}user_${userId}`);
        return data ? JSON.parse(data) : null;
    }
    
    async updateUser(userId, updates) {
        const existing = await this.getUser(userId) || {};
        const updated = { ...existing, ...updates, updated_at: new Date().toISOString() };
        localStorage.setItem(`${this.prefix}user_${userId}`, JSON.stringify(updated));
        return updated;
    }
    
    // Biomarker operations
    async saveBiomarkerAnalysis(analysisData) {
        const key = `${this.prefix}biomarker_${analysisData.user_id}`;
        const existing = JSON.parse(localStorage.getItem(key) || '[]');
        existing.push({ ...analysisData, id: Date.now().toString() });
        localStorage.setItem(key, JSON.stringify(existing));
        return analysisData;
    }
    
    async getLatestBiomarkerAnalysis(userId) {
        const key = `${this.prefix}biomarker_${userId}`;
        const analyses = JSON.parse(localStorage.getItem(key) || '[]');
        return analyses.sort((a, b) => new Date(b.analysis_date) - new Date(a.analysis_date))[0] || null;
    }
    
    // Daily metrics
    async saveDailyMetrics(userId, date, metrics) {
        const key = `${this.prefix}metrics_${userId}_${date}`;
        localStorage.setItem(key, JSON.stringify({ ...metrics, date }));
        return metrics;
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
    
    // Wearable connections
    async getWearableConnections(userId) {
        const key = `${this.prefix}wearables_${userId}`;
        return JSON.parse(localStorage.getItem(key) || '[]');
    }
    
    async connectWearable(userId, provider, data) {
        const key = `${this.prefix}wearables_${userId}`;
        const existing = JSON.parse(localStorage.getItem(key) || '[]');
        const filtered = existing.filter(w => w.provider !== provider);
        filtered.push({ user_id: userId, provider, ...data, is_connected: true });
        localStorage.setItem(key, JSON.stringify(filtered));
        return data;
    }
    
    // AI Insights
    async createInsight(userId, insightData) {
        const key = `${this.prefix}insights_${userId}`;
        const existing = JSON.parse(localStorage.getItem(key) || '[]');
        const insight = { ...insightData, id: Date.now().toString(), is_read: false };
        existing.push(insight);
        localStorage.setItem(key, JSON.stringify(existing));
        return insight;
    }
    
    async getInsights(userId, unreadOnly = false) {
        const key = `${this.prefix}insights_${userId}`;
        const insights = JSON.parse(localStorage.getItem(key) || '[]');
        return unreadOnly ? insights.filter(i => !i.is_read) : insights;
    }
    
    // Digital Twin
    async getDigitalTwin(userId) {
        const key = `${this.prefix}twin_${userId}`;
        const data = localStorage.getItem(key);
        return data ? JSON.parse(data) : this.getDefaultTwin();
    }
    
    async updateDigitalTwin(userId, updates) {
        const key = `${this.prefix}twin_${userId}`;
        const existing = await this.getDigitalTwin(userId);
        const updated = { ...existing, ...updates, last_updated: new Date().toISOString() };
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

// Demo data generator for testing
function generateDemoData(userId) {
    const db = new LocalStorageDB();
    const today = new Date();
    
    // Generate 30 days of metrics
    for (let i = 0; i < 30; i++) {
        const date = new Date(today);
        date.setDate(date.getDate() - i);
        const dateStr = date.toISOString().split('T')[0];
        
        db.saveDailyMetrics(userId, dateStr, {
            steps: 6000 + Math.floor(Math.random() * 6000),
            calories_burned: 350 + Math.floor(Math.random() * 300),
            active_minutes: 30 + Math.floor(Math.random() * 60),
            resting_heart_rate: 60 + Math.floor(Math.random() * 15),
            hrv_ms: 50 + Math.floor(Math.random() * 30),
            sleep_duration_minutes: 400 + Math.floor(Math.random() * 120),
            sleep_score_computed: 70 + Math.floor(Math.random() * 25),
            overall_score: 75 + Math.floor(Math.random() * 20)
        });
    }
    
    // Add sample insights
    db.createInsight(userId, {
        insight_type: 'sleep',
        title: 'Sleep Optimization Needed',
        description: 'Your deep sleep has decreased 15% over the past week.',
        severity: 'warning',
        recommendations: ['Take magnesium', 'Consistent bedtime']
    });
    
    db.createInsight(userId, {
        insight_type: 'heart',
        title: 'Cardiovascular Health Improving',
        description: 'Great news! Your resting heart rate has decreased by 3 BPM.',
        severity: 'positive',
        recommendations: ['Keep current exercise routine']
    });
    
    console.log('✅ Demo data generated');
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    longevityDB = initializeDatabase();
    
    // Generate demo data if none exists
    const demoUserId = 'demo-user-123';
    if (!localStorage.getItem(`longevity_user_${demoUserId}`)) {
        generateDemoData(demoUserId);
    }
});
