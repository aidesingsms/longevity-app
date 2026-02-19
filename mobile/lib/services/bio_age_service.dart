import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class BioAgeService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Calculate biological age via Edge Function
  Future<BiologicalAgeResult> calculateBiologicalAge(BiometricData data) async {
    try {
      final response = await _supabase.functions.invoke(
        'calculate-bio-age',
        body: data.toJson(),
      );
      
      if (response.status != 200) {
        throw Exception('Failed to calculate: ${response.data}');
      }
      
      return BiologicalAgeResult.fromJson(response.data);
    } catch (e) {
      throw Exception('Error calculating biological age: $e');
    }
  }
  
  // Alternative: Calculate locally (fallback)
  BiologicalAgeResult calculateLocally(BiometricData data) {
    // BMI calculation
    final bmi = data.bmi;
    
    // Base biological age
    double bioAge = data.chronologicalAge.toDouble();
    
    // BMI adjustment
    if (bmi < 18.5) {
      bioAge += 1.5;
    } else if (bmi > 30) {
      bioAge += 3.0;
    } else if (bmi > 25) {
      bioAge += 1.0;
    } else if (bmi >= 22 && bmi <= 25) {
      bioAge -= 1.0;
    }
    
    // WHR adjustment
    final whr = data.waistHipRatio;
    if (whr != null) {
      if (data.gender == 'male' && whr > 0.95) {
        bioAge += 1.5;
      } else if (data.gender == 'female' && whr > 0.85) {
        bioAge += 1.5;
      }
    }
    
    // Exercise
    final exerciseScore = (data.exerciseFrequency * data.exerciseIntensity) / 12;
    bioAge -= exerciseScore * 2.5;
    
    // Sleep
    if (data.sleepHours >= 7 && data.sleepHours <= 9 && data.sleepQuality >= 4) {
      bioAge -= 1.5;
    } else if (data.sleepHours < 6 || data.sleepQuality <= 2) {
      bioAge += 1.5;
    }
    
    // Stress
    if (data.stressLevel >= 4) {
      bioAge += 1.0;
    } else if (data.stressLevel <= 2) {
      bioAge -= 0.5;
    }
    
    // Diet
    if (data.dietQuality >= 4) {
      bioAge -= 1.0;
    } else if (data.dietQuality <= 2) {
      bioAge += 1.0;
    }
    
    // Smoking
    final smokingPenalty = [0.0, 1.5, 3.0, 5.0];
    bioAge += smokingPenalty[data.smokingStatus.clamp(0, 3)];
    
    // Alcohol
    if (data.alcoholIntake >= 3) {
      bioAge += 1.0;
    }
    
    // Calculate results
    final ageDiff = bioAge - data.chronologicalAge;
    final velocity = bioAge / data.chronologicalAge;
    
    // Scores
    int lifestyle = 50;
    lifestyle += (exerciseScore * 1.5).round().clamp(0, 20);
    if (data.sleepHours >= 7 && data.sleepHours <= 9) lifestyle += 10;
    if (data.sleepQuality >= 4) lifestyle += 5;
    lifestyle += (data.dietQuality - 3) * 3;
    lifestyle += (5 - data.stressLevel) * 2;
    if (data.smokingStatus == 0) lifestyle += 15;
    if (data.alcoholIntake <= 1) lifestyle += 5;
    lifestyle = lifestyle.clamp(0, 100);
    
    int metabolic = 100;
    if (bmi < 18.5 || bmi > 30) metabolic -= 20;
    else if (bmi > 25) metabolic -= 10;
    
    int cardiovascular = 100;
    if (data.smokingStatus > 0) cardiovascular -= 15 * data.smokingStatus;
    
    int longevity = ((lifestyle + metabolic + cardiovascular) / 3).round();
    
    // Interpretation
    String interpretation;
    if (ageDiff < -3) {
      interpretation = "Your biological age is significantly younger than your chronological age. Excellent lifestyle habits!";
    } else if (ageDiff < 0) {
      interpretation = "Your biological age is younger than your chronological age. Keep up the good work!";
    } else if (ageDiff < 3) {
      interpretation = "Your biological age is close to your chronological age. Small improvements can make a big difference.";
    } else {
      interpretation = "Your biological age is older than your chronological age. Don't worry - lifestyle changes can reverse this.";
    }
    
    return BiologicalAgeResult(
      chronologicalAge: data.chronologicalAge,
      biologicalAge: bioAge,
      ageDifference: ageDiff,
      agingVelocity: velocity,
      longevityScore: longevity,
      componentScores: ComponentScores(
        lifestyle: lifestyle,
        metabolic: metabolic,
        cardiovascular: cardiovascular,
      ),
      bmi: bmi,
      interpretation: interpretation,
      algorithmVersion: '1.0.0-local',
    );
  }
  
  // Save measurement to database
  Future<void> saveMeasurement(BiometricData data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    await _supabase.from('measurements').insert({
      'user_id': userId,
      'weight_kg': data.weightKg,
      'height_cm': data.heightCm,
      'waist_cm': data.waistCm,
      'hip_cm': data.hipCm,
    });
  }
  
  // Save lifestyle assessment
  Future<void> saveLifestyleAssessment(BiometricData data) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    await _supabase.from('lifestyle_assessments').insert({
      'user_id': userId,
      'exercise_frequency': data.exerciseFrequency,
      'exercise_intensity': data.exerciseIntensity,
      'sleep_hours': data.sleepHours,
      'sleep_quality': data.sleepQuality,
      'stress_level': data.stressLevel,
      'diet_quality': data.dietQuality,
      'smoking_status': data.smokingStatus,
      'alcohol_intake': data.alcoholIntake,
    });
  }
  
  // Save biological age result
  Future<void> saveResult(BiologicalAgeResult result) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    await _supabase.from('biological_age_results').insert({
      'user_id': userId,
      'chronological_age': result.chronologicalAge,
      'biological_age': result.biologicalAge,
      'longevity_score': result.longevityScore,
      'aging_velocity': result.agingVelocity,
      'algorithm_version': result.algorithmVersion,
    });
  }
  
  // Get user's calculation history
  Future<List<Map>> getHistory() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');
    
    final response = await _supabase
        .from('biological_age_results')
        .select()
        .eq('user_id', userId)
        .order('calculated_at', ascending: false);
    
    return response;
  }
}
