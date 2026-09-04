import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class TopicCard extends StatelessWidget {
  final String topic;
  final int score;
  final bool isWeak;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.score,
    this.isWeak = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: AppColors.ash, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic,
                    style: AppTextStyles.body(color: AppColors.offBlack),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: score / 100,
                            backgroundColor: AppColors.ash.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.lakeBlue,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$score%',
                        style: AppTextStyles.label(color: AppColors.smoke),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isWeak)
              Padding(
                padding: EdgeInsets.only(left: AppSpacing.md),
                child: Text(
                  'Needs work',
                  style: AppTextStyles.bodySmall(color: AppColors.coral),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
