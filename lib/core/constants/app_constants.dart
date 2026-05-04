class AppConstants {
  static const String appName = 'FixMyDiet';
  static const String tagline = 'Your AI Dietician & Ayurvedic Vaidya';
  static const String geminiApiKey = 'AIzaSyAuz_WuRecJlDvtUe6bUw2B6Ml8no5E5fw';

  static const String disclaimer =
      'This app is for informational purposes only. Always consult a qualified doctor for medical advice.';

  static const String fullDisclaimer =
      'FixMyDiet provides AI-generated dietary suggestions for general informational purposes only. '
      'This is NOT a substitute for professional medical advice, diagnosis, or treatment. '
      'Always consult a qualified doctor or registered dietician before making significant dietary changes. '
      'If you have a medical emergency, call your doctor or emergency services immediately.';

  static const List<String> supportedLanguages = [
    'English',
    'Hindi',
    'Gujarati',
    'Marathi',
    'Kutchi',
  ];

  static const List<String> healthGoals = [
    'Weight Loss',
    'Weight Gain',
    'Maintain Weight',
    'Muscle Building',
    'Improve Energy',
  ];

  static const List<String> activityLevels = [
    'Sedentary (Desk Job)',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];

  static const List<String> activityDescriptions = [
    'You sit most of the day',
    'Some walking, light household work',
    'Exercise 3-5 times/week',
    'Daily gym/running/sports',
    'Heavy labor, farming, athletics',
  ];

  static const List<IconLabel> activityIcons = [];

  static const List<String> dietTypes = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Eggetarian',
  ];

  static const List<String> budgetLevels = [
    'Strict Budget (₹200-400/week)',
    'Moderate (₹400-800/week)',
    'Flexible (₹800+/week)',
  ];

  static const List<String> medicalConditions = [
    'GERD / Acid Reflux',
    'PCOS / PCOD',
    'Type 2 Diabetes',
    'Thyroid (Hypothyroid)',
    'Thyroid (Hyperthyroid)',
    'High Blood Pressure',
    'High Cholesterol',
    'Fatty Liver',
    'Kidney Stones',
    'IBS (Irritable Bowel Syndrome)',
    'None',
  ];

  static const List<String> deficiencies = [
    'Vitamin B12',
    'Vitamin D',
    'Iron',
    'Calcium',
    'Zinc',
    'Omega-3',
    'Protein',
    'Folic Acid',
    'None',
  ];

  static const List<String> ayurvedicComplaints = [
    'Weak Immunity',
    'Rough / Dry Hair',
    'Hair Fall',
    'Acne / Pimples',
    'Dull Skin',
    'Digestion Issues / Bloating',
    'Joint Pain / Stiffness',
    'Low Energy / Fatigue',
    'Poor Sleep / Insomnia',
    'Stress / Anxiety',
    'Eye Strain / Weak Eyesight',
    'Frequent Cold & Cough',
    'Water Retention',
    'Irregular Periods',
  ];

  static const List<String> loadingMessages = [
    'Analyzing your health profile...',
    'Checking for food sensitivities...',
    'Crafting your personalized diet plan...',
    'Consulting the Ayurvedic Vaidya...',
    'Adding budget-friendly recipes...',
    'Preparing your 7-day meal plan...',
    'Calculating nutrition & costs...',
  ];

  static const List<String> healthFacts = [
    'Turmeric has been used in Ayurveda for 4,000 years.',
    'India is the world\'s largest producer of milk.',
    'Amla (Indian Gooseberry) has 20x more Vitamin C than oranges.',
    'Ghee has been a staple in Indian cooking for over 5,000 years.',
    'Tulsi (Holy Basil) is called the "Queen of Herbs" in Ayurveda.',
    'Jaggery is rich in iron and helps purify blood.',
    'Triphala is a 3-fruit combo that aids digestion naturally.',
    'Ashwagandha means "smell of the horse" — for strength!',
  ];

  static const List<String> commonIngredients = [
    'Rice', 'Suji/Rava', 'Besan', 'Poha', 'Oats', 'Maida', 'Atta',
    'Moong Dal', 'Chana Dal', 'Rajma', 'Chole', 'Urad Dal',
    'Milk', 'Curd', 'Paneer', 'Butter', 'Ghee', 'Cheese',
    'Potato', 'Onion', 'Tomato', 'Spinach', 'Peas', 'Capsicum', 'Carrot',
    'Green Chili', 'Ginger', 'Garlic', 'Coriander', 'Curry Leaves', 'Lemon',
    'Peanuts', 'Cashews', 'Sesame', 'Coconut',
    'Eggs', 'Bread', 'Jaggery', 'Honey',
  ];
}

class IconLabel {
  final String icon;
  final String label;
  const IconLabel(this.icon, this.label);
}
