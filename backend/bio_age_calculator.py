"""
Biological Age Calculator
Algorithms for estimating biological age based on phenotypic markers
"""

import numpy as np
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass

@dataclass
class BiometricData:
    """User biometric and lifestyle data"""
    chronological_age: int
    gender: str  # 'male', 'female', 'other'
    weight_kg: float
    height_cm: float
    waist_cm: Optional[float] = None
    hip_cm: Optional[float] = None
    
    # Lifestyle factors (0-4 or 1-5 scales)
    exercise_frequency: int = 0  # 0=never, 4=daily
    exercise_intensity: int = 0  # 0=none, 3=high
    sleep_hours: float = 7.0
    sleep_quality: int = 3  # 1-5
    stress_level: int = 3  # 1-5
    diet_quality: int = 3  # 1-5
    smoking_status: int = 0  # 0=never, 3=heavy
    alcohol_intake: int = 0  # 0=none, 4=heavy


class BiologicalAgeCalculator:
    """
    Calculate biological age using multiple algorithms
    
    References:
    - Klemera & Doubal method (2006)
    - Levine's Phenotypic Age (2018)
    - Modified for visual/self-reported biomarkers
    """
    
    def __init__(self):
        self.algorithm_version = "1.0.0"
        
    def calculate_bmi(self, weight_kg: float, height_cm: float) -> float:
        """Calculate BMI"""
        height_m = height_cm / 100
        return weight_kg / (height_m ** 2)
    
    def calculate_waist_hip_ratio(self, waist_cm: float, hip_cm: float) -> float:
        """Calculate waist-to-hip ratio"""
        if hip_cm > 0:
            return waist_cm / hip_cm
        return 0.0
    
    def klemera_doubal_estimate(self, data: BiometricData) -> Dict:
        """
        Modified Klemera-Doubal method
        Uses BMI, waist-hip ratio, and lifestyle factors
        """
        bmi = self.calculate_bmi(data.weight_kg, data.height_cm)
        whr = self.calculate_waist_hip_ratio(
            data.waist_cm or 0, 
            data.hip_cm or 1
        )
        
        # Base calculation from chronological age
        bio_age = float(data.chronological_age)
        
        # BMI adjustment (optimal BMI ~22-25)
        if bmi < 18.5:  # Underweight
            bio_age += 1.5
        elif bmi > 30:  # Obese
            bio_age += 3.0
        elif bmi > 25:  # Overweight
            bio_age += 1.0
        elif 22 <= bmi <= 25:  # Optimal
            bio_age -= 1.0
        
        # Waist-hip ratio adjustment (health risk indicator)
        if data.gender == 'male':
            if whr > 0.95:
                bio_age += 1.5
            elif whr < 0.90:
                bio_age -= 0.5
        else:  # female
            if whr > 0.85:
                bio_age += 1.5
            elif whr < 0.80:
                bio_age -= 0.5
        
        return {
            'biological_age': round(bio_age, 2),
            'components': {
                'bmi_contribution': round(bio_age - data.chronological_age, 2),
                'whr_contribution': 0.0  # Already included above
            }
        }
    
    def phenotypic_age_estimate(self, data: BiometricData) -> Dict:
        """
        Modified Phenotypic Age algorithm (Levine et al.)
        Adapted for self-reported lifestyle data
        """
        # Base score from chronological age
        score = float(data.chronological_age) * 0.1
        
        # Exercise factor (strongest lifestyle predictor)
        exercise_score = (data.exercise_frequency * data.exercise_intensity) / 12
        score -= exercise_score * 2.5  # Up to -2.5 years
        
        # Sleep factor
        sleep_optimal = 7.0 <= data.sleep_hours <= 9.0
        if sleep_optimal and data.sleep_quality >= 4:
            score -= 1.5
        elif data.sleep_hours < 6 or data.sleep_quality <= 2:
            score += 1.5
        
        # Stress factor
        if data.stress_level >= 4:
            score += 1.0
        elif data.stress_level <= 2:
            score -= 0.5
        
        # Diet factor
        if data.diet_quality >= 4:
            score -= 1.0
        elif data.diet_quality <= 2:
            score += 1.0
        
        # Smoking (major aging accelerator)
        smoking_penalty = [0, 1.5, 3.0, 5.0]  # never, former, light, heavy
        score += smoking_penalty[min(data.smoking_status, 3)]
        
        # Alcohol
        if data.alcohol_intake >= 3:  # Heavy
            score += 1.0
        
        # Convert score to biological age
        bio_age = score * 10
        
        return {
            'biological_age': round(bio_age, 2),
            'score': round(score, 3)
        }
    
    def lifestyle_score(self, data: BiometricData) -> int:
        """
        Calculate overall lifestyle score (0-100)
        """
        score = 50  # Base score
        
        # Exercise (+20 max)
        exercise_points = (data.exercise_frequency * data.exercise_intensity * 1.5)
        score += min(exercise_points, 20)
        
        # Sleep (+15 max)
        if 7 <= data.sleep_hours <= 9:
            score += 10
        if data.sleep_quality >= 4:
            score += 5
        
        # Diet (+15 max)
        score += (data.diet_quality - 3) * 3
        
        # Stress management (+10 max)
        score += (5 - data.stress_level) * 2
        
        # No smoking (+15)
        if data.smoking_status == 0:
            score += 15
        elif data.smoking_status == 1:
            score += 5
        
        # Alcohol moderation (+5)
        if data.alcohol_intake <= 1:
            score += 5
        
        return max(0, min(100, int(score)))
    
    def calculate(self, data: BiometricData) -> Dict:
        """
        Main calculation using ensemble of methods
        """
        # Get estimates from different algorithms
        klemera = self.klemera_doubal_estimate(data)
        phenotypic = self.phenotypic_age_estimate(data)
        
        # Ensemble: weighted average
        # Phenotypic gets more weight as it uses more lifestyle factors
        bio_age = (klemera['biological_age'] * 0.4 + 
                   phenotypic['biological_age'] * 0.6)
        
        # Calculate age difference
        age_diff = bio_age - data.chronological_age
        
        # Calculate aging velocity (relative to chronological)
        if data.chronological_age > 0:
            velocity = bio_age / data.chronological_age
        else:
            velocity = 1.0
        
        # Component scores
        lifestyle = self.lifestyle_score(data)
        
        # Metabolic score based on BMI and WHR
        bmi = self.calculate_bmi(data.weight_kg, data.height_cm)
        metabolic = 100
        if bmi < 18.5 or bmi > 30:
            metabolic -= 20
        elif bmi > 25:
            metabolic -= 10
        
        # Cardiovascular score (simplified)
        cardiovascular = 100
        if data.smoking_status > 0:
            cardiovascular -= 15 * data.smoking_status
        
        # Longevity score (composite)
        longevity = int((lifestyle + metabolic + cardiovascular) / 3)
        
        return {
            'chronological_age': data.chronological_age,
            'biological_age': round(bio_age, 2),
            'age_difference': round(age_diff, 2),
            'aging_velocity': round(velocity, 2),
            'longevity_score': longevity,
            'component_scores': {
                'lifestyle': lifestyle,
                'metabolic': metabolic,
                'cardiovascular': cardiovascular
            },
            'algorithm_details': {
                'version': self.algorithm_version,
                'klemera_estimate': klemera['biological_age'],
                'phenotypic_estimate': phenotypic['biological_age']
            },
            'interpretation': self._interpret_results(bio_age, age_diff, longevity)
        }
    
    def _interpret_results(self, bio_age: float, age_diff: float, 
                          longevity_score: int) -> str:
        """Generate human-readable interpretation"""
        if age_diff < -3:
            return "Your biological age is significantly younger than your chronological age. Excellent lifestyle habits!"
        elif age_diff < 0:
            return "Your biological age is younger than your chronological age. Keep up the good work!"
        elif age_diff < 3:
            return "Your biological age is close to your chronological age. Small improvements can make a big difference."
        else:
            return "Your biological age is older than your chronological age. Don't worry - lifestyle changes can reverse this."


# Example usage
if __name__ == "__main__":
    # Test with sample data
    test_data = BiometricData(
        chronological_age=40,
        gender='male',
        weight_kg=75,
        height_cm=175,
        waist_cm=85,
        hip_cm=95,
        exercise_frequency=3,
        exercise_intensity=2,
        sleep_hours=7.5,
        sleep_quality=4,
        stress_level=2,
        diet_quality=4,
        smoking_status=0,
        alcohol_intake=1
    )
    
    calculator = BiologicalAgeCalculator()
    result = calculator.calculate(test_data)
    
    print("Biological Age Calculation Results:")
    print(f"Chronological Age: {result['chronological_age']}")
    print(f"Biological Age: {result['biological_age']}")
    print(f"Age Difference: {result['age_difference']}")
    print(f"Longevity Score: {result['longevity_score']}/100")
    print(f"Aging Velocity: {result['aging_velocity']}")
    print(f"\nInterpretation: {result['interpretation']}")
