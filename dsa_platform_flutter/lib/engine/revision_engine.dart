import 'dart:collection';
import '../models/revision_card.dart';

/// Revision Engine — Min Heap + SM-2 Spaced Repetition.
///
/// Uses the SuperMemo-2 algorithm for spaced repetition:
/// - If user got it right: interval increases (ease factor increases)
/// - If user got it wrong: interval resets to 1 day (ease factor decreases)
///
/// Min Heap extracts the most overdue cards first.
///
/// DSA Concepts Used:
/// - Min Heap (Priority Queue) for urgency sorting
/// - Spaced Repetition (SM-2 algorithm)
class RevisionEngine {
  /// Create a new revision card for a problem
  RevisionCard createCard(String problemSlug, String problemTitle) {
    return RevisionCard(
      problemSlug: problemSlug,
      problemTitle: problemTitle,
      nextReview: DateTime.now().add(const Duration(days: 1)),
      intervalDays: 1,
      easeFactor: 2.5,
      repetitions: 0,
    );
  }

  /// Update card after review using SM-2 algorithm
  ///
  /// quality: 0-5 (0-2 = failed, 3-5 = passed)
  RevisionCard reviewCard(RevisionCard card, int quality) {
    if (quality < 0 || quality > 5) {
      throw ArgumentError('Quality must be between 0 and 5');
    }

    double newEaseFactor = card.easeFactor;
    int newInterval;
    int newRepetitions;

    if (quality >= 3) {
      // Passed
      if (card.repetitions == 0) {
        newInterval = 1;
      } else if (card.repetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * card.easeFactor).round();
      }
      newRepetitions = card.repetitions + 1;
    } else {
      // Failed — reset
      newInterval = 1;
      newRepetitions = 0;
    }

    // Update ease factor
    newEaseFactor = card.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (newEaseFactor < 1.3) newEaseFactor = 1.3;

    return card.copyWith(
      nextReview: DateTime.now().add(Duration(days: newInterval)),
      intervalDays: newInterval,
      easeFactor: newEaseFactor,
      repetitions: newRepetitions,
      lastResult: quality >= 3 ? 'solved' : 'failed',
    );
  }

  /// Get due revision cards sorted by urgency (most overdue first)
  ///
  /// Uses Min Heap concept: cards with earliest nextReview come first
  List<RevisionCard> getDueCards(List<RevisionCard> allCards) {
    final now = DateTime.now();
    final dueCards = allCards.where((card) => card.nextReview.isBefore(now)).toList();

    // Min Heap sort by urgency (most overdue = earliest nextReview)
    dueCards.sort((a, b) => a.nextReview.compareTo(b.nextReview));

    return dueCards;
  }

  /// Get upcoming revisions (not yet due)
  List<RevisionCard> getUpcomingCards(List<RevisionCard> allCards, {int limit = 10}) {
    final now = DateTime.now();
    final upcoming = allCards.where((card) => card.nextReview.isAfter(now)).toList();

    // Sort by nearest due date
    upcoming.sort((a, b) => a.nextReview.compareTo(b.nextReview));

    return upcoming.take(limit).toList();
  }

  /// Calculate retention stats
  Map<String, dynamic> getRetentionStats(List<RevisionCard> cards) {
    if (cards.isEmpty) {
      return {
        'totalCards': 0,
        'dueToday': 0,
        'mastered': 0,
        'struggling': 0,
        'avgEaseFactor': 2.5,
      };
    }

    final now = DateTime.now();
    final dueToday = cards.where((c) => c.nextReview.isBefore(now)).length;
    final mastered = cards.where((c) => c.intervalDays >= 21).length;
    final struggling = cards.where((c) => c.easeFactor < 1.8).length;
    final avgEase = cards.map((c) => c.easeFactor).reduce((a, b) => a + b) / cards.length;

    return {
      'totalCards': cards.length,
      'dueToday': dueToday,
      'mastered': mastered,
      'struggling': struggling,
      'avgEaseFactor': avgEase,
    };
  }
}
