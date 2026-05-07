import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/constants/app_constants.dart';
import 'package:fix_my_diet/core/utils/bmi_calculator.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';
import 'package:fix_my_diet/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  int _currentStep = 0;
  SurveyData _data = const SurveyData();
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final existingData = await _firestore.getUserSurvey(user.uid);
      final prefs = await SharedPreferences.getInstance();
      _selectedLanguage = prefs.getString('language') ?? 'English';
      
      if (existingData != null) {
        setState(() {
          _data = existingData.copyWith(selectedLanguage: _selectedLanguage);
          _isLoading = false;
        });
      } else {
        setState(() {
          _data = _data.copyWith(selectedLanguage: _selectedLanguage);
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitSurvey();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitSurvey() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      setState(() => _isLoading = true);
      await _firestore.saveUserProfile(user.uid, user.email ?? '', _data);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/loading');
      }
    }
  }

  Widget _buildStep1() {
    final bmi = BmiCalculator.calculate(_data.weightKg, _data.heightCm);
    final bmiCategory = BmiCalculator.category(bmi);
    Color bmiColor = AppColors.primary;
    if (bmiCategory == 'Underweight' || bmiCategory == 'Overweight') bmiColor = AppColors.secondary;
    if (bmiCategory == 'Obese') bmiColor = AppColors.error;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 20),
          
          Text('Age: ${_data.age} years', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Slider(
            value: _data.age.toDouble(),
            min: 10, max: 90,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _data = _data.copyWith(age: v.round())),
          ),
          
          const SizedBox(height: 16),
          Text('Gender', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((g) {
              final isSelected = _data.gender == g;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _data = _data.copyWith(gender: g)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                      ),
                      alignment: Alignment.center,
                      child: Text(g, style: GoogleFonts.poppins(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Height: ${_data.heightCm.round()} cm', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              Text(BmiCalculator.heightToFeetInches(_data.heightCm), style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ],
          ),
          Slider(
            value: _data.heightCm,
            min: 100, max: 220,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _data = _data.copyWith(heightCm: v)),
          ),
          
          const SizedBox(height: 16),
          Text('Weight: ${_data.weightKg.round()} kg', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          Slider(
            value: _data.weightKg,
            min: 25, max: 180,
            activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _data = _data.copyWith(weightKg: v)),
          ),
          
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bmiColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: bmiColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your BMI', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
                    Text(bmi.toStringAsFixed(1), style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: bmiColor)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: bmiColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(bmiCategory, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text('Health Goal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.healthGoals.map((g) {
              return ChoiceChip(
                label: Text(g),
                selected: _data.goal == g,
                onSelected: (selected) {
                  if (selected) setState(() => _data = _data.copyWith(goal: g));
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Level', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          Text('How active are you daily?', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          
          ...List.generate(AppConstants.activityLevels.length, (index) {
            final level = AppConstants.activityLevels[index];
            final desc = AppConstants.activityDescriptions[index];
            final isSelected = _data.activityLevel == level;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _data = _data.copyWith(activityLevel: level)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightGreen.withValues(alpha: 0.2) : AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(level, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textPrimary)),
                            Text(desc, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Diet & Budget', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 20),
          
          Text('Diet Preference', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Column(
            children: AppConstants.dietTypes.map((type) {
              return RadioListTile<String>(
                title: Text(type, style: GoogleFonts.poppins()),
                value: type,
                groupValue: _data.dietType,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _data = _data.copyWith(dietType: v)),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          Text('Weekly Food Budget (per person)', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Column(
            children: AppConstants.budgetLevels.map((budget) {
              return RadioListTile<String>(
                title: Text(budget, style: GoogleFonts.poppins()),
                value: budget,
                groupValue: _data.budgetLevel,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _data = _data.copyWith(budgetLevel: v)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medical Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          Text('Select any that apply. We will customize your plan to avoid trigger foods.', style: GoogleFonts.poppins(color: AppColors.accent, fontSize: 13)),
          const SizedBox(height: 20),
          
          Text('Medical Conditions', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.medicalConditions.map((cond) {
              final isSelected = _data.medicalConditions.contains(cond);
              return FilterChip(
                label: Text(cond),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final list = List<String>.from(_data.medicalConditions);
                    if (cond == 'None') {
                      list.clear();
                      if (selected) list.add(cond);
                    } else {
                      list.remove('None');
                      if (selected) list.add(cond); else list.remove(cond);
                    }
                    _data = _data.copyWith(medicalConditions: list);
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          Text('Known Nutritional Deficiencies', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.deficiencies.map((def) {
              final isSelected = _data.deficiencies.contains(def);
              return FilterChip(
                label: Text(def),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final list = List<String>.from(_data.deficiencies);
                    if (def == 'None') {
                      list.clear();
                      if (selected) list.add(def);
                    } else {
                      list.remove('None');
                      if (selected) list.add(def); else list.remove(def);
                    }
                    _data = _data.copyWith(deficiencies: list);
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ayurvedic Profile', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          Text('Select any common issues. The Vaidya will suggest home remedies.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.ayurvedicComplaints.map((comp) {
              final isSelected = _data.ayurvedicComplaints.contains(comp);
              return FilterChip(
                label: Text(comp),
                selected: isSelected,
                selectedColor: AppColors.secondary.withValues(alpha: 0.3),
                onSelected: (selected) {
                  setState(() {
                    final list = List<String>.from(_data.ayurvedicComplaints);
                    if (selected) list.add(comp); else list.remove(comp);
                    _data = _data.copyWith(ayurvedicComplaints: list);
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          Text('Anything Else?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _data.additionalNotes,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Allergies, work schedule notes, specific likes/dislikes...',
            ),
            onChanged: (v) => setState(() => _data = _data.copyWith(additionalNotes: v)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }

    final steps = [_buildStep1(), _buildStep2(), _buildStep3(), _buildStep4(), _buildStep5()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Health Profile'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            tooltip: 'Select Language',
            onSelected: (String result) async {
              setState(() {
                _selectedLanguage = result;
                _data = _data.copyWith(selectedLanguage: result);
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('language', result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              for (final lang in ['English', 'Hindi', 'Gujarati', 'Marathi', 'Tamil', 'Telugu', 'Bengali'])
                PopupMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                ),
            ],
          ),
          if (_currentStep == 4)
            TextButton(
              onPressed: _submitSurvey,
              child: Text('Skip & Gen', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (_currentStep + 1) / steps.length,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 6,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step ${_currentStep + 1} of ${steps.length}', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: steps[_currentStep],
              ),
            ),
            
            // Bottom Nav
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStep == steps.length - 1 ? 'Generate My Plan' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
