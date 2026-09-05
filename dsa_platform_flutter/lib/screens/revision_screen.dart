import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/revision_provider.dart';
import '../providers/user_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/revision_card_widget.dart';

class RevisionScreen extends StatefulWidget {
  const RevisionScreen({super.key});

  @override
  State<RevisionScreen> createState() => _RevisionScreenState();
}

class _RevisionScreenState extends State<RevisionScreen> {
  final Set<String> _rewarded = {};

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Consumer<RevisionProvider>(
          builder: (context, revisionProvider, _) {
            final dueCards = revisionProvider.dueCards;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Revision Queue',
                        style: AppTextStyles.heading3(),
                      ),
                      Text(
                        'Due today: ${dueCards.length}',
                        style: AppTextStyles.label(color: palette.faint),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  if (dueCards.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xxl),
                        child: Text(
                          'No revisions due today!',
                          style: AppTextStyles.label(color: palette.faint),
                        ),
                      ),
                    )
                  else
                    ...dueCards.map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RevisionCardWidget(
                            card: card,
                            onGotIt: () async {
                              await revisionProvider.rateRevision(
                                context.read<UserProvider>().profile?.uid ?? '',
                                card,
                                5, // quality 5 = perfect recall
                              );
                              _rewardReview(context, card.problemSlug, 5);
                            },
                            onForgot: () async {
                              await revisionProvider.rateRevision(
                                context.read<UserProvider>().profile?.uid ?? '',
                                card,
                                1, // quality 1 = complete blackout
                              );
                              _rewardReview(context, card.problemSlug, 1);
                            },
                          ),
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _rewardReview(BuildContext context, String slug, int quality) {
    if (_rewarded.contains(slug)) return;
    _rewarded.add(slug);
    context.read<GamificationProvider>().recordReview(quality);
  }
}
