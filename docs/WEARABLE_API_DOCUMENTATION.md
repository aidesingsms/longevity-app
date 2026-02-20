# Wearable API Integration Documentation

## Overview

This document provides technical details for integrating with Apple HealthKit and Samsung Health APIs for the AIDESING Longevity App.

---

## Apple HealthKit Integration

### Platform Requirements
- **iOS Version:** 16.0+
- **Framework:** HealthKit (`import HealthKit`)
- **Permissions:** Requires user authorization for each data type

### Data Types Available

#### Heart Health
```swift
// Heart Rate
let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

// Heart Rate Variability (HRV)
let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!

// Resting Heart Rate
let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!

// Blood Pressure
let systolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic)!
let diastolicType = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic)!
```

#### Sleep Analysis
```swift
// Sleep Stages (iOS 16+)
let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
// Categories: .asleepCore, .asleepDeep, .asleepREM, .awake

// Sleep Duration
let sleepDurationType = HKQuantityType.quantityType(forIdentifier: .sleepDuration)!
```

#### Activity
```swift
// Steps
let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!

// Active Energy Burned
let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

// Exercise Time
let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!

// Stand Hours
let standType = HKCategoryType.categoryType(forIdentifier: .appleStandHour)!
```

#### Respiratory
```swift
// Blood Oxygen Saturation
let spo2Type = HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!

// Respiratory Rate
let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
```

#### Body Measurements
```swift
// Body Temperature
let temperatureType = HKQuantityType.quantityType(forIdentifier: .bodyTemperature)!

// Wrist Temperature (Apple Watch Series 8+)
let wristTemperatureType = HKQuantityType.quantityType(forIdentifier: .appleSleepingWristTemperature)!
```

### Authorization Request

```swift
import HealthKit

class HealthKitManager {
    let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        // Define types to read
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKQuantityType.quantityType(forIdentifier: .appleSleepingWristTemperature)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization granted")
            } else if let error = error {
                print("Authorization failed: \(error.localizedDescription)")
            }
        }
    }
}
```

### Fetching Data

```swift
func fetchHeartRateData(for date: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    let startDate = Calendar.current.startOfDay(for: date)
    let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
    
    let predicate = HKQuery.predicateForSamples(
        withStart: startDate,
        end: endDate,
        options: .strictStartDate
    )
    
    let query = HKSampleQuery(
        sampleType: heartRateType,
        predicate: predicate,
        limit: HKObjectQueryNoLimit,
        sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
    ) { query, samples, error in
        guard let samples = samples as? [HKQuantitySample], error == nil else {
            print("Error fetching heart rate: \(error?.localizedDescription ?? "Unknown")")
            completion([])
            return
        }
        completion(samples)
    }
    
    healthStore.execute(query)
}
```

### Background Delivery

```swift
func enableBackgroundDelivery() {
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
        if success {
            print("Background delivery enabled")
        } else {
            print("Failed to enable background delivery: \(error?.localizedDescription ?? "Unknown")")
        }
    }
}
```

### Query Types

1. **HKSampleQuery** - Fetch historical samples
2. **HKStatisticsQuery** - Aggregate data (min, max, avg, sum)
3. **HKStatisticsCollectionQuery** - Time-series aggregates
4. **HKObserverQuery** - Background updates
5. **HKAnchoredObjectQuery** - Incremental updates

---

## Samsung Health SDK Integration

### Platform Requirements
- **Android Version:** 8.0+ (API 26+)
- **SDK:** Samsung Health SDK 1.5.0+
- **Permissions:** Requires Samsung Health app installed

### Setup

#### build.gradle (Module: app)
```gradle
dependencies {
    implementation 'com.samsung.android.sdk:health:1.5.0'
    implementation 'com.samsung.android.sdk:healthdata:1.5.0'
}
```

#### AndroidManifest.xml
```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.BODY_SENSORS" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />

<application>
    <meta-data
        android:name="com.samsung.android.health.version"
        android:value="1.5" />
</application>
```

### Data Types

#### Step Count
```java
HealthDataResolver resolver = new HealthDataResolver(store, null);

HealthDataResolver.ReadRequest request = new HealthDataResolver.ReadRequest.Builder()
    .setDataType(HealthConstants.StepCount.HEALTH_DATA_TYPE)
    .setProperties(new String[]{
        HealthConstants.StepCount.COUNT,
        HealthConstants.StepCount.START_TIME,
        HealthConstants.StepCount.END_TIME
    })
    .setFilter(HealthDataResolver.Filter.and(
        HealthDataResolver.Filter.greaterThanEquals(HealthConstants.StepCount.START_TIME, startTime),
        HealthDataResolver.Filter.lessThanEquals(HealthConstants.StepCount.END_TIME, endTime)
    ))
    .build();

resolver.read(request).setResultListener(result -> {
    // Process results
});
```

