import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../widgets/problem_card.dart';

class StatRow extends StatelessWidget {
  final List<Map<String, String>> stats;

  const StatRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.ash, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: stats.map((stat) {
          return Column(
            children: [
              Text(
                stat['value'] ?? '',
                style: AppTextStyles.statNumber(),
              ),
              const SizedBox(height: 4),
              Text(
                stat['label'] ?? '',
                style: AppTextStyles.statLabel(),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}