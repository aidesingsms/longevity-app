/**
 * AIDESING Longevity App - Shared UI Components
 * Centralized UI utilities for consistent design and UX
 */

// ============================================
// TOAST NOTIFICATION SYSTEM
// ============================================

class ToastSystem {
    constructor() {
        this.container = null;
        this.queue = [];
        this.init();
    }

    init() {
        // Create toast container if it doesn't exist
        if (!document.getElementById('toast-container')) {
            this.container = document.createElement('div');
            this.container.id = 'toast-container';
            this.container.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                display: flex;
                flex-direction: column;
                gap: 10px;
                pointer-events: none;
            `;
            document.body.appendChild(this.container);
        } else {
            this.container = document.getElementById('toast-container');
        }
    }

    show(message, type = 'info', duration = 4000) {
        const toast = this.createToast(message, type);
        this.container.appendChild(toast);
        
        // Trigger animation
        requestAnimationFrame(() => {
            toast.style.transform = 'translateX(0)';
            toast.style.opacity = '1';
        });

        // Auto dismiss
        if (duration > 0) {
            setTimeout(() => this.dismiss(toast), duration);
        }

        return toast;
    }

    createToast(message, type) {
        const toast = document.createElement('div');
        const colors = {
            success: { bg: 'rgba(72, 187, 120, 0.95)', border: '#48bb78', icon: '✓' },
            error: { bg: 'rgba(245, 101, 101, 0.95)', border: '#f56565', icon: '✕' },
            warning: { bg: 'rgba(237, 137, 54, 0.95)', border: '#ed8936', icon: '!' },
            info: { bg: 'rgba(0, 212, 255, 0.95)', border: '#00d4ff', icon: 'i' }
        };

        const style = colors[type] || colors.info;

        toast.style.cssText = `
            background: ${style.bg};
            border: 1px solid ${style.border};
            border-radius: 12px;
            padding: 16px 20px;
            min-width: 300px;
            max-width: 400px;
            display: flex;
            align-items: center;
            gap: 12px;
            transform: translateX(100%);
            opacity: 0;
            transition: all 0.3s ease;
            pointer-events: auto;
            backdrop-filter: blur(10px);
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        `;

        toast.innerHTML = `
            <div style="
                width: 24px;
                height: 24px;
                border-radius: 50%;
                background: rgba(255, 255, 255, 0.2);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
                font-size: 14px;
                flex-shrink: 0;
            ">${style.icon}</div>
            <div style="flex: 1; color: white; font-size: 14px; line-height: 1.5;">${message}</div>
            <button style="
                background: none;
                border: none;
                color: white;
                cursor: pointer;
                font-size: 18px;
                opacity: 0.7;
                padding: 0;
                width: 24px;
                height: 24px;
                display: flex;
                align-items: center;
                justify-content: center;
            " onclick="this.parentElement.remove()">×</button>
        `;

        return toast;
    }

    dismiss(toast) {
        toast.style.transform = 'translateX(100%)';
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 300);
    }

    success(message, duration) { return this.show(message, 'success', duration); }
    error(message, duration) { return this.show(message, 'error', duration); }
    warning(message, duration) { return this.show(message, 'warning', duration); }
    info(message, duration) { return this.show(message, 'info', duration); }
}

// Global toast instance
const toast = new ToastSystem();

// ============================================
// LOADING SPINNER COMPONENT
// ============================================

class LoadingSpinner {
    constructor() {
        this.overlay = null;
        this.spinner = null;
    }

    show(message = 'Loading...') {
        if (this.overlay) return;

        this.overlay = document.createElement('div');
        this.overlay.style.cssText = `
            position: fixed;
            inset: 0;
            background: rgba(10, 14, 26, 0.9);
            backdrop-filter: blur(5px);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 9999;
            transition: opacity 0.3s ease;
        `;

        this.spinner = document.createElement('div');
        this.spinner.style.cssText = `
            width: 50px;
            height: 50px;
            border: 3px solid rgba(0, 212, 255, 0.2);
            border-top-color: #00d4ff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
        `;

        const style = document.createElement('style');
        style.textContent = `
            @keyframes spin { to { transform: rotate(360deg); } }
            @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
        `;
        document.head.appendChild(style);

        const text = document.createElement('div');
        text.textContent = message;
        text.style.cssText = `
            margin-top: 20px;
            color: #00d4ff;
            font-size: 14px;
            animation: pulse 1.5s ease-in-out infinite;
        `;

        this.overlay.appendChild(this.spinner);
        this.overlay.appendChild(text);
        document.body.appendChild(this.overlay);
    }

    hide() {
        if (!this.overlay) return;
        this.overlay.style.opacity = '0';
        setTimeout(() => {
            this.overlay?.remove();
            this.overlay = null;
        }, 300);
    }

    updateMessage(message) {
        if (this.overlay) {
            const text = this.overlay.querySelector('div:last-child');
            if (text) text.textContent = message;
        }
    }
}

// Global spinner instance
const spinner = new LoadingSpinner();

// ============================================
// SKELETON LOADER COMPONENT
// ============================================

class SkeletonLoader {
    static createCard(width = '100%', height = '120px') {
        const skeleton = document.createElement('div');
        skeleton.style.cssText = `
            width: ${width};
            height: ${height};
            background: linear-gradient(90deg, #1a202c 25%, #2d3748 50%, #1a202c 75%);
            background-size: 200% 100%;
            border-radius: 12px;
            animation: shimmer 1.5s infinite;
        `;
        return skeleton;
    }

    static createText(lines = 3, width = '100%') {
        const container = document.createElement('div');
        container.style.cssText = 'display: flex; flex-direction: column; gap: 8px; width: ' + width;
        
        for (let i = 0; i < lines; i++) {
            const line = document.createElement('div');
            const lineWidth = i === lines - 1 ? '60%' : '100%';
            line.style.cssText = `
                height: 12px;
                width: ${lineWidth};
                background: linear-gradient(90deg, #1a202c 25%, #2d3748 50%, #1a202c 75%);
                background-size: 200% 100%;
                border-radius: 6px;
                animation: shimmer 1.5s infinite;
                animation-delay: ${i * 0.1}s;
            `;
            container.appendChild(line);
        }

        // Add shimmer keyframes if not present
        if (!document.getElementById('skeleton-styles')) {
            const style = document.createElement('style');
            style.id = 'skeleton-styles';
            style.textContent = `
                @keyframes shimmer {
                    0% { background-position: 200% 0; }
                    100% { background-position: -200% 0; }
                }
            `;
            document.head.appendChild(style);
        }

        return container;
    }

    static createAvatar(size = '50px') {
        const avatar = document.createElement('div');
        avatar.style.cssText = `
            width: ${size};
            height: ${size};
            border-radius: 50%;
            background: linear-gradient(90deg, #1a202c 25%, #2d3748 50%, #1a202c 75%);
            background-size: 200% 100%;
            animation: shimmer 1.5s infinite;
        `;
        return avatar;
    }
}

// ============================================
// FORM VALIDATION UTILITIES
// ============================================

const FormValidator = {
    email(email) {
        const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return re.test(email);
    },

    password(password, minLength = 8) {
        return {
            valid: password.length >= minLength,
            hasLower: /[a-z]/.test(password),
            hasUpper: /[A-Z]/.test(password),
            hasNumber: /[0-9]/.test(password),
            hasSpecial: /[!@#$%^&*]/.test(password),
            length: password.length >= minLength
        };
    },

    required(value) {
        return value !== null && value !== undefined && value.toString().trim() !== '';
    },

    minLength(value, min) {
        return value.length >= min;
    },

    maxLength(value, max) {
        return value.length <= max;
    },

    number(value, min, max) {
        const num = parseFloat(value);
        if (isNaN(num)) return false;
        if (min !== undefined && num < min) return false;
        if (max !== undefined && num > max) return false;
        return true;
    },

    date(value, min, max) {
        const date = new Date(value);
        if (isNaN(date.getTime())) return false;
        if (min && date < new Date(min)) return false;
        if (max && date > new Date(max)) return false;
        return true;
    },

    showError(input, message) {
        // Remove existing error
        this.clearError(input);

        input.style.borderColor = '#f56565';
        input.style.boxShadow = '0 0 0 3px rgba(245, 101, 101, 0.3)';

        const error = document.createElement('div');
        error.className = 'form-error';
        error.textContent = message;
        error.style.cssText = `
            color: #f56565;
            font-size: 12px;
            margin-top: 4px;
            animation: fadeIn 0.2s ease;
        `;

        input.parentElement.appendChild(error);
    },

    clearError(input) {
        input.style.borderColor = '';
        input.style.boxShadow = '';
        const error = input.parentElement.querySelector('.form-error');
        if (error) error.remove();
    },

    clearAllErrors(form) {
        form.querySelectorAll('.form-error').forEach(el => el.remove());
        form.querySelectorAll('input, select, textarea').forEach(input => {
            input.style.borderColor = '';
            input.style.boxShadow = '';
        });
    }
};

// ============================================
// DEBOUNCE/THROTTLE UTILITIES
// ============================================

function debounce(func, wait = 300) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

function throttle(func, limit = 300) {
    let inThrottle;
    return function executedFunction(...args) {
        if (!inThrottle) {
            func(...args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// ============================================
// LOCAL STORAGE UTILITIES
// ============================================

const Storage = {
    set(key, value, ttl = null) {
        const item = {
            value,
            timestamp: Date.now(),
            ttl: ttl ? ttl * 1000 : null
        };
        localStorage.setItem(key, JSON.stringify(item));
    },

    get(key) {
        const item = localStorage.getItem(key);
        if (!item) return null;

        try {
            const parsed = JSON.parse(item);
            if (parsed.ttl && Date.now() - parsed.timestamp > parsed.ttl) {
                localStorage.removeItem(key);
                return null;
            }
            return parsed.value;
        } catch {
            return null;
        }
    },

    remove(key) {
        localStorage.removeItem(key);
    },

    clear() {
        localStorage.clear();
    }
};

// ============================================
// NETWORK STATUS MONITORING
// ============================================

class NetworkMonitor {
    constructor() {
        this.isOnline = navigator.onLine;
        this.listeners = [];
        this.init();
    }

    init() {
        window.addEventListener('online', () => {
            this.isOnline = true;
            this.notify('online');
            toast.success('Connection restored');
        });

        window.addEventListener('offline', () => {
            this.isOnline = false;
            this.notify('offline');
            toast.warning('Connection lost. Working offline.');
        });
    }

    on(event, callback) {
        this.listeners.push({ event, callback });
    }

    notify(event) {
        this.listeners
            .filter(l => l.event === event)
            .forEach(l => l.callback());
    }

    checkConnection() {
        return this.isOnline;
    }
}

const network = new NetworkMonitor();

// ============================================
// EXPORT FOR MODULE SYSTEMS
// ============================================

if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        ToastSystem,
        LoadingSpinner,
        SkeletonLoader,
        FormValidator,
        debounce,
        throttle,
        Storage,
        NetworkMonitor,
        toast,
        spinner,
        network
    };
}
