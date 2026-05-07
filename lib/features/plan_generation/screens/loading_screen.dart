import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/services/firestore_service.dart';
import 'package:fix_my_diet/services/gemini_service.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut));
    _generatePlan();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _generatePlan() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      try {
        final survey = await FirestoreService().getUserSurvey(user.uid);
        if (survey != null) {
          final plan = await GeminiService().generateDietPlan(survey);
          await FirestoreService().savePlan(user.uid, plan);
          if (mounted) Navigator.of(context).pushReplacementNamed('/dashboard');
        } else {
          if (mounted) Navigator.of(context).pushReplacementNamed('/survey');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animCtrl,
              builder: (ctx, child) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.ramen_dining, size: 60, color: AppColors.primary),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text('Cooking your Desi Plan...', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
            const SizedBox(height: 12),
            Text('Analyzing your doshas and local ingredients 🌿', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
