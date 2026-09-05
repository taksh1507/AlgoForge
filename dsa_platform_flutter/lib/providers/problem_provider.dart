import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/problem.dart';
import '../services/firestore_service.dart';
import '../services/leetcode_api_service.dart';

class ProblemProvider extends ChangeNotifier {
  final _firestore = FirestoreService();

  List<Problem> _problems = [];
  Problem? _selectedProblem;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _loaded = false;
  int _offset = 0;
  static const int _pageSize = 100;

  List<Problem> get problems => _problems;
  Problem? get selectedProblem => _selectedProblem;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> loadProblems() async {
    if (_loaded) return;
    _loaded = true;
    _isLoading = true;
    notifyListeners();

    // 1) Instant offline cache first — renders immediately even when the
    //    network/Firestore are unreachable. Stored in questionId order.
    final cached = _loadFromCache();
    if (cached.isNotEmpty) {
      _problems = cached;
      _offset = cached.length;
      _isLoading = false;
      notifyListeners();
    }

    // 2) API refresh — single source of truth; replaces the cache silently
    //    (both are id-ordered so no visible reshuffle).
    try {
      final fetched = await LeetCodeApiService.fetchProblems(
        limit: _pageSize,
        skip: 0,
      );
      if (fetched.isNotEmpty) {
        _problems = fetched;
        _offset = fetched.length;
        _hasMore = fetched.length >= _pageSize;
        _isLoading = false;
        notifyListeners();
        _cacheProblems(fetched);
        _seedProblems();
        return;
      }
    } catch (e) {
      debugPrint('API unavailable, using cache: $e');
    }

    // 3) API unavailable → fall back to cached problems (id-ordered).
    try {
      final firestoreCached = await _firestore.problemsStream().first;
      if (firestoreCached.isNotEmpty) {
        _problems = firestoreCached;
        _offset = firestoreCached.length;
      }
    } catch (e) {
      debugPrint('Firestore problems load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  static const _cacheKey = 'problems_v1';

  void _cacheProblems(List<Problem> problems) {
    try {
      final box = Hive.box('problem_cache');
      box.put(
        _cacheKey,
        problems.map((p) => p.toFirestore()).toList(),
      );
    } catch (e) {
      debugPrint('Problem cache write error: $e');
    }
  }

  List<Problem> _loadFromCache() {
    try {
      final box = Hive.box('problem_cache');
      final raw = box.get(_cacheKey);
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((m) => Problem.fromFirestore((m as Map).cast<String, dynamic>()))
            .toList();
      }
    } catch (e) {
      debugPrint('Problem cache read error: $e');
    }
    return [];
  }

  Future<void> _fetchFromApi() async {
    _isLoading = true;
    notifyListeners();
    final fetched = await LeetCodeApiService.fetchProblems(
      limit: _pageSize,
      skip: _offset,
    );
    _problems = fetched;
    _isLoading = false;
    _hasMore = fetched.length >= _pageSize;
    _offset = fetched.length;
    notifyListeners();
  }

  /// Load the next page of problems from the API (infinite scroll).
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    _isLoading = true;
    notifyListeners();
    final fetched = await LeetCodeApiService.fetchProblems(
      limit: _pageSize,
      skip: _offset,
    );
    _problems = [..._problems, ...fetched];
    _isLoading = false;
    _hasMore = fetched.length >= _pageSize;
    _offset += fetched.length;
    notifyListeners();
  }

  /// Refresh problems directly from the API (pull-to-refresh).
  Future<void> refresh() async {
    _offset = 0;
    await _fetchFromApi();
    // Refresh Firestore cache in the background.
    await _seedProblems();
  }

  Future<void> selectProblem(String slug) async {
    final local = _problems.where((p) => p.titleSlug == slug).firstOrNull;
    if (local != null) {
      _selectedProblem = local;
    } else {
      _selectedProblem = await _firestore.getProblem(slug);
    }
    notifyListeners();
  }

  List<Problem> getByDifficulty(String difficulty) {
    return _problems.where((p) => p.difficulty == difficulty).toList();
  }

  List<Problem> getByTopic(String topic) {
    return _problems.where((p) => p.topics.contains(topic)).toList();
  }

  Future<void> _seedProblems() async {
    try {
      final res = await http.get(
          Uri.parse('https://alfa-leetcode-api-j1fi.onrender.com/problems?limit=100'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final problemList = data['problemsetQuestionList'] as List?;
        if (problemList == null) return;

        final batch = _firestore.firestore.batch();
        for (final p in problemList) {
          final tags =
              (p['topicTags'] as List?)?.map((t) => t['name'] as String).toList() ??
                  [];
          final problem = Problem(
            titleSlug: p['titleSlug'] ?? '',
            title: p['title'] ?? '',
            questionId: int.tryParse(p['frontendQuestionId'] ?? '0') ?? 0,
            difficulty: (p['difficulty'] as String?)?.toUpperCase() ?? 'MEDIUM',
            topics: tags,
            acceptanceRate: (p['acRate'] as num?)?.toDouble() ?? 0.0,
          );

          batch.set(
            _firestore.firestore.collection('problems').doc(problem.titleSlug),
            problem.toFirestore(),
          );
        }
        await batch.commit();
      }
    } catch (e) {
      print('Failed to seed problems from API: $e');
    }
  }
}
