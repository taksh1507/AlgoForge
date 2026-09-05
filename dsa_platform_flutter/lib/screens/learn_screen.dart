import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../widgets/topic_card.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Learning Paths',
                style: AppTextStyles.heading2(),
              ),
              const SizedBox(height: AppSpacing.xl),

              TopicCard(
                topic: 'Arrays',
                score: 82,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Arrays'),
              ),
              const SizedBox(height: AppSpacing.md),

              TopicCard(
                topic: 'Two Pointers',
                score: 48,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Two Pointers'),
              ),
              const SizedBox(height: AppSpacing.md),

              TopicCard(
                topic: 'Sliding Window',
                score: 31,
                isWeak: true,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Sliding Window'),
              ),
              const SizedBox(height: AppSpacing.md),

              TopicCard(
                topic: 'Binary Search',
                score: 65,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Binary Search'),
              ),
              const SizedBox(height: AppSpacing.md),

              TopicCard(
                topic: 'Trees',
                score: 24,
                isWeak: true,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Trees'),
              ),
              const SizedBox(height: AppSpacing.md),

              TopicCard(
                topic: 'Graphs',
                score: 12,
                isWeak: true,
                onTap: () => Navigator.pushNamed(context, '/learning-path',
                    arguments: 'Graphs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
