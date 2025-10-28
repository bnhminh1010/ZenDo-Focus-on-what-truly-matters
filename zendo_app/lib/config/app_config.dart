import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Cấu hình mặc định cho ứng dụng ZenDo
class AppConfig {
  // Development Configuration
  /// Kiểm tra có phải môi trường development không.
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;

  // Server Configuration
  /// Host mặc định cho web server.
  static const String defaultWebHost = 'localhost';
  /// Port mặc định cho web server.
  static const int defaultWebPort = 3000;
  /// URL web mặc định.
  static String get defaultWebUrl => EnvironmentConfig.baseUrl;

  // OAuth Redirect URIs
  /// Redirect URI cho web OAuth.
  static String get webRedirectUri => EnvironmentConfig.baseUrl;
  /// Callback URI cho Supabase OAuth.
  static String get supabaseCallbackUri =>
      EnvironmentConfig.supabaseCallbackUrl;

  // Default API Keys (for demo purposes)
  /// API key Gemini mặc định.
  static String get defaultGeminiApiKey => EnvironmentConfig.defaultApiKey;

  // App Information
  /// Tên ứng dụng.
  static const String appName = 'ZenDo';
  /// Phiên bản ứng dụng.
  static const String appVersion = '1.0.0';
  /// Mô tả ứng dụng.
  static const String appDescription = 'Focus on what truly matters';

  // Database Configuration
  /// Tên file database SQLite.
  static const String databaseName = 'zendo_database.db';
  /// Phiên bản database.
  static const int databaseVersion = 1;

  // Session Configuration
  /// Thời lượng focus session mặc định (phút).
  static const int defaultFocusSessionDuration = 25; // minutes
  /// Thời lượng nghỉ ngắn mặc định (phút).
  static const int defaultShortBreakDuration = 5; // minutes
  /// Thời lượng nghỉ dài mặc định (phút).
  static const int defaultLongBreakDuration = 15; // minutes

  // UI Configuration
  /// Bán kính bo tròn mặc định cho UI elements.
  static const double defaultBorderRadius = 12.0;
  /// Padding mặc định.
  static const double defaultPadding = 16.0;
  /// Margin mặc định.
  static const double defaultMargin = 8.0;

  // Animation Configuration
  /// Thời gian animation mặc định.
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  /// Thời gian animation ngắn.
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  /// Thời gian animation dài.
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Network Configuration (Legacy - sẽ được thay thế bởi EnvironmentConfig)
  /// Timeout mặc định cho network requests.
  static const Duration defaultTimeoutDuration = Duration(seconds: 30);
  /// Số lần retry tối đa.
  static const int defaultMaxRetryAttempts = 3;

  // Storage Keys
  /// Key lưu user preferences.
  static const String userPrefsKey = 'user_preferences';
  /// Key lưu theme preferences.
  static const String themePrefsKey = 'theme_preferences';
  /// Key lưu auth token.
  static const String authTokenKey = 'auth_token';

  // Feature Flags
  /// Bật/tắt Google Auth.
  static bool get enableGoogleAuth =>
      EnvironmentConfig.isFeatureEnabled('enableGoogleAuth');
  /// Bật/tắt GitHub Auth.
  static bool get enableGitHubAuth =>
      EnvironmentConfig.isFeatureEnabled('enableGitHubAuth');
  /// Bật/tắt Gemini AI.
  static bool get enableGeminiAI =>
      EnvironmentConfig.isFeatureEnabled('enableGeminiAI');
  /// Bật/tắt offline mode.
  static bool get enableOfflineMode =>
      EnvironmentConfig.isFeatureEnabled('enableOfflineMode');
  /// Bật/tắt analytics.
  static bool get enableAnalytics =>
      EnvironmentConfig.isFeatureEnabled('enableAnalytics');

  // Debug Configuration
  /// Bật/tắt debug mode.
  static bool get enableDebugMode =>
      EnvironmentConfig.isFeatureEnabled('enableDebugMode');
  /// Bật/tắt logging.
  static bool get enableLogging =>
      EnvironmentConfig.isFeatureEnabled('enableLogging');
  /// Bật/tắt performance monitoring.
  static bool get enablePerformanceMonitoring =>
      EnvironmentConfig.isFeatureEnabled('enablePerformanceMonitoring');

  /// Lấy redirect URI phù hợp dựa trên platform
  static String getRedirectUri(bool isWeb) {
    return EnvironmentConfig.getOAuthRedirectUri(isWeb);
  }

  /// Lấy network timeout dựa trên môi trường
  static Duration get networkTimeout => EnvironmentConfig.networkTimeout;

  /// Lấy số lần retry dựa trên môi trường
  static int get maxRetryAttempts => EnvironmentConfig.maxRetryAttempts;

  /// In thông tin cấu hình (chỉ trong development)
  static void printConfigInfo() {
    EnvironmentConfig.printEnvironmentInfo();
    if (enableDebugMode) {
      debugPrint('=== APP CONFIG INFO ===');
      debugPrint('Google Auth: $enableGoogleAuth');
      debugPrint('GitHub Auth: $enableGitHubAuth');
      debugPrint('Gemini AI: $enableGeminiAI');
      debugPrint('Analytics: $enableAnalytics');
      debugPrint('=======================');
    }
  }

  /// Lấy base URL cho API calls
  static String getBaseUrl() {
    return isDevelopment ? defaultWebUrl : 'https://your-production-url.com';
  }

  /// Kiểm tra xem có phải môi trường development không
  static bool get isDebugMode => isDevelopment && enableDebugMode;
}

