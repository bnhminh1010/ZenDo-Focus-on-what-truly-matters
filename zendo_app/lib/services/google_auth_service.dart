/*
 * Tên: services/google_auth_service.dart
 * Tác dụng: Service xử lý Google Sign-In authentication với PKCE flow và Supabase integration
 * Khi nào dùng: Cần đăng nhập bằng Google và đồng bộ user data với backend
 */

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service để xử lý Google Sign-In authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
/// Hỗ trợ PKCE flow cho tất cả platforms
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  /// Supabase client dùng cho các thao tác OAuth Google.
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Đăng nhập bằng Google sử dụng Supabase OAuth
  /// Returns: User nếu thành công, null nếu thất bại hoặc user hủy
  Future<User?> signInWithGoogle() async {
    try {
      // Sử dụng Supabase OAuth cho tất cả platforms
      return await _signInWithSupabaseOAuth();
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Đăng nhập Google cho tất cả platforms sử dụng Supabase OAuth với PKCE
  Future<User?> _signInWithSupabaseOAuth() async {
    try {
      // Cấu hình redirect URL cho từng platform
      String? redirect;
      if (kIsWeb) {
        redirect = Uri.base.origin; // Web: sử dụng origin hiện tại
      } else if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        // Mobile: sử dụng deep link scheme
        redirect = 'io.supabase.flutter://login-callback';
      } else {
        // Desktop: để null -> SDK tự động mở localhost:<random-port>
        redirect = null;
      }

      final started = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!started) return null;

      // Đợi auth state change
      final completer = Completer<User?>();
      late final StreamSubscription sub;

      sub = _supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (data.event == AuthChangeEvent.signedIn && session?.user != null) {
          sub.cancel();
          completer.complete(session!.user);
        } else if (data.event == AuthChangeEvent.signedOut) {
          sub.cancel();
          completer.complete(null);
        }
      });

      // Timeout sau 60 giây
      Future.delayed(const Duration(seconds: 60), () {
        if (!completer.isCompleted) {
          sub.cancel();
          completer.complete(null);
        }
      });

      return completer.future;
    } catch (e) {
      debugPrint('Supabase Google OAuth Error: $e');
      return null;
    }
  }

  /// Đăng xuất khỏi Supabase
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }

  /// Kiểm tra xem user có đang đăng nhập không
  Future<bool> isSignedIn() async {
    try {
      return _supabase.auth.currentUser != null;
    } catch (e) {
      debugPrint('Check Sign-In Status Error: $e');
      return false;
    }
  }

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentUser => _supabase.auth.currentUser;

  /// Lấy session hiện tại
  Session? get currentSession => _supabase.auth.currentSession;

  /// Ngắt kết nối hoàn toàn khỏi account
  Future<void> disconnect() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Disconnect Error: $e');
    }
  }

  /// Stream để lắng nghe thay đổi auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
