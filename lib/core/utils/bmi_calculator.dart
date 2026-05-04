class BmiCalculator {
  static double calculate(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  static String category(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  static String heightToFeetInches(double cm) {
    final totalInches = cm / 2.54;
    final feet = totalInches ~/ 12;
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

  static int calculateCalories({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'Male') {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }

    double multiplier;
    switch (activityLevel) {
      case 'Sedentary (Desk Job)':
        multiplier = 1.2;
        break;
      case 'Lightly Active':
        multiplier = 1.375;
        break;
      case 'Moderately Active':
        multiplier = 1.55;
        break;
      case 'Very Active':
        multiplier = 1.725;
        break;
      case 'Extremely Active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }

    double tdee = bmr * multiplier;

    switch (goal) {
      case 'Weight Loss':
        tdee -= 500;
        break;
      case 'Weight Gain':
      case 'Muscle Building':
        tdee += 300;
        break;
    }

    return tdee.round().clamp(1200, 4000);
  }
}
