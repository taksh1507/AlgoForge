import 'package:flutter/foundation.dart';
import '../models/revision_card.dart';
import '../engine/revision_engine.dart';
import '../services/firestore_service.dart';

class RevisionProvider extends ChangeNotifier {
  final _engine = RevisionEngine();
  final _firestore = FirestoreService();

  List<RevisionCard> _allCards = [];
  List<RevisionCard> _dueCards = [];
  bool _isLoading = false;

  List<RevisionCard> get allCards => _allCards;
  List<RevisionCard> get dueCards => _dueCards;
  bool get isLoading => _isLoading;
  int get dueCount => _dueCards.length;

  Future<void> loadRevisions(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestore.revisionStream(uid).listen((cards) {
        _allCards = cards;
        _dueCards = _engine.getDueCards(cards);
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rateRevision(String uid, RevisionCard card, int quality) async {
    final updated = _engine.reviewCard(card, quality);
    await _firestore.saveRevisionCard(uid, updated);
  }

  Future<void> addRevision(String uid, String slug, String title) async {
    final card = _engine.createCard(slug, title);
    await _firestore.saveRevisionCard(uid, card);
  }

  Map<String, dynamic> getRetentionStats() {
    return _engine.getRetentionStats(_allCards);
  }
}
