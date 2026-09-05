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
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bgColor(palette),
        border: Border.all(
          color: _borderColor(palette),
          width: status == 'locked' ? 1 : 1.5,
          style: status == 'locked' ? BorderStyle.solid : BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Row(
        children: [
          if (status == 'done')
            Icon(Icons.check, size: 16, color: palette.ink),
          if (status == 'current')
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
              ),
            ),
          if (status == 'locked')
            Icon(Icons.lock, size: 16, color: palette.faint.withOpacity(0.5)),
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

  Color _bgColor(AppPalette palette) {
    switch (status) {
      case 'done':
        return palette.card;
      case 'current':
        return palette.card;
      case 'locked':
        return palette.card.withOpacity(0.5);
      default:
        return palette.card;
    }
  }

  Color _borderColor(AppPalette palette) {
    switch (status) {
      case 'done':
        return palette.ink;
      case 'current':
        return palette.accent;
      case 'locked':
        return palette.line;
      default:
        return palette.line;
    }
  }
}