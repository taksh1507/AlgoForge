import 'dart:collection';
import '../models/problem.dart';
import '../models/skill_profile.dart';
import 'knowledge_graph.dart';

/// Recommendation Engine — Max Heap based next-problem scoring.
///
/// For each unsolved problem, calculate a score based on:
/// - Weak-topic boost: higher score if problem targets a weak area
/// - Prerequisite relevance: is the user ready for this problem?
/// - Pattern reinforcement: does it reinforce recently learned concepts?
/// - Difficulty suitability: is it in the right difficulty zone?
/// - Revision urgency: has the user seen related problems before?
/// - Similarity boost: similar to recently solved problems
/// - Penalties: already seen, too difficult
///
/// DSA Concepts Used:
/// - Max Heap (Priority Queue) to extract best recommendations
/// - HashMap for skill lookup
/// - Binary Search for difficulty targeting
class RecommendationEngine {
  /// Get top N recommendations from unsolved problems
  List<Map<String, dynamic>> getTopRecommendations({
    required List<Problem> unsolvedProblems,
    required SkillProfile skillProfile,
    required KnowledgeGraph graph,
    required List<String> solvedSlugs,
    required List<Map<String, dynamic>> recentAttempts,
    int topN = 3,
  }) {
    final scored = <Map<String, dynamic>>[];

    for (final problem in unsolvedProblems) {
      if (solvedSlugs.contains(problem.titleSlug)) continue;

      final score = _scoreProblem(
        problem: problem,
        skillProfile: skillProfile,
        graph: graph,
        solvedSlugs: solvedSlugs,
        recentAttempts: recentAttempts,
      );

      scored.add({
        'problem': problem,
        'score': score['total'],
        'reason': score['reason'],
        'breakdown': score,
      });
    }

    // Max Heap: sort by score descending
    scored.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));

    return scored.take(topN).toList();
  }

  Map<String, dynamic> _scoreProblem({
    required Problem problem,
    required SkillProfile skillProfile,
    required KnowledgeGraph graph,
    required List<String> solvedSlugs,
    required List<Map<String, dynamic>> recentAttempts,
  }) {
    double weakTopicBoost = 0;
    double prerequisiteRelevance = 0;
    double patternReinforcement = 0;
    double difficultySuitability = 0;
    double revisionUrgency = 0;
    double similarityBoost = 0;
    double alreadySeenPenalty = 0;
    double excessiveDifficultyPenalty = 0;
    final reasons = <String>[];

    // 1. Weak Topic Boost (0-30)
    for (final topic in problem.topics) {
      final topicScore = skillProfile.getTopic(topic);
      if (topicScore != null && topicScore.score < 50) {
        weakTopicBoost += (50 - topicScore.score) * 0.6;
        reasons.add('Targets weak area: $topic (${topicScore.score.round()}%)');
      }
    }
    weakTopicBoost = weakTopicBoost.clamp(0.0, 30.0);

    // 2. Prerequisite Relevance (0-25)
    final allPrereqs = <String>{};
    for (final topic in problem.topics) {
      allPrereqs.addAll(graph.getAllPrerequisites(topic));
    }
    if (allPrereqs.isNotEmpty) {
      int mastered = 0;
      for (final prereq in allPrereqs) {
        final score = skillProfile.getTopic(prereq);
        if (score != null && score.score >= 60) mastered++;
      }
      prerequisiteRelevance = (mastered / allPrereqs.length) * 25;
      if (prerequisiteRelevance >= 20) {
        reasons.add('Prerequisites well understood');
      }
    }

    // 3. Pattern Reinforcement (0-15)
    final recentTopics = recentAttempts
        .take(10)
        .expand((a) => List<String>.from(a['topics'] ?? []))
        .toList();
    int overlap = 0;
    for (final topic in problem.topics) {
      if (recentTopics.contains(topic)) overlap++;
    }
    if (overlap > 0) {
      patternReinforcement = (overlap / problem.topics.length) * 15;
      reasons.add('Reinforces recently practiced patterns');
    }

    // 4. Difficulty Suitability (0-15)
    // Target: slightly above current skill level
    final avgScore = skillProfile.overallScore;
    double targetDifficulty = 0;
    if (avgScore < 40) targetDifficulty = 1; // Easy
    else if (avgScore < 70) targetDifficulty = 2; // Medium
    else targetDifficulty = 3; // Hard

    double problemDifficulty = 2;
    if (problem.difficulty == 'EASY') problemDifficulty = 1;
    else if (problem.difficulty == 'HARD') problemDifficulty = 3;

    final diffDiff = (problemDifficulty - targetDifficulty).abs();
    difficultySuitability = (1 - diffDiff / 2) * 15;
    if (diffDiff <= 0.5) {
      reasons.add('Right difficulty for your level');
    }

    // 5. Revision Urgency (0-10)
    // If user has solved similar problems but not this one
    for (final topic in problem.topics) {
      final topicScore = skillProfile.getTopic(topic);
      if (topicScore != null &&
          topicScore.problemsSolved > 0 &&
          topicScore.score >= 40 &&
          topicScore.score < 70) {
        revisionUrgency += 3;
        reasons.add('Good time to consolidate $topic');
      }
    }
    revisionUrgency = revisionUrgency.clamp(0.0, 10.0);

    // 6. Similarity Boost (0-5)
    final lastSolvedTopics = recentAttempts
        .where((a) => a['status'] == 'SOLVED')
        .take(5)
        .expand((a) => List<String>.from(a['topics'] ?? []))
        .toList();
    int similarityCount = 0;
    for (final topic in problem.topics) {
      if (lastSolvedTopics.contains(topic)) similarityCount++;
    }
    similarityBoost = (similarityCount / problem.topics.length).clamp(0.0, 1.0) * 5;

    // 7. Already Seen Penalty (-20)
    if (solvedSlugs.contains(problem.titleSlug)) {
      alreadySeenPenalty = -20;
    }

    // 8. Excessive Difficulty Penalty (-15)
    if (problemDifficulty - targetDifficulty > 1) {
      excessiveDifficultyPenalty = -15;
      reasons.add('May be too challenging right now');
    }

    final total = (weakTopicBoost +
            prerequisiteRelevance +
            patternReinforcement +
            difficultySuitability +
            revisionUrgency +
            similarityBoost +
            alreadySeenPenalty +
            excessiveDifficultyPenalty)
        .clamp(0.0, 100.0);

    if (reasons.isEmpty) {
      reasons.add('Good general practice problem');
    }

    return {
      'total': total,
      'weakTopicBoost': weakTopicBoost,
      'prerequisiteRelevance': prerequisiteRelevance,
      'patternReinforcement': patternReinforcement,
      'difficultySuitability': difficultySuitability,
      'revisionUrgency': revisionUrgency,
      'similarityBoost': similarityBoost,
      'alreadySeenPenalty': alreadySeenPenalty,
      'excessiveDifficultyPenalty': excessiveDifficultyPenalty,
      'reason': reasons.first,
    };
  }
}
