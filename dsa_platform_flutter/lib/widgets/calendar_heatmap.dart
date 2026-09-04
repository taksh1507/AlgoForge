import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class CalendarHeatmap extends StatelessWidget {
  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate mock calendar data for last 12 weeks
    final weeks = 12;
    final daysPerWeek = 7;
    final random = DateTime.now().millisecondsSinceEpoch;

    return SizedBox(
      height: 100,
      child: Column(
        children: [
          // Day labels
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) {
              return Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelTiny(),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          // Calendar grid
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
              ),
              itemCount: weeks * daysPerWeek,
              itemBuilder: (context, index) {
                // Mock intensity based on pseudo-random
                final intensity = ((index * 7 + random) % 5) / 4;
                return Container(
                  decoration: BoxDecoration(
                    color: _getIntensityColor(intensity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity < 0.1) return AppColors.ash.withOpacity(0.3);
    if (intensity < 0.3) return AppColors.lakeBlue.withOpacity(0.2);
    if (intensity < 0.5) return AppColors.lakeBlue.withOpacity(0.4);
    if (intensity < 0.7) return AppColors.lakeBlue.withOpacity(0.6);
    return AppColors.lakeBlue.withOpacity(0.9);
  }
}
