import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../models/problem.dart';

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
    return Scaffold(
      backgroundColor: AppColors.parchment,
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
              _buildField('TIME (MIN)', _timeController),
              const SizedBox(height: AppSpacing.lg),

              // Attempts
              _buildField('ATTEMPTS', _attemptsController),
              const SizedBox(height: AppSpacing.lg),

              // Hints
              _buildField('HINTS USED', _hintsController),
              const SizedBox(height: AppSpacing.lg),

              // Solution viewed
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SOLUTION VIEWED',
                    style: AppTextStyles.statLabel(color: AppColors.smoke),
                  ),
                  Switch(
                    value: _solutionViewed,
                    onChanged: (v) => setState(() => _solutionViewed = v),
                    activeColor: AppColors.lakeBlue,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Confidence
              Text(
                'CONFIDENCE',
                style: AppTextStyles.statLabel(color: AppColors.smoke),
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
                        color: index < _confidence ? AppColors.lakeBlue : AppColors.ash,
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
                  onPressed: () {
                    // Save attempt and navigate back
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.offBlack,
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

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.statLabel(color: AppColors.smoke),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(),
          style: AppTextStyles.body(color: AppColors.offBlack),
        ),
      ],
    );
  }
}
