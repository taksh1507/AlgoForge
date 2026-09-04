import '../models/skill_profile.dart';

/// Skill Engine — Weighted scoring per topic.
///
/// Considers multiple factors:
/// - Success rate (solved / attempted)
/// - Time taken vs expected time
/// - Number of attempts
/// - Hints used
/// - Confidence level
/// - Recent performance trend (sliding window)
///
/// DSA Concepts Used:
/// - HashMap for topic index
/// - Weighted scoring algorithm
/// - Sliding window for recent performance
class SkillEngine {
  // Weights for different factors
  static const double _successRateWeight = 0.30;
  static const double _timeWeight = 0.20;
  static const double _attemptsWeight = 0.15;
  static const double _hintsWeight = 0.10;
  static const double _confidenceWeight = 0.15;
  static const double _trendWeight = 0.10;

  /// Calculate skill score for a single topic based on attempts
  TopicScore calculateTopicScore(String topic, List<Map<String, dynamic>> attempts) {
    if (attempts.isEmpty) {
      return TopicScore(topic: topic, score: 0.0);
    }

    final solved = attempts.where((a) => a['status'] == 'SOLVED' || a['status'] == 'MASTERED').length;
    final total = attempts.length;
    final successRate = solved / total;

    // Time score: compare against expected time per difficulty
    double avgTime = 0;
    double timeScore = 1.0;
    if (attempts.isNotEmpty) {
      avgTime = attempts.map((a) => (a['timeTakenMin'] ?? 0).toDouble()).reduce((a, b) => a + b) / total;
      // Expected times: Easy=15, Medium=30, Hard=60
      final expectedTime = 30.0; // average
      timeScore = (1 - (avgTime / (expectedTime * 2))).clamp(0.0, 1.0);
    }

    // Attempts score: fewer attempts = higher score
    final avgAttempts = attempts.map((a) => (a['attempts'] ?? 1).toDouble()).reduce((a, b) => a + b) / total;
    final attemptsScore = (1 - ((avgAttempts - 1) / 4)).clamp(0.0, 1.0);

    // Hints score: fewer hints = higher score
    final avgHints = attempts.map((a) => (a['hintsUsed'] ?? 0).toDouble()).reduce((a, b) => a + b) / total;
    final hintsScore = (1 - (avgHints / 3)).clamp(0.0, 1.0);

    // Confidence score
    final avgConfidence = attempts.map((a) => (a['confidence'] ?? 3).toDouble()).reduce((a, b) => a + b) / total;
    final confidenceScore = avgConfidence / 5;

    // Trend: compare first half vs second half
    double trend = 0;
    if (attempts.length >= 4) {
      final mid = attempts.length ~/ 2;
      final firstHalf = attempts.sublist(0, mid);
      final secondHalf = attempts.sublist(mid);
      final firstSolved = firstHalf.where((a) => a['status'] == 'SOLVED').length / firstHalf.length;
      final secondSolved = secondHalf.where((a) => a['status'] == 'SOLVED').length / secondHalf.length;
      trend = secondSolved - firstSolved;
    }

    // Weighted score (0-100)
    final rawScore = (successRate * _successRateWeight +
            timeScore * _timeWeight +
            attemptsScore * _attemptsWeight +
            hintsScore * _hintsWeight +
            confidenceScore * _confidenceWeight +
            (0.5 + trend) * _trendWeight) *
        100;

    return TopicScore(
      topic: topic,
      score: rawScore.clamp(0.0, 100.0),
      problemsAttempted: total,
      problemsSolved: solved,
      avgTimeMin: avgTime,
      avgConfidence: avgConfidence,
      recentTrend: trend,
    );
  }

  /// Calculate full skill profile from all attempts
  SkillProfile calculateProfile(String uid, List<Map<String, dynamic>> allAttempts) {
    // Group attempts by topic
    final topicAttempts = <String, List<Map<String, dynamic>>>{};
    for (final attempt in allAttempts) {
      final topics = List<String>.from(attempt['topics'] ?? []);
      for (final topic in topics) {
        topicAttempts.putIfAbsent(topic, () => []).add(attempt);
      }
    }

    // Calculate score for each topic
    final topics = <String, TopicScore>{};
    double totalScore = 0;
    for (final entry in topicAttempts.entries) {
      final score = calculateTopicScore(entry.key, entry.value);
      topics[entry.key] = score;
      totalScore += score.score;
    }

    final overallScore = topics.isNotEmpty ? totalScore / topics.length : 0.0;

    // Find weak and strong topics
    final sortedEntries = topics.entries.toList()
      ..sort((a, b) => a.value.score.compareTo(b.value.score));

    final weakTopics = sortedEntries
        .where((e) => e.value.score < 50)
        .map((e) => e.key)
        .toList();

    final strongTopics = sortedEntries
        .where((e) => e.value.score >= 75)
        .map((e) => e.key)
        .toList()
        .reversed
        .toList();

    return SkillProfile(
      topics: topics,
      overallScore: overallScore,
      weakTopics: weakTopics,
      strongTopics: strongTopics,
    );
  }
}