#### Heart Rate
```java
HealthDataResolver.ReadRequest request = new HealthDataResolver.ReadRequest.Builder()
    .setDataType(HealthConstants.HeartRate.HEALTH_DATA_TYPE)
    .setProperties(new String[]{
        HealthConstants.HeartRate.HEART_RATE,
        HealthConstants.HeartRate.START_TIME
    })
    .setFilter(HealthDataResolver.Filter.greaterThanEquals(
        HealthConstants.HeartRate.START_TIME, startTime
    ))
    .build();
```

#### Sleep
```java
HealthDataResolver.ReadRequest request = new HealthDataResolver.ReadRequest.Builder()
    .setDataType(HealthConstants.Sleep.HEALTH_DATA_TYPE)
    .setProperties(new String[]{
        HealthConstants.Sleep.STAGE,
        HealthConstants.Sleep.START_TIME,
        HealthConstants.Sleep.END_TIME
    })
    .build();

// Sleep stages:
// SleepStage.SLEEP_STAGE_AWAKE = 40001
// SleepStage.SLEEP_STAGE_LIGHT = 40002
// SleepStage.SLEEP_STAGE_DEEP = 40003
// SleepStage.SLEEP_STAGE_REM = 40004
```

#### Blood Oxygen
```java
HealthDataResolver.ReadRequest request = new HealthDataResolver.ReadRequest.Builder()
    .setDataType(HealthConstants.OxygenSaturation.HEALTH_DATA_TYPE)
    .setProperties(new String[]{
        HealthConstants.OxygenSaturation.SPO2,
        HealthConstants.OxygenSaturation.START_TIME
    })
    .build();
```

### Connection Manager

```java
public class SamsungHealthManager {
    private HealthDataStore store;
    private ConnectionListener connectionListener;
    
    public interface ConnectionListener {
        void onConnected();
        void onDisconnected();
        void onConnectionFailed(HealthConnectionErrorResult error);
    }
    
    public void connect(Context context, ConnectionListener listener) {
        this.connectionListener = listener;
        
        store = new HealthDataStore(context, new HealthDataStore.ConnectionListener() {
            @Override
            public void onConnected() {
                connectionListener.onConnected();
            }
            
            @Override
            public void onDisconnected() {
                connectionListener.onDisconnected();
            }
            
            @Override
            public void onConnectionFailed(HealthConnectionErrorResult error) {
                connectionListener.onConnectionFailed(error);
            }
        });
        
        store.connectService();
    }
    
    public void disconnect() {
        if (store != null) {
            store.disconnectService();
        }
    }
    
    public HealthDataStore getStore() {
        return store;
    }
}
```

### Permission Request

```java
public void requestPermissions(Activity activity) {
    Set<HealthPermissionManager.PermissionKey> permissions = new HashSet<>();
    
    permissions.add(new HealthPermissionManager.PermissionKey(
        HealthConstants.StepCount.HEALTH_DATA_TYPE,
        HealthPermissionManager.PermissionType.READ
    ));
    permissions.add(new HealthPermissionManager.PermissionKey(
        HealthConstants.HeartRate.HEALTH_DATA_TYPE,
        HealthPermissionManager.PermissionType.READ
    ));
    permissions.add(new HealthPermissionManager.PermissionKey(
        HealthConstants.Sleep.HEALTH_DATA_TYPE,
        HealthPermissionManager.PermissionType.READ
    ));
    
    HealthPermissionManager permissionManager = new HealthPermissionManager(store);
    
    try {
        permissionManager.requestPermissions(permissions, activity)
            .setResultListener(result -> {
                Map<HealthPermissionManager.PermissionKey, Boolean> resultMap = result.getResultMap();
                // Check granted permissions
            });
    } catch (Exception e) {
        Log.e(TAG, "Permission request failed", e);
    }
}
```

---

## Other Wearable APIs

### Fitbit Web API

**Base URL:** `https://api.fitbit.com/1/user/-/`

**Authentication:** OAuth 2.0

**Key Endpoints:**
```
GET /activities/steps/date/today/1d.json
GET /activities/heart/date/today/1d/1min.json
GET /sleep/date/2024-01-01.json
GET /spo2/date/2024-01-01.json
```

**Rate Limits:**
- 150 requests per hour per user
- 1,500 requests per hour per application

### Garmin Health API

**Base URL:** `https://healthapi.garmin.com/wellness-api/rest/`

**Authentication:** OAuth 1.0a

**Key Endpoints:**
```
GET /activities?uploadStartTimeInSeconds={start}&uploadEndTimeInSeconds={end}
GET /sleeps?uploadStartTimeInSeconds={start}&uploadEndTimeInSeconds={end}
GET /heartRates?uploadStartTimeInSeconds={start}&uploadEndTimeInSeconds={end}
```

