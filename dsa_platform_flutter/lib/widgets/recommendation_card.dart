import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/recommendation_provider.dart';
import '../models/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (context, recProvider, _) {
        if (recProvider.isLoading) {
          return _buildLoadingCard();
        }

        final recs = recProvider.recommendations;
        if (recs.isEmpty) {
          return _buildEmptyCard();
        }

        final top = recs.first;
        return _buildRecommendation(context, top);
      },
    );
  }

  Widget _buildRecommendation(BuildContext context, Recommendation rec) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/problem-detail',
          arguments: {
            'problem': rec,
            'reason': rec.reason,
          },
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.periwinkleMist,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⭐ NEXT PROBLEM',
              style: AppTextStyles.statLabel(color: AppColors.lakeBlue),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rec.problemTitle,
              style: AppTextStyles.heading3(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Score: ${rec.score.round()}/100',
              style: AppTextStyles.label(color: AppColors.graphite),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rec.reason,
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildTag(rec.difficulty, _difficultyColor(rec.difficulty)),
                const SizedBox(width: AppSpacing.sm),
                for (final topic in rec.topics.take(2)) ...[
                  _buildTag(topic, AppColors.offBlack),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.periwinkleMist,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ NEXT PROBLEM',
            style: AppTextStyles.statLabel(color: AppColors.lakeBlue),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 24,
            width: 120,
            child: LinearProgressIndicator(backgroundColor: AppColors.ash),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 14,
            width: 200,
            child: LinearProgressIndicator(backgroundColor: AppColors.ash),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.periwinkleMist,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ NEXT PROBLEM',
            style: AppTextStyles.statLabel(color: AppColors.lakeBlue),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sync your LeetCode data to get personalized recommendations',
            style: AppTextStyles.label(color: AppColors.smoke),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ash, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelTiny(color: color),
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
