# 🧬 AIDESING Longevity App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-green.svg)](https://supabase.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **Calculate your biological age, track your longevity journey, and optimize your healthspan.**

<p align="center">
  <img src="docs/screenshot.png" alt="Longevity App Screenshot" width="300"/>
</p>

## ✨ Features

### 🧮 Biological Age Calculator
- **Multi-algorithm approach**: Klemera-Doubal + Phenotypic Age ensemble
- **Lifestyle assessment**: Exercise, sleep, stress, diet, habits
- **Body composition**: BMI, waist-hip ratio analysis
- **Personalized insights**: Actionable recommendations

### 📊 Health Dashboard
- **Longevity Score**: 0-100 composite metric
- **Component Breakdown**: Lifestyle, Metabolic, Cardiovascular
- **Progress Tracking**: Historical trends and improvements
- **Visual Analytics**: Charts and visualizations

### 📱 Cross-Platform
- **iOS & Android**: Built with Flutter
- **Web Demo**: Instant browser testing
- **Responsive Design**: Works on all screen sizes

## 🚀 Quick Start

### Web Demo (No Installation)
```bash
# Open in browser
cd web-demo
open index.html  # or double-click
```

### Flutter App
```bash
# 1. Clone repository
git clone https://github.com/aidesing/longevity-app.git
cd longevity-app/mobile

# 2. Install dependencies
flutter pub get

# 3. Run app
flutter run
```

### Backend Setup
```bash
# 1. Create Supabase project
# https://supabase.com

# 2. Run database schema
psql -f backend/database_schema.sql

# 3. Deploy Edge Functions
supabase functions deploy calculate-bio-age
```

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         FLUTTER APP (iOS/Android)       │
│  • Camera: Full body photo capture      │
│  • Inputs: Biometrics & lifestyle       │
│  • ML: TensorFlow Lite on-device        │
│  • UI: Material Design 3                │
└─────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────┐
│      SUPABASE (Backend as a Service)    │
│  • Auth: Email, Google, Apple           │
│  • Database: PostgreSQL                 │
│  • Storage: User photos                 │
│  • Edge Functions: Python/ML            │
│  • Realtime: Live updates               │
└─────────────────────────────────────────┘
```

## 🧬 Biological Age Algorithm

### Inputs
| Parameter | Type | Description |
|-----------|------|-------------|
| `chronological_age` | int | Calendar age in years |
| `gender` | enum | male, female |
| `weight_kg` | float | Body weight |
| `height_cm` | float | Body height |
| `waist_cm` | float | Waist circumference |
| `hip_cm` | float | Hip circumference |
| `exercise_frequency` | 0-4 | Never to Daily |
| `exercise_intensity` | 0-3 | None to High |
| `sleep_hours` | float | Average sleep duration |
| `sleep_quality` | 1-5 | Poor to Excellent |
| `stress_level` | 1-5 | Low to High |
| `diet_quality` | 1-5 | Poor to Excellent |
| `smoking_status` | 0-3 | Never to Heavy |
| `alcohol_intake` | 0-4 | None to Heavy |

### Outputs
```json
{
  "chronological_age": 40,
  "biological_age": 38.5,
  "age_difference": -1.5,
  "aging_velocity": 0.96,
  "longevity_score": 85,
  "component_scores": {
    "lifestyle": 80,
    "metabolic": 85,
    "cardiovascular": 90
  },
  "bmi": 24.5,
  "interpretation": "Your biological age is younger..."
}
```

### Formula
```python
# Ensemble of validated algorithms
bio_age = (
    klemera_doubal_estimate() * 0.4 + 
    phenotypic_age_estimate() * 0.6
)

# Adjustments for lifestyle factors
bio_age += bmi_adjustment()
bio_age += exercise_adjustment()
bio_age += sleep_adjustment()
bio_age += stress_adjustment()
bio_age += smoking_penalty()
```

## 📁 Project Structure

```
longevity-app/
├── 📱 mobile/                    # Flutter application
│   ├── lib/
│   │   ├── screens/             # UI screens
│   │   ├── widgets/             # Reusable components
│   │   ├── models/              # Data models
│   │   ├── services/            # API & business logic
│   │   ├── blocs/               # State management
│   │   └── utils/               # Helpers & constants
│   ├── assets/
│   │   ├── images/              # App images
│   │   ├── icons/               # Custom icons
│   │   └── models/              # TensorFlow Lite models
│   └── test/                    # Unit tests
│
├── 🌐 web-demo/                 # Browser demo
│   └── index.html               # Standalone web version
│
├── ⚙️ backend/                  # Server-side
│   ├── database_schema.sql      # PostgreSQL schema
│   ├── bio_age_calculator.py    # Python algorithm
│   └── functions/               # Supabase Edge Functions
│       └── calculate-bio-age/
│           └── index.py
│
├── 🤖 ml_models/                # Machine learning
│   ├── pose_estimation/         # Body pose detection
│   └── body_composition/        # Body fat estimation
│
└── 📚 docs/                     # Documentation
    ├── api.md                   # API reference
    ├── algorithm.md             # Algorithm details
    └── screenshots/             # App screenshots
```

## 🛠️ Development

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- [Dart](https://dart.dev/get-dart) 3.x
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/)
- [Supabase CLI](https://supabase.com/docs/guides/cli)

### Setup
```bash
# Clone repo
git clone https://github.com/aidesing/longevity-app.git
cd longevity-app

# Setup Flutter
cd mobile
flutter pub get

# Setup Supabase (optional)
cd ../backend
supabase login
supabase link --project-ref your-project-ref

# Run tests
flutter test
```

### Contributing
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

## 📋 Roadmap

### Phase 1: MVP ✅
- [x] Biological age algorithm
- [x] Web demo
- [x] Flutter project structure
- [x] Database schema

### Phase 2: Core Features 🚧
- [ ] User authentication
- [ ] Photo capture & upload
- [ ] Results history
- [ ] Basic recommendations

### Phase 3: AI/ML 🔮
- [ ] Pose estimation (TensorFlow Lite)
- [ ] Body composition analysis
- [ ] Progress photos comparison
- [ ] Personalized routines

### Phase 4: Advanced 🚀
- [ ] 3D digital twin
- [ ] Wearable integration
- [ ] Social features
- [ ] Premium subscriptions

## 📄 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Acknowledgments

- [Klemera & Doubal (2006)](https://pubmed.ncbi.nlm.nih.gov/16368241/) - Biological age estimation
- [Levine et al. (2018)](https://pubmed.ncbi.nlm.nih.gov/29676998/) - Phenotypic Age
- [Supabase](https://supabase.com) - Backend infrastructure
- [Flutter](https://flutter.dev) - Cross-platform framework

---

<p align="center">
  <b>Built with 💙 by AIDESING SMART SOLUTIONS</b><br>
  <a href="https://aidesing.com">Website</a> •
  <a href="mailto:aidesingsmartsolutions@gmail.com">Email</a> •
  <a href="https://instagram.com/aidesing">Instagram</a>
</p>
