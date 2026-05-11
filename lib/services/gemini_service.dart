import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:fix_my_diet/features/recipe_finder/models/recipe.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';

class GeminiService {
  // Get API key from environment or use default
  final String _apiKey = const String.fromEnvironment('GROQ_API_KEY', defaultValue: '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');
  final String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Using Groq's lightning-fast Llama 3.3 model
  final String _model = 'llama-3.3-70b-versatile';

  Future<String> _generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': 'You are a strict JSON API. Output exactly the requested JSON schema without markdown blocks.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
        'response_format': {'type': 'json_object'}
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Groq Error: ${response.body}');
    }
  }

  
  Future<DietPlan> generateFastingPlan(SurveyData survey, String mode) async {
    final prompt = '''
    Act as a professional Ayurvedic Vaidya.
    Generate a complete 7-day FASTING diet plan for "$mode".
    STRICTLY follow the fasting rules (e.g. Navratri = only sabudana, kuttu, singhara, makhana. Jain = no root veg, no onion/garlic).
    
    Data:
    - Language: ${survey.selectedLanguage}
    - Medical/Deficiencies: ${survey.medicalConditions.join(', ')} / ${survey.deficiencies.join(', ')}

    CRITICAL: YOU MUST WRITE ALL RESPONSE VALUES (including descriptions, names, grocery lists, ayurveda routines) IN THE SELECTED LANGUAGE: ${survey.selectedLanguage}. If Gujarati/Hindi/Marathi/Tamil/Telugu, output in that native script.
    Respond ONLY with a valid JSON object matching the exact normal schema (daily_calorie_target, estimated_weekly_cost_inr, grocery_list, diet_plan, ayurveda_routine).
    CRITICAL: For every meal append "| NUTRITION: ...". The "diet_plan" array MUST contain exactly 7 objects!
    ''';
    try {
      final text = await _generateResponse(prompt);
      String cleanText = text.replaceAll('`json', '').replaceAll('`', '').trim();
      final decoded = jsonDecode(cleanText);
      return DietPlan.fromMap(decoded);
    } catch (e) {
      throw Exception('Failed to parse fasting plan: ');
    }
  }

  Future<DietPlan> generateDietPlan(SurveyData survey) async {
    final prompt = '''
    Act as a professional Ayurvedic Vaidya and modern Dietician for an Indian user.
    Generate a complete 7-day diet plan using STRICTLY local Indian home-cooked meals. Avoid fancy western meals.
    BUDGET: Must strictly align with the user's budget (${survey.budgetLevel}). Do not exceed this budget in "estimated_weekly_cost_inr".
    
    Data:
    - Age/Gender: ${survey.age} ${survey.gender}
    - Weight/Height: ${survey.weightKg}kg, ${survey.heightCm}cm
    - Activity: ${survey.activityLevel}
    - Diet Type: ${survey.dietType}
    - Budget Level: ${survey.budgetLevel}
    - Medical/Deficiencies: ${survey.medicalConditions.join(', ')} / ${survey.deficiencies.join(', ')}
    - Ayurvedic Complaints: ${survey.ayurvedicComplaints.join(', ')}
    - Language: ${survey.selectedLanguage}
    - Regional Cuisines: ${survey.regions.isNotEmpty ? survey.regions.join(', ') : 'Any Indian'}

    CRITICAL: YOU MUST WRITE ALL RESPONSE VALUES (descriptions, names, grocery lists, ayurveda routines) ENTIRELY IN ${survey.selectedLanguage}. Use the native script for that language!
    Respond ONLY with a valid JSON object. 
    CRITICAL INSTRUCTION FOR NUTRITION: For EVERY single meal, you MUST append detailed nutrition info using this EXACT format: "Meal description | NUTRITION: 300 kcal, Protein: 10g, Carbs: 40g, Fat: 5g, Vit C: 10%, Iron: 15%"
    CRITICAL INSTRUCTION FOR GROCERIES: You MUST generate a "grocery_list" array that calculates the EXACT quantities needed for the 7-day plan and their realistic costs in INR. The total sum of "cost_inr" across all items MUST perfectly match "estimated_weekly_cost_inr" and must align with the budget. Do not miss any calculation.
    CRITICAL: The "diet_plan" array MUST contain exactly 7 objects!
    {
      "daily_calorie_target": 2000,
      "estimated_weekly_cost_inr": 1500,
      "grocery_list": [
        {"item": "Coconut", "quantity": "3 pcs", "cost_inr": 75},
        {"item": "Poha", "quantity": "500g", "cost_inr": 40}
      ],
      "diet_plan": [
        {
          "day": 1,
          "meals": {
            "early_morning": "warm water",
            "breakfast": "poha",
            "lunch": "dal chawal",
            "evening_snack": "makhana",
            "dinner": "khichdi"
          }
        }
      ],
      "ayurveda_routine": {
        "internal_remedies": ["Triphala at night"],
        "external_applications": ["Oil massage"],
        "lifestyle_tips": ["Sleep early"]
      }
    }
    ''';

    try {
      final text = await _generateResponse(prompt);
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleanText);
      return DietPlan.fromMap(decoded);
    } catch (e) {
      throw Exception('Failed to parse diet plan: $e');
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
    Suggest 5 Indian $mealType recipes using these ingredients: ${ingredients.join(', ')}.
    Diet: $dietType, Healthy: $healthy, Language: $language.
    
    CRITICAL INSTRUCTIONS:
    1. Make the recipes highly detailed. Include exact measurements (e.g. 1 cup, 2 tbsp) in the steps.
    2. Provide a full step-by-step cooking guide. Do not use just two lines.
    3. The "nutritionNote" MUST contain highly detailed macros (e.g., Calories: 300 kcal, Protein: 15g, Vitamin A: 10%, Iron: 20%, etc.).

    Respond ONLY with a valid JSON object matching this exact structure:
    {
      "recipes": [
        {
          "name": "Recipe Name",
          "description": "Short description",
          "cookingTimeMinutes": 20,
          "healthRating": "A",
          "nutritionNote": "High protein",
          "steps": ["Step 1", "Step 2"],
          "youtubeSearchQuery": "Recipe Name in Hindi"
        }
      ]
    }
    ''';

    try {
      final text = await _generateResponse(prompt);
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> decoded = jsonDecode(cleanText);
      final List recipesList = decoded['recipes'] ?? [];
      return recipesList.map((e) => Recipe.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to parse recipes: $e');
    }
  }

  Future<String> generateSickPlan(SurveyData survey, String illness) async {
    final prompt = '''
    Act as an Ayurvedic Vaidya and Dietician. The user is currently sick with "$illness".
    Language: ${survey.selectedLanguage}. Diet Type: ${survey.dietType}.
    Provide a highly effective 1-day healing diet and home remedies.
    CRITICAL: YOU MUST RESPOND ENTIRELY IN ${survey.selectedLanguage}. IF THE LANGUAGE IS HINDI/GUJARATI/MARATHI, WRITE IN THAT SCRIPT.
    For Ayurvedic morning drinks, specifically recommend affordable local options based on their problem (e.g., Giloy tea, Neem juice, overnight soaked Methi water).
    Format your response beautifully using Markdown. Include:
    1. 🍲 1-Day Healing Diet (Breakfast, Lunch, Dinner, Drinks)
    2. 🌿 Ayurvedic Home Remedies (Include Giloy/Neem/Methi if appropriate)
    3. 💡 Quick Recovery Tips
    ''';
    
    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': 'You are a helpful AI Doctor.'},
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.4,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['choices'][0]['message']['content'];
      }
      throw Exception('Groq Error');
    } catch (e) {
      throw Exception('Failed to generate sick plan: $e');
    }
  }
}
