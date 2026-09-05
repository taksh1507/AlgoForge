import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// App-wide user preferences: theme, offline mode, and the optional
/// user-provided Gemini API key for the AI assistant.
class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'app_settings';
  late final Box _box;

  ThemeMode _themeMode = ThemeMode.system;
  bool _offlineEnabled = true;
  String _geminiApiKey = '';

  ThemeMode get themeMode => _themeMode;
  bool get offlineEnabled => _offlineEnabled;
  String get geminiApiKey => _geminiApiKey;
  bool get hasGeminiKey => _geminiApiKey.trim().isNotEmpty;

  Future<void> initialize() async {
    _box = Hive.box(_boxName);
    _themeMode = _themeFromIndex(_box.get('themeMode', defaultValue: 0));
    _offlineEnabled = _box.get('offlineEnabled', defaultValue: true);
    _geminiApiKey = _box.get('geminiApiKey', defaultValue: '');
  }

  ThemeMode _themeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setOfflineEnabled(bool value) async {
    _offlineEnabled = value;
    await _box.put('offlineEnabled', value);
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key.trim();
    await _box.put('geminiApiKey', _geminiApiKey);
    notifyListeners();
  }
}