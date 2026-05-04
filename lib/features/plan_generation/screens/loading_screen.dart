import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/constants/app_constants.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/services/firestore_service.dart';
import 'package:fix_my_diet/services/gemini_service.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  final FirestoreService _firestore = FirestoreService();
  final GeminiService _gemini = GeminiService();
  
  int _messageIndex = 0;
  Timer? _timer;
  String? _error;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
    _generatePlan();
  }

  void _startMessageCycle() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % AppConstants.loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    if (_isGenerating) return;
    setState(() {
      _isGenerating = true;
      _error = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      // 1. Get survey data
      final survey = await _firestore.getUserSurvey(user.uid);
      if (survey == null) throw Exception('Survey data not found');

      // 2. Generate plan via Gemini
      final plan = await _gemini.generateDietPlan(survey);

      // 3. Save plan to Firestore
      await _firestore.savePlan(user.uid, plan);

      // 4. Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pick a random health fact
    final fact = AppConstants.healthFacts[DateTime.now().second % AppConstants.healthFacts.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error == null) ...[
                // Loading Animation Placeholder (Using a styled container/icon for now, ideally Lottie)
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
                  ),
                ),
                const SizedBox(height: 40),
                
                Text(
                  'Consulting your AI Dietician\n& Vaidya...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen),
                ),
                const SizedBox(height: 16),
                
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    AppConstants.loadingMessages[_messageIndex],
                    key: ValueKey<int>(_messageIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                  ),
                ),
                
                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightYellow.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 20),
                          const SizedBox(width: 8),
                          Text('Did you know?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fact,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Error State
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 24),
                Text('Oops! Something went wrong.', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _generatePlan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/survey'),
                  child: const Text('Go Back to Survey'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
