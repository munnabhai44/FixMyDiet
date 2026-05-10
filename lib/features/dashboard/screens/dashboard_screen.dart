import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/utils/bmi_calculator.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:fix_my_diet/features/survey/models/survey_data.dart';
import 'package:fix_my_diet/services/firestore_service.dart';
import 'package:fix_my_diet/features/dashboard/tabs/diet_plan_tab.dart';
import 'package:fix_my_diet/features/dashboard/tabs/ayurveda_tab.dart';
import 'package:fix_my_diet/features/dashboard/tabs/grocery_tab.dart';
import 'package:fix_my_diet/features/recipe_finder/screens/recipe_finder_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fix_my_diet/core/utils/translations.dart';
import 'package:fix_my_diet/services/gemini_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  bool _isFastingMode = false;
  final FirestoreService _firestore = FirestoreService();
  late TabController _tabController;
  
  DietPlan? _plan;
  SurveyData? _survey;
  bool _isLoading = true;
  int _waterGlasses = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final plan = await _firestore.getLatestPlan(user.uid);
      final survey = await _firestore.getUserSurvey(user.uid);
      
      if (mounted) {
        setState(() {
          _plan = plan;
          _survey = survey;
          _isLoading = false;
        });
        
        if (_plan == null && !_isLoading) {
          Navigator.of(context).pushReplacementNamed('/survey');
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  
  
    void _showFastingModeSheet() {
    showModalBottomSheet(
      context: context, 
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Icon(Icons.nightlight_round, size: 48, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(AppTranslations.t('Fasting Mode', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(AppTranslations.t('Switch to a specialized fasting diet (Ekadashi/Intermittent). Your meals will be reduced to 2 light fast-friendly options.', _survey?.selectedLanguage ?? 'English'), textAlign: TextAlign.center, style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                ),
                onPressed: () {
                  setState(() { _isFastingMode = !_isFastingMode; });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(_isFastingMode ? 'Fasting Mode Activated 🌙' : 'Fasting Mode Deactivated ☀️'),
                    backgroundColor: AppColors.primary,
                  ));
                }, 
                child: Text(_isFastingMode ? 'Deactivate Fasting Mode' : 'Activate Fasting Mode', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        )
    ));
  }

  void _showShareCard() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Your Diet ID Card 🪪'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green.shade100, Colors.teal.shade50]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_2, size: 80, color: Colors.teal),
                const SizedBox(height: 8),
                Text('FixMyDiet Member', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_plan?.dailyCalorieTarget ?? 2000} kcal/day', style: GoogleFonts.poppins(color: Colors.teal.shade700)),
                Text('Scan to view my Desi Diet Plan!', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('Take a screenshot and share it with your friends!', style: GoogleFonts.poppins(fontSize: 12, fontStyle: FontStyle.italic)),
        ]
      ),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  
  void _showCheatApprover() {
    final bmi = _survey!.weightKg / ((_survey!.heightCm / 100) * (_survey!.heightCm / 100));
    final isApproved = bmi < 24.0;
    showDialog(context: context, builder: (_) => AlertDialog(
      title: Text(isApproved ? AppTranslations.t('Cheat Meal Approved! 🎉', _survey?.selectedLanguage ?? 'English') : AppTranslations.t('Cheat Meal Denied! 🚨', _survey?.selectedLanguage ?? 'English')),
      content: Text(isApproved 
        ? AppTranslations.t('Your BMI is looking good. AI suggests: 1 Air-Fried Samosa or a bowl of Wheat Pasta.', _survey?.selectedLanguage ?? 'English') 
        : AppTranslations.t('Stay strong! Have roasted Makhana or 1 piece of Dark Chocolate instead to keep your progress.', _survey?.selectedLanguage ?? 'English')),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppTranslations.t('Okay!', _survey?.selectedLanguage ?? 'English')))],
    ));
  }

  void _showCravingDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Craving Sweets? 🤤'),
      content: const Text('Try eating 2 Dates (Khajoor) with warm ghee, or roasted Makhana with jaggery. Avoid processed sugar!\n\n+ Ayurvedic Fact: Sweet cravings often indicate Vata imbalance.'),
      actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Got it!'))],
    ));
  }

  void _showSickModeDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.t('Feeling Sick?', _survey!.selectedLanguage)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'E.g., Cold & Cough, Fever...'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (ctrl.text.isEmpty) return;
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                final plan = await GeminiService().generateSickPlan(_survey!, ctrl.text);
                if (!mounted) return;
                Navigator.pop(context); // close loading
                
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(24),
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: Column(
                      children: [
                        const Text('Your Healing Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Expanded(child: SingleChildScrollView(child: Text(plan))),
                        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                      ],
                    ),
                  ),
                );
              } catch(e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Get Healing Plan'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, val, child) {
                return Opacity(
                  opacity: val,
                  child: Transform.scale(
                    scale: 0.8 + (val * 0.2),
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.4), blurRadius: 20 * val, spreadRadius: 2 * val)],
                      ),
                      child: const Icon(Icons.spa, color: Colors.white, size: 48),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text('Curating your Ayurvedic plan...', style: GoogleFonts.playfairDisplay(color: AppColors.primary, fontSize: 18, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            SizedBox(width: 150, child: ClipRRect(borderRadius: BorderRadius.circular(4), child: const LinearProgressIndicator(color: AppColors.secondary, backgroundColor: Color(0xFFEAEAEA), minHeight: 4))),
          ],
        ),
      ),
    );
    if (_plan == null || _survey == null) return const Scaffold(body: Center(child: Text('No data found.')));

    final bmi = BmiCalculator.calculate(_survey!.weightKg, _survey!.heightCm);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.spa, color: AppColors.secondary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text('FixMyDiet', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(AppTranslations.t('Your Personalized Ayurvedic Diet', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(color: AppColors.lightYellow, fontSize: 11, letterSpacing: 0.5)),
                ],
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.language, color: AppColors.secondary),
              title: Text(AppTranslations.t('Change Language', _survey?.selectedLanguage ?? 'English')),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppTranslations.t('Change Language', _survey?.selectedLanguage ?? 'English')),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['English', 'Hindi', 'Gujarati', 'Marathi', 'Tamil', 'Telugu', 'Bengali'].map((lang) {
                        return ListTile(
                          title: Text(lang),
                          trailing: _survey?.selectedLanguage == lang ? const Icon(Icons.check, color: AppColors.success) : null,
                          onTap: () async {
                            Navigator.pop(context);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('language', lang);
                            final user = ref.read(currentUserProvider);
                            if (user != null) {
                              final survey = await _firestore.getUserSurvey(user.uid);
                              if (survey != null) {
                                await _firestore.saveUserProfile(user.uid, user.email ?? '', survey.copyWith(selectedLanguage: lang));
                              }
                            }
                            if (context.mounted) Navigator.of(context).pushReplacementNamed('/loading');
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(leading: const Icon(Icons.person_outline, color: AppColors.primary), title: Text(AppTranslations.t('Reset Profile', _survey?.selectedLanguage ?? 'English')), onTap: () async {
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await _firestore.saveUserProfile(user.uid, user.email ?? '', _survey!.copyWith(age: 0));
              }
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/survey');
            }),
            ListTile(leading: const Icon(Icons.share, color: Colors.blueAccent), title: Text(AppTranslations.t('Share Diet ID', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showShareCard(); }),
            ListTile(leading: const Icon(Icons.air, color: Colors.lightBlue), title: Text(AppTranslations.t('Pre-meal Breathing', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showBreathingExercise(); }),
            ListTile(leading: const Icon(Icons.fastfood, color: Colors.redAccent), title: Text(AppTranslations.t('Cheat Meal Approver', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showCheatApprover(); }),
            ListTile(leading: const Icon(Icons.cookie, color: Colors.orangeAccent), title: Text(AppTranslations.t('Sweet Craving Logger', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showCravingDialog(); }),
            ListTile(leading: const Icon(Icons.nightlight_round, color: Colors.amber), title: Text(AppTranslations.t('Fasting Mode', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showFastingModeSheet(); }),
            ListTile(leading: const Icon(Icons.medical_services, color: Colors.red), title: Text(AppTranslations.t('Sick Mode (Pathya)', _survey?.selectedLanguage ?? 'English')), onTap: () { Navigator.pop(context); _showSickModeDialog(); }),
            
            ListTile(leading: const Icon(Icons.bedtime, color: Colors.deepPurple), title: Text(AppTranslations.t('Sleep Routine Alarm', _survey?.selectedLanguage ?? 'English')), onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => AlertDialog(
                title: Text(AppTranslations.t('Ayurvedic Sleep Routine', _survey?.selectedLanguage ?? 'English')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nights_stay, size: 50, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(AppTranslations.t('Based on Ayurveda, the best time to sleep is 10:00 PM (Kapha time) to wake up refreshed at 6:00 AM (Vata time).', _survey?.selectedLanguage ?? 'English'), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppTranslations.t('Enable Bedtime Reminder', _survey?.selectedLanguage ?? 'English'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        Switch(value: true, activeColor: Colors.deepPurple, onChanged: (val) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTranslations.t('Reminder set for 9:30 PM!', _survey?.selectedLanguage ?? 'English'))));
                        })
                      ]
                    )
                  ]
                ),
                actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: Text(AppTranslations.t('Close', _survey?.selectedLanguage ?? 'English')))],
              ));
            }),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text(AppTranslations.t('Logout', _survey?.selectedLanguage ?? 'English'), style: const TextStyle(color: Colors.red)), onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
            }),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipeFinderScreen())),
        icon: const Icon(Icons.restaurant_menu),
        label: Text(AppTranslations.t('What Can I Cook?', _survey!.selectedLanguage)),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppTranslations.t('Your Health Plan', _survey!.selectedLanguage), style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(AppTranslations.t('BMI', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(color: AppColors.lightYellow, fontSize: 10, letterSpacing: 1.0)),
                                    
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 40, height: 40,
                                          child: CircularProgressIndicator(
                                            value: bmi / 40.0,
                                            backgroundColor: Colors.white24,
                                            valueColor: AlwaysStoppedAnimation<Color>(bmi > 25 ? Colors.red : (bmi < 18.5 ? Colors.orange : Colors.green)),
                                          )
                                        ),
                                        Text(bmi.toStringAsFixed(1), style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ]
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatChip(Icons.local_fire_department, '${_plan!.dailyCalorieTarget} kcal/day'),
                              const SizedBox(width: 8),
                              _buildStatChip(Icons.account_balance_wallet, '₹${_plan!.estimatedWeeklyCostInr}/week'),
                              const SizedBox(width: 8),
                              GestureDetector(onTap: () => setState(() => _waterGlasses++), child: _buildHydrationTracker()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorWeight: 4,
                indicatorColor: AppColors.secondary,
                tabs: [
                  Tab(text: AppTranslations.t('7-Day Plan', _survey!.selectedLanguage), icon: const Icon(Icons.calendar_month)),
                  Tab(text: AppTranslations.t('Ayurveda', _survey!.selectedLanguage), icon: const Icon(Icons.spa)),
                  Tab(text: AppTranslations.t('Grocery', _survey!.selectedLanguage), icon: const Icon(Icons.shopping_cart)),
                ],
              ),
              actions: const [],  // All tools moved to sidebar drawer
            ),
          ];
        },
        body: Column(
          children: [
            // MOOD TRACKER (Level 5 Punishment Feature)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))], border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(AppTranslations.t('Mood today:', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  IconButton(icon: const Text('😊', style: TextStyle(fontSize: 24)), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTranslations.t('Great! Stay positive and drink water.', _survey?.selectedLanguage ?? 'English'))));
                  }),
                  IconButton(icon: const Text('😫', style: TextStyle(fontSize: 24)), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTranslations.t('Stressed? Try the breathing exercise in the menu!', _survey?.selectedLanguage ?? 'English'))));
                  }),
                  IconButton(icon: const Text('😴', style: TextStyle(fontSize: 24)), onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTranslations.t('Tired? Get some rest and avoid heavy meals.', _survey?.selectedLanguage ?? 'English'))));
                  }),
                ],
              ),
            ),

            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DietPlanTab(plan: _plan!, isFastingMode: _isFastingMode),
                  ListView(
                    children: [
                      DadiMaaAnimatedWidget(language: _survey?.selectedLanguage ?? 'English'),
                      
                      
                      SizedBox(
                        height: 500, // Wrap in sized box since we have nested listviews
                        child: AyurvedaTab(routine: _plan!.ayurvedaRoutine),
                      ),
                    ],
                  ),
                  GroceryTab(plan: _plan!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  void _showBreathingExercise() {
    
        showDialog(context: context, builder: (_) => AlertDialog(
          title: const Text('Mindful Eating 🧘🏽'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Take 3 deep breaths before eating to improve digestion.'),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  int breathState = 0; // 0=In, 1=Hold, 2=Out
                  String getLabel() {
                    if (breathState == 0) return AppTranslations.t('Breathe In', _survey?.selectedLanguage ?? 'English');
                    if (breathState == 1) return AppTranslations.t('Hold', _survey?.selectedLanguage ?? 'English');
                    return AppTranslations.t('Breathe Out', _survey?.selectedLanguage ?? 'English');
                  }
                  return TweenAnimationBuilder<double>(
                    key: ValueKey<int>(breathState),
                    tween: Tween(
                      begin: breathState == 0 ? 0.5 : (breathState == 1 ? 1.0 : 1.0), 
                      end: breathState == 0 ? 1.0 : (breathState == 1 ? 1.0 : 0.5)
                    ),
                    duration: Duration(seconds: breathState == 0 ? 4 : (breathState == 1 ? 7 : 8)),
                    curve: Curves.easeInOutSine,
                    builder: (context, val, child) {
                      return Transform.scale(
                        scale: val,
                        child: Container(
                          width: 150, height: 150,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withValues(alpha: 0.3)),
                          child: Center(child: Text(getLabel(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
                        ),
                      );
                    },
                    onEnd: () {
                      if (context.mounted) {
                        setState(() {
                          breathState = (breathState + 1) % 3;
                        });
                      }
                    },
                  );
                }
              )
            ]
          ),
          actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Done'))],
        ));
  }

  Widget _buildDoshaBadge() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade50, Colors.pink.shade50]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🧘🏽‍♀️', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppTranslations.t('Your Prakriti (Dosha)', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                  Text('Vata-Pitta Dominant', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
            onPressed: () {
              
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text('Quick Dosha Quiz 🧘🏽‍♀️'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('1. Is your skin usually dry (Vata), warm/oily (Pitta), or thick/cool (Kapha)?'),
                    SizedBox(height: 8),
                    Text('2. Is your digestion irregular (Vata), fast/strong (Pitta), or slow/steady (Kapha)?'),
                    SizedBox(height: 8),
                    Text('3. Under stress, do you feel anxious (Vata), irritable (Pitta), or withdrawn (Kapha)?'),
                  ]
                ),
                actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text('Take Full Test Later'))],
              ));

            },
            child: Text(AppTranslations.t('Retest', _survey?.selectedLanguage ?? 'English'), style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildGrandmaWisdom() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Text('👵🏽', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppTranslations.t('Dadi Maa Ke Nuskhe', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                Text(AppTranslations.t([
                  'Having digestion issues? Soak 1 tsp Ajwain in warm water overnight and drink it first thing in the morning!',
                  'Sore throat? Boil Tulsi leaves, ginger, and a pinch of black pepper. Add honey before drinking.',
                  'Feeling weak? A glass of warm turmeric milk (Haldi Doodh) at night boosts immunity!',
                  'Dry cough? Mix a pinch of turmeric and rock salt in warm water and gargle before bed.',
                  'Hair falling? Massage scalp with warm coconut oil mixed with curry leaves twice a week.',
                  'Acne problems? Apply a paste of neem leaves and rose water for 15 minutes.',
                  'Feeling bloated? Chew half a teaspoon of roasted fennel seeds (Saunf) after every meal.',
                  'Low energy? Eat 2 overnight soaked almonds and 1 walnut every morning.',
                  'Joint pain? Massage with warm mustard oil infused with garlic cloves.',
                  'Trouble sleeping? Rub a few drops of warm ghee on the soles of your feet before bed.'
                ][DateTime.now().day % 10], _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHydrationTracker() {
    double progress = (_waterGlasses * 250) / 3000.0;
    if (progress > 1.0) progress = 1.0;
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              minHeight: 20,
            ),
          ),
          Center(
            child: Text(
              '💧 ml / 3L',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 14),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}



class DadiMaaAnimatedWidget extends StatefulWidget {
  final String language;
  const DadiMaaAnimatedWidget({super.key, required this.language});
  @override
  State<DadiMaaAnimatedWidget> createState() => _DadiMaaAnimatedWidgetState();
}
class _DadiMaaAnimatedWidgetState extends State<DadiMaaAnimatedWidget> {
  int _currentIndex = 0;
  final List<String> tips = [
    'Having digestion issues? Soak 1 tsp Ajwain in warm water overnight and drink it first thing in the morning!',
    'Sore throat? Boil Tulsi leaves, ginger, and a pinch of black pepper. Add honey before drinking.',
    'Feeling weak? A glass of warm turmeric milk (Haldi Doodh) at night boosts immunity!',
    'Dry cough? Mix a pinch of turmeric and rock salt in warm water and gargle before bed.',
    'Hair falling? Massage scalp with warm coconut oil mixed with curry leaves twice a week.',
    'Acne problems? Apply a paste of neem leaves and rose water for 15 minutes.',
    'Feeling bloated? Chew half a teaspoon of roasted fennel seeds (Saunf) after every meal.',
    'Low energy? Eat 2 overnight soaked almonds and 1 walnut every morning.',
    'Joint pain? Massage with warm mustard oil infused with garlic cloves.',
    'Trouble sleeping? Rub a few drops of warm ghee on the soles of your feet before bed.'
  ];
  @override
  void initState() {
    super.initState();
    _startTimer();
  }
  void _startTimer() {
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted) {
        setState(() => _currentIndex = (_currentIndex + 1) % tips.length);
        _startTimer();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightYellow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👵🏽', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppTranslations.t('Dadi Maa Ke Nuskhe', widget.language), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(AppTranslations.t(tips[_currentIndex], widget.language), key: ValueKey(_currentIndex), style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
