class KnowledgeGraphModel {
  final String topic;
  final List<String> prerequisites;
  final List<String> relatedTopics;
  final List<String> problems;
  final String difficulty;
  final String description;

  KnowledgeGraphModel({
    required this.topic,
    this.prerequisites = const [],
    this.relatedTopics = const [],
    this.problems = const [],
    this.difficulty = 'MEDIUM',
    this.description = '',
  });

  factory KnowledgeGraphModel.fromFirestore(Map<String, dynamic> data) {
    return KnowledgeGraphModel(
      topic: data['topic'] ?? '',
      prerequisites: List<String>.from(data['prerequisites'] ?? []),
      relatedTopics: List<String>.from(data['relatedTopics'] ?? []),
      problems: List<String>.from(data['problems'] ?? []),
      difficulty: data['difficulty'] ?? 'MEDIUM',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'topic': topic,
      'prerequisites': prerequisites,
      'relatedTopics': relatedTopics,
      'problems': problems,
      'difficulty': difficulty,
      'description': description,
    };
  }
}
