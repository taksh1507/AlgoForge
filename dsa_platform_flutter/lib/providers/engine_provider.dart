import 'package:flutter/foundation.dart';
import '../engine/knowledge_graph.dart';
import '../engine/skill_engine.dart';
import '../engine/learning_path_engine.dart';
import '../engine/similar_problems_engine.dart';
import '../engine/search_engine.dart';
import '../engine/performance_analyzer.dart';
import '../engine/recommendation_engine.dart';
import '../engine/revision_engine.dart';
import '../services/firestore_service.dart';

class EngineProvider extends ChangeNotifier {
  final _firestore = FirestoreService();

  final skillEngine = SkillEngine();
  final learningPathEngine = LearningPathEngine();
  final similarProblemsEngine = SimilarProblemsEngine();
  final searchEngine = SearchEngine();
  final performanceAnalyzer = PerformanceAnalyzer();
  final recommendationEngine = RecommendationEngine();
  final revisionEngine = RevisionEngine();

  KnowledgeGraph? _knowledgeGraph;
  bool _isGraphLoaded = false;

  KnowledgeGraph? get knowledgeGraph => _knowledgeGraph;
  bool get isGraphLoaded => _isGraphLoaded;

  /// Load knowledge graph from Firestore
  Future<void> loadKnowledgeGraph() async {
    try {
      final data = await _firestore.graphStream().first;
      _knowledgeGraph = KnowledgeGraph.fromFirestore(data);
      _isGraphLoaded = true;
      notifyListeners();
    } catch (e) {
      print('Error loading knowledge graph: $e');
    }
  }

  /// Get learning path for a topic
  List<String> getLearningPath(String topic) {
    if (_knowledgeGraph == null) return [topic];
    return learningPathEngine.getLearningPath(_knowledgeGraph!, topic);
  }

  /// Find similar problems (BFS)
  List<String> findSimilarProblems(String slug, List<String> topics) {
    if (_knowledgeGraph == null) return [];
    return similarProblemsEngine.findSimilarBFS(_knowledgeGraph!, slug, topics);
  }

  /// Analyze recent performance
  Map<String, dynamic> analyzePerformance(List<Map<String, dynamic>> attempts) {
    return performanceAnalyzer.analyzeRecent(attempts: attempts);
  }
}
