class SkillProfile {
  final Map<String, TopicScore> topics;
  final double overallScore;
  final List<String> weakTopics;
  final List<String> strongTopics;

  SkillProfile({
    this.topics = const {},
    this.overallScore = 0.0,
    this.weakTopics = const [],
    this.strongTopics = const [],
  });

  factory SkillProfile.fromFirestore(Map<String, dynamic> data) {
    final topicsMap = <String, TopicScore>{};
    if (data['topics'] != null) {
      (data['topics'] as Map<String, dynamic>).forEach((key, value) {
        topicsMap[key] = TopicScore.fromFirestore(value);
      });
    }
    return SkillProfile(
      topics: topicsMap,
      overallScore: (data['overallScore'] ?? 0.0).toDouble(),
      weakTopics: List<String>.from(data['weakTopics'] ?? []),
      strongTopics: List<String>.from(data['strongTopics'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    final topicsMap = <String, dynamic>{};
    topics.forEach((key, value) {
      topicsMap[key] = value.toFirestore();
    });
    return {
      'topics': topicsMap,
      'overallScore': overallScore,
      'weakTopics': weakTopics,
      'strongTopics': strongTopics,
    };
  }

  TopicScore? getTopic(String topic) => topics[topic];

  List<MapEntry<String, TopicScore>> get sortedTopics {
    final entries = topics.entries.toList();
    entries.sort((a, b) => a.value.score.compareTo(b.value.score));
    return entries;
  }
}

class TopicScore {
  final String topic;
  final double score;
  final int problemsAttempted;
  final int problemsSolved;
  final double avgTimeMin;
  final double avgConfidence;
  final double recentTrend;

  TopicScore({
    required this.topic,
    this.score = 0.0,
    this.problemsAttempted = 0,
    this.problemsSolved = 0,
    this.avgTimeMin = 0.0,
    this.avgConfidence = 0.0,
    this.recentTrend = 0.0,
  });

  factory TopicScore.fromFirestore(Map<String, dynamic> data) {
    return TopicScore(
      topic: data['topic'] ?? '',
      score: (data['score'] ?? 0.0).toDouble(),
      problemsAttempted: data['problemsAttempted'] ?? 0,
      problemsSolved: data['problemsSolved'] ?? 0,
      avgTimeMin: (data['avgTimeMin'] ?? 0.0).toDouble(),
      avgConfidence: (data['avgConfidence'] ?? 0.0).toDouble(),
      recentTrend: (data['recentTrend'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topic': topic,
      'score': score,
      'problemsAttempted': problemsAttempted,
      'problemsSolved': problemsSolved,
      'avgTimeMin': avgTimeMin,
      'avgConfidence': avgConfidence,
      'recentTrend': recentTrend,
    };
  }

  String get level {
    if (score >= 80) return 'Strong';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Learning';
    return 'Needs work';
  }
}
