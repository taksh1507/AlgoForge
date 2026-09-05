import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/problem.dart';

/// Direct client for the Alfa LeetCode public API.
/// Used to browse the full LeetCode problem catalog without waiting
/// for Firestore seeding.
class LeetCodeApiService {
  static const String baseUrl = 'https://alfa-leetcode-api-j1fi.onrender.com';

  static const String _problemsEndpoint = '$baseUrl/problems';

  /// Fetches problems directly from the LeetCode API.
  ///
  /// [limit] how many problems to fetch (1-100 per request).
  /// [skip] offset for pagination / infinite scrolling.
  /// [difficulty] optional filter: easy/medium/hard.
  /// [tags] optional tag filter (comma separated slugs, e.g. "array,hash-table").
  static Future<List<Problem>> fetchProblems({
    int limit = 100,
    int skip = 0,
    String? difficulty,
    String? tags,
  }) async {
    final uri = Uri.parse(_problemsEndpoint).replace(queryParameters: {
      'limit': '$limit',
      'skip': '$skip',
      if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty.toLowerCase(),
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    });

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        print('LeetCode API error: ${res.statusCode} for $uri');
        return [];
      }
      final data = json.decode(res.body);
      final list = data['problemsetQuestionList'] as List?;
      if (list == null) return [];

      return list.map((p) {
        final tagsList = (p['topicTags'] as List?)
                ?.map((t) => t['name'] as String)
                .toList() ??
            [];
        return Problem(
          titleSlug: p['titleSlug'] ?? '',
          title: p['title'] ?? '',
          questionId: int.tryParse(p['questionFrontendId'] ?? '0') ?? 0,
          difficulty: (p['difficulty'] as String?)?.toUpperCase() ?? 'MEDIUM',
          topics: tagsList,
          isPaidOnly: p['isPaidOnly'] ?? false,
          acceptanceRate: (p['acRate'] as num?)?.toDouble() ?? 0.0,
          url: 'https://leetcode.com/problems/${p['titleSlug'] ?? ''}',
        );
      }).toList();
    } catch (e) {
      print('Failed to fetch problems from API: $e');
      return [];
    }
  }
}
