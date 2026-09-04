class Recommendation {
  final String problemSlug;
  final String problemTitle;
  final double score;
  final String reason;
  final String difficulty;
  final List<String> topics;

  Recommendation({
    required this.problemSlug,
    required this.problemTitle,
    required this.score,
    required this.reason,
    this.difficulty = 'MEDIUM',
    this.topics = const [],
  });

  factory Recommendation.fromFirestore(Map<String, dynamic> data) {
    return Recommendation(
      problemSlug: data['slug'] ?? '',
      problemTitle: data['title'] ?? '',
      score: (data['score'] ?? 0.0).toDouble(),
      reason: data['reason'] ?? '',
      difficulty: data['difficulty'] ?? 'MEDIUM',
      topics: List<String>.from(data['topics'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'slug': problemSlug,
      'title': problemTitle,
      'score': score,
      'reason': reason,
      'difficulty': difficulty,
      'topics': topics,
    };
  }
}
