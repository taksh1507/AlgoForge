import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../models/problem.dart';
import '../providers/user_provider.dart';
import '../providers/revision_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/firestore_service.dart';

class RateProblemScreen extends StatefulWidget {
  final Problem problem;

  const RateProblemScreen({super.key, required this.problem});

  @override
  State<RateProblemScreen> createState() => _RateProblemScreenState();
}

class _RateProblemScreenState extends State<RateProblemScreen> {
  final _timeController = TextEditingController(text: '25');
  final _attemptsController = TextEditingController(text: '1');
  final _hintsController = TextEditingController(text: '0');
  int _confidence = 3;
  bool _solutionViewed = false;

  @override
  void dispose() {
    _timeController.dispose();
    _attemptsController.dispose();
    _hintsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How did you do?',
                style: AppTextStyles.heading3(),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Time
              _buildField(palette, 'TIME (MIN)', _timeController),
              const SizedBox(height: AppSpacing.lg),

              // Attempts
              _buildField(palette, 'ATTEMPTS', _attemptsController),
              const SizedBox(height: AppSpacing.lg),

              // Hints
              _buildField(palette, 'HINTS USED', _hintsController),
              const SizedBox(height: AppSpacing.lg),

              // Solution viewed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOLUTION VIEWED',
                    style: AppTextStyles.statLabel(color: palette.faint),
                  ),
                  Switch(
                    value: _solutionViewed,
                    onChanged: (v) => setState(() => _solutionViewed = v),
                    activeColor: palette.accent,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Confidence
              Text(
                'CONFIDENCE',
                style: AppTextStyles.statLabel(color: palette.faint),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () => setState(() => _confidence = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        index < _confidence ? Icons.star : Icons.star_border,
                        color: index < _confidence ? palette.accent : palette.line,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Done button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final uid =
                        context.read<UserProvider>().profile?.uid ?? '';
                    final revisionProvider =
                        context.read<RevisionProvider>();
                    final gamification =
                        context.read<GamificationProvider>();

                    if (uid.isNotEmpty) {
                      try {
                        final firestore = FirestoreService();
                        await firestore.saveAttempt(uid, {
                          'problemSlug': widget.problem.titleSlug,
                          'problemTitle': widget.problem.title,
                          'status': 'SOLVED',
                          'timeTakenMin':
                              int.tryParse(_timeController.text) ?? 0,
                          'attempts':
                              int.tryParse(_attemptsController.text) ?? 1,
                          'hintsUsed':
                              int.tryParse(_hintsController.text) ?? 0,
                          'solutionViewed': _solutionViewed,
                          'confidence': _confidence,
                          'topics': widget.problem.topics,
                          'difficulty': widget.problem.difficulty,
                        });

                        await revisionProvider.addRevision(
                          uid,
                          widget.problem.titleSlug,
                          widget.problem.title,
                        );

                        // Gamification: solve XP + quest progress + badges.
                        final difficultyXp = switch (widget.problem.difficulty) {
                          'EASY' => 10,
                          'MEDIUM' => 20,
                          'HARD' => 35,
                          _ => 10,
                        };
                        await gamification.recordSolve(difficultyXp: difficultyXp);
                        await gamification.evaluateBadges(
                          streak: context.read<UserProvider>().profile?.streak ?? 0,
                        );

                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Completed! +$difficultyXp XP · ${gamification.level}',
                            ),
                          ),
                        );
                      } catch (e) {
                        print('RateProblem save failed: $e');
                      }
                    }

                    navigator.pop();
                    navigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.ink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'DONE',
                    style: AppTextStyles.label(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(AppPalette palette, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.statLabel(color: palette.faint),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(),
          style: AppTextStyles.body(color: palette.ink),
        ),
      ],
    );
  }
}
