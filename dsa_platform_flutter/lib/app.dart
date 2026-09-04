import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'providers/user_provider.dart';
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
import 'models/problem.dart';
import 'models/recommendation.dart';

class DSAPlatformApp extends StatelessWidget {
  const DSAPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlgoForge',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
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
          case '/learning-path':
            final topic = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => LearningPathScreen(topic: topic),
            );
          case '/revision':
            return MaterialPageRoute(builder: (_) => const RevisionScreen());
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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.ash, width: 0.5),
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
