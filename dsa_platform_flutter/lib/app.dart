import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'utils/text_styles.dart';
import 'providers/notification_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/problem_detail_screen.dart';
import 'screens/rate_problem_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/learning_path_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/revision_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/code_editor_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/interview_prep_screen.dart';
import 'models/problem.dart';
import 'models/recommendation.dart';

/// Global route observer used to detect when the user returns to a screen
/// (e.g. back from solving a problem) so it can refresh its state.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

class DSAPlatformApp extends StatelessWidget {
  const DSAPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'AlgoForge',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainShell());
          case '/problem-detail':
            final args = settings.arguments as Map<String, dynamic>;
            final problem = args['problem'];
            final reason = args['reason'] as String?;

            // Handle both Problem and Recommendation types
            if (problem is Recommendation) {
              return MaterialPageRoute(
                builder: (_) => ProblemDetailScreen(
                  problem: Problem(
                    titleSlug: problem.problemSlug,
                    title: problem.problemTitle,
                    questionId: 0,
                    difficulty: problem.difficulty,
                    topics: problem.topics,
                  ),
                  reason: reason,
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => ProblemDetailScreen(
                problem: problem as Problem,
                reason: reason,
              ),
            );
          case '/rate':
            final problem = settings.arguments as Problem;
            return MaterialPageRoute(
              builder: (_) => RateProblemScreen(problem: problem),
            );
          case '/code':
            final problem = settings.arguments as Problem?;
            return MaterialPageRoute(
              builder: (_) => CodeEditorScreen(problemTitle: problem?.title),
            );
          case '/analytics':
            return MaterialPageRoute(builder: (_) => const AnalyticsScreen());
          case '/interview':
            return MaterialPageRoute(builder: (_) => const InterviewPrepScreen());
          case '/learning-path':
            final topic = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => LearningPathScreen(topic: topic),
            );
          case '/revision':
            return MaterialPageRoute(builder: (_) => const RevisionScreen());
          case '/notifications':
            return MaterialPageRoute(
                builder: (_) => const NotificationsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    LearnScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'AlgoForge',
          style: AppTextStyles.heading3(),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unread = notificationProvider.unreadCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    tooltip: 'Notifications',
                    icon: Icon(Icons.notifications_none, color: palette.ink),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/notifications'),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: palette.danger,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 16, minHeight: 16),
                        child: Center(
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: palette.line, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Learn',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
