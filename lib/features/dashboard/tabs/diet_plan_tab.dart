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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(meal.colorValue).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Center(child: Icon(Icons.restaurant, size: 64, color: Color(meal.colorValue))),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(meal.title, style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold))),
                      Text(meal.time, style: GoogleFonts.inter(color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Description', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    meal.description.split(' | NUTRITION: ')[0],
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (meal.description.contains(' | NUTRITION: ')) ...[
                    Text('Nutrition Facts', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        meal.description.split(' | NUTRITION: ')[1].replaceAll(', ', '\n• '),
                        style: GoogleFonts.inter(height: 1.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

              return GestureDetector(
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
                                  Text(meal.title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                  const SizedBox(height: 6),
                                  Text(
                                    meal.description.split(' | NUTRITION: ')[0],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _SmallActionButton(
                                        icon: Icons.info_outline,
                                        label: 'Info',
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
