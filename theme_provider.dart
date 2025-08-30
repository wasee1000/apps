import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Notifier for theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _prefsKey = 'theme_mode';
  
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  // Load theme mode from shared preferences
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_prefsKey);
    
    if (themeString != null) {
      state = _themeFromString(themeString);
    } else {
      // Check if device is in dark mode
      final window = WidgetsBinding.instance.window;
      final brightness = window.platformBrightness;
      state = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
  }
  
  // Save theme mode to shared preferences
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _themeToString(mode));
  }
  
  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _saveThemeMode(mode);
  }
  
  // Toggle between light and dark mode
  Future<void> toggleThemeMode() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    await _saveThemeMode(newMode);
  }
  
  // Convert theme mode to string
  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
  
  // Convert string to theme mode
  ThemeMode _themeFromString(String themeString) {
    switch (themeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}

// Provider for checking if dark mode is active
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  
  if (themeMode == ThemeMode.system) {
    // Check system theme
    final window = WidgetsBinding.instance.window;
    final brightness = window.platformBrightness;
    return brightness == Brightness.dark;
  }
  
  return themeMode == ThemeMode.dark;
});

