import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/revision_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/revision_card_widget.dart';

class RevisionScreen extends StatelessWidget {
  const RevisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
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
                        style: AppTextStyles.label(color: AppColors.smoke),
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
                          style: AppTextStyles.label(color: AppColors.smoke),
                        ),
                      ),
                    )
                  else
                    ...dueCards.map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: RevisionCardWidget(
                            card: card,
                            onGotIt: () {
                              revisionProvider.rateRevision(
                                context.read<UserProvider>().profile?.uid ?? '',
                                card,
                                5, // quality 5 = perfect recall
                              );
                            },
                            onForgot: () {
                              revisionProvider.rateRevision(
                                context.read<UserProvider>().profile?.uid ?? '',
                                card,
                                1, // quality 1 = complete blackout
                              );
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
}
