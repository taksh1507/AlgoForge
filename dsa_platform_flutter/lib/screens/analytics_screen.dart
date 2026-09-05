import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Map<String, dynamic>> _attempts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<UserProvider>().profile?.uid ?? '';
    if (uid.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }
    final attempts = await FirestoreService().getAttempts(uid, limit: 200);
    if (!mounted) return;
    setState(() {
      _attempts = attempts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final user = context.watch<UserProvider>();
    final skill = user.skillProfile;

    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: palette.accent),
        ),
      );
    }

    // Aggregate activity per day for last 30 days
    final now = DateTime.now();
    final days30 = List.generate(30, (i) {
      final d = now.subtract(Duration(days: 29 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final Map<String, int> dayCounts = {};
    for (final day in days30) {
      dayCounts['${day.year}-${day.month}-${day.day}'] = 0;
    }

    for (final a in _attempts) {
      final t = a['timestamp'];
      DateTime? ts;
      if (t is DateTime) ts = t;
      if (t is Timestamp) ts = t.toDate();
      if (ts == null) continue;
      final local = ts.toLocal();
      final key = '${local.year}-${local.month}-${local.day}';
      if (dayCounts.containsKey(key)) {
        dayCounts[key] = (dayCounts[key] ?? 0) + 1;
      }
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < days30.length; i++) {
      final key = '${days30[i].year}-${days30[i].month}-${days30[i].day}';
      spots.add(FlSpot(i.toDouble(), (dayCounts[key] ?? 0).toDouble()));
    }

    // Topic mastery bars
    final topics = skill?.sortedTopics.take(8).toList() ?? const [];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Insights', style: AppTextStyles.heading3()),
              const SizedBox(height: AppSpacing.xl),

              // Activity (last 30 days)
              Text('ACTIVITY (30 DAYS)', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.md),
              Container(
                height: 160,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.card,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: palette.line, width: 1),
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: palette.accent,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: palette.accentSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Topic mastery
              Text('TOPIC MASTERY', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.md),
              if (topics.isEmpty)
                Text('No topic data yet.', style: AppTextStyles.bodySmall())
              else
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: palette.card,
                    borderRadius: BorderRadius.circular(AppRadii.card),
                    border: Border.all(color: palette.line, width: 1),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= topics.length) return const SizedBox();
                              final name = topics[idx].key;
                              return SideTitleWidget(
                                axisSide: AxisSide.bottom,
                                child: Text(
                                  name.length > 8 ? '${name.substring(0, 8)}…' : name,
                                  style: AppTextStyles.labelTiny(color: palette.faint),
                                ),
                              );
                            },
                            reservedSize: 32,
                          ),
                        ),
                      ),
                      barGroups: List.generate(topics.length, (i) {
                        final pct = topics[i].value.score.clamp(0.0, 100.0).toDouble();
                        final color = pct < 50 ? palette.danger : palette.success;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: pct,
                              color: color,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),

              // Stats
              Text('SUMMARY', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _statBox(palette, 'Total', '${user.profile?.totalSolved ?? 0}'),
                  _statBox(palette, 'Streak', '${user.profile?.streak ?? 0}'),
                  _statBox(palette, 'Rating', '${user.profile?.rating ?? 0}'),
                  _statBox(palette, 'This Mo.', '${_attempts.length}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(AppPalette palette, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: palette.card,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(color: palette.line, width: 1),
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading3()),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: AppTextStyles.labelTiny(color: palette.faint)),
          ],
        ),
      ),
    );
  }
}