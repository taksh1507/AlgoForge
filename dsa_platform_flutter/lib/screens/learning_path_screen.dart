import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/problem_provider.dart';
import '../providers/engine_provider.dart';
import '../models/problem.dart';
import '../widgets/problem_card.dart';
import '../widgets/pipeline_node.dart';

class LearningPathScreen extends StatefulWidget {
  final String topic;

  const LearningPathScreen({super.key, required this.topic});

  @override
  State<LearningPathScreen> createState() => _LearningPathScreenState();
}

class _LearningPathScreenState extends State<LearningPathScreen> {
  List<String> _path = [];
  List<Problem> _pathProblems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPath();
  }

  Future<void> _loadPath() async {
    final engine = context.read<EngineProvider>();
    final problemProvider = context.read<ProblemProvider>();

    final path = engine.getLearningPath(widget.topic);

    // Get problems for each topic in the path
    final problems = <Problem>[];
    for (final topic in path) {
      final topicProblems = problemProvider.getByTopic(topic);
      problems.addAll(topicProblems);
    }

    setState(() {
      _path = path;
      _pathProblems = problems;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.lakeBlue),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back link
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        '← Back to Learning',
                        style: AppTextStyles.label(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Topic title
                    Text(
                      widget.topic,
                      style: AppTextStyles.heading2(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Pipeline nodes (Topological Sort path)
                    ...List.generate(_path.length, (index) {
                      final topic = _path[index];
                      final isLast = index == _path.length - 1;

                      // Determine status based on user's skill
                      String status = 'locked';
                      // For now, mark first few as done for demo
                      if (index < _path.length - 2) {
                        status = 'done';
                      } else if (index == _path.length - 2) {
                        status = 'current';
                      }

                      return Column(
                        children: [
                          PipelineNode(
                            name: topic,
                            status: status,
                            progress: status == 'done'
                                ? 100
                                : status == 'current'
                                    ? 60
                                    : 0,
                          ),
                          if (!isLast)
                            Container(
                              width: 1,
                              height: 24,
                              color: AppColors.ash,
                            ),
                        ],
                      );
                    }),
                    const SizedBox(height: AppSpacing.xl),

                    // Problems in path
                    if (_pathProblems.isNotEmpty) ...[
                      Text(
                        'Problems in this path',
                        style: AppTextStyles.label(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ..._pathProblems.take(10).map((problem) {
                        return ProblemCard(
                          problem: problem,
                          subtitle: problem.topics.join(' · '),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/problem-detail',
                              arguments: {
                                'problem': problem,
                                'reason': 'Part of ${widget.topic} learning path',
                              },
                            );
                          },
                        );
                      }),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: Text(
                            'No problems available for this path yet',
                            style: AppTextStyles.label(color: AppColors.smoke),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
