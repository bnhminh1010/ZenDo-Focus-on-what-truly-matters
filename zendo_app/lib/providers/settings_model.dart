import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model quản lý cài đặt ứng dụng
/// Sử dụng SharedPreferences để lưu trữ cài đặt
class SettingsModel extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  int _focusSessionDuration = 25; // minutes
  int _shortBreakDuration = 5; // minutes
  int _longBreakDuration = 15; // minutes
  String _language = 'vi'; // vi, en
  bool _soundEnabled = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  int get focusSessionDuration => _focusSessionDuration;
  int get shortBreakDuration => _shortBreakDuration;
  int get longBreakDuration => _longBreakDuration;
  String get language => _language;
  bool get soundEnabled => _soundEnabled;

  /// Khởi tạo và load cài đặt từ SharedPreferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _focusSessionDuration = prefs.getInt('focusSessionDuration') ?? 25;
      _shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
      _longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
      _language = prefs.getString('language') ?? 'vi';
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  /// Thay đổi theme mode
  Future<void> setDarkMode(bool value) async {
    try {
      _isDarkMode = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
  }

  /// Bật/tắt thông báo
  Future<void> setNotificationsEnabled(bool value) async {
    try {
      _notificationsEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notificationsEnabled', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  /// Cài đặt thời gian focus session
  Future<void> setFocusSessionDuration(int minutes) async {
    try {
      if (minutes >= 5 && minutes <= 60) {
        _focusSessionDuration = minutes;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('focusSessionDuration', minutes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting focus session duration: $e');
    }
  }

  /// Cài đặt thời gian nghỉ ngắn
  Future<void> setShortBreakDuration(int minutes) async {
    try {
      if (minutes >= 1 && minutes <= 15) {
        _shortBreakDuration = minutes;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('shortBreakDuration', minutes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting short break duration: $e');
    }
  }

  /// Cài đặt thời gian nghỉ dài
  Future<void> setLongBreakDuration(int minutes) async {
    try {
      if (minutes >= 10 && minutes <= 30) {
        _longBreakDuration = minutes;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('longBreakDuration', minutes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting long break duration: $e');
    }
  }

  /// Thay đổi ngôn ngữ
  Future<void> setLanguage(String languageCode) async {
    try {
      _language = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  /// Bật/tắt âm thanh
  Future<void> setSoundEnabled(bool value) async {
    try {
      _soundEnabled = value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('soundEnabled', value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting sound: $e');
    }
  }

  /// Reset về cài đặt mặc định
  Future<void> resetToDefaults() async {
    try {
      _isDarkMode = false;
      _notificationsEnabled = true;
      _focusSessionDuration = 25;
      _shortBreakDuration = 5;
      _longBreakDuration = 15;
      _language = 'vi';
      _soundEnabled = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Lưu lại cài đặt mặc định
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setBool('notificationsEnabled', _notificationsEnabled);
      await prefs.setInt('focusSessionDuration', _focusSessionDuration);
      await prefs.setInt('shortBreakDuration', _shortBreakDuration);
      await prefs.setInt('longBreakDuration', _longBreakDuration);
      await prefs.setString('language', _language);
      await prefs.setBool('soundEnabled', _soundEnabled);

      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }
}
