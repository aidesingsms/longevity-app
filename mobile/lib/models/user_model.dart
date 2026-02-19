// User biometric and lifestyle data model
class BiometricData {
  final int chronologicalAge;
  final String gender;
  final double weightKg;
  final double heightCm;
  final double? waistCm;
  final double? hipCm;
  
  // Lifestyle
  final int exerciseFrequency;  // 0-4
  final int exerciseIntensity;  // 0-3
  final double sleepHours;
  final int sleepQuality;       // 1-5
  final int stressLevel;        // 1-5
  final int dietQuality;        // 1-5
  final int smokingStatus;      // 0-3
  final int alcoholIntake;      // 0-4
  
  BiometricData({
    required this.chronologicalAge,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
    this.waistCm,
    this.hipCm,
    this.exerciseFrequency = 0,
    this.exerciseIntensity = 0,
    this.sleepHours = 7.0,
    this.sleepQuality = 3,
    this.stressLevel = 3,
    this.dietQuality = 3,
    this.smokingStatus = 0,
    this.alcoholIntake = 0,
  });
  
  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }
  
  double? get waistHipRatio {
    if (waistCm != null && hipCm != null && hipCm! > 0) {
      return waistCm! / hipCm!;
    }
    return null;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'chronological_age': chronologicalAge,
      'gender': gender,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'waist_cm': waistCm,
      'hip_cm': hipCm,
      'exercise_frequency': exerciseFrequency,
      'exercise_intensity': exerciseIntensity,
      'sleep_hours': sleepHours,
      'sleep_quality': sleepQuality,
      'stress_level': stressLevel,
      'diet_quality': dietQuality,
      'smoking_status': smokingStatus,
      'alcohol_intake': alcoholIntake,
    };
  }
}

// Biological age calculation result
class BiologicalAgeResult {
  final int chronologicalAge;
  final double biologicalAge;
  final double ageDifference;
  final double agingVelocity;
  final int longevityScore;
  final ComponentScores componentScores;
  final double bmi;
  final String interpretation;
  final String algorithmVersion;
  
  BiologicalAgeResult({
    required this.chronologicalAge,
    required this.biologicalAge,
    required this.ageDifference,
    required this.agingVelocity,
    required this.longevityScore,
    required this.componentScores,
    required this.bmi,
    required this.interpretation,
    required this.algorithmVersion,
  });
  
  factory BiologicalAgeResult.fromJson(Map<String, dynamic> json) {
    return BiologicalAgeResult(
      chronologicalAge: json['chronological_age'],
      biologicalAge: json['biological_age'].toDouble(),
      ageDifference: json['age_difference'].toDouble(),
      agingVelocity: json['aging_velocity'].toDouble(),
      longevityScore: json['longevity_score'],
      componentScores: ComponentScores.fromJson(json['component_scores']),
      bmi: json['bmi'].toDouble(),
      interpretation: json['interpretation'],
      algorithmVersion: json['algorithm_version'],
    );
  }
}

class ComponentScores {
  final int lifestyle;
  final int metabolic;
  final int cardiovascular;
  
  ComponentScores({
    required this.lifestyle,
    required this.metabolic,
    required this.cardiovascular,
  });
  
  factory ComponentScores.fromJson(Map<String, dynamic> json) {
    return ComponentScores(
      lifestyle: json['lifestyle'],
      metabolic: json['metabolic'],
      cardiovascular: json['cardiovascular'],
    );
  }
}

// User profile
class UserProfile {
  final String id;
  final String email;
  final String? fullName;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  
  UserProfile({
    required this.id,
    required this.email,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    required this.createdAt,
  });
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      gender: json['gender'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
