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
import 'package:fix_my_diet/core/constants/dadi_maa_remedies.dart';
import 'dart:math';

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

  // --- Feature Dialogs ---

  void _showFastingModeSheet() {
    final modes = ['Ekadashi Vrat', 'Navratri Vrat', 'Pradosh Vrat', 'Chaturthi Vrat', 'Sattvic Fast', 'Jain Diet', 'Intermittent Fasting'];
    final icons = [Icons.auto_awesome, Icons.local_florist_rounded, Icons.nights_stay_rounded, Icons.wb_twilight_rounded, Icons.spa_rounded, Icons.brightness_7_rounded, Icons.timer_rounded];
    final colors = [Color(0xFFFFD54F), Color(0xFFE57373), Color(0xFF9575CD), Color(0xFFFFB74D), Color(0xFF81C784), Color(0xFF4FC3F7), Color(0xFF90A4AE)];
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppTranslations.t('Fasting Mode', _survey?.selectedLanguage ?? 'English'), style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 20),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: modes.length,
                itemBuilder: (ctx, i) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(backgroundColor: colors[i].withOpacity(0.1), child: Icon(icons[i], color: colors[i], size: 20)),
                  title: Text(modes[i], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  trailing: TextButton(
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
                    child: const Text('Start'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareCard() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(AppTranslations.t('Your Diet ID Card', _survey?.selectedLanguage ?? 'English')),
      content: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 100, color: Colors.white),
            const SizedBox(height: 16),
            Text('FixMyDiet Premium', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('${_plan?.dailyCalorieTarget ?? 2000} kcal/day', style: GoogleFonts.inter(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('UID: ${ref.read(currentUserProvider)?.uid.substring(0, 8)}...', style: GoogleFonts.inter(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  void _showCheatApprover() {
    final bmi = BmiCalculator.calculate(_survey!.weightKg, _survey!.heightCm);
    final isApproved = bmi < 24.5;
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(isApproved ? 'Approved! 🎉' : 'Wait... 🚨'),
      content: Text(isApproved 
        ? 'Your BMI ($bmi) is in the safe zone. You can enjoy 1 small portion of your favorite desi treat today!'
        : 'Your BMI ($bmi) suggests staying disciplined. Try roasted Makhana or 1 piece of dark chocolate instead.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it!'))],
    ));
  }

  void _showCravingDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Craving Sweets? 🤤'),
      content: const Text('Try eating 2 Dates (Khajoor) with warm ghee, or a small piece of Jaggery. It balances Vata and satisfies the soul without the sugar crash!'),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('I will try!'))],
    ));
  }

  void _showSickModeDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(AppTranslations.t('Feeling Sick?', _survey!.selectedLanguage)),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'E.g., Fever, Bloating, Cold...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (ctrl.text.isEmpty) return;
              setState(() => _isLoading = true);
              try {
                final plan = await GeminiService().generateSickPlan(_survey!, ctrl.text);
                if (!mounted) return;
                setState(() => _isLoading = false);
                _showHealingPlan(plan);
              } catch (e) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Get Healing Plan'),
          )
        ],
      )
    );
  }

  void _showHealingPlan(String plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Text('🌿 Your Pathya (Healing) Plan', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: Text(plan, style: GoogleFonts.inter(height: 1.6)))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
          ],
        ),
      ),
    );
  }

  void _showSleepAlarm() {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Ayurvedic Sleep Timer 🌙'),
      content: const Text('Ayurveda recommends sleeping by 10 PM (Kapha time) to ensure deep cellular repair. Would you like a reminder 30 mins before?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder set for 9:30 PM!')));
        }, child: const Text('Enable')),
      ],
    ));
  }

  void _showBreathingExercise() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('Mindful Eating 🧘🏽', style: GoogleFonts.plusJakartaSans(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text('Take 3 deep breaths before eating to improve digestion.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            const Spacer(),
            _BreathingCircle(language: _survey?.selectedLanguage ?? 'English'),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Done'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_plan == null || _survey == null) return const Scaffold(body: Center(child: Text('No data found.')));

    final bmi = BmiCalculator.calculate(_survey!.weightKg, _survey!.heightCm);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('FixMyDiet', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.person_outline, size: 20, color: AppColors.primary),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildPremiumDrawer(),
      body: Column(
        children: [
          _buildHeroHeader(bmi),
          const SizedBox(height: 8),
          _buildCustomTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DietPlanTab(plan: _plan!, isFastingMode: _isFastingMode),
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DadiMaaAnimatedWidget(language: _survey?.selectedLanguage ?? 'English'),
                    const SizedBox(height: 20),
                    AyurvedaTab(routine: _plan!.ayurvedaRoutine),
                  ],
                ),
                GroceryTab(plan: _plan!),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecipeFinderScreen())),
        icon: const Icon(Icons.restaurant_menu),
        label: Text(AppTranslations.t('What Can I Cook?', _survey!.selectedLanguage)),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text('Curating your premium plan...', style: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          Tab(text: AppTranslations.t('7-Day Plan', _survey!.selectedLanguage)),
          Tab(text: AppTranslations.t('Ayurveda', _survey!.selectedLanguage)),
          Tab(text: AppTranslations.t('Grocery', _survey!.selectedLanguage)),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(double bmi) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current BMI', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(bmi.toStringAsFixed(1), style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text('Premium Profile', style: GoogleFonts.inter(color: AppColors.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatItem(icon: Icons.local_fire_department, label: '${_plan!.dailyCalorieTarget} kcal', color: Colors.orange),
              const Spacer(),
              _StatItem(icon: Icons.account_balance_wallet, label: '₹${_plan!.estimatedWeeklyCostInr}', color: Colors.green),
              const Spacer(),
              _StatItem(icon: Icons.water_drop, label: '${_waterGlasses * 250} ml', color: Colors.blue, onTap: () => setState(() => _waterGlasses++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumDrawer() {
    return Drawer(
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(32))),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.secondary,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Text('Hello, Premium User!', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                Text(_survey?.selectedLanguage ?? 'English', style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDrawerGroup('Health Tools', [
                  _DrawerItem(Icons.self_improvement, '4-7-8 Breathing', () { Navigator.pop(context); _showBreathingExercise(); }),
                  _DrawerItem(Icons.auto_awesome, 'Fasting Mode', () { Navigator.pop(context); _showFastingModeSheet(); }),
                  _DrawerItem(Icons.healing, 'Sick Mode (Pathya)', () { Navigator.pop(context); _showSickModeDialog(); }),
                  _DrawerItem(Icons.nights_stay, 'Sleep Routine', () { Navigator.pop(context); _showSleepAlarm(); }),
                ]),
                const SizedBox(height: 16),
                _buildDrawerGroup('Discipline Tools', [
                  _DrawerItem(Icons.local_pizza, 'Cheat Approver', () { Navigator.pop(context); _showCheatApprover(); }),
                  _DrawerItem(Icons.cake, 'Sweet Cravings', () { Navigator.pop(context); _showCravingDialog(); }),
                  _DrawerItem(Icons.card_membership, 'Share Diet ID', () { Navigator.pop(context); _showShareCard(); }),
                ]),
                const SizedBox(height: 16),
                _buildDrawerGroup('Settings', [
                  _DrawerItem(Icons.language, 'Change Language', () => _showLanguageDialog()),
                  _DrawerItem(Icons.refresh, 'Reset Profile', () async {
                    final user = ref.read(currentUserProvider);
                    if (user != null) {
                      await _firestore.saveUserProfile(user.uid, user.email ?? '', _survey!.copyWith(age: 0));
                    }
                    if (context.mounted) Navigator.of(context).pushReplacementNamed('/survey');
                  }),
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _DrawerItem(Icons.logout, 'Logout', () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) Navigator.of(context).pushReplacementNamed('/');
            }, isDestructive: true),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(title.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textTertiary, letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: items),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Change Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Hindi', 'Gujarati'].map((l) => ListTile(
            title: Text(l),
            onTap: () async {
              Navigator.pop(ctx);
              final user = ref.read(currentUserProvider);
              if (user != null) {
                await _firestore.saveUserProfile(user.uid, user.email ?? '', _survey!.copyWith(selectedLanguage: l));
                _loadData();
              }
            },
          )).toList(),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem(this.icon, this.title, this.onTap, {this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.primary, size: 20),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : AppColors.textPrimary)),
      onTap: onTap,
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatItem({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
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
  late DadiMaaRemedy _currentRemedy;

  @override
  void initState() {
    super.initState();
    _currentRemedy = DadiMaaRemedies.getRandomRemedy();
  }

  @override
  Widget build(BuildContext context) {
    final isGujarati = widget.language == 'Gujarati';
    final title = isGujarati ? _currentRemedy.titleGu : _currentRemedy.titleEn;
    final desc = isGujarati ? _currentRemedy.descriptionGu : _currentRemedy.descriptionEn;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightYellow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text('Dadi Maa Ke Nuskhe', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const Spacer(),
              const Icon(Icons.refresh, size: 14, color: AppColors.secondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}

enum BreathPhase { inhale, hold, exhale }

class _BreathingCircle extends StatefulWidget {
  final String language;
  const _BreathingCircle({required this.language});
  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle> {
  BreathPhase _phase = BreathPhase.inhale;
  int _cycleCount = 0;

  void _nextPhase() {
    if (!mounted) return;
    setState(() {
      switch (_phase) {
        case BreathPhase.inhale: _phase = BreathPhase.hold; break;
        case BreathPhase.hold: _phase = BreathPhase.exhale; break;
        case BreathPhase.exhale: 
          _phase = BreathPhase.inhale; 
          _cycleCount++;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final duration = _phase == BreathPhase.inhale ? 4 : (_phase == BreathPhase.hold ? 7 : 8);
    final label = _phase == BreathPhase.inhale ? 'Breathe In' : (_phase == BreathPhase.hold ? 'Hold' : 'Breathe Out');
    
    return TweenAnimationBuilder<double>(
      key: ValueKey('${_phase.name}_$_cycleCount'),
      tween: Tween(begin: _phase == BreathPhase.inhale ? 0.5 : 1.0, end: _phase == BreathPhase.exhale ? 0.5 : 1.0),
      duration: Duration(seconds: duration),
      onEnd: _nextPhase,
      builder: (context, val, child) {
        return Column(
          children: [
            Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 10),
              ),
              child: Center(
                child: Transform.scale(
                  scale: val,
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                    ),
                    child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text('${duration}s', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        );
      },
    );
  }
}
