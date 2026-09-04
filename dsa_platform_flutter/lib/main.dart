import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'providers/problem_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/revision_provider.dart';
import 'providers/engine_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService().initialize();

  // Sign in anonymously if not already authenticated
  final authService = AuthService();
  if (!authService.isLoggedIn) {
    await authService.signInAnonymously();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProblemProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => RevisionProvider()),
        ChangeNotifierProvider(create: (_) => EngineProvider()),
      ],
      child: const DSAPlatformApp(),
    ),
  );
}
