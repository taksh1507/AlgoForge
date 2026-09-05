import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../models/problem.dart';
import '../providers/settings_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/gemini_service.dart';

class ProblemDetailScreen extends StatelessWidget {
  final Problem problem;
  final String? reason;

  const ProblemDetailScreen({
    super.key,
    required this.problem,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with back arrow and problem number
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      '←',
                      style: AppTextStyles.body(color: palette.ink),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.line, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.tag),
                    ),
                    child: Text(
                      '#${problem.questionId}',
                      style: AppTextStyles.bodySmall(color: palette.faint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Problem title
              Text(
                problem.title,
                style: AppTextStyles.heading2(),
              ),
              const SizedBox(height: AppSpacing.md),

              // Difficulty and topic tags
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildTag(palette, problem.difficulty, _difficultyColor(palette, problem.difficulty)),
                  for (final topic in problem.topics.take(2))
                    _buildTag(palette, topic, palette.ink),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Why this problem?
              if (reason != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: palette.line, width: 1),
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHY THIS PROBLEM?',
                        style: AppTextStyles.statLabel(color: palette.faint),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        reason!,
                        style: AppTextStyles.body(color: palette.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Similar Problems
              Text(
                'Similar Problems',
                style: AppTextStyles.label(),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: problem.topics.map((topic) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.line, width: 1),
                      borderRadius: BorderRadius.circular(AppRadii.tag),
                    ),
                    child: Text(
                      topic,
                      style: AppTextStyles.bodySmall(color: palette.ink),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Start Solving button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/rate', arguments: problem);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'START SOLVING',
                    style: AppTextStyles.label(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: palette.card,
                          builder: (_) => _AiChatSheet(problem: problem),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.accent,
                        side: BorderSide(color: palette.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.button),
                        ),
                      ),
                      icon: const Icon(Icons.smart_toy_outlined, size: 18),
                      label: const Text('ASK AI'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/code', arguments: problem);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.accent,
                        side: BorderSide(color: palette.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.button),
                        ),
                      ),
                      icon: const Icon(Icons.terminal, size: 18),
                      label: const Text('RUN CODE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(AppPalette palette, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: palette.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.tag),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.statLabel(color: color),
      ),
    );
  }

  Color _difficultyColor(AppPalette palette, String difficulty) {
    switch (difficulty) {
      case 'EASY':
        return palette.success;
      case 'MEDIUM':
        return palette.warn;
      case 'HARD':
        return palette.danger;
      default:
        return palette.ink;
    }
  }
}

/// Inline AI assistant chat for a specific problem.
class _AiChatSheet extends StatefulWidget {
  final Problem problem;

  const _AiChatSheet({required this.problem});

  @override
  State<_AiChatSheet> createState() => _AiChatSheetState();
}

class _AiChatSheetState extends State<_AiChatSheet> {
  final _gemini = GeminiService();
  final _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<({String role, String text})> _messages = [];
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _busy) return;
    _controller.clear();
    setState(() {
      _messages.add((role: 'user', text: question));
      _busy = true;
      _error = null;
    });
    _scrollToEnd();

    final settings = context.read<SettingsProvider>();
    final gamification = context.read<GamificationProvider>();
    if (!settings.hasGeminiKey) {
      setState(() {
        _error = 'Add a Gemini API key in Profile → App Settings first.';
        _busy = false;
      });
      return;
    }

    final prompt = [
      'You are the AlgoForge DSA coach assisting an interview candidate.',
      'Problem: ${widget.problem.title} (#${widget.problem.questionId}, ${widget.problem.difficulty})',
      'Topics: ${widget.problem.topics.join(', ')}',
      'Be concise. Prefer hints over full solutions unless asked for code.',
      '',
      question,
    ].join('\n');

    try {
      final answer = await _gemini.ask(settings.geminiApiKey, prompt);
      if (!mounted) return;
      setState(() {
        _messages.add((role: 'assistant', text: answer));
        _busy = false;
      });
      _scrollToEnd();
      await gamification.recordAiUse();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _busy = false;
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'AI Assistant',
                      style: AppTextStyles.heading4(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _messages.isEmpty && _error == null
                  ? Center(
                      child: Text(
                        'Ask for a hint, approach, or complexity analysis for\n${widget.problem.title}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall(),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _messages.length + (_error != null ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length && _error != null) {
                          return Text(
                            _error!,
                            style: AppTextStyles.bodySmall(color: palette.danger),
                          );
                        }
                        final m = _messages[index];
                        final mine = m.role == 'user';
                        return Align(
                          alignment: mine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            constraints: const BoxConstraints(maxWidth: 320),
                            decoration: BoxDecoration(
                              color: mine ? palette.accent : palette.accentSoft,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                            ),
                            child: Text(
                              m.text,
                              style: AppTextStyles.bodySmall(
                                color: mine ? Colors.white : palette.ink,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.line, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: AppTextStyles.body(),
                      decoration: const InputDecoration(
                        hintText: 'Ask a hint…',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: _busy ? null : _send,
                    icon: const Icon(Icons.arrow_upward),
                    style: IconButton.styleFrom(backgroundColor: palette.accent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}