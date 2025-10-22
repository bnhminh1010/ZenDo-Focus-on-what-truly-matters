import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Cấu hình mặc định cho ứng dụng ZenDo
class AppConfig {
  // Development Configuration
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;

  // Server Configuration
  static const String defaultWebHost = 'localhost';
  static const int defaultWebPort = 3000;
  static String get defaultWebUrl => EnvironmentConfig.baseUrl;

  // OAuth Redirect URIs
  static String get webRedirectUri => EnvironmentConfig.baseUrl;
  static String get supabaseCallbackUri =>
      EnvironmentConfig.supabaseCallbackUrl;

  // Default API Keys (for demo purposes)
  static String get defaultGeminiApiKey => EnvironmentConfig.defaultApiKey;

  // App Information
  static const String appName = 'ZenDo';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Focus on what truly matters';

  // Database Configuration
  static const String databaseName = 'zendo_database.db';
  static const int databaseVersion = 1;

  // Session Configuration
  static const int defaultFocusSessionDuration = 25; // minutes
  static const int defaultShortBreakDuration = 5; // minutes
  static const int defaultLongBreakDuration = 15; // minutes

  // UI Configuration
  static const double defaultBorderRadius = 12.0;
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;

  // Animation Configuration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Network Configuration (Legacy - sẽ được thay thế bởi EnvironmentConfig)
  static const Duration defaultTimeoutDuration = Duration(seconds: 30);
  static const int defaultMaxRetryAttempts = 3;

  // Storage Keys
  static const String userPrefsKey = 'user_preferences';
  static const String themePrefsKey = 'theme_preferences';
  static const String authTokenKey = 'auth_token';

  // Feature Flags
  static bool get enableGoogleAuth =>
      EnvironmentConfig.isFeatureEnabled('enableGoogleAuth');
  static bool get enableGitHubAuth =>
      EnvironmentConfig.isFeatureEnabled('enableGitHubAuth');
  static bool get enableGeminiAI =>
      EnvironmentConfig.isFeatureEnabled('enableGeminiAI');
  static bool get enableOfflineMode =>
      EnvironmentConfig.isFeatureEnabled('enableOfflineMode');
  static bool get enableAnalytics =>
      EnvironmentConfig.isFeatureEnabled('enableAnalytics');

  // Debug Configuration
  static bool get enableDebugMode =>
      EnvironmentConfig.isFeatureEnabled('enableDebugMode');
  static bool get enableLogging =>
      EnvironmentConfig.isFeatureEnabled('enableLogging');
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

