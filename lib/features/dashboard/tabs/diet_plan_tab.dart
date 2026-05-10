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
  void _showLogMealDialog(BuildContext context, String mealName) {
    int katori = 1;
    int roti = 2;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Meal: $mealName', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🥣 Katori (Bowls)', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(onPressed: () => setSheetState(() => katori = katori > 0 ? katori - 1 : 0), icon: const Icon(Icons.remove_circle_outline)),
                      Text('$katori', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => setSheetState(() => katori++), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🫓 Roti / Chapati', style: TextStyle(fontSize: 16)),
                  Row(
                    children: [
                      IconButton(onPressed: () => setSheetState(() => roti = roti > 0 ? roti - 1 : 0), icon: const Icon(Icons.remove_circle_outline)),
                      Text('$roti', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => setSheetState(() => roti++), icon: const Icon(Icons.add_circle_outline)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logged: $katori Katori, $roti Roti. Estimated +${katori * 150 + roti * 100} kcal')));
                  },
                  child: const Text('Log Meal (Indian Units)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showSmartSwapSheet(BuildContext context, String desc) {
    List<Widget> swaps = [];
    SmartSwaps.db.forEach((key, value) {
      if (desc.toLowerCase().contains(key)) {
        swaps.add(ListTile(
          title: Text('Swap $key with ${value['swap']}'),
          subtitle: Text('${value['nutrition']}'),
          trailing: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), child: const Text('Apply')),
        ));
      }
    });
    
    if (swaps.isEmpty) {
      swaps.add(const ListTile(title: Text('No expensive ingredients detected! Highly Desi. 🇮🇳')));
    }
    
    showModalBottomSheet(context: context, builder: (ctx) => Container(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('💰 Smart Swap', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16), ...swaps])));
  }

  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.plan.days.isEmpty) {
      return const Center(child: Text('No plan available'));
    }

    final dayPlan = widget.plan.days[_selectedDay];
    final meals = dayPlan.mealEntries;

    return Column(
      children: [
        // Day Selector
        Container(
          height: 70,
          color: AppColors.cardWhite,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.plan.days.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              final isSelected = _selectedDay == index;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () => setState(() => _selectedDay = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary : AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: isSelected ? AppColors.secondary : AppColors.divider),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Day ${index + 1}',
                      style: GoogleFonts.poppins(
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
            padding: const EdgeInsets.all(16),
            itemCount: widget.isFastingMode ? (meals.length > 2 ? 2 : meals.length) : meals.length,
            itemBuilder: (context, index) {
              // If fasting, show a modified generic fasting meal or the first 2 meals modified
              var meal = meals[index];
              if (widget.isFastingMode) {
                if (index == 0) meal = MealEntry('Warm Lemon Water & Nuts', 'Morning', 'Hydrating flush. | NUTRITION: 100 kcal', 0xFFD4AF37);
                if (index == 1) meal = MealEntry('Light Fruits & Milk', 'Sunset', 'Easy digestion before night. | NUTRITION: 250 kcal', 0xFF1E392A);
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time indicator
                      Container(
                        width: 4,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(meal.colorValue),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(meal.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                Text(meal.time, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              meal.description.split(' | NUTRITION: ')[0],
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                SizedBox(
                                  height: 30,
                                  child: TextButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Nutrition Information', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                                          content: Text('Meal: ${meal.description.split(' | NUTRITION: ')[0]}\n\n${meal.description.contains(' | NUTRITION: ') ? meal.description.split(' | NUTRITION: ')[1].replaceAll(', ', '\n') : 'Estimated Calories: ~${(widget.plan.dailyCalorieTarget / 4).round()} kcal\nMacros: Balanced ratio for your target.'}', style: GoogleFonts.poppins(fontSize: 14, height: 1.5)),
                                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                                        )
                                      );
                                    },
                                    icon: const Icon(Icons.info_outline, size: 16),
                                    label: const Text('Nutrition', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: TextButton.icon(
                                    onPressed: () => _showLogMealDialog(context, meal.title),
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text('Log Meal', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.secondary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: TextButton.icon(
                                    onPressed: () => _showSmartSwapSheet(context, meal.description),
                                    icon: const Icon(Icons.currency_rupee, size: 16),
                                    label: const Text('Swap', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
