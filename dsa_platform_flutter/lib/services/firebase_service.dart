import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;
  User? get currentUser => auth.currentUser;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
