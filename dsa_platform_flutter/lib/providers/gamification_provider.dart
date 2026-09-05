import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Level thresholds — XP needed to reach level N.
const int xpPerLevel = 250;

class GamificationProvider extends ChangeNotifier {
  static const _boxName = 'gamification';
  late final Box _box;

  int _xp = 0;
  int _solveCount = 0;
  int _reviewCount = 0;
  int _testPassCount = 0;
  int _interviewCount = 0;
  int _aiUseCount = 0;
  Set<String> _badges = {};
  String _questDate = '';
  Map<String, int> _questProgress = {};
  (int, String)? _lastAward;

  int get xp => _xp;
  int get level => xpPerLevel < 1 ? 1 : (_xp ~/ xpPerLevel) + 1;
  int get levelProgress => _xp % xpPerLevel;
  int get solveCount => _solveCount;
  int get reviewCount => _reviewCount;
  int get testPassCount => _testPassCount;
  int get interviewCount => _interviewCount;
  int get aiUseCount => _aiUseCount;
  Set<String> get badges => _badges;
  String get questDate => _questDate;
  (int, String)? get lastAward => _lastAward;
  Map<String, int> get questProgress => _questProgress;

  Future<void> initialize() async {
    _box = Hive.box(_boxName);
    _xp = _box.get('xp', defaultValue: 0);
    _solveCount = _box.get('solveCount', defaultValue: 0);
    _reviewCount = _box.get('reviewCount', defaultValue: 0);
    _testPassCount = _box.get('testPassCount', defaultValue: 0);
    _interviewCount = _box.get('interviewCount', defaultValue: 0);
    _aiUseCount = _box.get('aiUseCount', defaultValue: 0);
    _badges = (_box.get('badges', defaultValue: <String>[]) as List)
        .cast<String>()
        .toSet();
    _loadQuests();
  }

