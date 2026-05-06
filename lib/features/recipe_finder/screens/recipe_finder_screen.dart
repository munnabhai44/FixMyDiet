import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/core/constants/app_constants.dart';
import 'package:fix_my_diet/features/auth/providers/auth_provider.dart';
import 'package:fix_my_diet/features/recipe_finder/models/recipe.dart';
import 'package:fix_my_diet/services/firestore_service.dart';
import 'package:fix_my_diet/services/gemini_service.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeFinderScreen extends ConsumerStatefulWidget {
  const RecipeFinderScreen({super.key});

  @override
  ConsumerState<RecipeFinderScreen> createState() => _RecipeFinderScreenState();
}

class _RecipeFinderScreenState extends ConsumerState<RecipeFinderScreen> {
  final GeminiService _gemini = GeminiService();
  final FirestoreService _firestore = FirestoreService();
  final TextEditingController _ingredientController = TextEditingController();
  
  final List<String> _selectedIngredients = [];
  String _mealType = 'Snack';
  bool _isHealthy = true;
  bool _isLoading = false;
  String? _error;
  List<Recipe>? _recipes;

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    final clean = ingredient.trim().toLowerCase();
    if (clean.isNotEmpty && !_selectedIngredients.contains(clean)) {
      setState(() => _selectedIngredients.add(clean));
      _ingredientController.clear();
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() => _selectedIngredients.remove(ingredient));
  }

  Future<void> _findRecipes() async {
    if (_selectedIngredients.isEmpty) {
      setState(() => _error = 'Please add at least one ingredient');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _recipes = null;
    });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not logged in');

      final survey = await _firestore.getUserSurvey(user.uid);
      if (survey == null) throw Exception('Survey data not found');

      final recipes = await _gemini.findRecipes(
        ingredients: _selectedIngredients,
        mealType: _mealType,
        dietType: survey.dietType,
        healthy: _isHealthy,
        language: survey.selectedLanguage,
      );

      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _openYouTube(String query) async {
    final url = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What Can I Cook?')),
      body: _recipes != null ? _buildResults() : _buildInputForm(),
    );
  }

  Widget _buildInputForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us what you have', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
          const SizedBox(height: 8),
          Text('Enter ingredients you have in your kitchen right now.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          const SizedBox(height: 20),

          // Input field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ingredientController,
                  decoration: const InputDecoration(
                    hintText: 'E.g., Suji, Curd, Peanuts...',
                    prefixIcon: Icon(Icons.kitchen),
                  ),
                  onSubmitted: _addIngredient,
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => _addIngredient(_ingredientController.text),
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(16)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Selected Chips
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _selectedIngredients.map((ing) {
              return Chip(
                label: Text(ing),
                onDeleted: () => _removeIngredient(ing),
                backgroundColor: AppColors.lightGreen.withValues(alpha: 0.3),
                deleteIconColor: AppColors.darkGreen,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Quick Select
          Text('Quick Add Staples', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.commonIngredients.map((ing) {
              final val = ing.toLowerCase();
              final isSelected = _selectedIngredients.contains(val);
              return FilterChip(
                label: Text(ing, style: TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _addIngredient(val);
                  } else {
                    _removeIngredient(val);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Filters
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('I want to make a:', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.cardWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _mealType,
                          isExpanded: true,
                          items: ['Snack', 'Breakfast', 'Quick Meal', 'Sweet', 'Drink', 'Any'].map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (v) { if (v != null) setState(() => _mealType = v); },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Healthy?', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Switch(
                    value: _isHealthy,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isHealthy = v),
                  ),
                ],
              ),
            ],
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13)),
          ],

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _findRecipes,
              child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Find Recipes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.cardWhite,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_recipes!.length} ideas found', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => setState(() => _recipes = null),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Ingredients'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _recipes!.length,
            itemBuilder: (context, index) {
              final recipe = _recipes![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(recipe.name, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(recipe.description, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.timer, size: 14, color: AppColors.accent),
                          const SizedBox(width: 4),
                          Text('${recipe.cookingTimeMinutes}m', style: GoogleFonts.poppins(fontSize: 12)),
                          const SizedBox(width: 12),
                          Icon(Icons.health_and_safety, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(recipe.healthRating.toUpperCase(), style: GoogleFonts.poppins(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(24),
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(recipe.name, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Nutrition Information', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                      content: Text(recipe.nutritionNote, style: GoogleFonts.poppins(fontSize: 14, height: 1.5)),
                                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                                    )
                                  );
                                },
                                icon: const Icon(Icons.info_outline),
                                label: const Text('View Nutrition Info'),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightYellow, foregroundColor: AppColors.textPrimary, elevation: 0),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('How to make it:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView(
                                children: recipe.steps.map((step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                      Expanded(child: Text(step, style: GoogleFonts.poppins(fontSize: 14))),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: () => _openYouTube(recipe.youtubeSearchQuery),
                                icon: const Icon(Icons.play_circle_fill, color: Colors.red),
                                label: const Text('Watch on YouTube'),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      )
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
