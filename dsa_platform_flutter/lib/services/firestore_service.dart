import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/skill_profile.dart';
import '../models/revision_card.dart';
import '../models/problem.dart';
import 'firebase_service.dart';

class FirestoreService {
  final _firebase = FirebaseService();

  FirebaseFirestore get firestore => _firebase.firestore;

  CollectionReference get _users => _firebase.firestore.collection('users');
  CollectionReference get _problems => _firebase.firestore.collection('problems');
  CollectionReference get _graph => _firebase.firestore.collection('knowledge_graph');
  CollectionReference get _companies => _firebase.firestore.collection('company_index');

  // ── User ──────────────────────────────────────────────────────

  Future<void> saveUser(UserProfile user) async {
    await _users.doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<UserProfile?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, uid);
  }

  Stream<UserProfile?> userStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromFirestore(doc.data() as Map<String, dynamic>, uid);
    });
  }

  // ── Attempts ──────────────────────────────────────────────────

  Future<void> saveAttempt(String uid, Map<String, dynamic> attempt) async {
    await _users.doc(uid).collection('attempts').add({
      ...attempt,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> attemptsStream(String uid, {int limit = 50}) {
    return _users
        .doc(uid)
        .collection('attempts')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getAttempts(String uid, {int limit = 50}) async {
    final snapshot = await _users
        .doc(uid)
        .collection('attempts')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // ── Skills ────────────────────────────────────────────────────

  Future<void> saveSkill(String uid, TopicScore skill) async {
    await _users.doc(uid).collection('skills').doc(skill.topic).set(skill.toFirestore());
  }

  Future<void> saveAllSkills(String uid, Map<String, TopicScore> skills) async {
    final batch = _firebase.firestore.batch();
    skills.forEach((topic, score) {
      final ref = _users.doc(uid).collection('skills').doc(topic);
      batch.set(ref, score.toFirestore());
    });
    await batch.commit();
  }

  Stream<Map<String, TopicScore>> skillsStream(String uid) {
    return _users.doc(uid).collection('skills').snapshots().map((snapshot) {
      final skills = <String, TopicScore>{};
      for (final doc in snapshot.docs) {
        skills[doc.id] = TopicScore.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return skills;
    });
  }

  // ── Revision ──────────────────────────────────────────────────

  Future<void> saveRevisionCard(String uid, RevisionCard card) async {
    await _users
        .doc(uid)
        .collection('revision')
        .doc(card.problemSlug)
        .set(card.toFirestore());
  }

  Stream<List<RevisionCard>> revisionStream(String uid) {
    return _users
        .doc(uid)
        .collection('revision')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RevisionCard.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<RevisionCard>> getDueRevisions(String uid) async {
    final snapshot = await _users
        .doc(uid)
        .collection('revision')
        .where('nextReview', isLessThanOrEqualTo: DateTime.now())
        .get();
    return snapshot.docs
        .map((doc) => RevisionCard.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // ── Problems ──────────────────────────────────────────────────

  Stream<List<Problem>> problemsStream({int limit = 100}) {
    return _problems.limit(limit).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Problem.fromFirestore(doc.data() as Map<String, dynamic>)).toList());
  }

  Future<Problem?> getProblem(String slug) async {
    final doc = await _problems.doc(slug).get();
    if (!doc.exists) return null;
    return Problem.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  // ── Knowledge Graph ───────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> graphStream() {
    return _graph.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  // ── Company Index ─────────────────────────────────────────────

  Future<List<String>> getCompanyProblems(String company) async {
    final doc = await _companies.doc(company).get();
    if (!doc.exists) return [];
    final data = doc.data() as Map<String, dynamic>;
    return List<String>.from(data['problemSlugs'] ?? []);
  }
}
