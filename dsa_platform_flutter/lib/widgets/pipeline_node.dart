import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class PipelineNode extends StatelessWidget {
  final String name;
  final String status; // 'done', 'current', 'locked'
  final int progress;

  const PipelineNode({
    super.key,
    required this.name,
    required this.status,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor(),
        border: Border.all(
          color: _borderColor(),
          width: status == 'locked' ? 1 : 1.5,
          style: status == 'locked' ? BorderStyle.solid : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Row(
        children: [
          if (status == 'done')
            const Icon(Icons.check, size: 16, color: AppColors.offBlack),
          if (status == 'current')
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.lakeBlue,
                shape: BoxShape.circle,
              ),
            ),
          if (status == 'locked')
            Icon(Icons.lock, size: 16, color: AppColors.smoke.withOpacity(0.5)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name.toUpperCase(),
              style: AppTextStyles.label(),
            ),
          ),
          if (status != 'locked')
            Text(
              '$progress%',
              style: AppTextStyles.statNumber(),
            ),
        ],
      ),
    );
  }

  Color _bgColor() {
    switch (status) {
      case 'done':
        return AppColors.parchment;
      case 'current':
        return AppColors.parchment;
      case 'locked':
        return AppColors.parchment.withOpacity(0.5);
      default:
        return AppColors.parchment;
    }
  }

  Color _borderColor() {
    switch (status) {
      case 'done':
        return AppColors.offBlack;
      case 'current':
        return AppColors.lakeBlue;
      case 'locked':
        return AppColors.ash;
      default:
        return AppColors.ash;
    }
  }
}