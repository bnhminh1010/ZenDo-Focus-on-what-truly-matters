import 'package:flutter/foundation.dart';

/// Enum định nghĩa các môi trường
enum Environment { development, staging, production }

/// Cấu hình cho từng môi trường
class EnvironmentConfig {
  // Môi trường hiện tại
  static const Environment _currentEnvironment = kDebugMode
      ? Environment.development
      : Environment.production;

  static Environment get currentEnvironment => _currentEnvironment;

  // Base URLs cho từng môi trường
  static const Map<Environment, String> _baseUrls = {
    // Desktop không cần base URL cố định, web sẽ dùng Uri.base.origin
    Environment.development: '',
    Environment.staging: 'https://staging.zendo.app',
    Environment.production: 'https://zendo.app',
  };

  // Supabase URLs cho từng môi trường
  static const Map<Environment, String> _supabaseUrls = {
    Environment.development: 'https://ewfjqvatkzeyccilxzne.supabase.co',
    Environment.staging: 'https://staging-supabase-url.supabase.co',
    Environment.production: 'https://production-supabase-url.supabase.co',
  };

  // API Keys mặc định cho từng môi trường
  static const Map<Environment, String> _defaultApiKeys = {
    Environment.development: '', // Sẽ lấy từ .env file
    Environment.staging: 'staging-gemini-api-key',
    Environment.production: 'AIzaSyDemoKey-ReplaceWithRealProductionKey', // Demo key cho production
  };

  // Feature flags cho từng môi trường
  static const Map<Environment, Map<String, bool>> _featureFlags = {
    Environment.development: {
      'enableLogging': true,
      'enableDebugMode': true,
      'enableAnalytics': false,
      'enableCrashReporting': false,
      'enablePerformanceMonitoring': true,
    },
    Environment.staging: {
      'enableLogging': true,
      'enableDebugMode': false,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'enablePerformanceMonitoring': true,
    },
    Environment.production: {
      'enableLogging': false,
      'enableDebugMode': false,
      'enableAnalytics': true,
      'enableCrashReporting': true,
      'enablePerformanceMonitoring': false,
    },
  };

  /// Lấy base URL cho môi trường hiện tại
  static String get baseUrl => _baseUrls[_currentEnvironment]!;

  /// Lấy Supabase URL cho môi trường hiện tại
  static String get supabaseUrl => _supabaseUrls[_currentEnvironment]!;

  /// Lấy Supabase callback URL
  static String get supabaseCallbackUrl => '$supabaseUrl/auth/v1/callback';

  /// Lấy API key mặc định cho môi trường hiện tại
  static String get defaultApiKey => _defaultApiKeys[_currentEnvironment]!;

  /// Kiểm tra feature flag
  static bool isFeatureEnabled(String feature) {
    return _featureFlags[_currentEnvironment]?[feature] ?? false;
  }

  /// Lấy tất cả feature flags cho môi trường hiện tại
  static Map<String, bool> get currentFeatureFlags =>
      _featureFlags[_currentEnvironment]!;

  /// Kiểm tra xem có phải môi trường development không
  static bool get isDevelopment =>
      _currentEnvironment == Environment.development;

  /// Kiểm tra xem có phải môi trường staging không
  static bool get isStaging => _currentEnvironment == Environment.staging;

  /// Kiểm tra xem có phải môi trường production không
  static bool get isProduction => _currentEnvironment == Environment.production;

  /// Lấy redirect URI phù hợp cho OAuth
  static String getOAuthRedirectUri(bool isWeb) {
    if (isWeb) {
      return baseUrl;
    } else {
      return supabaseCallbackUrl;
    }
  }

  /// Lấy timeout duration dựa trên môi trường
  static Duration get networkTimeout {
    switch (_currentEnvironment) {
      case Environment.development:
        return const Duration(seconds: 60); // Longer timeout for development
      case Environment.staging:
        return const Duration(seconds: 45);
      case Environment.production:
        return const Duration(seconds: 30);
    }
  }

  /// Lấy số lần retry dựa trên môi trường
  static int get maxRetryAttempts {
    switch (_currentEnvironment) {
      case Environment.development:
        return 5;
      case Environment.staging:
        return 3;
      case Environment.production:
        return 2;
    }
  }

  /// In thông tin môi trường hiện tại (chỉ trong development)
  static void printEnvironmentInfo() {
    if (isDevelopment) {
      debugPrint('=== ENVIRONMENT INFO ===');
      debugPrint('Environment: $_currentEnvironment');
      debugPrint('Base URL: $baseUrl');
      debugPrint('Supabase URL: $supabaseUrl');
      debugPrint('Feature Flags: $currentFeatureFlags');
      debugPrint('========================');
    }
  }
}

