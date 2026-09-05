import 'dart:convert';
import 'package:http/http.dart' as http;

/// Minimal REST client for the Gemini API (no SDK dependency).
/// The user supplies their own API key in Profile → App Settings.
class GeminiService {
  static const _base = 'https://generativelanguage.googleapis.com/v1beta';
  static const _model = 'gemini-2.0-flash';

  final http.Client _client;

  GeminiService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns the assistant's text reply for [prompt].
  /// Throws [GeminiException] on any failure (missing key, network, API error).
  Future<String> ask(String apiKey, String prompt) async {
    final uri = Uri.parse('$_base/models/$_model:generateContent?key=$apiKey');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.4, 'maxOutputTokens': 900},
      }),
    );

    if (response.statusCode != 200) {
      throw GeminiException(
        'Gemini API error (${response.statusCode}): '
        '${response.body}',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = body['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw GeminiException('Gemini returned no candidates.');
    }
    final text = (candidates.first['content']?['parts'] as List?)?.first?['text'];
    if (text == null) {
      throw GeminiException('Gemini returned an empty response.');
    }
    return text as String;
  }
}

class GeminiException implements Exception {
  final String message;
  GeminiException(this.message);

  @override
  String toString() => message;
}