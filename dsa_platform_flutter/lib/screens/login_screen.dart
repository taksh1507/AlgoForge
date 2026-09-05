import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = TextEditingController();
  bool _isSyncing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncData() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSyncing = true);

    final userProvider = context.read<UserProvider>();
    await userProvider.syncUsername(_controller.text.trim());

    if (mounted) {
      setState(() => _isSyncing = false);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Sync your progress',
                style: AppTextStyles.heading2(),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'LeetCode username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                    borderSide: BorderSide(color: palette.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                    borderSide: BorderSide(color: palette.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.tag),
                    borderSide: BorderSide(color: palette.accent),
                  ),
                  filled: true,
                  fillColor: palette.field,
                ),
                style: AppTextStyles.label(),
                onSubmitted: (_) => _syncData(),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'WE PULL YOUR DATA FROM LEETCODE',
                style: TextStyle(
                  fontFamily: 'ABCDiatypeMono',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: palette.faint,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSyncing ? null : _syncData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: _isSyncing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'SYNC MY DATA',
                              style: TextStyle(
                                fontFamily: 'ABCDiatypeMono',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Text('▸', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}