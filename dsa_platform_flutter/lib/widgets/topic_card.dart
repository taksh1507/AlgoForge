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
    final palette = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: palette.line, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic,
                    style: AppTextStyles.body(color: palette.ink),
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
                            backgroundColor: palette.line.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              palette.accent,
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$score%',
                        style: AppTextStyles.label(color: palette.muted),
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
                  style: AppTextStyles.bodySmall(color: palette.danger),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
