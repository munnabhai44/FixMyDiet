import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/theme/app_theme.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/features/auth/screens/auth_screen.dart';
import 'package:fix_my_diet/features/dashboard/screens/dashboard_screen.dart';
import 'package:fix_my_diet/features/survey/screens/survey_screen.dart';
import 'package:fix_my_diet/features/plan_generation/screens/loading_screen.dart';

class FixMyDietApp extends ConsumerWidget {
  const FixMyDietApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'FixMyDiet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: authState.when(
        data: (user) {
          if (user == null) return const AuthScreen();
          return const DashboardScreen();
        },
        loading: () => const _SplashScreen(),
        error: (_, __) => const AuthScreen(),
      ),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/survey': (_) => const SurveyScreen(),
        '/loading': (_) => const LoadingScreen(),
        '/dashboard': (_) => const DashboardScreen(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.spa, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'FixMyDiet',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
