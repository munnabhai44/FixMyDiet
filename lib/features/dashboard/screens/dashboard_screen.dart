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
    final modes = ['Navratri Vrat', 'Ramadan', 'Jain Diet', 'Sattvic', 'Ekadashi'];
    final icons = ['🪔', '🌙', '🙏', '🕉️', '📿'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Festival & Fasting Mode', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(modes.length, (i) => ListTile(
              leading: Text(icons[i], style: const TextStyle(fontSize: 24)),
              title: Text(modes[i], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    final newPlan = await GeminiService().generateFastingPlan(_survey!, modes[i]);
                    await _firestore.savePlan(ref.read(currentUserProvider)!.uid, newPlan);
                    _loadData();
                  } catch (e) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Start Mode'),
              ),
            )),
          ],
        ),
      ),
    );
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
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_plan == null || _survey == null) return const Scaffold(body: Center(child: Text('No data found.')));

    final bmi = BmiCalculator.calculate(_survey!.weightKg, _survey!.heightCm);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipeFinderScreen())),
        icon: const Icon(Icons.restaurant_menu),
        label: Text(AppTranslations.t('What Can I Cook?', _survey!.selectedLanguage)),
        backgroundColor: AppColors.secondary,
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
                              Text(AppTranslations.t('Your Health Plan', _survey!.selectedLanguage), style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('BMI', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
                                    Text(bmi.toStringAsFixed(1), style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
              actions: [
                IconButton(
                  icon: const Icon(Icons.nightlight_round, color: Colors.amber),
                  tooltip: 'Fasting Mode',
                  onPressed: _showFastingModeSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.medical_services, color: Colors.white),
                  tooltip: 'Sick Mode',
                  onPressed: _showSickModeDialog,
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Share Plan',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan copied to clipboard!')));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'New Consultation',
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/survey'),
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Account Profile'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.language),
                              title: const Text('Change Language'),
                              onTap: () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Select Language'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: ['English', 'Hindi', 'Gujarati', 'Marathi', 'Tamil', 'Telugu', 'Bengali'].map((lang) {
                                        return ListTile(
                                          title: Text(lang),
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
                                            if (context.mounted) {
                                              Navigator.of(context).pushReplacementNamed('/loading');
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete_forever),
                              title: Text(AppTranslations.t('Reset Profile', _survey!.selectedLanguage)),
                              onTap: () async {
                                final user = ref.read(currentUserProvider);
                                if (user != null) {
                                  await _firestore.saveUserProfile(user.uid, user.email ?? '', _survey!.copyWith(age: 0));
                                }
                                if (context.mounted) Navigator.of(context).pushReplacementNamed('/survey');
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Logout', style: TextStyle(color: Colors.red)),
                              onTap: () async {
                                await ref.read(authServiceProvider).signOut();
                                if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ];
        },
        body: Column(
          children: [
            _buildGrandmaWisdom(), _buildDoshaBadge(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  DietPlanTab(plan: _plan!),
                  AyurvedaTab(routine: _plan!.ayurvedaRoutine),
                  GroceryTab(plan: _plan!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  Text('Your Prakriti (Dosha)', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                  Text('Vata-Pitta Dominant', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detailed Prakriti test coming in v2!')));
            },
            child: const Text('Retest', style: TextStyle(fontSize: 12)),
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
                Text('Dadi Maa Ke Nuskhe', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                Text([
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
                ][DateTime.now().day % 10], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary)),
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