### Oura Cloud API v2

**Base URL:** `https://api.ouraring.com/v2/`

**Authentication:** Personal Access Token

**Key Endpoints:**
```
GET /usercollection/daily_activity
GET /usercollection/daily_sleep
GET /usercollection/daily_readiness
GET /usercollection/heartrate
```

### Whoop API v1

**Base URL:** `https://api.whoop.com/v1/`

**Authentication:** OAuth 2.0

**Key Endpoints:**
```
GET /activities
GET /cycles
GET /recoveries
GET /sleeps
```

---

## Data Mapping

### Unified Data Schema

```typescript
interface WearableData {
    deviceType: 'apple' | 'samsung' | 'fitbit' | 'garmin' | 'oura' | 'whoop';
    deviceId: string;
    timestamp: string;
    metrics: {
        heartRate?: {
            current: number;
            resting: number;
            min: number;
            max: number;
        };
        hrv?: {
            sdnn: number;
            rmssd: number;
        };
        steps?: number;
        sleep?: {
            totalMinutes: number;
            deepMinutes: number;
            remMinutes: number;
            lightMinutes: number;
            awakeMinutes: number;
            score: number;
        };
        spo2?: number;
        temperature?: {
            current: number;
            baseline: number;
            deviation: number;
        };
        activity?: {
            calories: number;
            activeMinutes: number;
            floors: number;
            distance: number;
        };
    };
}
```

### Field Mappings

| Metric | HealthKit | Samsung Health | Fitbit | Garmin | Oura | Whoop |
|--------|-----------|----------------|--------|--------|------|-------|
| Heart Rate | `heartRate` | `HeartRate.HEART_RATE` | `activities-heart` | `heartRates` | `heartrate` | `cycles.strain` |
| HRV | `heartRateVariabilitySDNN` | N/A | N/A | N/A | `daily_readiness.hrv` | `cycles.recovery.hrv` |
| Steps | `stepCount` | `StepCount.COUNT` | `activities-steps` | `activities` | `daily_activity.steps` | N/A |
| Sleep | `sleepAnalysis` | `Sleep.STAGE` | `sleep` | `sleeps` | `daily_sleep` | `sleeps` |
| SpO2 | `oxygenSaturation` | `OxygenSaturation.SPO2` | `spo2` | N/A | N/A | N/A |
| Temp | `appleSleepingWristTemperature` | N/A | N/A | N/A | `daily_sleep.temperature` | N/A |

---

## Implementation Best Practices

### 1. Error Handling
```javascript
async function fetchWearableData(deviceType) {
    try {
        const data = await api.getData();
        return { success: true, data };
    } catch (error) {
        if (error.code === 'AUTH_REQUIRED') {
            return { success: false, error: 'Re-authentication required' };
        }
        if (error.code === 'RATE_LIMITED') {
            return { success: false, error: 'Rate limit exceeded. Please try again later.' };
        }
        return { success: false, error: 'Failed to fetch data' };
    }
}
```

### 2. Data Caching
```javascript
const CACHE_DURATION = 5 * 60 * 1000; // 5 minutes

async function getCachedWearableData(userId) {
    const cacheKey = `wearable_data_${userId}`;
    const cached = Storage.get(cacheKey);
    
    if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
        return cached.data;
    }
    
    const fresh = await fetchWearableData();
    Storage.set(cacheKey, { data: fresh, timestamp: Date.now() });
    return fresh;
}
```

### 3. Background Sync
```javascript
// Register background sync
if ('serviceWorker' in navigator && 'sync' in registration) {
    await registration.sync.register('wearable-sync');
}

// In service worker
self.addEventListener('sync', event => {
    if (event.tag === 'wearable-sync') {
        event.waitUntil(syncWearableData());
    }
});
```

### 4. Privacy Compliance
- Always request explicit user consent
- Allow users to revoke permissions
- Implement data retention policies
- Provide data export functionality
- Anonymize data for analytics

---

## Testing

### HealthKit Testing
- Use iOS Simulator with Health app
- Create mock data in Health app
- Test permission flows
- Verify background delivery

### Samsung Health Testing
- Requires physical Samsung device
- Install Samsung Health app
- Enable developer mode
- Use Samsung Health test environment

---

## Resources

- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Samsung Health SDK Guide](https://developer.samsung.com/health)
- [Fitbit Web API Docs](https://dev.fitbit.com/build/reference/web-api/)
- [Garmin Health API](https://developer.garmin.com/health-api/)
- [Oura API Documentation](https://cloud.ouraring.com/docs/)
- [Whoop API Documentation](https://developer.whoop.com/)
