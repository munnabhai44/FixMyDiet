class SurveyData {
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
  final String dietType;
  final String budgetLevel;
  final List<String> medicalConditions;
  final List<String> deficiencies;
  final List<String> ayurvedicComplaints;
  final String additionalNotes;
  final String selectedLanguage;

  const SurveyData({
    this.age = 25,
    this.gender = 'Male',
    this.heightCm = 170,
    this.weightKg = 70,
    this.goal = 'Maintain Weight',
    this.activityLevel = 'Sedentary (Desk Job)',
    this.dietType = 'Vegetarian',
    this.budgetLevel = 'Moderate (₹400-800/week)',
    this.medicalConditions = const [],
    this.deficiencies = const [],
    this.ayurvedicComplaints = const [],
    this.additionalNotes = '',
    this.selectedLanguage = 'English',
  });

  SurveyData copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
    String? dietType,
    String? budgetLevel,
    List<String>? medicalConditions,
    List<String>? deficiencies,
    List<String>? ayurvedicComplaints,
    String? additionalNotes,
    String? selectedLanguage,
  }) {
    return SurveyData(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietType: dietType ?? this.dietType,
      budgetLevel: budgetLevel ?? this.budgetLevel,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      deficiencies: deficiencies ?? this.deficiencies,
      ayurvedicComplaints: ayurvedicComplaints ?? this.ayurvedicComplaints,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': goal,
      'activityLevel': activityLevel,
      'dietType': dietType,
      'budgetLevel': budgetLevel,
      'medicalConditions': medicalConditions,
      'deficiencies': deficiencies,
      'ayurvedicComplaints': ayurvedicComplaints,
      'additionalNotes': additionalNotes,
      'selectedLanguage': selectedLanguage,
    };
  }

  factory SurveyData.fromMap(Map<String, dynamic> map) {
    return SurveyData(
      age: map['age'] ?? 25,
      gender: map['gender'] ?? 'Male',
      heightCm: (map['heightCm'] ?? 170).toDouble(),
      weightKg: (map['weightKg'] ?? 70).toDouble(),
      goal: map['goal'] ?? 'Maintain Weight',
      activityLevel: map['activityLevel'] ?? 'Sedentary (Desk Job)',
      dietType: map['dietType'] ?? 'Vegetarian',
      budgetLevel: map['budgetLevel'] ?? 'Moderate (₹400-800/week)',
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      deficiencies: List<String>.from(map['deficiencies'] ?? []),
      ayurvedicComplaints: List<String>.from(map['ayurvedicComplaints'] ?? []),
      additionalNotes: map['additionalNotes'] ?? '',
      selectedLanguage: map['selectedLanguage'] ?? 'English',
    );
  }
}
