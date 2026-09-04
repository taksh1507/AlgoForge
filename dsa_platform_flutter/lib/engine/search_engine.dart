import '../models/problem.dart';

/// Search Engine — Trie + Inverted Index.
///
/// Trie: Prefix-based search for problem titles
/// - "binary sea..." → ["Binary Search", "Binary Search Tree", ...]
///
/// Inverted Index: Company/tag/difficulty filtering
/// - Google → [#1, #15, #121, ...]
///
/// DSA Concepts Used:
/// - Trie for prefix matching
/// - Inverted Index for filtering
class SearchEngine {
  final TrieNode _trieRoot = TrieNode();
  final Map<String, Set<String>> _companyIndex = {};
  final Map<String, Set<String>> _topicIndex = {};
  final Map<String, Set<String>> _difficultyIndex = {};
  final Map<String, Problem> _problemMap = {};

  /// Build search index from problems
  void buildIndex(List<Problem> problems) {
    for (final problem in problems) {
      // Insert into Trie
      _insertTrie(problem.title.toLowerCase(), problem.titleSlug);

      // Insert into inverted indexes
      _problemMap[problem.titleSlug] = problem;

      for (final company in problem.companies) {
        _companyIndex.putIfAbsent(company, () => {}).add(problem.titleSlug);
      }
      for (final topic in problem.topics) {
        _topicIndex.putIfAbsent(topic, () => {}).add(problem.titleSlug);
      }
      _difficultyIndex
          .putIfAbsent(problem.difficulty, () => {})
          .add(problem.titleSlug);
    }
  }

  /// Trie insertion
  void _insertTrie(String word, String slug) {
    var node = _trieRoot;
    for (final char in word.split('')) {
      node.children.putIfAbsent(char, () => TrieNode());
      node = node.children[char]!;
      node.slugs.add(slug);
    }
    node.isEnd = true;
  }

  /// Prefix search using Trie
  List<String> searchByPrefix(String prefix) {
    var node = _trieRoot;
    for (final char in prefix.toLowerCase().split('')) {
      if (!node.children.containsKey(char)) return [];
      node = node.children[char]!;
    }
    return node.slugs.toList();
  }

  /// Filter by company
  List<String> filterByCompany(String company) {
    return _companyIndex[company]?.toList() ?? [];
  }

  /// Filter by topic
  List<String> filterByTopic(String topic) {
    return _topicIndex[topic]?.toList() ?? [];
  }

  /// Filter by difficulty
  List<String> filterByDifficulty(String difficulty) {
    return _difficultyIndex[difficulty.toUpperCase()]?.toList() ?? [];
  }

  /// Combined search: prefix + filters
  List<Problem> search({
    String? query,
    String? company,
    String? topic,
    String? difficulty,
    int limit = 20,
  }) {
    Set<String>? results;

    // Prefix search
    if (query != null && query.isNotEmpty) {
      results = searchByPrefix(query).toSet();
    }

    // Company filter
    if (company != null && company.isNotEmpty) {
      final companyResults = filterByCompany(company).toSet();
      results = results == null ? companyResults : results.intersection(companyResults);
    }

    // Topic filter
    if (topic != null && topic.isNotEmpty) {
      final topicResults = filterByTopic(topic).toSet();
      results = results == null ? topicResults : results.intersection(topicResults);
    }

    // Difficulty filter
    if (difficulty != null && difficulty.isNotEmpty) {
      final diffResults = filterByDifficulty(difficulty).toSet();
      results = results == null ? diffResults : results.intersection(diffResults);
    }

    // If no filters applied, return empty
    if (results == null) return [];

    return results
        .take(limit)
        .map((slug) => _problemMap[slug])
        .whereType<Problem>()
        .toList();
  }
}

/// Trie Node
class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEnd = false;
  final Set<String> slugs = {};
}
