import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/engine_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/skill_radar_chart.dart';
import '../widgets/calendar_heatmap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            final profile = userProvider.profile;
            if (profile == null) {
              return Center(
                child: Text(
                  'No profile',
                  style: AppTextStyles.bodySmall(),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.username,
                    style: AppTextStyles.heading2(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'LeetCode Rating: ${profile.rating}',
                    style: AppTextStyles.body(color: AppColors.graphite),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.periwinkleMist,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKILL BREAKDOWN',
                          style: AppTextStyles.statLabel(color: AppColors.lakeBlue),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const SkillRadarChart(),
                        const SizedBox(height: AppSpacing.md),
                        if (userProvider.skillProfile != null)
                          ...userProvider.skillProfile!.sortedTopics.take(6).map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: AppTextStyles.bodySmall(color: AppColors.offBlack),
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.score.round()}%',
                                    style: AppTextStyles.labelSmall(
                                      color: entry.value.score < 50
                                          ? AppColors.coral
                                          : AppColors.offBlack,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Submission Calendar',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const CalendarHeatmap(),
                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Achievements',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildAchievement('🔥', '${profile.streak}-day streak'),
                      _buildAchievement('💯', '${profile.totalSolved} problems'),
                      if (profile.contestRanking > 0)
                        _buildAchievement('🎯', 'Contest #${profile.contestRanking}'),
                      if (profile.easySolved > 0)
                        _buildAchievement('🟢', '${profile.easySolved} Easy'),
                      if (profile.mediumSolved > 0)
                        _buildAchievement('🟡', '${profile.mediumSolved} Medium'),
                      if (profile.hardSolved > 0)
                        _buildAchievement('🔴', '${profile.hardSolved} Hard'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Stats',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatRow('Total Solved', '${profile.totalSolved}'),
                  _buildStatRow('Easy', '${profile.easySolved}'),
                  _buildStatRow('Medium', '${profile.mediumSolved}'),
                  _buildStatRow('Hard', '${profile.hardSolved}'),
                  _buildStatRow('Streak', '${profile.streak} days'),
                  _buildStatRow('Rating', '${profile.rating}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievement(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.ash, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        '$emoji $label',
        style: AppTextStyles.labelSmall(color: AppColors.offBlack),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.ash, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: AppColors.graphite),
          ),
          Text(
            value,
            style: AppTextStyles.label(),
          ),
        ],
      ),
    );
  }
}
