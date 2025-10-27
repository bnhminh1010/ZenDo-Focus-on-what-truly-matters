import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider để quản lý theme mode (light/dark)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  /// Getter cho theme mode hiện tại
  ThemeMode get themeMode => _themeMode;

  /// Kiểm tra xem có đang ở dark mode không
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Constructor - khởi tạo và load theme từ SharedPreferences
  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  /// Load theme mode từ SharedPreferences
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      // Nếu có lỗi, sử dụng light mode mặc định
      _themeMode = ThemeMode.light;
    }
  }

  /// Lưu theme mode vào SharedPreferences
  Future<void> _saveThemeToPrefs(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // Xử lý lỗi nếu cần
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Chuyển đổi theme mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await _saveThemeToPrefs(_themeMode == ThemeMode.dark);
    notifyListeners();
  }

  /// Set theme mode cụ thể
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeToPrefs(mode == ThemeMode.dark);
      notifyListeners();
    }
  }

  /// Set dark mode
  Future<void> setDarkMode(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
