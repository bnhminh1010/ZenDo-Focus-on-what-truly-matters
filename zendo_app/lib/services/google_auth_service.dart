import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service để xử lý Google Sign-In authentication
/// Tích hợp với Supabase Auth để đồng bộ user data
/// Hỗ trợ PKCE flow cho desktop platforms
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? null : _getGoogleClientId(),
    scopes: ['email', 'profile'],
  );

  /// Lấy Google Client ID an toàn
  static String? _getGoogleClientId() {
    if (kDebugMode) {
      try {
        return dotenv.env['GOOGLE_CLIENT_ID'];
      } catch (e) {
        return null; // Trả về null nếu không load được dotenv
      }
    }
    return null; // Trong production, trả về null để sử dụng OAuth flow
  }

  /// Đăng nhập bằng Google
  /// Returns: User nếu thành công, null nếu thất bại hoặc user hủy
  Future<User?> signInWithGoogle() async {
    try {
      // Luôn dùng Supabase OAuth cho tất cả platforms để tránh cấu hình phức tạp
      return _signInWithSupabaseOAuth();

      // Code cũ - comment lại để tránh lỗi SHA-1 fingerprint
      /*
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux) {
        return _signInWithSupabaseOAuth();
      }

      final user = await _googleSignIn.signIn();
      if (user == null) return null;

      final auth = await user.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;
      if (idToken == null || accessToken == null) {
        throw Exception('Missing Google tokens');
      }

      final res = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      return res.user;
      */
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  /// Đăng nhập Google cho Web/Desktop sử dụng Supabase OAuth với PKCE
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

  /// Đăng xuất khỏi Google và Supabase
  Future<void> signOut() async {
    try {
      final isDesktop =
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      if (!(kIsWeb || isDesktop)) {
        await _googleSignIn.signOut();
      }
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }

  /// Kiểm tra xem user có đang đăng nhập Google không
  Future<bool> isSignedIn() async {
    try {
      final isDesktop =
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      if (kIsWeb || isDesktop) {
        return _supabase.auth.currentUser != null;
      }

      final supaUser = _supabase.auth.currentUser;
      final isG = await _googleSignIn.isSignedIn();
      return isG && supaUser != null;
    } catch (e) {
      debugPrint('Check Sign-In Status Error: $e');
      return false;
    }
  }

  /// Lấy thông tin user hiện tại từ Google
  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;

  /// Lấy thông tin user hiện tại từ Supabase
  User? get currentSupabaseUser => _supabase.auth.currentUser;

  /// Ngắt kết nối hoàn toàn khỏi Google account
  Future<void> disconnect() async {
    try {
      final isDesktop =
          defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux;

      if (!(kIsWeb || isDesktop)) {
        await _googleSignIn.disconnect();
      }
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Disconnect Error: $e');
    }
  }
}

