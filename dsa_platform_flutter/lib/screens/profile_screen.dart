import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/skill_radar_chart.dart';
import '../widgets/calendar_heatmap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
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
                    style: AppTextStyles.body(color: palette.muted),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: palette.accentSoft,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SKILL BREAKDOWN',
                          style: AppTextStyles.statLabel(color: palette.accent),
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
                                      style: AppTextStyles.bodySmall(color: palette.ink),
                                    ),
                                  ),
                                  Text(
                                    '${entry.value.score.round()}%',
                                    style: AppTextStyles.labelSmall(
                                      color: entry.value.score < 50
                                          ? palette.danger
                                          : palette.ink,
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
                      _buildAchievement(palette, '🔥', '${profile.streak}-day streak'),
                      _buildAchievement(palette, '💯', '${profile.totalSolved} problems'),
                      if (profile.contestRanking > 0)
                        _buildAchievement(palette, '🎯', 'Contest #${profile.contestRanking}'),
                      if (profile.easySolved > 0)
                        _buildAchievement(palette, '🟢', '${profile.easySolved} Easy'),
                      if (profile.mediumSolved > 0)
                        _buildAchievement(palette, '🟡', '${profile.mediumSolved} Medium'),
                      if (profile.hardSolved > 0)
                        _buildAchievement(palette, '🔴', '${profile.hardSolved} Hard'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Progression',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _ProgressionCard(),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Insights & Training',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/analytics'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.accent,
                            side: BorderSide(color: palette.accent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.insights, size: 18),
                          label: const Text('Analytics'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/interview'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.accent,
                            side: BorderSide(color: palette.accent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.record_voice_over, size: 18),
                          label: const Text('Interview Prep'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Notification Settings',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const NotificationSettingsCard(),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'App Settings',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _AppSettingsCard(),
                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    'Stats',
                    style: AppTextStyles.heading4(),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatRow(palette, 'Total Solved', '${profile.totalSolved}'),
                  _buildStatRow(palette, 'Easy', '${profile.easySolved}'),
                  _buildStatRow(palette, 'Medium', '${profile.mediumSolved}'),
                  _buildStatRow(palette, 'Hard', '${profile.hardSolved}'),
                  _buildStatRow(palette, 'Streak', '${profile.streak} days'),
                  _buildStatRow(palette, 'Rating', '${profile.rating}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievement(AppPalette palette, String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: palette.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        '$emoji $label',
        style: AppTextStyles.labelSmall(color: palette.ink),
      ),
    );
  }

  Widget _buildStatRow(AppPalette palette, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: palette.line, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.label(color: palette.muted),
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

/// XP, level progress, and badge grid — driven by GamificationProvider.
class _ProgressionCard extends StatelessWidget {
  const _ProgressionCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final g = context.watch<GamificationProvider>();
    final pct = (g.levelProgress / xpPerLevel).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL ${g.level}',
                style: AppTextStyles.statLabel(color: palette.accent),
              ),
              Text(
                '${g.xp} XP',
                style: AppTextStyles.label(color: palette.ink),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.tag),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: palette.line,
              color: palette.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${g.levelProgress} / $xpPerLevel to level ${g.level + 1}',
            style: AppTextStyles.bodySmall(),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: badgesList.map((b) {
              final unlocked = g.badges.contains(b['id']);
              return Tooltip(
                message: '${b['name']} — ${b['desc']}',
                child: Opacity(
                  opacity: unlocked ? 1 : 0.25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(
                        unlocked ? '' : '???',
                        style: AppTextStyles.labelTiny(
                          color: unlocked ? palette.faint : palette.line,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${g.badges.length} / ${badgesList.length} badges earned',
            style: AppTextStyles.bodySmall(),
          ),
        ],
      ),
    );
  }
}

/// Theme mode, offline caching, and the Gemini API key.
class _AppSettingsCard extends StatefulWidget {
  const _AppSettingsCard();

  @override
  State<_AppSettingsCard> createState() => _AppSettingsCardState();
}

class _AppSettingsCardState extends State<_AppSettingsCard> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<SettingsProvider>().geminiApiKey,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settings = context.watch<SettingsProvider>();
    final g = context.watch<GamificationProvider>();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('THEME', style: AppTextStyles.statLabel(color: palette.faint)),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Auto'),
                icon: Icon(Icons.brightness_auto, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined, size: 16),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined, size: 16),
              ),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Offline caching',
              style: AppTextStyles.label(color: palette.ink),
            ),
            subtitle: Text(
              'Keep problems cached for offline use',
              style: AppTextStyles.bodySmall(),
            ),
            value: settings.offlineEnabled,
            onChanged: settings.setOfflineEnabled,
          ),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Text(
            'GEMINI API KEY',
            style: AppTextStyles.statLabel(color: palette.faint),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'AI assistant (optional)',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    settings.setGeminiApiKey(_controller.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('API key saved')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.accent,
                    side: BorderSide(color: palette.accent),
                  ),
                  child: const Text('SAVE KEY'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    g.recordAiUse();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.ink,
                    foregroundColor: palette.bg,
                  ),
                  child: const Text('TEST AI (+5 XP)'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Lets the user toggle which reminders are active and set the daily time.
class NotificationSettingsCard extends StatelessWidget {
  const NotificationSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: palette.line, width: 1),
      ),
      child: Column(
        children: [
          _ToggleRow(
            label: 'Daily revision reminder',
            value: provider.dailyReminderEnabled,
            onChanged: provider.setDailyReminderEnabled,
          ),
          Divider(color: palette.line, height: 1),
          _ReminderTimeRow(provider: provider),
          Divider(color: palette.line, height: 1),
          _ToggleRow(
            label: 'Streak / practice reminder',
            value: provider.streakReminderEnabled,
            onChanged: provider.setStreakReminderEnabled,
          ),
          Divider(color: palette.line, height: 1),
          _ToggleRow(
            label: 'Revision-due alerts',
            value: provider.revisionDueEnabled,
            onChanged: provider.setRevisionDueEnabled,
          ),
          Divider(color: palette.line, height: 1),
          _ToggleRow(
            label: 'Learning path / recommendations',
            value: provider.recommendationEnabled,
            onChanged: provider.setRecommendationEnabled,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.accent,
              side: BorderSide(color: palette.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
            ),
            onPressed: () async {
              await provider.sendTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.notifications_active, size: 18),
            label: const Text('Send Test Notification'),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final Future<void> Function(bool) onChanged;

  const _ToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: AppTextStyles.label(color: palette.ink),
      ),
      value: value,
      activeTrackColor: palette.accent,
      onChanged: onChanged,
    );
  }
}

class _ReminderTimeRow extends StatelessWidget {
  final NotificationProvider provider;

  const _ReminderTimeRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final timeOfDay = TimeOfDay(
      hour: provider.reminderHour,
      minute: provider.reminderMinute,
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.schedule, color: palette.accent, size: 22),
      title: Text(
        'Daily reminder time',
        style: AppTextStyles.label(color: palette.ink),
      ),
      subtitle: Text(
        timeOfDay.format(context),
        style: AppTextStyles.bodySmall(),
      ),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: timeOfDay,
          );
          if (picked != null) {
            await provider.setReminderTime(picked.hour, picked.minute);
          }
        },
        child: Text(
          'CHANGE',
          style: AppTextStyles.labelTiny(color: palette.accent),
        ),
      ),
    );
  }
}