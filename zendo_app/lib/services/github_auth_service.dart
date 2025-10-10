import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service để xử lý GitHub authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
class GitHubAuthService {
  static final GitHubAuthService _instance = GitHubAuthService._internal();
  factory GitHubAuthService() => _instance;
  GitHubAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Redirect URI - lấy từ environment variables
  static String get _redirectUri => dotenv.env['GITHUB_REDIRECT_URI'] ?? 'https://ewfjqvatkzeyccilxzne.supabase.co/auth/v1/callback';
  
  Map<String, dynamic>? _userInfo;

  /// Đăng nhập bằng GitHub thông qua Supabase OAuth
  /// Returns: User info nếu thành công, null nếu thất bại
  Future<Map<String, dynamic>?> signInWithGitHub() async {
    try {
      // Sử dụng Supabase OAuth với cấu hình đúng format
      final bool success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        // Không cần redirect URI cụ thể, để Supabase tự xử lý
      );

      if (success) {
        // Đợi một chút để Supabase cập nhật user
        await Future.delayed(const Duration(milliseconds: 500));
        
        final user = _supabase.auth.currentUser;
        if (user != null) {
          // Lấy thông tin user từ Supabase metadata
          _userInfo = {
            'id': user.id,
            'login': user.userMetadata?['user_name'] ?? user.userMetadata?['preferred_username'],
            'name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'],
            'email': user.email,
            'avatar_url': user.userMetadata?['avatar_url'],
          };
          return _userInfo;
        }
      }
      
      return null;
    } catch (e) {
      print('GitHub Sign-In Error: $e');
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
      print('GitHub sign-out error: $e');
    }
  }

  /// Kiểm tra trạng thái đăng nhập
  bool get isSignedIn => _supabase.auth.currentUser != null && _userInfo != null;

  /// Lấy thông tin user hiện tại từ GitHub
  Map<String, dynamic>? get currentGitHubUser => _userInfo;

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Ngắt kết nối GitHub account
  Future<void> disconnect() async {
    await signOut();
  }
}