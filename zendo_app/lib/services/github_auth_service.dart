/*
 * Tên: services/github_auth_service.dart
 * Tác dụng: Service xử lý GitHub authentication tích hợp với Supabase Auth
 * Khi nào dùng: Cần đăng nhập bằng GitHub và đồng bộ user data với backend
 */

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

/// Service để xử lý GitHub authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
class GitHubAuthService {
  static final GitHubAuthService _instance = GitHubAuthService._internal();
  factory GitHubAuthService() => _instance;
  GitHubAuthService._internal();

  /// Supabase client dùng để thực hiện OAuth GitHub.
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cache thông tin user GitHub sau khi đăng nhập.
  Map<String, dynamic>? _userInfo;

  /// Đăng nhập GitHub sử dụng Supabase OAuth
  Future<User?> signInWithGitHub() async {
    try {
      // Sử dụng cấu hình từ AppConfig
      final redirectUrl = AppConfig.getRedirectUri(kIsWeb);

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectUrl,
      );

      // Chờ user hoàn thành OAuth flow
      await Future.delayed(const Duration(seconds: 2));

      // Lấy user sau khi OAuth hoàn thành
      final user = _supabase.auth.currentUser;
      return user;
    } catch (e) {
      debugPrint('GitHub OAuth Error: $e');
      return null;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    try {
      _userInfo = null;

      // Đăng xuất khỏi Supabase
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('GitHub sign-out error: $e');
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  bool get isSignedIn =>
      _supabase.auth.currentUser != null && _userInfo != null;

  /// Lấy thông tin user hiện tại từ GitHub
  Map<String, dynamic>? get currentGitHubUser => _userInfo;

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Ngắt kết nối GitHub account
  Future<void> disconnect() async {
    await signOut();
  }
}
