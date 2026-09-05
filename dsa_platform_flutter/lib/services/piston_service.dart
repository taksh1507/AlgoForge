import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result of a Piston code execution.
class PistonResult {
  final String output;
  final int? exitCode;

  const PistonResult({required this.output, this.exitCode});

  factory PistonResult.fromJson(Map<String, dynamic> json) {
    final run = json['run'] as Map<String, dynamic>? ?? const {};
    return PistonResult(
      output: (run['output'] as String?)?.trimRight() ?? '',
      exitCode: (run['code'] as num?)?.toInt(),
    );
  }
}

/// Runtime descriptor returned by the Piston `/runtimes` endpoint.
class PistonRuntime {
  final String language;
  final String version;
  final String? alias;

  const PistonRuntime({
    required this.language,
    required this.version,
    this.alias,
  });

  factory PistonRuntime.fromJson(Map<String, dynamic> json) {
    return PistonRuntime(
      language: json['language'] as String? ?? '',
      version: json['version'] as String? ?? '',
      alias: (json['aliases'] as List?)?.firstOrNull as String?,
    );
  }

  String get label => alias ?? language;
}

/// Executes code snippets via the free Piston API (emkc.org).
/// No auth required; used by the in-app Code Runner.
class PistonService {
  static const _api = 'https://emkc.org/api/v2/piston';

  final http.Client _client;

  PistonService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PistonRuntime>> runtimes() async {
    final resp =
        await _client.get(Uri.parse('$_api/runtimes')).timeout(
      const Duration(seconds: 15),
    );
    if (resp.statusCode != 200) {
      throw PistonException('Could not fetch runtimes (${resp.statusCode}).');
    }
    final list = jsonDecode(resp.body) as List;
    return list
        .map((e) => PistonRuntime.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PistonResult> execute({
    required String language,
    required String version,
    required String code,
    String stdin = '',
  }) async {
    final resp =
        await _client
            .post(
              Uri.parse('$_api/execute'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'language': language,
                'version': version,
                'files': [
                  {'content': code},
                ],
                'stdin': stdin,
              }),
            )
            .timeout(const Duration(seconds: 30));

    if (resp.statusCode != 200) {
      throw PistonException('Execution failed (${resp.statusCode}).');
    }
    return PistonResult.fromJson(jsonDecode(resp.body));
  }
}

class PistonException implements Exception {
  final String message;
  PistonException(this.message);

  @override
  String toString() => message;
}