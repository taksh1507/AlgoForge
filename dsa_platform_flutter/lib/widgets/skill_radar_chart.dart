import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../models/skill_profile.dart';

class SkillRadarChart extends StatelessWidget {
  const SkillRadarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final palette = context.palette;
        final skillProfile = userProvider.skillProfile;
        if (skillProfile == null || skillProfile.topics.isEmpty) {
          return SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 40, color: palette.line),
                  const SizedBox(height: 8),
                  Text(
                    'Solve problems to see skills',
                    style: AppTextStyles.bodySmall(),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _RadarPainter(
              topics: skillProfile.sortedTopics.take(6).toList(),
              accent: palette.accent,
            ),
          ),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<MapEntry<String, TopicScore>> topics;
  final Color accent;

  _RadarPainter({required this.topics, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    if (topics.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final count = topics.length;

    // Draw grid (4 levels)
    final gridPaint = Paint()
      ..color = AppColors.ash.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 4; i++) {
      final r = radius * i / 4;
      final path = Path();
      for (int j = 0; j < count; j++) {
        final angle = (2 * pi * j / count) - pi / 2;
        final point = Offset(
          center.dx + r * cos(angle),
          center.dy + r * sin(angle),
        );
        if (j == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw axis lines
    final axisPaint = Paint()
      ..color = AppColors.ash.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, point, axisPaint);
    }

    // Draw labels
    final labelStyle = AppTextStyles.labelTiny();

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final labelPoint = Offset(
        center.dx + (radius + 18) * cos(angle),
        center.dy + (radius + 18) * sin(angle),
      );

      // Truncate long topic names
      String name = topics[i].key;
      if (name.length > 8) name = '${name.substring(0, 7)}…';

      final textPainter = TextPainter(
        text: TextSpan(text: name, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }

    // Draw data polygon
    final dataPaint = Paint()
      ..color = accent.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final score = topics[i].value.score / 100;
      final point = Offset(
        center.dx + radius * score * cos(angle),
        center.dy + radius * score * sin(angle),
      );
      if (i == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(dataPath, dataPaint);
    canvas.drawPath(dataPath, borderPaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final score = topics[i].value.score / 100;
      final point = Offset(
        center.dx + radius * score * cos(angle),
        center.dy + radius * score * sin(angle),
      );
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
