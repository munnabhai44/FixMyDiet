import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_my_diet/core/constants/app_colors.dart';
import 'package:fix_my_diet/features/plan_generation/models/diet_plan.dart';

class AyurvedaTab extends StatelessWidget {
  final AyurvedaRoutine routine;
  const AyurvedaTab({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSection(
          title: 'Internal Remedies',
          icon: Icons.local_drink,
          color: AppColors.secondary,
          items: routine.internalRemedies,
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: 'External Applications',
          icon: Icons.face,
          color: AppColors.accent,
          items: routine.externalApplications,
        ),
        const SizedBox(height: 20),
        _buildSection(
          title: 'Lifestyle Tips',
          icon: Icons.directions_walk,
          color: AppColors.primary,
          items: routine.lifestyleTips,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.divider.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Disclaimer: These Ayurvedic suggestions are home remedies based on general principles. For severe or chronic conditions, please consult a registered BAMS Vaidya.',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    if (items.isEmpty || (items.length == 1 && items.first.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(Icons.fiber_manual_record, size: 8, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(item, style: GoogleFonts.poppins(fontSize: 14, height: 1.4)),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
