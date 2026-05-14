import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:fix_my_diet/core/constants/smart_swaps.dart';

class DietPlanTab extends StatefulWidget {
  final DietPlan plan;
  final bool isFastingMode;
  const DietPlanTab({super.key, required this.plan, this.isFastingMode = false});

  @override
  State<DietPlanTab> createState() => _DietPlanTabState();
}

class _DietPlanTabState extends State<DietPlanTab> {
  int _selectedDay = 0;

  void _showLogMealDialog(BuildContext context, String mealName) {
    int katori = 1;
    int roti = 2;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Meal: $mealName', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 24),
              _buildUnitSelector('🥣 Katori (Bowls)', katori, (val) => setSheetState(() => katori = val)),
              const SizedBox(height: 16),
              _buildUnitSelector('🫓 Roti / Chapati', roti, (val) => setSheetState(() => roti = val)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Logged: $katori Katori, $roti Roti. Estimated +${katori * 150 + roti * 100} kcal'),
                      backgroundColor: AppColors.primary,
                    ));
                  },
                  child: const Text('Confirm Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitSelector(String label, int value, Function(int) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary)),
        Row(
          children: [
            IconButton(
              onPressed: () => onChanged(value > 0 ? value - 1 : 0),
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Text('$value', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            ),
          ],
        ),
      ],
    );
  }
  
  void _showSmartSwapSheet(BuildContext context, String desc) {
    List<Widget> swaps = [];
    SmartSwaps.db.forEach((key, value) {
      if (desc.toLowerCase().contains(key.toLowerCase())) {
        swaps.add(ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('Swap $key with ${value['swap']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${value['nutrition']}'),
          trailing: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ));
      }
    });
    
    if (swaps.isEmpty) {
      swaps.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text('No expensive items detected. High local value! 🇮🇳')),
      ));
    }
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 Smart Swaps', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...swaps,
          ],
        ),
      ),
    );
  }

  void _showMealDetail(BuildContext context, MealEntry meal) {
    // Generate high-quality Unsplash image based on meal name
    String imageUrl = 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=800'; // Default Dal Chawal
    if (meal.title.toLowerCase().contains('poha')) imageUrl = 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?q=80&w=800';
    if (meal.title.toLowerCase().contains('khichdi')) imageUrl = 'https://images.unsplash.com/photo-1606491956689-2ea84b72c444?q=80&w=800';
    if (meal.title.toLowerCase().contains('idli')) imageUrl = 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?q=80&w=800';
    if (meal.title.toLowerCase().contains('roti') || meal.title.toLowerCase().contains('sabzi')) imageUrl = 'https://images.unsplash.com/photo-1601050690597-df0568f70950?q=80&w=800';
    if (meal.title.toLowerCase().contains('fruits')) imageUrl = 'https://images.unsplash.com/photo-1596591606975-97ee5cef3a1e?q=80&w=800';

    Navigator.push(context, MaterialPageRoute(builder: (context) => _MealDetailScreen(meal: meal, imageUrl: imageUrl)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.plan.days.isEmpty) return const Center(child: Text('No plan available'));
    final dayPlan = widget.plan.days[_selectedDay];
    final meals = dayPlan.mealEntries;

    return Column(
      children: [
        // Premium Day Selector
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.plan.days.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemBuilder: (context, index) {
              final isSelected = _selectedDay == index;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedDay = index),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Day ${index + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Meals List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: widget.isFastingMode ? 2 : meals.length,
            itemBuilder: (context, index) {
              var meal = meals[index];
              if (widget.isFastingMode) {
                if (index == 0) meal = MealEntry('Warm Lemon Water & Nuts', 'Morning', 'Hydrating flush. | NUTRITION: 100 kcal', 0xFFD4AF37);
                if (index == 1) meal = MealEntry('Light Fruits & Milk', 'Sunset', 'Easy digestion before night. | NUTRITION: 250 kcal', 0xFF1E392A);
              }

              return Hero(
                tag: 'meal_${meal.title}_$index',
                child: GestureDetector(
                  onTap: () => _showMealDetail(context, meal),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(width: 6, color: Color(meal.colorValue)),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(meal.time, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                        const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Material(color: Colors.transparent, child: Text(meal.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                                    const SizedBox(height: 6),
                                    Material(color: Colors.transparent, child: Text(
                                      meal.description.split(' | NUTRITION: ')[0],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                    )),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _SmallActionButton(
                                          icon: Icons.info_outline,
                                          label: 'Recipe',
                                          onTap: () => _showMealDetail(context, meal),
                                        ),
                                        const SizedBox(width: 12),
                                        _SmallActionButton(
                                          icon: Icons.add_circle_outline,
                                          label: 'Log',
                                          color: AppColors.secondary,
                                          onTap: () => _showLogMealDialog(context, meal.title),
                                        ),
                                        const SizedBox(width: 12),
                                        _SmallActionButton(
                                          icon: Icons.currency_rupee,
                                          label: 'Swap',
                                          color: Colors.green,
                                          onTap: () => _showSmartSwapSheet(context, meal.description),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SmallActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: activeColor),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: activeColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MealDetailScreen extends StatelessWidget {
  final MealEntry meal;
  final String imageUrl;

  const _MealDetailScreen({required this.meal, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'meal_${meal.title}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(imageUrl, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.6)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(meal.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _DetailStat(Icons.schedule, meal.time),
                      _DetailStat(Icons.star_outline, 'Ayurvedic Choice'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  Text(
                    meal.description.split(' | NUTRITION: ')[0],
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary, height: 1.6),
                  ),
                  const SizedBox(height: 32),
                  _buildNutritionCard(),
                  const SizedBox(height: 32),
                  Text('Preparation Guide', style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  _buildRecipeStep(1, 'Prepare ingredients: Ensure they are fresh and organic.'),
                  _buildRecipeStep(2, 'Cook mindfully: Maintain a peaceful state of mind.'),
                  _buildRecipeStep(3, 'Serve warm: Ayurveda suggests eating warm food for best digestion.'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    final nutrition = meal.description.contains(' | NUTRITION: ') 
        ? meal.description.split(' | NUTRITION: ')[1]
        : 'Calories: ~350 kcal, Protein: 10g, Carbs: 45g';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text('Nutrition Facts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nutrition.replaceAll(', ', '\n• '),
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary, height: 1.8),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeStep(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.secondary.withOpacity(0.2),
            child: Text('$step', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary, height: 1.4))),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailStat(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
