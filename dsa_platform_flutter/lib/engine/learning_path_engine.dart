import 'dart:collection';
import 'knowledge_graph.dart';

/// Learning Path Engine — Topological Sort for learning order.
///
/// Given a target topic, finds the correct learning sequence
/// by topologically sorting the prerequisite DAG.
///
/// Uses Kahn's Algorithm:
/// 1. Calculate in-degrees
/// 2. Start with nodes having in-degree 0
/// 3. Process nodes, reducing in-degrees of neighbors
/// 4. Continue until all nodes processed
///
/// DSA Concepts Used:
/// - DAG (Directed Acyclic Graph)
/// - Topological Sort (Kahn's Algorithm)
/// - BFS for prerequisite discovery
class LearningPathEngine {
  /// Get the learning path for a target topic
  /// Returns ordered list of topics from fundamentals to target
  List<String> getLearningPath(KnowledgeGraph graph, String targetTopic) {
    // 1. Find all prerequisites (BFS backward)
    final allNeeded = graph.getAllPrerequisites(targetTopic);
    allNeeded.add(targetTopic);

    // 2. Build subgraph of only needed topics
    final subgraph = <String, Set<String>>{};
    for (final topic in allNeeded) {
      subgraph[topic] = {};
      for (final prereq in graph.getPrerequisites(topic)) {
        if (allNeeded.contains(prereq)) {
          subgraph[topic]!.add(prereq);
        }
      }
    }

    // 3. Topological sort using Kahn's algorithm
    return _topologicalSort(subgraph);
  }

  /// Kahn's Algorithm for topological sorting
  List<String> _topologicalSort(Map<String, Set<String>> graph) {
    // Calculate in-degrees
    final inDegree = <String, int>{};
    for (final node in graph.keys) {
      inDegree.putIfAbsent(node, () => 0);
      for (final neighbor in graph[node]!) {
        inDegree[neighbor] = (inDegree[neighbor] ?? 0) + 1;
      }
    }

    // Start with nodes having in-degree 0
    final queue = ListQueue<String>();
    for (final entry in inDegree.entries) {
      if (entry.value == 0) {
        queue.add(entry.key);
      }
    }

    final result = <String>[];

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(current);

      for (final neighbor in graph[current] ?? {}) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    // If result doesn't contain all nodes, there's a cycle
    if (result.length != graph.length) {
      // Fallback: return BFS order
      final start = graph.keys.first;
      return _bfsFallback(graph, start);
    }

    return result;
  }

  List<String> _bfsFallback(Map<String, Set<String>> graph, String start) {
    final visited = <String>{};
    final queue = [start];
    final result = <String>[];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;
      visited.add(current);
      result.add(current);

      for (final neighbor in graph[current] ?? {}) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    return result;
  }

  /// Get all available learning paths (grouped by category)
  Map<String, List<String>> getAllPaths(KnowledgeGraph graph) {
    final paths = <String, List<String>>{};

    // Define common learning paths
    final pathDefinitions = {
      'Two Pointers': ['Arrays', 'Two Pointers'],
      'Sliding Window': ['Arrays', 'Hashing', 'Two Pointers', 'Sliding Window'],
      'Binary Search': ['Arrays', 'Binary Search'],
      'Trees': ['Binary Trees', 'BST', 'Tree Traversal'],
      'Graphs': ['BFS', 'DFS', 'Graph Algorithms'],
      'Dynamic Programming': ['Arrays', 'Recursion', 'Memoization', 'Dynamic Programming'],
    };

    for (final entry in pathDefinitions.entries) {
      final fullPath = <String>[];
      for (final topic in entry.value) {
        if (graph.topics.contains(topic)) {
          fullPath.add(topic);
        }
      }
      if (fullPath.isNotEmpty) {
        paths[entry.key] = fullPath;
      }
    }

    return paths;
  }
}