  void _loadQuests() {
    _questDate = _box.get('questDate', defaultValue: '');
    _questProgress = () {
      final raw = _box.get('questProgress', defaultValue: <String, dynamic>{});
      return Map<String, int>.from(raw as Map);
    }();
    final today = _today();
    if (_questDate != today) {
      _questDate = today;
      _questProgress = {};
      _box.put('questDate', today);
      _box.put('questProgress', <String, int>{});
    }
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ── Events ──────────────────────────────────────────────────

  Future<void> recordSolve({int difficultyXp = 10}) async {
    _solveCount += 1;
    await awardXp(difficultyXp, reason: 'Problem completed');
    await _bumpQuest('solve_one');
  }

  Future<void> recordReview(int quality) async {
    _reviewCount += 1;
    await awardXp(quality >= 3 ? 8 : 3, reason: 'Revision reviewed');
    await _bumpQuest('review_three');
  }

  Future<void> recordTestPassed() async {
    _testPassCount += 1;
    await awardXp(15, reason: 'Code passed sample cases');
    await _bumpQuest('run_code');
  }

  Future<void> recordInterviewSession() async {
    _interviewCount += 1;
    await awardXp(60, reason: 'Mock session completed');
    await _bumpQuest('interview');
  }

  Future<void> recordAiUse() async {
    _aiUseCount += 1;
    await awardXp(5, reason: 'Asked the AI assistant');
    await _bumpQuest('ask_ai');
  }

  Future<void> awardXp(int amount, {String? reason}) async {
    if (amount <= 0) return;
    _xp += amount;
    _lastAward = (amount, reason ?? '');
    await _persist();
    notifyListeners();
  }

  Future<void> _bumpQuest(String questId) async {
    final quest = quests.firstWhere((q) => q['id'] == questId);
    final current = _questProgress[questId] ?? 0;
    if (current >= (quest['target'] as int)) return;
    _questProgress[questId] = current + 1;
    await _box.put('questProgress', _questProgress);
    if (_questProgress[questId]! >= (quest['target'] as int)) {
      await awardXp(quest['xp'] as int, reason: 'Quest complete');
    }
    notifyListeners();
  }

  /// Re-evaluates badges after an event using current stats + LeetCode streak.
  Future<List<String>> evaluateBadges({int streak = 0}) async {
    final unlocked = <String>{};
    for (final b in badgesList) {
      if (_badges.contains(b['id'])) continue;
      final ok = _checkBadge(b, streak: streak);
      if (ok) unlocked.add(b['id'] as String);
    }
    if (unlocked.isNotEmpty) {
      _badges.addAll(unlocked);
      await _persist();
      notifyListeners();
    }
    return unlocked.toList();
  }

  bool _checkBadge(Map<String, dynamic> badge, {int streak = 0}) {
    switch (badge['id']) {
      case 'first_solve':
        return _solveCount >= 1;
      case 'solve_10':
        return _solveCount >= 10;
      case 'solve_50':
        return _solveCount >= 50;
      case 'review_10':
        return _reviewCount >= 10;
      case 'review_50':
        return _reviewCount >= 50;
      case 'ai_5':
        return _aiUseCount >= 5;
      case 'code_5':
        return _testPassCount >= 5;
      case 'interview_1':
        return _interviewCount >= 1;
      case 'streak_7':
        return streak >= 7;
      case 'streak_30':
        return streak >= 30;
      case 'level_5':
        return level >= 5;
      case 'level_10':
        return level >= 10;
      default:
        return false;
    }
  }

  Future<void> _persist() async {
    await _box.put('xp', _xp);
    await _box.put('solveCount', _solveCount);
    await _box.put('reviewCount', _reviewCount);
    await _box.put('testPassCount', _testPassCount);
    await _box.put('interviewCount', _interviewCount);
    await _box.put('aiUseCount', _aiUseCount);
    await _box.put('badges', _badges.toList());
    await _box.put('questProgress', _questProgress);
  }
}

/// Daily quests — reset each local day.
final List<Map<String, dynamic>> quests = [
  {
    'id': 'solve_one',
    'emoji': '🎯',
    'name': 'Solve one problem',
    'target': 1,
    'xp': 50,
  },
  {
    'id': 'review_three',
    'emoji': '🔁',
    'name': 'Review 3 revision cards',
    'target': 3,
    'xp': 40,
  },
  {
    'id': 'ask_ai',
    'emoji': '🤖',
    'name': 'Ask the AI assistant',
    'target': 1,
    'xp': 25,
  },
  {
    'id': 'run_code',
    'emoji': '💻',
    'name': 'Run your code',
    'target': 1,
    'xp': 25,
  },
  {
    'id': 'interview',
    'emoji': '🎤',
    'name': 'Finish a mock session',
    'target': 1,
    'xp': 60,
  },
];

final List<Map<String, dynamic>> badgesList = [
  {'id': 'first_solve', 'emoji': '🎯', 'name': 'First Solve', 'desc': 'Complete your first problem'},
  {'id': 'solve_10', 'emoji': '🧠', 'name': 'Decade', 'desc': 'Complete 10 problems'},
  {'id': 'solve_50', 'emoji': '💪', 'name': 'Iron Will', 'desc': 'Complete 50 problems'},
  {'id': 'review_10', 'emoji': '🔁', 'name': 'Reviewer', 'desc': 'Review 10 revision cards'},
  {'id': 'review_50', 'emoji': '📚', 'name': 'Master Reviewer', 'desc': 'Review 50 revision cards'},
  {'id': 'ai_5', 'emoji': '🤖', 'name': 'AI Native', 'desc': 'Ask the AI 5 times'},
  {'id': 'code_5', 'emoji': '💻', 'name': 'Code Runner', 'desc': 'Run code 5 times'},
  {'id': 'interview_1', 'emoji': '🎤', 'name': 'On Stage', 'desc': 'Finish your first mock interview'},
  {'id': 'streak_7', 'emoji': '🔥', 'name': 'Week Streak', 'desc': 'Reach a 7-day streak'},
  {'id': 'streak_30', 'emoji': '⚡', 'name': 'Unstoppable', 'desc': 'Reach a 30-day streak'},
  {'id': 'level_5', 'emoji': '🚀', 'name': 'Rising Star', 'desc': 'Reach level 5'},
  {'id': 'level_10', 'emoji': '👑', 'name': 'Legend', 'desc': 'Reach level 10'},
];