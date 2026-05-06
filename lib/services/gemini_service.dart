import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:fix_my_diet/core/constants/app_constants.dart';
import 'package:fix_my_diet/core/utils/bmi_calculator.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:fix_my_diet/features/recipe_finder/models/recipe.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: AppConstants.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 8192,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<DietPlan> generateDietPlan(SurveyData survey) async {
    final bmi = BmiCalculator.calculate(survey.weightKg, survey.heightCm);
    final bmiCategory = BmiCalculator.category(bmi);
    final calories = BmiCalculator.calculateCalories(
      weightKg: survey.weightKg,
      heightCm: survey.heightCm,
      age: survey.age,
      gender: survey.gender,
      activityLevel: survey.activityLevel,
      goal: survey.goal,
    );

    final prompt = '''
You are an expert clinical dietician and an Ayurvedic Vaidya specializing in Indian lifestyles and Indian household cooking. Generate a comprehensive, holistic health plan for the following person:

PATIENT PROFILE:
- Age: ${survey.age} years
- Gender: ${survey.gender}
- Height: ${survey.heightCm} cm
- Weight: ${survey.weightKg} kg
- BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)
- Health Goal: ${survey.goal}
- Activity Level: ${survey.activityLevel}
- Diet Preference: ${survey.dietType}
- Weekly Budget: ${survey.budgetLevel}
- Medical Conditions: ${survey.medicalConditions.isEmpty ? 'None' : survey.medicalConditions.join(', ')}
- Nutritional Deficiencies: ${survey.deficiencies.isEmpty ? 'None' : survey.deficiencies.join(', ')}
- Holistic/Ayurvedic Complaints: ${survey.ayurvedicComplaints.isEmpty ? 'None' : survey.ayurvedicComplaints.join(', ')}
- Additional Notes: ${survey.additionalNotes.isEmpty ? 'None' : survey.additionalNotes}
- Estimated Daily Calorie Target: $calories kcal

CRITICAL INSTRUCTIONS:

1. MEDICAL SAFETY: STRICTLY avoid ALL trigger foods for their medical conditions:
   - GERD: No citrus, tomato, spicy food, fried food, caffeine, chocolate, raw onion
   - Diabetes: No high GI foods, no white rice (use brown), no sugar, limited fruits
   - PCOS: No refined carbs, no dairy excess, no sugar, anti-inflammatory focus
   - Thyroid (Hypo): No soy, no raw cruciferous vegetables, no processed food
   - High BP: Low sodium, no pickles, no papad, no processed food
   - Kidney Stones: Low oxalate, more water, limited spinach/tomato
   - IBS: Low FODMAP, no beans initially, no raw salads
   - Fatty Liver: No fried food, no sugar

2. BUDGET COMPLIANCE: Only suggest foods within ${survey.budgetLevel}. For strict budget, use ONLY common Indian kitchen staples.

3. INDIAN HOUSEHOLD MEASUREMENTS: Use katori (bowl), glass, chamach (spoon), roti count, piece count. NOT cups or grams.

4. DEFICIENCY TARGETING: Include foods rich in their deficient nutrients.

5. VARIETY: Each of the 7 days must have DIFFERENT meals. Realistic for an Indian household.

6. AYURVEDIC REMEDIES: Suggest PRACTICAL, AFFORDABLE, EASILY AVAILABLE homemade remedies with EXACT quantities.

7. LANGUAGE: ALL text values MUST be in ${survey.selectedLanguage}. Keep JSON keys in English only.

RETURN ONLY valid JSON with this structure:
{
  "daily_calorie_target": $calories,
  "estimated_weekly_cost_inr": 850,
  "diet_plan": [
    {"day": 1, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 2, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 3, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 4, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 5, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 6, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}},
    {"day": 7, "meals": {"early_morning": "...", "breakfast": "...", "lunch": "...", "evening_snack": "...", "dinner": "..."}}
  ],
  "ayurveda_routine": {
    "internal_remedies": ["Remedy 1 with exact dosage and timing", "Remedy 2", "Remedy 3", "Remedy 4", "Remedy 5"],
    "external_applications": ["Application 1 with ingredients and frequency", "Application 2", "Application 3"],
    "lifestyle_tips": ["Tip 1", "Tip 2", "Tip 3", "Tip 4", "Tip 5"]
  }
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStr = _extractJson(text);
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      map['generatedAt'] = DateTime.now().toIso8601String();
      map['language'] = survey.selectedLanguage;
      return DietPlan.fromMap(map);
    } catch (e) {
      throw Exception('Failed to generate diet plan: $e');
    }
  }

  Future<List<Recipe>> findRecipes({
    required List<String> ingredients,
    required String mealType,
    required String dietType,
    required bool healthy,
    required String language,
  }) async {
    final prompt = '''
You are an expert Indian home cook and nutritionist. A user wants to make something using ingredients they have at home.

AVAILABLE INGREDIENTS: ${ingredients.join(', ')}
MEAL TYPE WANTED: $mealType
DIET PREFERENCE: $dietType
HEALTH PREFERENCE: ${healthy ? 'Healthy' : 'Any'}
LANGUAGE: $language

INSTRUCTIONS:
1. Suggest exactly 5 Indian recipes using MOSTLY these ingredients. Common staples like salt, oil, water, basic spices (haldi, mirch, jeera) are assumed available.
2. Prioritize HEALTHY options if health preference is "Healthy".
3. Each recipe should be practical, common in Indian households, and doable in under 30 minutes.
4. Provide step-by-step instructions a beginner can follow.
5. ALL text must be in $language.

RETURN ONLY valid JSON:
{
  "recipes": [
    {
      "name": "Recipe Name",
      "description": "One-line description",
      "cooking_time_minutes": 15,
      "health_rating": "healthy",
      "difficulty": "easy",
      "uses_all_ingredients": true,
      "ingredients_needed": ["ingredient 1", "ingredient 2"],
      "steps": ["Step 1...", "Step 2...", "Step 3...", "Step 4..."],
      "nutrition_note": "Rich in protein and fiber",
      "youtube_search_query": "recipe name healthy"
    }
  ]
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      final jsonStr = _extractJson(text);
      final map = json.decode(jsonStr) as Map<String, dynamic>;
      final recipes = (map['recipes'] as List).map((r) => Recipe.fromMap(r)).toList();
      return recipes;
    } catch (e) {
      throw Exception('Failed to find recipes: $e');
    }
  }

  String _extractJson(String text) {
    var cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
}
