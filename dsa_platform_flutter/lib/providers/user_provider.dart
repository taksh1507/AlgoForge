import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/skill_profile.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/leetcode_sync_service.dart';

class UserProvider extends ChangeNotifier {
  final _firestore = FirestoreService();
  final _auth = AuthService();
  final _leetcode = LeetcodeSyncService();

  UserProfile? _profile;
  SkillProfile? _skillProfile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  SkillProfile? get skillProfile => _skillProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _auth.isLoggedIn;

  Future<void> loadProfile() async {
    if (!_auth.isLoggedIn) return;

    _isLoading = true;
    notifyListeners();

    try {
      final uid = await _auth.getUid();
      _profile = await _firestore.getUser(uid);
      
      // Listen to skills subcollection to populate the Radar Chart!
      _firestore.skillsStream(uid).listen((skillsMap) {
        _skillProfile = SkillProfile(
          topics: skillsMap,
          overallScore: skillsMap.values.fold(0.0, (sum, t) => sum + t.score) / (skillsMap.isEmpty ? 1 : skillsMap.length),
        );
        notifyListeners();
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> syncUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uid = await _auth.getUid();

      // Save user profile immediately so UI renders
      _profile = UserProfile(uid: uid, username: username, syncedAt: DateTime.now());
      await _firestore.saveUser(_profile!);
      notifyListeners();

      // Trigger Cloud Function to fetch LeetCode data
      await _leetcode.syncUser(username);

      // Reload profile from Firestore after sync
      final updated = await _firestore.getUser(uid);
      if (updated != null) {
        _profile = updated;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSkillProfile(SkillProfile profile) {
    _skillProfile = profile;
    notifyListeners();
  }
}
