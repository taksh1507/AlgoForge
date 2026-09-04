/// Knowledge Graph — DAG representation of topics and their prerequisites.
///
/// Data Structure: Adjacency List
/// - Each topic is a node
/// - Edges represent prerequisite relationships (A -> B means A is prerequisite for B)
/// - Forms a DAG (Directed Acyclic Graph)
///
/// DSA Concepts Used:
/// - Graph (Adjacency List)
/// - DAG (Directed Acyclic Graph)
/// - BFS / DFS for traversal
class KnowledgeGraph {
  final Map<String, Set<String>> _adjacencyList = {};
  final Map<String, Map<String, dynamic>> _topicData = {};

  KnowledgeGraph();

  /// Build graph from Firestore data
  factory KnowledgeGraph.fromFirestore(List<Map<String, dynamic>> graphData) {
    final graph = KnowledgeGraph();
    for (final node in graphData) {
      final topic = node['topic'] as String? ?? '';
      final prerequisites = List<String>.from(node['prerequisites'] ?? []);
      final relatedTopics = List<String>.from(node['relatedTopics'] ?? []);
      final problems = List<String>.from(node['problems'] ?? []);

      graph._topicData[topic] = {
        'prerequisites': prerequisites,
        'relatedTopics': relatedTopics,
        'problems': problems,
        'difficulty': node['difficulty'] ?? 'MEDIUM',
        'description': node['description'] ?? '',
      };

      graph._adjacencyList[topic] = {};
      for (final prereq in prerequisites) {
        graph._adjacencyList[topic]!.add(prereq);
      }
    }
    return graph;
  }

  Set<String> get topics => _adjacencyList.keys.toSet();

  Map<String, dynamic>? getTopicData(String topic) => _topicData[topic];

  List<String> getPrerequisites(String topic) {
    return _topicData[topic]?['prerequisites'] ?? [];
  }

  List<String> getRelatedTopics(String topic) {
    return _topicData[topic]?['relatedTopics'] ?? [];
  }

  List<String> getProblems(String topic) {
    return _topicData[topic]?['problems'] ?? [];
  }

  /// BFS — find all reachable topics from a starting point
  List<String> bfs(String start) {
    final visited = <String>{};
    final queue = [start];
    final result = <String>[];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      if (visited.contains(current)) continue;
      visited.add(current);
      result.add(current);

      for (final neighbor in _adjacencyList[current] ?? {}) {
        if (!visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
    return result;
  }

  /// DFS — recursive traversal for full topic coverage
  List<String> dfs(String start) {
    final visited = <String>{};
    final result = <String>[];
    _dfsHelper(start, visited, result);
    return result;
  }

  void _dfsHelper(String current, Set<String> visited, List<String> result) {
    if (visited.contains(current)) return;
    visited.add(current);
    result.add(current);

    for (final neighbor in _adjacencyList[current] ?? {}) {
      _dfsHelper(neighbor, visited, result);
    }
  }

  /// Find all prerequisites for a topic (transitive closure)
  List<String> getAllPrerequisites(String topic) {
    final allPrereqs = <String>{};
    _collectPrereqs(topic, allPrereqs);
    return allPrereqs.toList();
  }

  void _collectPrereqs(String topic, Set<String> collected) {
    final directPrereqs = _adjacencyList[topic] ?? {};
    for (final prereq in directPrereqs) {
      if (!collected.contains(prereq)) {
        collected.add(prereq);
        _collectPrereqs(prereq, collected);
      }
    }
  }
}
