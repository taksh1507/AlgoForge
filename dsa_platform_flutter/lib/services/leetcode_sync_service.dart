import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// Fetches LeetCode data directly from the Alfa LeetCode API
/// and writes it to Firestore — no Cloud Function needed.
class LeetcodeSyncService {
  final _firebase = FirebaseService();
  final _auth = AuthService();

  static const String _baseUrl = 'https://alfa-leetcode-api-j1fi.onrender.com';

  Future<void> syncUser(String username) async {
    final uid = await _auth.getUid();

    // Fetch all data in parallel for maximum speed
    print('Fetching data in parallel from $_baseUrl for $username');
    final results = await Future.wait([
      _safeGet('$_baseUrl/$username'),
      _safeGet('$_baseUrl/$username/solved'),
      _safeGet('$_baseUrl/$username/skill'),
      _safeGet('$_baseUrl/$username/acSubmission?limit=50'),
      _safeGet('$_baseUrl/$username/calendar'),
    ]);
    
    final profile = results[0];
    final solved = results[1];
    final skill = results[2];
    final submissions = results[3];
    final calendar = results[4];
    
    print('Fetch complete for $username');



    print('Profile: $profile');
    print('Solved: $solved');
    print('Skill: $skill');

    final db = _firebase.firestore;

    // ── Write user profile ────────────────────────────────────────
    await db.collection('users').doc(uid).set({
      'username': username,
      'displayName': profile?['name'] ?? username,
      'rating': profile?['ranking'] ?? 0,
      'totalSolved': solved?['solvedProblem'] ?? 0,
      'easySolved': solved?['easySolved'] ?? 0,
      'mediumSolved': solved?['mediumSolved'] ?? 0,
      'hardSolved': solved?['hardSolved'] ?? 0,
      'streak': _extractStreak(calendar),
      'syncedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // ── Write skill scores ────────────────────────────────────────
    // The Alfa API returns the skill breakdown directly at the root of the object
    final tagCounts = skill;
                   
    if (tagCounts != null && (tagCounts.containsKey('fundamental') || tagCounts.containsKey('advanced'))) {
      final skillBatch = db.batch();
      final skillsRef = db.collection('users').doc(uid).collection('skills');

      void processTopics(dynamic list) {
        if (list is! List) return;
        for (final item in list) {
          final topic = item['tagName'] as String? ?? '';
          if (topic.isEmpty) continue;
          final count = (item['problemsSolved'] as num?)?.toInt() ?? 0;
          final score = (count * 10).clamp(0, 100);
          skillBatch.set(skillsRef.doc(topic), {
            'topic': topic,
            'score': score,
            'problemsSolved': count,
            'problemsAttempted': count,
            'avgTimeMin': 0,
            'avgConfidence': 3,
            'recentTrend': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      processTopics(tagCounts['advanced']);
      processTopics(tagCounts['intermediate']);
      processTopics(tagCounts['fundamental']);

      await skillBatch.commit();
    }

    // ── Write submissions as attempts ─────────────────────────────
    final submissionList = submissions?['submission'];
    if (submissionList is List) {
      final attemptBatch = db.batch();
      final attemptsRef = db.collection('users').doc(uid).collection('attempts');

      for (final sub in submissionList.take(20)) {
        attemptBatch.set(attemptsRef.doc(), {
          'problemSlug': sub['titleSlug'] ?? '',
          'problemTitle': sub['title'] ?? '',
          'status': sub['statusDisplay'] == 'Accepted' ? 'SOLVED' : 'ATTEMPTED',
          'timeTakenMin': 0,
          'attempts': 1,
          'hintsUsed': 0,
          'solutionViewed': false,
          'confidence': 3,
          'topics': <String>[],
          'difficulty': sub['difficulty'] ?? 'MEDIUM',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await attemptBatch.commit();
    }
  }

  /// Safe HTTP GET — returns null on any error instead of throwing
  Future<Map<String, dynamic>?> _safeGet(String url) async {
    try {
      final res = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 15),
      );
      if (res.statusCode == 200) {
        return json.decode(res.body) as Map<String, dynamic>?;
      } else {
        print('HTTP Error: ${res.statusCode} for $url');
      }
    } catch (e) {
      print('SafeGet Error for $url: $e');
    }
    return null;
  }

  int _extractStreak(Map<String, dynamic>? calendar) {
    if (calendar == null) return 0;
    return (calendar['streak'] as num?)?.toInt() ?? 0;
  }

  Future<String> getUid() => _auth.getUid();
}
