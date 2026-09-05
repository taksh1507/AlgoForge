import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';
import '../utils/text_styles.dart';
import '../services/piston_service.dart';
import '../providers/gamification_provider.dart';

class CodeEditorScreen extends StatefulWidget {
  final String? problemTitle;
  final String initialCode;

  const CodeEditorScreen({super.key, this.problemTitle, this.initialCode = ''});

  @override
  State<CodeEditorScreen> createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  final PistonService _piston = PistonService();
  late final TextEditingController _code;
  String _language = 'python';
  String _version = '';
  List<PistonRuntime> _runtimes = const [];
  String? _error;
  String _output = '';
  int? _exitCode;
  bool _running = false;

  static const _starters = <String, String>{
    'python': 'def solve():\n    # write your solution\n    return 0\n\nprint(solve())\n',
    'javascript': 'function solve() {\n  // write your solution\n  return 0;\n}\n\nconsole.log(solve());\n',
    'cpp': '#include <iostream>\nusing namespace std;\n\nint main() {\n  // write your solution\n  cout << 0 << endl;\n  return 0;\n}\n',
  };

  static const _languages = ['python', 'javascript', 'cpp'];

  @override
  void initState() {
    super.initState();
    _code = TextEditingController(
      text: widget.initialCode.isNotEmpty
          ? widget.initialCode
          : _starters[_language],
    );
    _loadRuntimes();
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _loadRuntimes() async {
    try {
      final runtimes = await _piston.runtimes();
      if (!mounted) return;
      setState(() {
        _runtimes = runtimes;
        // Prefer te_codes3 for stability where available.
        final chosen = _language == 'cpp'
            ? 'c++'
            : _language;
        final match = runtimes.firstWhere(
          (r) => r.language == chosen,
          orElse: () => runtimes.isEmpty
              ? const PistonRuntime(language: 'python', version: '')
              : runtimes.first,
        );
        _version = match.version;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Could not reach code runner: $e');
    }
  }

  void _switchLanguage(String lang) {
    setState(() {
      _language = lang;
      if (widget.initialCode.isEmpty) {
        _code.text = _starters[lang] ?? '';
      }
      final chosen = lang == 'cpp' ? 'c++' : lang;
      final match = _runtimes.firstWhere(
        (r) => r.language == chosen,
        orElse: () => const PistonRuntime(language: 'python', version: ''),
      );
      _version = match.version;
      _output = '';
      _exitCode = null;
    });
  }

  Future<void> _run() async {
    setState(() {
      _running = true;
      _output = '';
      _error = null;
      _exitCode = null;
    });
    try {
      final result = await _piston.execute(
        language: _language,
        version: _version.isNotEmpty ? _version : '5.0.0',
        code: _code.text,
      );
      if (!mounted) return;
      setState(() {
        _output = result.output;
        _exitCode = result.exitCode;
      });
      if (result.exitCode == 0) {
        final gamification = context.read<GamificationProvider>();
        await gamification.recordTestPassed();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.problemTitle ?? 'Code Runner',
          style: AppTextStyles.heading4(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _language,
                dropdownColor: palette.card,
                style: AppTextStyles.label(color: palette.ink),
                items: _languages
                    .map(
                      (l) => DropdownMenuItem(
                        value: l,
                        child: Text(l.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) _switchLanguage(v);
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: TextField(
                      controller: _code,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: GoogleFonts.spaceMono(fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF101418),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                        hintText: 'Write your code…',
                        hintStyle: AppTextStyles.bodySmall(
                          color: palette.faint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(color: palette.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadii.card),
                          borderSide: BorderSide(color: palette.line),
                        ),
                      ),
                    ),
                  ),
                  if (_running)
                    Positioned(
                      right: AppSpacing.lg,
                      top: AppSpacing.lg,
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_error != null || _output.isNotEmpty)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: palette.card,
                  border: Border(
                    top: BorderSide(color: palette.line, width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _error != null ? _error! : _output,
                    style: GoogleFonts.spaceMono(
                      fontSize: 13,
                      height: 1.5,
                      color: _exitCode == 0 ? palette.success : palette.danger,
                    ),
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: palette.line, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _running ? null : _run,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.ink,
                    foregroundColor: palette.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(
                    _running ? 'RUNNING…' : 'RUN CODE',
                    style: AppTextStyles.label(color: palette.bg),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}