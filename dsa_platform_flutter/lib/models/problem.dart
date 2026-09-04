class Problem {
  final String titleSlug;
  final String title;
  final int questionId;
  final String difficulty;
  final List<String> topics;
  final List<String> companies;
  final String url;
  final bool isPaidOnly;
  final double acceptanceRate;

  Problem({
    required this.titleSlug,
    required this.title,
    required this.questionId,
    required this.difficulty,
    this.topics = const [],
    this.companies = const [],
    this.url = '',
    this.isPaidOnly = false,
    this.acceptanceRate = 0.0,
  });

  factory Problem.fromFirestore(Map<String, dynamic> data) {
    return Problem(
      titleSlug: data['titleSlug'] ?? '',
      title: data['title'] ?? '',
      questionId: data['questionId'] ?? 0,
      difficulty: data['difficulty'] ?? 'MEDIUM',
      topics: List<String>.from(data['topics'] ?? []),
      companies: List<String>.from(data['companies'] ?? []),
      url: data['url'] ?? '',
      isPaidOnly: data['isPaidOnly'] ?? false,
      acceptanceRate: (data['acceptanceRate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titleSlug': titleSlug,
      'title': title,
      'questionId': questionId,
      'difficulty': difficulty,
      'topics': topics,
      'companies': companies,
      'url': url,
      'isPaidOnly': isPaidOnly,
      'acceptanceRate': acceptanceRate,
    };
  }

  String get difficultyEmoji {
    switch (difficulty) {
      case 'EASY':
        return '🟢';
      case 'MEDIUM':
        return '🟡';
      case 'HARD':
        return '🔴';
      default:
        return '⚪';
    }
  }
}
