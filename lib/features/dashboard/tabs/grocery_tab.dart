import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroceryTab extends StatefulWidget {
  final DietPlan plan;
  const GroceryTab({super.key, required this.plan});

  @override
  State<GroceryTab> createState() => _GroceryTabState();
}

class _GroceryTabState extends State<GroceryTab> {
  final List<_CheckedGrocery> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we have AI generated list or need to fallback
    if (widget.plan.groceryList.isNotEmpty) {
      for (var item in widget.plan.groceryList) {
        bool checked = prefs.getBool('grocery_${item.item}') ?? false;
        _items.add(_CheckedGrocery(item, checked));
      }
    }
    
    _sortItems();
    if (mounted) setState(() => _isLoading = false);
  }

  void _sortItems() {
    _items.sort((a, b) {
      if (a.isChecked == b.isChecked) return a.item.item.compareTo(b.item.item);
      return a.isChecked ? 1 : -1;
    });
  }

  Future<void> _toggleItem(int index) async {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;
      _sortItems();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('grocery_${_items[index].item.item}', _items[index].isChecked);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final checkedCount = _items.where((i) => i.isChecked).length;
    final totalCount = _items.length;
    final totalCalculatedCost = _items.fold<int>(0, (sum, i) => sum + i.item.costInr);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.warmGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.secondary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Text('Precise Grocery List', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 4),
              Text('₹$totalCalculatedCost', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: totalCount == 0 ? 0 : checkedCount / totalCount,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Text('$checkedCount of $totalCount items bought', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text('Generate a new plan to see precise grocery list.', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final gi = _items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: gi.isChecked ? AppColors.background : AppColors.cardWhite,
                      child: CheckboxListTile(
                        value: gi.isChecked,
                        onChanged: (_) => _toggleItem(index),
                        activeColor: AppColors.primary,
                        title: Text(
                          gi.item.item,
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, decoration: gi.isChecked ? TextDecoration.lineThrough : null, color: gi.isChecked ? AppColors.textSecondary : AppColors.textPrimary),
                        ),
                        subtitle: Text(
                          'Qty: ${gi.item.quantity}',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent, decoration: gi.isChecked ? TextDecoration.lineThrough : null),
                        ),
                        secondary: Text('₹${gi.item.costInr}', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CheckedGrocery {
  final GroceryItem item;
  bool isChecked;
  _CheckedGrocery(this.item, this.isChecked);
}
