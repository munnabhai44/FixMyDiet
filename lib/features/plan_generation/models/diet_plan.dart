class DietPlan {
  final int dailyCalorieTarget;
  final int estimatedWeeklyCostInr;
  final List<DayPlan> days;
  final List<GroceryItem> groceryList;
  final AyurvedaRoutine ayurvedaRoutine;
  final String generatedAt;
  final String language;

  const DietPlan({
    required this.dailyCalorieTarget,
    required this.estimatedWeeklyCostInr,
    required this.days,
    required this.groceryList,
    required this.ayurvedaRoutine,
    required this.generatedAt,
    required this.language,
  });

  Map<String, dynamic> toMap() => {
    'dailyCalorieTarget': dailyCalorieTarget,
    'estimatedWeeklyCostInr': estimatedWeeklyCostInr,
    'dietPlan': days.map((d) => d.toMap()).toList(),
    'groceryList': groceryList.map((g) => g.toMap()).toList(),
    'ayurvedaRoutine': ayurvedaRoutine.toMap(),
    'generatedAt': generatedAt,
    'language': language,
  };

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    final dietPlanList = map['diet_plan'] ?? map['dietPlan'] ?? [];
    return DietPlan(
      dailyCalorieTarget: map['daily_calorie_target'] ?? map['dailyCalorieTarget'] ?? 1800,
      estimatedWeeklyCostInr: map['estimated_weekly_cost_inr'] ?? map['estimatedWeeklyCostInr'] ?? 800,
      days: (dietPlanList as List).map((d) => DayPlan.fromMap(d)).toList(),
      groceryList: (map['grocery_list'] ?? map['groceryList'] ?? []).map<GroceryItem>((g) => GroceryItem.fromMap(g)).toList(),
      ayurvedaRoutine: AyurvedaRoutine.fromMap(
        map['ayurveda_routine'] ?? map['ayurvedaRoutine'] ?? {},
      ),
      generatedAt: map['generatedAt'] ?? DateTime.now().toIso8601String(),
      language: map['language'] ?? 'English',
    );
  }
}

class DayPlan {
  final int day;
  final String earlyMorning;
  final String breakfast;
  final String lunch;
  final String eveningSnack;
  final String dinner;

  const DayPlan({
    required this.day,
    required this.earlyMorning,
    required this.breakfast,
    required this.lunch,
    required this.eveningSnack,
    required this.dinner,
  });

  Map<String, dynamic> toMap() => {
    'day': day,
    'meals': {
      'early_morning': earlyMorning,
      'breakfast': breakfast,
      'lunch': lunch,
      'evening_snack': eveningSnack,
      'dinner': dinner,
    },
  };

  factory DayPlan.fromMap(Map<String, dynamic> map) {
    final meals = map['meals'] ?? {};
    String parseMeal(dynamic m) {
       if (m is Map) return "${m['description']} | NUTRITION: ${m['nutrition_info']}";
       return m?.toString() ?? 'No suggestion';
    }
    return DayPlan(
      day: map['day'] ?? 1,
      earlyMorning: parseMeal(meals['early_morning']),
      breakfast: parseMeal(meals['breakfast']),
      lunch: parseMeal(meals['lunch']),
      eveningSnack: parseMeal(meals['evening_snack']),
      dinner: parseMeal(meals['dinner']),
    );
  }

  List<MealEntry> get mealEntries => [
    MealEntry('Early Morning', '6:00 - 7:00 AM', earlyMorning, 0xFF81C784),
    MealEntry('Breakfast', '8:00 - 9:00 AM', breakfast, 0xFF4CAF50),
    MealEntry('Lunch', '12:30 - 1:30 PM', lunch, 0xFFE8B84B),
    MealEntry('Evening Snack', '4:30 - 5:30 PM', eveningSnack, 0xFFCB7B5B),
    MealEntry('Dinner', '7:30 - 8:30 PM', dinner, 0xFF6B8E6B),
  ];
}

class MealEntry {
  final String title;
  final String time;
  final String description;
  final int colorValue;
  MealEntry(this.title, this.time, this.description, this.colorValue);
}

class AyurvedaRoutine {
  final List<String> internalRemedies;
  final List<String> externalApplications;
  final List<String> lifestyleTips;

  const AyurvedaRoutine({
    required this.internalRemedies,
    required this.externalApplications,
    required this.lifestyleTips,
  });

  Map<String, dynamic> toMap() => {
    'internal_remedies': internalRemedies,
    'external_applications': externalApplications,
    'lifestyle_tips': lifestyleTips,
  };

  factory AyurvedaRoutine.fromMap(Map<String, dynamic> map) {
    return AyurvedaRoutine(
      internalRemedies: List<String>.from(map['internal_remedies'] ?? []),
      externalApplications: List<String>.from(map['external_applications'] ?? []),
      lifestyleTips: List<String>.from(map['lifestyle_tips'] ?? []),
    );
  }
}

class GroceryItem {
  final String item;
  final String quantity;
  final int costInr;
  const GroceryItem(this.item, this.quantity, this.costInr);
  Map<String, dynamic> toMap() => {'item': item, 'quantity': quantity, 'cost_inr': costInr};
  factory GroceryItem.fromMap(Map<String, dynamic> map) => GroceryItem(
    map['item'] ?? '', map['quantity'] ?? '', map['cost_inr'] ?? map['costInr'] ?? 0,
  );
}
