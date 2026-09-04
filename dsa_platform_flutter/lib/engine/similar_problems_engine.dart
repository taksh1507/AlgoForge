import 'dart:collection';
import 'knowledge_graph.dart';
import '../models/problem.dart';

/// Similar Problems Engine — BFS/DFS on knowledge graph.
///
/// After solving a problem, finds related problems by:
/// 1. BFS to find problems in same topic (1 hop)
/// 2. DFS to find problems in related topics (2 hops)
///
/// DSA Concepts Used:
/// - BFS for immediate neighbors
/// - DFS for deeper traversal
/// - Graph traversal on knowledge graph
class SimilarProblemsEngine {
  /// Find similar problems using BFS (same topic, 1 hop)
  List<String> findSimilarBFS(
    KnowledgeGraph graph,
    String problemSlug,
    List<String> problemTopics, {
    int limit = 5,
  }) {
    final visited = <String>{};
    final queue = ListQueue<String>();
    final result = <String>[];

    // Start from problem's topics
    for (final topic in problemTopics) {
      queue.add(topic);
    }

    while (queue.isNotEmpty && result.length < limit) {
      final current = queue.removeFirst();
      if (visited.contains(current)) continue;
      visited.add(current);

      // Get problems in this topic
      final topicProblems = graph.getProblems(current);
      for (final slug in topicProblems) {
        if (slug != problemSlug && !result.contains(slug) && result.length < limit) {
          result.add(slug);
        }
      }

      // Add related topics to queue (1 hop)
      for (final related in graph.getRelatedTopics(current)) {
        if (!visited.contains(related)) {
          queue.add(related);
        }
      }
    }

    return result;
  }

  /// Find similar problems using DFS (related topics, 2 hops)
  List<String> findSimilarDFS(
    KnowledgeGraph graph,
    String problemSlug,
    List<String> problemTopics, {
    int limit = 10,
  }) {
    final visited = <String>{};
    final result = <String>[];

    for (final topic in problemTopics) {
      _dfsTraversal(graph, topic, problemSlug, visited, result, limit, 0, 2);
    }

    return result;
  }

  void _dfsTraversal(
    KnowledgeGraph graph,
    String current,
    String excludeSlug,
    Set<String> visited,
    List<String> result,
    int limit,
    int depth,
    int maxDepth,
  ) {
    if (depth > maxDepth || result.length >= limit || visited.contains(current)) return;
    visited.add(current);

    // Add problems from this topic
    final topicProblems = graph.getProblems(current);
    for (final slug in topicProblems) {
      if (slug != excludeSlug && !result.contains(slug) && result.length < limit) {
        result.add(slug);
      }
    }

    // Recurse into related topics
    for (final related in graph.getRelatedTopics(current)) {
      _dfsTraversal(graph, related, excludeSlug, visited, result, limit, depth + 1, maxDepth);
    }
  }

  /// Get problems by difficulty using Binary Search
  List<Problem> getProblemsByDifficulty(
    List<Problem> sortedProblems,
    String targetDifficulty,
  ) {
    // Binary search for the first problem of target difficulty
    int low = 0;
    int high = sortedProblems.length - 1;
    int result = -1;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (sortedProblems[mid].difficulty == targetDifficulty) {
        result = mid;
        high = mid - 1; // Keep searching left for first occurrence
      } else if (sortedProblems[mid].difficulty.compareTo(targetDifficulty) < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    if (result == -1) return [];

    // Collect all problems of this difficulty
    final found = <Problem>[];
    for (int i = result; i < sortedProblems.length; i++) {
      if (sortedProblems[i].difficulty == targetDifficulty) {
        found.add(sortedProblems[i]);
      } else {
        break;
      }
    }

    return found;
  }
}
