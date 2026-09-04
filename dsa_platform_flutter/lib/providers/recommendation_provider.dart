import 'package:flutter/foundation.dart';
import '../models/recommendation.dart';
import '../engine/recommendation_engine.dart';
import '../engine/knowledge_graph.dart';
import '../services/firestore_service.dart';
import 'user_provider.dart';
import 'problem_provider.dart';

class RecommendationProvider extends ChangeNotifier {
  final _engine = RecommendationEngine();
  final _firestore = FirestoreService();

  List<Recommendation> _recommendations = [];
  bool _isLoading = false;

  List<Recommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations({
    required UserProvider userProvider,
    required ProblemProvider problemProvider,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uid = userProvider.profile?.uid ?? '';
      final skillProfile = userProvider.skillProfile;
      final problems = problemProvider.problems;

      // Get solved slugs from attempts
      final attempts = await _firestore.getAttempts(uid);
      final solvedSlugs = attempts
          .where((a) => a['status'] == 'SOLVED' || a['status'] == 'MASTERED')
          .map((a) => a['problemSlug'] as String)
          .toSet()
          .toList();

      // Load knowledge graph
      final graphData = await _firestore.graphStream().first;
      final graph = KnowledgeGraph.fromFirestore(graphData);

      // Get unsolved problems
      final unsolved = problems.where((p) => !solvedSlugs.contains(p.titleSlug)).toList();

      if (skillProfile != null) {
        final results = _engine.getTopRecommendations(
          unsolvedProblems: unsolved,
          skillProfile: skillProfile,
          graph: graph,
          solvedSlugs: solvedSlugs,
          recentAttempts: attempts,
          topN: 3,
        );

        _recommendations = results.map((r) {
          final problem = r['problem'];
          return Recommendation(
            problemSlug: problem.titleSlug,
            problemTitle: problem.title,
            score: r['score'],
            reason: r['reason'],
            difficulty: problem.difficulty,
            topics: problem.topics,
          );
        }).toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
