import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthService {
  final _firebase = FirebaseService();

  User? get currentUser => _firebase.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<User?> get authStateChanges => _firebase.auth.authStateChanges();

  Future<UserCredential> signInAnonymously() async {
    return await _firebase.auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _firebase.auth.signOut();
  }

  Future<String> getUid() async {
    if (currentUser != null) return currentUser!.uid;
    final cred = await signInAnonymously();
    return cred.user!.uid;
  }
}
