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
      padding: const EdgeInsets.all(20),
      children: [
        _buildSection(
          title: 'Internal Remedies',
          icon: Icons.local_drink_outlined,
          color: AppColors.secondary,
          items: routine.internalRemedies,
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'External Applications',
          icon: Icons.spa_outlined,
          color: AppColors.accent,
          items: routine.externalApplications,
        ),
        const SizedBox(height: 16),
        _buildSection(
          title: 'Lifestyle Tips',
          icon: Icons.wb_sunny_outlined,
          color: AppColors.primary,
          items: routine.lifestyleTips,
        ),
        const SizedBox(height: 40),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            'Disclaimer: These Ayurvedic suggestions are home remedies based on general principles. For severe or chronic conditions, please consult a registered BAMS Vaidya.',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 100),
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item, style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textPrimary)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
