class Recipe {
  final String name;
  final String description;
  final int cookingTimeMinutes;
  final String healthRating;
  final String difficulty;
  final bool usesAllIngredients;
  final List<String> ingredientsNeeded;
  final List<String> steps;
  final String nutritionNote;
  final String youtubeSearchQuery;

  const Recipe({
    required this.name,
    required this.description,
    required this.cookingTimeMinutes,
    required this.healthRating,
    required this.difficulty,
    required this.usesAllIngredients,
    required this.ingredientsNeeded,
    required this.steps,
    required this.nutritionNote,
    required this.youtubeSearchQuery,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      cookingTimeMinutes: map['cooking_time_minutes'] ?? 15,
      healthRating: map['health_rating'] ?? 'moderate',
      difficulty: map['difficulty'] ?? 'easy',
      usesAllIngredients: map['uses_all_ingredients'] ?? false,
      ingredientsNeeded: List<String>.from(map['ingredients_needed'] ?? []),
      steps: List<String>.from(map['steps'] ?? []),
      nutritionNote: map['nutrition_note'] ?? '',
      youtubeSearchQuery: map['youtube_search_query'] ?? '',
    );
  }
}
