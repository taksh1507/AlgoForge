import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/problem_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/revision_provider.dart';
import '../providers/engine_provider.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/skill_radar_chart.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/stat_row.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final problemProvider = context.read<ProblemProvider>();
    final recProvider = context.read<RecommendationProvider>();
    final revisionProvider = context.read<RevisionProvider>();
    final engineProvider = context.read<EngineProvider>();

    // Load user profile
    await userProvider.loadProfile();

    // Load knowledge graph
    await engineProvider.loadKnowledgeGraph();

    // Load problems
    await problemProvider.loadProblems();

    // Load recommendations
    await recProvider.loadRecommendations(
      userProvider: userProvider,
      problemProvider: problemProvider,
    );

    // Load revisions
    final uid = userProvider.profile?.uid;
    if (uid != null) {
      await revisionProvider.loadRevisions(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.lakeBlue),
              );
            }

            final profile = userProvider.profile;
            if (profile == null) {
              return Center(
                child: Text(
                  'No profile loaded. Please sync your LeetCode data.',
                  style: AppTextStyles.bodySmall(),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _loadData,
              color: AppColors.lakeBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Welcome, ${profile.username}',
                            style: AppTextStyles.heading3(),
                          ),
                        ),
                        Text(
                          profile.streak > 0 ? '🔥 ${profile.streak}' : '',
                          style: AppTextStyles.body(color: AppColors.coral),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Recommendation Card
                    const RecommendationCard(),
                    const SizedBox(height: AppSpacing.lg),

                    // Revise Today
                    _buildReviseCard(),
                    const SizedBox(height: AppSpacing.lg),

                    // Skill Profile
                    Text(
                      'Skill Profile',
                      style: AppTextStyles.heading4(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const SkillRadarChart(),
                    const SizedBox(height: AppSpacing.lg),

                    // Activity Calendar
                    Text(
                      'Activity',
                      style: AppTextStyles.heading4(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const CalendarHeatmap(),
                    const SizedBox(height: AppSpacing.lg),

                    // Stats
                    StatRow(
                      stats: [
                        {'value': '${profile.totalSolved}', 'label': 'SOLVED'},
                        {'value': '${profile.streak}', 'label': 'STREAK'},
                        {'value': '${profile.rating}', 'label': 'RATING'},
                        {'value': '${profile.easySolved}', 'label': 'EASY'},
                        {'value': '${profile.mediumSolved}', 'label': 'MED'},
                        {'value': '${profile.hardSolved}', 'label': 'HARD'},
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviseCard() {
    return Consumer<RevisionProvider>(
      builder: (context, revisionProvider, _) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/revision'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.parchment,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: AppColors.ash, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revise Today',
                        style: AppTextStyles.body(color: AppColors.offBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spaced repetition keeps memories strong',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: revisionProvider.dueCount > 0
                        ? AppColors.lakeBlue
                        : AppColors.ash,
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                  ),
                  child: Text(
                    '${revisionProvider.dueCount}',
                    style: AppTextStyles.label(
                      color: revisionProvider.dueCount > 0
                          ? Colors.white
                          : AppColors.smoke,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
