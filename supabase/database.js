// AIDESING Longevity App - Supabase Client
// JavaScript client for database operations

class LongevityDatabase {
    constructor(supabaseUrl, supabaseKey) {
        this.supabaseUrl = supabaseUrl;
        this.supabaseKey = supabaseKey;
        this.baseUrl = `${supabaseUrl}/rest/v1`;
    }

    // Helper: Make API request
    async request(endpoint, options = {}) {
        const url = `${this.baseUrl}${endpoint}`;
        const headers = {
            'apikey': this.supabaseKey,
            'Authorization': `Bearer ${this.supabaseKey}`,
            'Content-Type': 'application/json',
            ...options.headers
        };

        const response = await fetch(url, {
            ...options,
            headers
        });

        if (!response.ok) {
            const error = await response.json();
            throw new Error(error.message || 'Request failed');
        }

        return response.json();
    }

    // ============================================
    // USER OPERATIONS
    // ============================================
    
    async createUser(userData) {
        return this.request('/users', {
            method: 'POST',
            body: JSON.stringify(userData)
        });
    }

    async getUser(userId) {
        return this.request(`/users?id=eq.${userId}`);
    }

    async updateUser(userId, updates) {
        return this.request(`/users?id=eq.${userId}`, {
            method: 'PATCH',
            body: JSON.stringify(updates)
        });
    }

    // ============================================
    // BIOMARKER OPERATIONS
    // ============================================
    
    async saveBiomarkerAnalysis(analysisData) {
        return this.request('/biomarker_analyses', {
            method: 'POST',
            body: JSON.stringify(analysisData)
        });
    }

    async getBiomarkerAnalyses(userId, limit = 10) {
        return this.request(`/biomarker_analyses?user_id=eq.${userId}&order=analysis_date.desc&limit=${limit}`);
    }

    async getLatestBiomarkerAnalysis(userId) {
        const results = await this.request(`/biomarker_analyses?user_id=eq.${userId}&order=analysis_date.desc&limit=1`);
        return results[0] || null;
    }

    // ============================================
    // WEARABLE CONNECTIONS
    // ============================================
    
