import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _themeKey = "isDarkMode";
  static const String _extensionsEnabledKey = "extensionsEnabled";
  bool _isDarkMode = true;
  bool _extensionsEnabled = false;

  bool get isDarkMode => _isDarkMode;
  bool get extensionsEnabled => _extensionsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? true;
    _extensionsEnabled = prefs.getBool(_extensionsEnabledKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> setExtensionsEnabled(bool value) async {
    _extensionsEnabled = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_extensionsEnabledKey, _extensionsEnabled);
  }
}
