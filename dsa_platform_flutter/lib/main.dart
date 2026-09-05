import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'providers/user_provider.dart';
import 'providers/problem_provider.dart';
import 'providers/recommendation_provider.dart';
import 'providers/revision_provider.dart';
import 'providers/engine_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/gamification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local persistence (feeds, settings, cache, gamification)
  await Hive.initFlutter();
  await Hive.openBox('app_notifications');
  await Hive.openBox('notification_settings');
  await Hive.openBox('app_settings');
  await Hive.openBox('gamification');
  await Hive.openBox('problem_cache');

  await FirebaseService().initialize();

  // Sign in anonymously if not already authenticated
  final authService = AuthService();
  if (!authService.isLoggedIn) {
    await authService.signInAnonymously();
  }

  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  final gamificationProvider = GamificationProvider();
  await gamificationProvider.initialize();

  // Initialize the notification system
  final notificationProvider = NotificationProvider();
  await notificationProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProblemProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationProvider()),
        ChangeNotifierProvider(create: (_) => RevisionProvider()),
        ChangeNotifierProvider(create: (_) => EngineProvider()),
        ChangeNotifierProvider(create: (_) => notificationProvider),
        ChangeNotifierProvider(create: (_) => settingsProvider),
        ChangeNotifierProvider(create: (_) => gamificationProvider),
      ],
      child: const DSAPlatformApp(),
    ),
  );
}