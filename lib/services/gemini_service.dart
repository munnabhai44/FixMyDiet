import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:fix_my_diet/features/recipe_finder/models/recipe.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';

class GeminiService {
  final String _apiKey = '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';
  final String _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  
  // Using Groq's lightning-fast Llama 3 model
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
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Groq Error: ${response.body}');
    }
  }

  Future<DietPlan> generateDietPlan(SurveyData survey) async {
    final prompt = '''
    Act as a professional Ayurvedic Vaidya and modern Dietician for an Indian user.
    Generate a 7-day diet plan and Ayurvedic routine based on this data:
    - Age: ${survey.age}, Gender: ${survey.gender}
    - Weight: ${survey.weightKg}kg, Height: ${survey.heightCm}cm
    - Activity Level: ${survey.activityLevel}
    - Diet Type: ${survey.dietType}
    - Medical Conditions: ${survey.medicalConditions.join(', ')}
    - Deficiencies: ${survey.deficiencies.join(', ')}
    - Ayurvedic Complaints: ${survey.ayurvedicComplaints.join(', ')}
    - Language: ${survey.selectedLanguage}

    Respond ONLY with a valid JSON object matching this exact structure:
    {
      "dailyCalorieTarget": 2000,
      "estimatedWeeklyCostInr": 1500,
      "days": [
        {
          "earlyMorning": "warm water",
          "breakfast": "poha",
          "lunch": "dal chawal",
          "eveningSnack": "makhana",
          "dinner": "khichdi",
          "mealEntries": [
             {"title": "Breakfast", "time": "8:00 AM", "description": "Poha", "colorValue": 4294198070}
          ]
        }
      ],
      "ayurvedaRoutine": {
        "internalRemedies": ["Triphala at night"],
        "externalApplications": ["Oil massage"],
        "lifestyleTips": ["Sleep early"]
      }
    }
    ''';

    try {
      final text = await _generateResponse(prompt);
      // Clean up markdown block if present
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
    
    Respond ONLY with a valid JSON array of objects matching this exact structure:
    [
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
    ''';

    try {
      final text = await _generateResponse(prompt);
      // Clean up markdown block if present
      String cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final List decoded = jsonDecode(cleanText);
      return decoded.map((e) => Recipe.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to parse recipes: $e');
    }
  }
}
