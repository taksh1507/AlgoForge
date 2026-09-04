import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../models/problem.dart';

class ProblemDetailScreen extends StatelessWidget {
  final Problem problem;
  final String? reason;

  const ProblemDetailScreen({
    super.key,
    required this.problem,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back arrow and problem number
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '←',
                      style: AppTextStyles.body(color: AppColors.offBlack),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.ash, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.tag),
                    ),
                    child: Text(
                      '#${problem.questionId}',
                      style: AppTextStyles.bodySmall(color: AppColors.smoke),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Problem title
              Text(
                problem.title,
                style: AppTextStyles.heading2(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Difficulty and topic tags
              Row(
                children: [
                  _buildTag(problem.difficulty, _difficultyColor(problem.difficulty)),
                  const SizedBox(width: AppSpacing.sm),
                  for (final topic in problem.topics.take(2)) ...[
                    _buildTag(topic, AppColors.offBlack),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Why this problem?
              if (reason != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ash, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHY THIS PROBLEM?',
                        style: AppTextStyles.statLabel(color: AppColors.smoke),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        reason!,
                        style: AppTextStyles.body(color: AppColors.graphite),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Similar Problems
              Text(
                'Similar Problems',
                style: AppTextStyles.label(),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: problem.topics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.ash, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.tag),
                    ),
                    child: Text(
                      topic,
                      style: AppTextStyles.bodySmall(color: AppColors.offBlack),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Start Solving button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/rate', arguments: problem);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lakeBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'START SOLVING',
                    style: AppTextStyles.label(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ash, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.statLabel(color: color),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return AppColors.mint;
      case 'MEDIUM':
        return AppColors.gold;
      case 'HARD':
        return AppColors.coral;
      default:
        return AppColors.offBlack;
    }
  }
}
