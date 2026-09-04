import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/problem.dart';
import '../services/firestore_service.dart';

class ProblemProvider extends ChangeNotifier {
  final _firestore = FirestoreService();

  List<Problem> _problems = [];
  Problem? _selectedProblem;
  bool _isLoading = false;

  List<Problem> get problems => _problems;
  Problem? get selectedProblem => _selectedProblem;
  bool get isLoading => _isLoading;

  Future<void> loadProblems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore.problemsStream().listen((problems) async {
        if (problems.length < 50) {
          // Seed the database if we only have the dummy problems
          await _seedProblems();
        } else {
          _problems = problems;
          _isLoading = false;
          notifyListeners();
        }
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProblem(String slug) async {
    _selectedProblem = await _firestore.getProblem(slug);
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
      final res = await http.get(Uri.parse('https://alfa-leetcode-api-j1fi.onrender.com/problems?limit=100'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final problemList = data['problemsetQuestionList'] as List?;
        if (problemList == null) return;

        final batch = _firestore.firestore.batch();
        for (final p in problemList) {
          final tags = (p['topicTags'] as List?)?.map((t) => t['name'] as String).toList() ?? [];
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
            problem.toFirestore()
          );
        }
        await batch.commit();
      }
    } catch (e) {
      print('Failed to seed problems from API: $e');
    }
  }
}
