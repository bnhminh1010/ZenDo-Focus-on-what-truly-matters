import 'package:flutter/foundation.dart';

/// Cấu hình production cho ZenDo App
/// Chứa các API keys và cấu hình cần thiết cho release build
class ProductionConfig {
  // API Keys cho production
  /// Gemini API key cho production.
  static const String geminiApiKey = 'AIzaSyA3PsqssdVC6x_M-fQDuIfW9z2NSHtmT3A';
  /// Google OAuth client ID.
  static const String googleClientId = '538172119543-ej32i50o92v6g97ds5t7c7pm267offs5.apps.googleusercontent.com';
  /// GitHub OAuth client ID.
  static const String githubClientId = 'Ov23liP2hm6a08RXqcI2';
  /// GitHub OAuth client secret.
  static const String githubClientSecret = '39cbf3ccde1a655cd2202b618b371bbed7675a46';

  // Supabase Production Configuration
  /// Supabase project URL cho production.
  static const String supabaseUrl = 'https://ewfjqvatkzeyccilxzne.supabase.co';
  /// Supabase anon key cho production.
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3ZmpxdmF0a3pleWNjaWx4em5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk4NjMxMDEsImV4cCI6MjA3NTQzOTEwMX0.JhSrgxhaT-nfzx6aQuv9MO7qwD5NXhtGJZFtcHBKdeY';

  // OAuth Redirect URIs cho production
  /// Base URL cho production.
  static const String productionBaseUrl = 'https://ewfjqvatkzeyccilxzne.supabase.co';
  /// OAuth redirect URI cho production.
  static const String productionOAuthRedirectUri = 'https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback';

  // Feature flags cho production
  /// Feature flags cho production environment.
  static const Map<String, bool> productionFeatureFlags = {
    'enableLogging': false,
    'enableDebugMode': false,
    'enableAnalytics': true,
    'enableCrashReporting': true,
    'enablePerformanceMonitoring': false,
    'enableGoogleAuth': true,
    'enableGitHubAuth': true,
    'enableGeminiAI': true,
    'enableOfflineMode': true,
  };

  // Network configuration cho production
  static const Duration productionNetworkTimeout = Duration(seconds: 30);
  static const int productionMaxRetryAttempts = 3;

  /// Lấy API key dựa trên môi trường
  static String getApiKey(String keyName) {
    if (kDebugMode) {
      // Trong development, trả về empty string để sử dụng .env
      return '';
    }
    
    switch (keyName) {
      case 'GEMINI_API_KEY':
        return geminiApiKey;
      case 'GOOGLE_CLIENT_ID':
        return googleClientId;
      case 'GITHUB_CLIENT_ID':
        return githubClientId;
      case 'GITHUB_CLIENT_SECRET':
        return githubClientSecret;
      default:
        return '';
    }
  }

  /// Kiểm tra xem có phải production build không
  static bool get isProductionBuild => !kDebugMode;

  /// In thông tin cấu hình production (chỉ khi debug)
  static void printProductionInfo() {
    if (kDebugMode) {
      debugPrint('=== PRODUCTION CONFIG INFO ===');
      debugPrint('Is Production Build: $isProductionBuild');
      debugPrint('Gemini API Key: ${geminiApiKey.isNotEmpty ? "Configured" : "Not configured"}');
      debugPrint('Google Client ID: ${googleClientId.isNotEmpty ? "Configured" : "Not configured"}');
      debugPrint('Feature Flags: $productionFeatureFlags');
      debugPrint('==============================');
    }
  }
}
