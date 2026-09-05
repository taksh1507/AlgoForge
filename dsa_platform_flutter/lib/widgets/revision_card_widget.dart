import 'package:flutter/material.dart';
import '../models/revision_card.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class RevisionCardWidget extends StatelessWidget {
  final RevisionCard card;
  final VoidCallback? onGotIt;
  final VoidCallback? onForgot;

  const RevisionCardWidget({
    super.key,
    required this.card,
    this.onGotIt,
    this.onForgot,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.problemTitle,
            style: AppTextStyles.body(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                card.lastResult == 'failed' ? 'Last: Failed' : 'Last: Solved',
                style: AppTextStyles.labelSmall(color: card.lastResult == 'failed' ? palette.danger : palette.success),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Interval: ${card.intervalDays} days',
                style: AppTextStyles.labelSmall(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onGotIt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'GOT IT',
                    style: AppTextStyles.labelSmall(color: palette.ink),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onForgot,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.ink,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    side: BorderSide(color: palette.ink, width: 1),
                  ),
                  child: Text(
                    'FORGOT',
                    style: AppTextStyles.labelSmall(color: palette.ink),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}