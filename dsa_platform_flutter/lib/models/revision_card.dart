class RevisionCard {
  final String problemSlug;
  final String problemTitle;
  final DateTime nextReview;
  final int intervalDays;
  final double easeFactor;
  final int repetitions;
  final String lastResult;

  RevisionCard({
    required this.problemSlug,
    required this.problemTitle,
    required this.nextReview,
    this.intervalDays = 1,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.lastResult = '',
  });

  factory RevisionCard.fromFirestore(Map<String, dynamic> data) {
    return RevisionCard(
      problemSlug: data['problemSlug'] ?? '',
      problemTitle: data['problemTitle'] ?? '',
      nextReview: data['nextReview']?.toDate() ?? DateTime.now(),
      intervalDays: data['intervalDays'] ?? 1,
      easeFactor: (data['easeFactor'] ?? 2.5).toDouble(),
      repetitions: data['repetitions'] ?? 0,
      lastResult: data['lastResult'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'problemSlug': problemSlug,
      'problemTitle': problemTitle,
      'nextReview': nextReview,
      'intervalDays': intervalDays,
      'easeFactor': easeFactor,
      'repetitions': repetitions,
      'lastResult': lastResult,
    };
  }

  bool get isDue => nextReview.isBefore(DateTime.now());

  int get daysOverdue {
    if (!isDue) return 0;
    return DateTime.now().difference(nextReview).inDays;
  }

  RevisionCard copyWith({
    DateTime? nextReview,
    int? intervalDays,
    double? easeFactor,
    int? repetitions,
    String? lastResult,
  }) {
    return RevisionCard(
      problemSlug: problemSlug,
      problemTitle: problemTitle,
      nextReview: nextReview ?? this.nextReview,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      repetitions: repetitions ?? this.repetitions,
      lastResult: lastResult ?? this.lastResult,
    );
  }
}
