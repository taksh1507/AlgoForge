/// Performance Analyzer — Sliding Window for recent stats.
///
/// Uses a sliding window of the last N attempts to calculate
/// recent performance metrics without processing all history.
///
/// DSA Concepts Used:
/// - Sliding Window for efficient recent stats
class PerformanceAnalyzer {
  /// Calculate recent performance using sliding window
  Map<String, dynamic> analyzeRecent({
    required List<Map<String, dynamic>> attempts,
    int windowSize = 20,
  }) {
    if (attempts.isEmpty) {
      return {
        'totalAttempts': 0,
        'successRate': 0.0,
        'avgTime': 0.0,
        'avgConfidence': 0.0,
        'improving': false,
        'weakTopics': <String>[],
        'strongTopics': <String>[],
      };
    }

    // Sliding window: last N attempts
    final window = attempts.take(windowSize).toList();
    final solved = window.where((a) => a['status'] == 'SOLVED' || a['status'] == 'MASTERED').length;
    final successRate = solved / window.length;

    // Average time
    final avgTime = window.map((a) => (a['timeTakenMin'] ?? 0).toDouble()).reduce((a, b) => a + b) / window.length;

    // Average confidence
    final avgConfidence = window.map((a) => (a['confidence'] ?? 3).toDouble()).reduce((a, b) => a + b) / window.length;

    // Trend: compare first half vs second half of window
    bool improving = false;
    if (window.length >= 4) {
      final mid = window.length ~/ 2;
      final firstHalf = window.sublist(mid); // older
      final secondHalf = window.sublist(0, mid); // newer
      final firstRate = firstHalf.where((a) => a['status'] == 'SOLVED').length / firstHalf.length;
      final secondRate = secondHalf.where((a) => a['status'] == 'SOLVED').length / secondHalf.length;
      improving = secondRate > firstRate;
    }

    // Topic breakdown
    final topicStats = <String, Map<String, int>>{};
    for (final attempt in window) {
      final topics = List<String>.from(attempt['topics'] ?? []);
      for (final topic in topics) {
        topicStats.putIfAbsent(topic, () => {'solved': 0, 'total': 0});
        topicStats[topic]!['total'] = topicStats[topic]!['total']! + 1;
        if (attempt['status'] == 'SOLVED' || attempt['status'] == 'MASTERED') {
          topicStats[topic]!['solved'] = topicStats[topic]!['solved']! + 1;
        }
      }
    }

    final weakTopics = <String>[];
    final strongTopics = <String>[];
    topicStats.forEach((topic, stats) {
      final rate = stats['solved']! / stats['total']!;
      if (rate < 0.5) weakTopics.add(topic);
      if (rate >= 0.8) strongTopics.add(topic);
    });

    return {
      'totalAttempts': window.length,
      'successRate': successRate,
      'avgTime': avgTime,
      'avgConfidence': avgConfidence,
      'improving': improving,
      'weakTopics': weakTopics,
      'strongTopics': strongTopics,
    };
  }

  /// Calculate streak (consecutive days with submissions)
  int calculateStreak(List<Map<String, dynamic>> calendarData) {
    if (calendarData.isEmpty) return 0;

    final dates = calendarData
        .map((d) => DateTime.parse(d['date'] ?? DateTime.now().toIso8601String()))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // newest first

    int streak = 0;
    DateTime expected = DateTime.now();

    for (final date in dates) {
      final diff = expected.difference(date).inDays;
      if (diff <= 1) {
        streak++;
        expected = date;
      } else {
        break;
      }
    }

    return streak;
  }
}