    async connectWearable(userId, provider, connectionData) {
        const data = {
            user_id: userId,
            provider,
            ...connectionData,
            is_connected: true,
            last_sync_at: new Date().toISOString()
        };
        
        return this.request('/wearable_connections', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getWearableConnections(userId) {
        return this.request(`/wearable_connections?user_id=eq.${userId}`);
    }

    async updateWearableSync(userId, provider) {
        return this.request(`/wearable_connections?user_id=eq.${userId}&provider=eq.${provider}`, {
            method: 'PATCH',
            body: JSON.stringify({
                last_sync_at: new Date().toISOString()
            })
        });
    }

    // ============================================
    // DAILY HEALTH METRICS
    // ============================================
    
    async saveDailyMetrics(userId, date, metrics) {
        const data = {
            user_id: userId,
            date,
            ...metrics,
            created_at: new Date().toISOString()
        };
        
        return this.request('/daily_health_metrics', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getDailyMetrics(userId, startDate, endDate) {
        return this.request(
            `/daily_health_metrics?user_id=eq.${userId}&date=gte.${startDate}&date=lte.${endDate}&order=date.desc`
        );
    }

    async getLatestDailyMetrics(userId) {
        const today = new Date().toISOString().split('T')[0];
        const results = await this.request(`/daily_health_metrics?user_id=eq.${userId}&date=eq.${today}`);
        return results[0] || null;
    }

    // ============================================
    // HOURLY METRICS
    // ============================================
    
    async saveHourlyMetrics(userId, metrics) {
        const data = {
            user_id: userId,
            timestamp: new Date().toISOString(),
            ...metrics
        };
        
        return this.request('/hourly_health_metrics', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getHourlyMetrics(userId, startTime, endTime) {
        return this.request(
            `/hourly_health_metrics?user_id=eq.${userId}&timestamp=gte.${startTime}&timestamp=lte.${endTime}&order=timestamp.desc`
        );
    }

    // ============================================
    // SUPPLEMENTS
    // ============================================
    
    async addSupplement(userId, supplementData) {
        const data = {
            user_id: userId,
            ...supplementData,
            created_at: new Date().toISOString()
        };
        
        return this.request('/supplements', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getSupplements(userId) {
        return this.request(`/supplements?user_id=eq.${userId}&is_active=eq.true`);
    }

    async logSupplement(userId, supplementId, logData) {
        const data = {
            user_id: userId,
            supplement_id: supplementId,
            ...logData,
            taken_at: new Date().toISOString()
        };
        
        return this.request('/supplement_logs', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    // ============================================
    // DIGITAL TWIN
    // ============================================
    
    async createDigitalTwin(userId, twinData) {
        const data = {
            user_id: userId,
            ...twinData,
            created_at: new Date().toISOString()
        };
        
        return this.request('/digital_twins', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getDigitalTwin(userId) {
        const results = await this.request(`/digital_twins?user_id=eq.${userId}`);
        return results[0] || null;
    }

    async updateDigitalTwin(userId, updates) {
        return this.request(`/digital_twins?user_id=eq.${userId}`, {
            method: 'PATCH',
            body: JSON.stringify({
                ...updates,
                last_updated: new Date().toISOString()
            })
        });
    }

    // ============================================
    // AI INSIGHTS
    // ============================================
    
    async createInsight(userId, insightData) {
        const data = {
            user_id: userId,
            ...insightData,
            generated_at: new Date().toISOString()
        };
        
        return this.request('/ai_insights', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getInsights(userId, unreadOnly = false) {
        let endpoint = `/ai_insights?user_id=eq.${userId}&order=generated_at.desc`;
        if (unreadOnly) {
            endpoint += '&is_read=eq.false';
        }
        return this.request(endpoint);
    }

    async markInsightRead(insightId) {
        return this.request(`/ai_insights?id=eq.${insightId}`, {
            method: 'PATCH',
            body: JSON.stringify({ is_read: true })
        });
    }

    // ============================================
    // HEALTH GOALS
    // ============================================
    
    async createGoal(userId, goalData) {
        const data = {
            user_id: userId,
            ...goalData,
            created_at: new Date().toISOString()
        };
        
        return this.request('/health_goals', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getGoals(userId) {
        return this.request(`/health_goals?user_id=eq.${userId}&order=created_at.desc`);
    }

    async updateGoalProgress(goalId, currentValue, progressPercentage) {
        return this.request(`/health_goals?id=eq.${goalId}`, {
            method: 'PATCH',
            body: JSON.stringify({
                current_value: currentValue,
                progress_percentage: progressPercentage,
                updated_at: new Date().toISOString()
            })
        });
    }

    // ============================================
    // LAB RESULTS
    // ============================================
    
    async saveLabResult(userId, labData) {
        const data = {
            user_id: userId,
            ...labData,
            created_at: new Date().toISOString()
        };
        
        return this.request('/lab_results', {
            method: 'POST',
            body: JSON.stringify(data)
        });
    }

    async getLabResults(userId) {
        return this.request(`/lab_results?user_id=eq.${userId}&order=test_date.desc`);
    }

    // ============================================
    // AGGREGATED QUERIES
    // ============================================
    
    async getWeeklySummary(userId) {
        // This would use the weekly_health_summary view
        // For now, we'll calculate manually
        const endDate = new Date().toISOString().split('T')[0];
        const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        
        const metrics = await this.getDailyMetrics(userId, startDate, endDate);
        
        if (metrics.length === 0) return null;
        
        const avg = (arr) => arr.reduce((a, b) => a + b, 0) / arr.length;
        
        return {
            week_start: startDate,
            avg_steps: Math.round(avg(metrics.map(m => m.steps).filter(Boolean))),
            avg_sleep_minutes: Math.round(avg(metrics.map(m => m.sleep_duration_minutes).filter(Boolean))),
            avg_resting_hr: Math.round(avg(metrics.map(m => m.resting_heart_rate).filter(Boolean))),
            avg_hrv: Math.round(avg(metrics.map(m => m.hrv_ms).filter(Boolean))),
            avg_health_score: Math.round(avg(metrics.map(m => m.overall_score).filter(Boolean))),
            days_logged: metrics.length
        };
    }

    async getHealthScoreHistory(userId, days = 30) {
        const endDate = new Date().toISOString().split('T')[0];
        const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
        
        const metrics = await this.getDailyMetrics(userId, startDate, endDate);
        
        return metrics.map(m => ({
            date: m.date,
            health_score: m.overall_score,
            activity_score: m.activity_score,
            sleep_score: m.sleep_score_computed,
            recovery_score: m.recovery_score
        })).reverse();
    }

    // ============================================
    // SYNC OPERATIONS
    // ============================================
    
    async syncWearableData(userId, provider, data) {
        // Save daily metrics
        const today = new Date().toISOString().split('T')[0];
        
        try {
            await this.saveDailyMetrics(userId, today, {
                steps: data.steps,
                calories_burned: data.calories,
                active_minutes: data.activeMinutes,
                resting_heart_rate: data.restingHR,
                avg_heart_rate: data.avgHR,
                hrv_ms: data.hrv,
                sleep_duration_minutes: data.sleepMinutes,
                deep_sleep_minutes: data.deepSleep,
                rem_sleep_minutes: data.remSleep,
                sleep_score_computed: data.sleepScore,
                spo2_avg: data.spo2,
                sources: [provider]
            });
            
            // Update last sync
            await this.updateWearableSync(userId, provider);
            
            return { success: true };
        } catch (error) {
            console.error('Sync failed:', error);
            return { success: false, error: error.message };
        }
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = LongevityDatabase;
}

// Example usage:
// const db = new LongevityDatabase('https://your-project.supabase.co', 'your-anon-key');
// const user = await db.getUser('user-uuid');
