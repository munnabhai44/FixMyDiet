import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/constants/pricing_database.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroceryTab extends StatefulWidget {
  final DietPlan plan;
  const GroceryTab({super.key, required this.plan});

  @override
  State<GroceryTab> createState() => _GroceryTabState();
}

class _GroceryTabState extends State<GroceryTab> {
  final List<_GroceryItem> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _extractAndMatchIngredients();
  }

  Future<void> _extractAndMatchIngredients() async {
    // 1. Extract words from plan
    final Set<String> words = {};
    for (var day in widget.plan.days) {
      final text = '${day.earlyMorning} ${day.breakfast} ${day.lunch} ${day.eveningSnack} ${day.dinner}';
      words.addAll(text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' '));
    }
    for (var rem in widget.plan.ayurvedaRoutine.internalRemedies) {
      words.addAll(rem.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' '));
    }
    for (var rem in widget.plan.ayurvedaRoutine.externalApplications) {
      words.addAll(rem.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').split(' '));
    }

    // 2. Match with DB
    final Set<String> matchedKeys = {};
    for (var word in words) {
      if (word.length > 2) {
        final entry = PricingDatabase.lookup(word);
        if (entry != null) {
          // Avoid duplicates (e.g., matching 'curd' and 'dahi' which might resolve to same entry)
          bool alreadyAdded = false;
          for(var existing in _items) {
             if(existing.entry.displayName == entry.displayName) {
                 alreadyAdded = true;
                 break;
             }
          }
          if(!alreadyAdded) {
             _items.add(_GroceryItem(entry: entry));
          }
        }
      }
    }

    // 3. Load checked state
    final prefs = await SharedPreferences.getInstance();
    for (var i = 0; i < _items.length; i++) {
      _items[i].isChecked = prefs.getBool('grocery_${_items[i].entry.displayName}') ?? false;
    }

    // Sort: unchecked first, then alphabetically
    _sortItems();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _sortItems() {
    _items.sort((a, b) {
      if (a.isChecked == b.isChecked) {
        return a.entry.displayName.compareTo(b.entry.displayName);
      }
      return a.isChecked ? 1 : -1; // false comes before true
    });
  }

  Future<void> _toggleItem(int index) async {
    setState(() {
      _items[index].isChecked = !_items[index].isChecked;
      _sortItems();
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('grocery_${_items[index].entry.displayName}', _items[index].isChecked);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final checkedCount = _items.where((i) => i.isChecked).length;
    final totalCount = _items.length;

    return Column(
      children: [
        // Header Card
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
              Text('Estimated Weekly Groceries', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 4),
              Text('~ ₹${widget.plan.estimatedWeeklyCostInr}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
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

        // List
        Expanded(
          child: _items.isEmpty
              ? Center(child: Text('No items identified from the plan.', style: GoogleFonts.poppins(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: item.isChecked ? AppColors.background : AppColors.cardWhite,
                      child: CheckboxListTile(
                        value: item.isChecked,
                        onChanged: (_) => _toggleItem(index),
                        activeColor: AppColors.primary,
                        title: Text(
                          item.entry.displayName,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                            color: item.isChecked ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          item.entry.formatted,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.accent,
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }
}

class _GroceryItem {
  final PriceEntry entry;
  bool isChecked;
  _GroceryItem({required this.entry, this.isChecked = false});
}
