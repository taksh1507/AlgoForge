import 'package:flutter/material.dart';
import '../models/problem.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class ProblemCard extends StatelessWidget {
  final Problem problem;
  final VoidCallback? onTap;
  final String? subtitle;

  const ProblemCard({
    super.key,
    required this.problem,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.ash, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${problem.questionId}',
                        style: AppTextStyles.label(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          problem.title,
                          style: AppTextStyles.body(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.ash, width: 1),
                borderRadius: BorderRadius.circular(AppRadii.tag),
              ),
              child: Text(
                problem.difficulty,
                style: AppTextStyles.label(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}