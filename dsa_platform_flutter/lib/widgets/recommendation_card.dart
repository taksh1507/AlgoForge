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
        final palette = context.palette;
        if (recProvider.isLoading) {
          return _buildLoadingCard(palette);
        }

        final recs = recProvider.recommendations;
        if (recs.isEmpty) {
          return _buildEmptyCard(palette);
        }

        final top = recs.first;
        return _buildRecommendation(context, palette, top);
      },
    );
  }

  Widget _buildRecommendation(
      BuildContext context, AppPalette palette, Recommendation rec) {
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
          color: palette.accentSoft,
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⭐ NEXT PROBLEM',
              style: AppTextStyles.statLabel(color: palette.accent),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rec.problemTitle,
              style: AppTextStyles.heading3(),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Score: ${rec.score.round()}/100',
              style: AppTextStyles.label(color: palette.muted),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              rec.reason,
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildTag(
                    rec.difficulty, _difficultyColor(palette, rec.difficulty),
                    palette),
                for (final topic in rec.topics.take(2))
                  _buildTag(topic, palette.ink, palette),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(AppPalette palette) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ NEXT PROBLEM',
            style: AppTextStyles.statLabel(color: palette.accent),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 24,
            width: 120,
            child: LinearProgressIndicator(backgroundColor: palette.line),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 14,
            width: 200,
            child: LinearProgressIndicator(backgroundColor: palette.line),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(AppPalette palette) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⭐ NEXT PROBLEM',
            style: AppTextStyles.statLabel(color: palette.accent),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Sync your LeetCode data to get personalized recommendations',
            style: AppTextStyles.label(color: palette.faint),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, AppPalette palette) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: palette.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.labelTiny(color: color),
      ),
    );
  }

  Color _difficultyColor(AppPalette palette, String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return palette.success;
      case 'MEDIUM':
        return palette.warn;
      case 'HARD':
        return palette.danger;
      default:
        return palette.ink;
    }
  }
}
