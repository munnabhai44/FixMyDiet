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
                  ),),
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
                  ),),
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

  void _showMealDetail(BuildContext context, MealEntry meal) {
    String imageUrl = 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&q=80&w=800'; // Default Biryani
    if (meal.title.toLowerCase().contains('poha')) imageUrl = 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?auto=format&fit=crop&q=80&w=800';
    if (meal.title.toLowerCase().contains('dal') || meal.title.toLowerCase().contains('chawal')) imageUrl = 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&q=80&w=800';
    if (meal.title.toLowerCase().contains('khichdi')) imageUrl = 'https://images.unsplash.com/photo-1606491956689-2ea84b72c444?auto=format&fit=crop&q=80&w=800';
    if (meal.title.toLowerCase().contains('idli') || meal.title.toLowerCase().contains('dosa')) imageUrl = 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&q=80&w=800';
    if (meal.title.toLowerCase().contains('roti') || meal.title.toLowerCase().contains('sabzi')) imageUrl = 'https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&q=80&w=800';
    if (meal.title.toLowerCase().contains('nuts') || meal.title.toLowerCase().contains('fruit')) imageUrl = 'https://images.unsplash.com/photo-1596591606975-97ee5cef3a1e?auto=format&fit=crop&q=80&w=800';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Header Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Image.network(
                    imageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),),
                ),
                Position: Positioned(
                  top: 20, right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ),),
                ),
                Positioned(
                  bottom: -1,
                  left: 0, right: 0,
                  child: Container(
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                    ),),
                  ),),
                ),
              ],
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(meal.title, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Color(meal.colorValue).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.restaurant, color: Color(meal.colorValue)),
                        ),),
                      ],
                    ),),
                    const SizedBox(height: 8),
                    Text(meal.time, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 20),
                    
                    Text('Health Benefits & Description', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      meal.description.split(' | NUTRITION: ')[0],
                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary, height: 1.6),
                    ),),
                    const SizedBox(height: 24),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
                      ),),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.analytics_outlined, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('Nutrition Facts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),),
                          const SizedBox(height: 12),
                          Text(
                            meal.description.contains(' | NUTRITION: ') 
                              ? meal.description.split(' | NUTRITION: ')[1].replaceAll(', ', '\n• ')
                              : '• Calories: ~350 kcal\n• Macros: Balanced',
                            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, height: 1.8),
                          ),),
                        ],
                      ),),
                    ),),
                    const SizedBox(height: 30),
                  ],
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
                    ),),
                    alignment: Alignment.center,
                    child: Text(
                      'Day ${index + 1}',
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),),
                    ),),
                  ),),
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
                        ),),
                      ),),
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
                            ),),
                            const SizedBox(height: 8),
                            Text(
                              meal.description.split(' | NUTRITION: ')[0],
                              style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                            ),),
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
                                  ),),
                                ),),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: TextButton.icon(
                                    onPressed: () => _showLogMealDialog(context, meal.title),
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text('Log Meal', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.secondary),
                                  ),),
                                ),),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 30,
                                  child: TextButton.icon(
                                    onPressed: () => _showSmartSwapSheet(context, meal.description),
                                    icon: const Icon(Icons.currency_rupee, size: 16),
                                    label: const Text('Swap', style: TextStyle(fontSize: 12)),
                                    style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: Colors.green),
                                  ),),
                                ),),
                              ],
                            ),),
                          ],
                        ),),
                      ),),
                    ],
                  ),),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
