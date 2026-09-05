import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../app.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../providers/problem_provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/revision_provider.dart';
import '../providers/engine_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/skill_radar_chart.dart';
import '../widgets/calendar_heatmap.dart';
import '../widgets/stat_row.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Returning from solving a problem → recompute practice state and
    // reschedule reminders so a just-completed session stops the nagging.
    _loadData();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final problemProvider = context.read<ProblemProvider>();
    final recProvider = context.read<RecommendationProvider>();
    final revisionProvider = context.read<RevisionProvider>();
    final engineProvider = context.read<EngineProvider>();
    final gamification = context.read<GamificationProvider>();

    // Load user profile
    await userProvider.loadProfile();

    // Refresh gamification-level badges based on live streak
    if (userProvider.profile != null) {
      await gamification.evaluateBadges(streak: userProvider.profile!.streak);
    }

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

    // Generate notifications based on live data
    await _generateNotifications(userProvider, revisionProvider, recProvider);
  }

  Future<void> _generateNotifications(
    UserProvider userProvider,
    RevisionProvider revisionProvider,
    RecommendationProvider recProvider,
  ) async {
    final notificationProvider = context.read<NotificationProvider>();
    final profile = userProvider.profile;

    // Detect whether the user already practiced today (from attempts)
    final uid = profile?.uid ?? '';
    final firestore = FirestoreService();
    var practicedToday = false;
    if (uid.isNotEmpty) {
      final attempts = await firestore.getAttempts(uid, limit: 50);
      final now = DateTime.now();
      for (final a in attempts) {
        final t = a['timestamp'];
        DateTime? ts;
        if (t is DateTime) ts = t;
        if (t is Timestamp) ts = t.toDate();
        if (ts != null &&
            ts.toLocal().year == now.year &&
            ts.toLocal().month == now.month &&
            ts.toLocal().day == now.day) {
          practicedToday = true;
          break;
        }
      }
    }
    print('AlgoForge: practiced today → $practicedToday');

    // Schedule all dynamic on-device reminders from live data:
    // next revision-card due time, evening streak-saver, weekly recommendation.
    await notificationProvider.scheduleDynamicReminders(
      profile: profile,
      cards: revisionProvider.allCards,
      practicedToday: practicedToday,
    );

    // Revision-due in-app notification (only once per app session)
    if (revisionProvider.dueCards.isNotEmpty &&
        notificationProvider.shouldNotifyRevisionDue) {
      await notificationProvider.addNotification(
        'revision',
        'Revision due: ${revisionProvider.dueCount} card(s)',
        'Your spaced-repetition queue has ${revisionProvider.dueCount} card(s) waiting. A quick review keeps the material fresh!',
        alsoTray: true,
      );
      notificationProvider.markNotified('revision');
    }

    // Streak reminder when idle / streak at risk
    if (profile != null &&
        profile.streak > 0 &&
        notificationProvider.streakReminderEnabled &&
        !notificationProvider.streakNotified) {
      await notificationProvider.addNotification(
        'streak',
        'Keep your ${profile.streak}-day streak alive!',
        'Solve one problem today to maintain your momentum. Don\'t let the flame go out! 🔥',
        alsoTray: true,
      );
      notificationProvider.markNotified('streak');
    }

    // Learning path / recommendation update
    if (recProvider.recommendations.isNotEmpty &&
        notificationProvider.recommendationEnabled &&
        !notificationProvider.recommendationNotified) {
      final top = recProvider.recommendations.first;
      await notificationProvider.addNotification(
        'recommendation',
        'Next up: ${top.problemTitle}',
        'Recommended next problem based on your skill profile — ${top.reason}.',
        alsoTray: true,
      );
      notificationProvider.markNotified('recommendation');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, _) {
            if (userProvider.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: palette.accent),
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
              color: palette.accent,
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
                          style: AppTextStyles.body(color: palette.danger),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // XP / level / daily quests
                    const _GamificationCard(),
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
        final palette = context.palette;
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/revision'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: palette.card,
              borderRadius: BorderRadius.circular(AppRadii.card),
              border: Border.all(color: palette.line, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Revise Today',
                        style: AppTextStyles.body(color: palette.ink),
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
                        ? palette.accent
                        : palette.line,
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                  ),
                  child: Text(
                    '${revisionProvider.dueCount}',
                    style: AppTextStyles.label(
                      color: revisionProvider.dueCount > 0
                          ? Colors.white
                          : palette.ink,
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

/// Dashboard card showing XP/level progress and today's quests.
class _GamificationCard extends StatelessWidget {
  const _GamificationCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Consumer<GamificationProvider>(
      builder: (context, g, _) {
        final pct =
            (g.levelProgress / xpPerLevel).clamp(0.0, 1.0).toDouble();
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
              ...quests.map((q) {
                final done = (g.questProgress[q['id']] ?? 0) >= q['target'];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Text(q['emoji'] as String,
                          style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          q['name'] as String,
                          style: AppTextStyles.bodySmall(
                            color: done ? palette.ink : palette.faint,
                          ),
                        ),
                      ),
                      Text(
                        done
                            ? '✓'
                            : '${g.questProgress[q['id']] ?? 0}/${q['target']}',
                        style: AppTextStyles.labelSmall(
                          color: done ? palette.success : palette.accent,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
