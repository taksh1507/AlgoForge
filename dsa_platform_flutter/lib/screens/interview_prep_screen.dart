import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../models/problem.dart';
import '../providers/problem_provider.dart';
import '../providers/gamification_provider.dart';

class InterviewPrepScreen extends StatefulWidget {
  const InterviewPrepScreen({super.key});

  @override
  State<InterviewPrepScreen> createState() => _InterviewPrepScreenState();
}

class _InterviewPrepScreenState extends State<InterviewPrepScreen> {
  // Selection state
  String? _topic;
  String _difficulty = 'MEDIUM';
  int _timeMinutes = 30;
  int _targetCount = 5;

  // Session state
  bool _running = false;
  late List<Problem> _queue;
  int _current = 0;
  int _solved = 0;
  int _remainingSec = 0;
  Timer? _ticker;
  final Set<String> _solvedSlugs = {};

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _start() {
    final all = context.read<ProblemProvider>().problems;
    var pool = all.where((p) => p.difficulty == _difficulty).toList();
    if (_topic != null && _topic!.isNotEmpty) {
      pool = pool.where((p) => p.topics.contains(_topic)).toList();
    }
    pool.shuffle();
    _queue = pool.take(_targetCount).toList();
    if (_queue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No problems match that filter.')),
      );
      return;
    }
    _current = 0;
    _solved = 0;
    _remainingSec = _timeMinutes * 60;
    _solvedSlugs.clear();
    _running = true;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSec <= 0) {
        _ticker?.cancel();
        setState(() => _running = false);
        return;
      }
      setState(() => _remainingSec--);
    });
    setState(() {});
  }

  void _skip() {
    if (_current + 1 >= _queue.length) {
      _finish();
    } else {
      setState(() => _current++);
    }
  }

  void _markSolved() {
    final slug = _queue[_current].titleSlug;
    if (!_solvedSlugs.contains(slug)) {
      _solvedSlugs.add(slug);
      _solved++;
      context.read<GamificationProvider>().recordSolve(
            difficultyXp: switch (_difficulty) {
              'EASY' => 10,
              'MEDIUM' => 20,
              'HARD' => 35,
              _ => 10,
            },
          );
    }
    if (_current + 1 >= _queue.length) {
      _finish();
    } else {
      setState(() => _current++);
    }
  }

  void _finish() {
    _ticker?.cancel();
    setState(() => _running = false);
    context.read<GamificationProvider>().recordInterviewSession();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final topics = context
        .watch<ProblemProvider>()
        .problems
        .expand((p) => p.topics)
        .toSet()
        .toList()
      ..sort();

    if (_running && _queue.isNotEmpty) {
      return _buildSession(palette);
    }
    if (_running) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: palette.accent)),
      );
    }
    if (_queue.isNotEmpty) return _buildResult(palette);

    // Setup screen
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Interview Prep', style: AppTextStyles.heading3()),
              const SizedBox(height: AppSpacing.sm),
              Text('Simulated timed sessions with score tracking.',
                  style: AppTextStyles.bodySmall()),
              const SizedBox(height: AppSpacing.xl),

              Text('TOPIC', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                value: _topic,
                dropdownColor: palette.card,
                style: AppTextStyles.body(color: palette.ink),
                decoration: const InputDecoration(hintText: 'Any topic'),
                items: <DropdownMenuItem<String>>[
                  const DropdownMenuItem(value: '', child: Text('All')),
                  ...topics.map((t) => DropdownMenuItem(value: t, child: Text(t))),
                ],
                onChanged: (v) => setState(
                  () => _topic = (v == null || v.isEmpty) ? null : v,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('DIFFICULTY', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'EASY', label: Text('Easy')),
                  ButtonSegment(value: 'MEDIUM', label: Text('Medium')),
                  ButtonSegment(value: 'HARD', label: Text('Hard')),
                ],
                selected: {_difficulty},
                onSelectionChanged: (s) => setState(() => _difficulty = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('TIME LIMIT', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 15, label: Text('15m')),
                  ButtonSegment(value: 30, label: Text('30m')),
                  ButtonSegment(value: 45, label: Text('45m')),
                ],
                selected: {_timeMinutes},
                onSelectionChanged: (s) => setState(() => _timeMinutes = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text('PROBLEMS', style: AppTextStyles.statLabel(color: palette.faint)),
              const SizedBox(height: AppSpacing.sm),
              Slider(
                value: _targetCount.toDouble(),
                min: 3,
                max: 10,
                divisions: 7,
                label: '$_targetCount',
                activeColor: palette.accent,
                onChanged: (v) => setState(() => _targetCount = v.round()),
              ),
              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                  child: const Text('START SESSION'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSession(AppPalette palette) {
    final problem = _queue[_current];
    final mm = (_remainingSec ~/ 60).toString().padLeft(2, '0');
    final ss = (_remainingSec % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_current + 1} / ${_queue.length}',
                    style: AppTextStyles.label(color: palette.faint),
                  ),
                  Text(
                    '$mm:$ss',
                    style: AppTextStyles.heading3(
                      color: _remainingSec < 120 ? palette.danger : palette.ink,
                    ),
                  ),
                  Text(
                    'Solved: $_solved',
                    style: AppTextStyles.label(color: palette.success),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Timer bar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.tag),
                child: LinearProgressIndicator(
                  value: _remainingSec / (_timeMinutes * 60),
                  minHeight: 6,
                  backgroundColor: palette.line,
                  color: _remainingSec < 120 ? palette.danger : palette.accent,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(problem.title, style: AppTextStyles.heading4()),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${problem.difficulty} · ${problem.topics.take(3).join(', ')}',
                style: AppTextStyles.bodySmall(),
              ),
              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skip,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.faint,
                        side: BorderSide(color: palette.line),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('SKIP'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _markSolved,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.button),
                        ),
                      ),
                      child: const Text('SOLVED ✓'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppPalette palette) {
    final total = _queue.length;
    final rate = total == 0 ? 0.0 : _solved / total;

    // Weak topics: topics the user missed
    final missed = _queue
        .where((p) => !_solvedSlugs.contains(p.titleSlug))
        .expand((p) => p.topics)
        .fold<Map<String, int>>({}, (m, t) {
      m[t] = (m[t] ?? 0) + 1;
      return m;
    });
    final weak = (missed.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .take(5)
        .map((e) => e.key)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session Complete', style: AppTextStyles.heading3()),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  _statBox(palette, 'Solved', '$_solved'),
                  _statBox(palette, 'Total', '$total'),
                  _statBox(palette, 'Rate', '${(rate * 100).round()}%'),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (weak.isNotEmpty) ...[
                Text('WEAK AREAS', style: AppTextStyles.statLabel(color: palette.faint)),
                const SizedBox(height: AppSpacing.sm),
                ...weak.map(
                  (t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 16, color: palette.warn),
                        const SizedBox(width: AppSpacing.sm),
                        Text(t, style: AppTextStyles.label()),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _queue = []),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                  child: const Text('NEW SESSION'),
                ),
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