# Supabase Edge Function: calculate-bio-age
# Calculate biological age from user data

import json
from typing import Dict, Any

def main(request):
    """
    Calculate biological age endpoint
    
    Expected JSON body:
    {
        "chronological_age": 40,
        "gender": "male",
        "weight_kg": 75,
        "height_cm": 175,
        "waist_cm": 85,
        "hip_cm": 95,
        "exercise_frequency": 3,
        "exercise_intensity": 2,
        "sleep_hours": 7.5,
        "sleep_quality": 4,
        "stress_level": 2,
        "diet_quality": 4,
        "smoking_status": 0,
        "alcohol_intake": 1
    }
    """
    
    try:
        # Parse request body
        body = request.json()
        
        # Validate required fields
        required = ['chronological_age', 'gender', 'weight_kg', 'height_cm']
        for field in required:
            if field not in body:
                return {
                    "statusCode": 400,
                    "body": json.dumps({"error": f"Missing required field: {field}"})
                }
        
        # Import calculator (would be in same directory in production)
        # For now, inline the calculation
        result = calculate_biological_age(body)
        
        return {
            "statusCode": 200,
            "body": json.dumps(result)
        }
        
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }


def calculate_biological_age(data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Simplified biological age calculation for edge function
    """
    chronological_age = data['chronological_age']
    gender = data['gender']
    weight_kg = data['weight_kg']
    height_cm = data['height_cm']
    
    # Calculate BMI
    bmi = weight_kg / ((height_cm / 100) ** 2)
    
    # Base biological age
    bio_age = float(chronological_age)
    
    # BMI adjustment
    if bmi < 18.5:
        bio_age += 1.5
    elif bmi > 30:
        bio_age += 3.0
    elif bmi > 25:
        bio_age += 1.0
    elif 22 <= bmi <= 25:
        bio_age -= 1.0
    
    # Waist-hip ratio adjustment
    waist_cm = data.get('waist_cm', 0)
    hip_cm = data.get('hip_cm', 1)
    if hip_cm > 0:
        whr = waist_cm / hip_cm
        if gender == 'male' and whr > 0.95:
            bio_age += 1.5
        elif gender == 'female' and whr > 0.85:
            bio_age += 1.5
    
    # Lifestyle adjustments
    exercise_freq = data.get('exercise_frequency', 0)
    exercise_intensity = data.get('exercise_intensity', 0)
    exercise_score = (exercise_freq * exercise_intensity) / 12
    bio_age -= exercise_score * 2.5
    
    # Sleep
    sleep_hours = data.get('sleep_hours', 7)
    sleep_quality = data.get('sleep_quality', 3)
    if 7 <= sleep_hours <= 9 and sleep_quality >= 4:
        bio_age -= 1.5
    elif sleep_hours < 6 or sleep_quality <= 2:
        bio_age += 1.5
    
    # Stress
    stress = data.get('stress_level', 3)
    if stress >= 4:
        bio_age += 1.0
    elif stress <= 2:
        bio_age -= 0.5
    
    # Diet
    diet = data.get('diet_quality', 3)
    if diet >= 4:
        bio_age -= 1.0
    elif diet <= 2:
        bio_age += 1.0
    
    # Smoking
    smoking = data.get('smoking_status', 0)
    smoking_penalty = [0, 1.5, 3.0, 5.0]
    bio_age += smoking_penalty[min(smoking, 3)]
    
    # Alcohol
    alcohol = data.get('alcohol_intake', 0)
    if alcohol >= 3:
        bio_age += 1.0
    
    # Calculate scores
    age_diff = bio_age - chronological_age
    velocity = bio_age / chronological_age if chronological_age > 0 else 1.0
    
    # Lifestyle score (0-100)
    lifestyle = 50
    lifestyle += min((exercise_freq * exercise_intensity * 1.5), 20)
    if 7 <= sleep_hours <= 9:
        lifestyle += 10
    if sleep_quality >= 4:
        lifestyle += 5
    lifestyle += (diet - 3) * 3
    lifestyle += (5 - stress) * 2
    if smoking == 0:
        lifestyle += 15
    elif smoking == 1:
        lifestyle += 5
    if alcohol <= 1:
        lifestyle += 5
    lifestyle = max(0, min(100, lifestyle))
    
    # Metabolic score
    metabolic = 100
    if bmi < 18.5 or bmi > 30:
        metabolic -= 20
    elif bmi > 25:
        metabolic -= 10
    
    # Cardiovascular score
    cardiovascular = 100
    if smoking > 0:
        cardiovascular -= 15 * smoking
    
    # Longevity score
    longevity = int((lifestyle + metabolic + cardiovascular) / 3)
    
    # Interpretation
    if age_diff < -3:
        interpretation = "Your biological age is significantly younger than your chronological age. Excellent lifestyle habits!"
    elif age_diff < 0:
        interpretation = "Your biological age is younger than your chronological age. Keep up the good work!"
    elif age_diff < 3:
        interpretation = "Your biological age is close to your chronological age. Small improvements can make a big difference."
    else:
        interpretation = "Your biological age is older than your chronological age. Don't worry - lifestyle changes can reverse this."
    
    return {
        "chronological_age": chronological_age,
        "biological_age": round(bio_age, 2),
        "age_difference": round(age_diff, 2),
        "aging_velocity": round(velocity, 2),
        "longevity_score": longevity,
        "component_scores": {
            "lifestyle": lifestyle,
            "metabolic": metabolic,
            "cardiovascular": cardiovascular
        },
        "bmi": round(bmi, 2),
        "interpretation": interpretation,
        "algorithm_version": "1.0.0"
    }
