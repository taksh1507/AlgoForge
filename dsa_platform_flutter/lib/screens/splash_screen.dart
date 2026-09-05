import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'AlgoForge',
              style: TextStyle(
                fontFamily: 'UntitledSerif',
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Forge your algorithm skills',
              style: TextStyle(
                fontFamily: 'ABCDiatypeMono',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}